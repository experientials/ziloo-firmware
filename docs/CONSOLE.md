# Serial console access (UCM-iMX8M-Plus)

Reliable, repeatable access to the board's console on macOS.

## TL;DR

```sh
scripts/console.sh            # connect at 115200; quit with Ctrl-a Ctrl-x
scripts/console.sh --wait     # start first, then power the board — waits for it to appear
scripts/console.sh --reconnect  # survive USB drops
```

## Why serial is the primary channel (not SSH)

On the current image (`NXP i.MX Release Distro 5.10-gatesgarth`, U-Boot SPL 2020.04-compulab)
the on-board Ethernet fails to initialise:

```
imx-dwmac 30bf0000.ethernet eth0: stmmac_hw_setup: DMA engine initialization failed
imx-dwmac 30bf0000.ethernet eth0: stmmac_open: Hw setup failed
```

So `eth0` never comes up and SSH-over-Ethernet is **not** a dependable fallback yet. Until
that's fixed (or USB-CDC networking is brought up), the serial console is the one channel we
can rely on — hence the effort to make it solid. Fixing `eth0` is tracked separately; when it
works, `ip addr` on the console gives the address to SSH to.

## The stable device anchor

The console runs over a **Silicon Labs CP2104 USB-UART bridge** (VID `0x10c4`, PID `0xea60`,
serial **`0236DC3C`** on this bench). macOS names it after that serial number:

- `/dev/cu.usbserial-0236DC3C`  ← use this (callout node; `open()` doesn't block on carrier detect)
- `/dev/tty.usbserial-0236DC3C`  (callin node; blocks waiting for DCD — avoid)

Because the name is derived from the adapter's serial number, it is **stable across replug and
across board reboots** — unlike the location-based `/dev/*.usbmodem…` names (which is what the
MSP430 eZ-FET debugger enumerates as). Console settings: **115200 8N1, no flow control**. The
board auto-logs-in as `root` on `ttymxc1`.

## The helper: `scripts/console.sh`

Wraps `picocom` and removes the sharp edges:

- **Resolves the device by serial number** (`UCM_CONSOLE_SERIAL`, default `0236DC3C`), falling
  back to a lone CP2104 if only one USB-serial device is present.
- **`--wait`** polls for the adapter so you can launch the console *before* powering the board
  and catch the full boot log.
- **Refuses to open a port another session already holds** (checks both the `cu.` and `tty.`
  nodes — they're the same UART) and tells you which PID to kill.
- **Logs every session** to `docs/console-logs/console-<timestamp>.log` (`--no-log` to skip).
- **`--reconnect`** re-opens automatically if the USB link drops, while still honoring a clean
  `Ctrl-a Ctrl-x` quit.

Overrides: `UCM_CONSOLE_DEV=/dev/cu.usbserial-XXXX` to bypass resolution entirely; `-b <baud>`
to change speed; `--list` to see candidate devices.

### Manual fallback

If the script isn't handy:

```sh
picocom -b 115200 /dev/cu.usbserial-0236DC3C     # quit: Ctrl-a Ctrl-x
# or
screen /dev/cu.usbserial-0236DC3C 115200         # quit: Ctrl-a k
```

## Roadmap: a hardware daemon in `@thepia/cli`, consumed by a client app

This shell script is a **throwaway bench stopgap** — not the foundation. The intended end state
is a **daemon** (near-term) that owns the board hardware and exposes functionality to a separate
**client app**, built in Rust as part of `@thepia/cli`. Per that repo's `STRATEGY.md`,
`@thepia/cli` is a single cross-platform Rust binary built **on Goose** (Block's Rust
coding-assistant shell) with a **hardware/firmware workbench** role (driving UART/GPIO/I2C/SPI via
`rppal`) and a **fleet node** role serving an API over Tailscale (`thepia-fabric`). The board
daemon lives there, capability-gated.

Division of responsibility:
- **Daemon** — the only thing touching the port; owns the serial stream, USB recovery, reset
  lines. Enumerates the CP2104 by USB VID/PID (`0x10c4`/`0xea60`) + serial via a Rust serial crate
  (`serialport`/`nusb`/`tokio-serial`), so it is not tied to macOS `/dev/cu.usbserial-*` naming and
  runs identically on Linux fleet nodes. Exposes `console.attach`, `console.exec`, `board.reboot`,
  `usb.recover`, `board.status`, and a network fast-path — keeping the session, scrollback, and
  logs alive regardless of who is connected.
- **Client app** — GUI/TUI (and/or the Goose agent surface) that speaks only the daemon API; no
  serial/hardware code. Drives a local or remote (Tailscale) daemon identically; aggregates many
  boards.

The full requirements and the genuinely open decisions (hard-reset mechanism, network path,
USB-recovery approach) live in the `ucm-dev` skill: `references/console-access.md`. Sequencing is
deliberately **not** fixed — `@thepia/cli` is Goose-based and shell-first, and has no code yet.
