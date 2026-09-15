# UCM-iMX8M-Plus HIL harness (pytest + labgrid)

Hardware-in-the-loop tests for the UCM board, driven from a host (Mac/Pi). Two tiers:

- **On-board** (`@pytest.mark.on_board`) — run *on* the board (native aarch64), over SSH or the
  serial console; assert the software works on the target.
- **Host-controlled** (`@pytest.mark.host`) — run on the host; assert the board's external
  behaviour (reachability, the USB *device* contract, etc.).

Board access is abstracted by **labgrid** (Resource/Driver/Protocol); the pytest `target` fixture
comes from `environment.yaml`. This is the near-term HIL layer; long-term the fixtures repoint at
the `thepia-hwd` daemon (see the `ucm-dev` skill → `references/thepia-hwd.md`, and the daemon's own
design at `Thepia/cli/docs/hwd.md`).

## Run
```sh
make test        # full suite (incl. a real reboot cycle — ~60 s)
make quick       # everything except the slow reboot tests
make onboard     # on-board tests (SSH + serial), no reboot
make host        # host-controlled tests only
make serial      # out-of-band serial-console tests only
make reboot      # reboot cycle (soft reset + re-establish access)
make uboot       # opt-in U-Boot tests — power-cycle the board when they start
make archive-help  # how to build+push the on-board Rust nextest archive
```

## Transports (picked explicitly per test)
- **SSH** (`ssh` fixture) — the network fast path (`eth1` dongle or CDC `usb0`). Default for
  on-board tests; interactive shell, bulk exec, file transfer.
- **Serial** (`serial_shell` / `serial_console` fixtures) — the out-of-band console over the
  CP2104 (micro-USB). The path that must work when the network is down. **Skips cleanly** when the
  serial device isn't attached to this host, so a network-only host still runs the rest.

## Prerequisites
- Board on the shared network, reachable at `ucm-imx8m-plus.local` (mDNS; falls back to the IP in
  `environment.yaml`). The Mac shares that network (Internet Sharing / bridge).
- Your SSH public key in the board's `root` authorized_keys (key-auth, no password).
- For the serial tier: the CP2104 attached (`/dev/cu.usbserial-0236DC3C` on this Mac) and free —
  no other console holder (close `console.sh`/picocom first).
- Host with **`uv`** + `ssh` (uv builds/manages the venv; `make test` handles it).
- macOS note: the Makefile sets a short `TMPDIR` so labgrid's SSH ControlMaster socket stays under
  the 104-char unix-socket limit (the long default `/var/folders/...` path otherwise breaks it).

## Current tests (14: 11 run, 3 self-skip on this bench)
- **on-board / SSH:** aarch64, USB1 UDC in device mode, `usb-gadget.service` enabled, `usb0` MAC.
- **on-board / serial:** reaches the auto-root prompt, aarch64 over UART, exit-code contract.
- **host:** board reachable (ping); CDC-ECM device enumerates on the host (skips if USB-C off).
- **reboot:** soft reboot over SSH verified by a **new kernel boot_id** (race-free — uptime alone
  can be fooled by reconnecting during the pre-shutdown window); reboot triggered over SSH and
  **observed booting on the serial console** (cross-transport proof).
- **product (skip scaffold):** runs a cross-compiled Rust `cargo nextest` archive *on the board*
  if one is staged at `/opt/hil/` (see `make archive-help`); skips until a product crate exists.
- **U-Boot (opt-in):** boots from eMMC; `stdin` includes serial (guards the USB-C-at-boot finding).
  Needs the autoboot countdown interrupted after a reset → run `make uboot` and power-cycle.

## Roadmap
- **A4 recovery tier** (deferred until unattended CI): add a `NetworkPowerDriver` (relay / JTAG-Pi
  / smart-plug across 12 V or `SW_RES`) so the U-Boot and hung-board tests run without a human, and
  add a hung-board recovery test. See the commented block in `environment.yaml`.
- **Remote exporter:** run the labgrid **exporter** on the Pi so tests can drive a board attached
  to a fleet node, not just a locally-cabled one.
- **Migrate transport to `thepia-hwd`** (MCP + console stream) when it lands; keep the same pytest
  tests — only the fixtures change. See `Thepia/cli/docs/hwd.md`.
