# Dev-time USB-host programming of MCU peers (SoM-as-programmer)

**Status: PLANNING (2026-09-21).** Captures a bench/CI architecture decision that shapes the image
build and the HIL harness. See the bench wiring in the pinmux model
(`bob-929/Hardware/bench/bench-v1-wiring.md`) and the CI model in
[`CONTINUOUS_INTEGRATION.md`](./CONTINUOUS_INTEGRATION.md).

## Idea

On the bench/CI, the **UCM SoM hosts and flashes the attached MCU dev boards** (Raspberry Pi Pico /
RP2040, BBC micro:bit, nRF52840 board, MSP430 LaunchPad) over its **own USB HOST port**, instead of
routing every board's USB up to the Raspberry Pi supervisor.

- **Offloads the RPi:** a naïve design hangs ~6 USB boards + the SoM's own gadget/debug per bench on the
  RPi → ~30 USB endpoints across a 5-bench lab. Moving the MCU boards onto the SoM host leaves the RPi
  managing just the SoM's **one USB-C link** per bench (~5–10 total).
- **Dogfoods the SoM:** the product processor manages its own peripherals; the dev loop (flash +
  console + exercise) runs on-target.
- **Synergy with the signal buses:** a board is on the SoM USB host **and** on the carrier headers at
  once — **USB = flash + console**, **I²C3/ECSPI2/UART4 = the product-bus test**. Flash the Pico over
  USB, exercise it as an I²C3 slave; flash the nRF board over USB, run the NCP over ECSPI2.

## Production constraint (authoritative — do not lose)

- **Only the USB-C *gadget* port is exposed in the shipped toy.**
- The **USB HOST is NOT exposed**. If a host link exists in production at all, it is **internal
  board-to-board wiring that does not present as a user-accessible USB port** — not a USB-A jack.
- Therefore this capability ships as **inert software** (kernel + tools present, no exposed port). For
  **CRA / RED / PSTI** this means **no external USB attack surface**; any internal host link is locked
  to known, authorized devices. The dev USB-host programming is a **bench/CI capability**, not a
  product feature.

## Bench topology

- SoM **USB-A host (J3)** → **powered hub** → { Pico H, micro:bit V1.3, nRF board, MSP430 LaunchPad }.
- SoM **USB-C gadget (J5, `usb0`)** → RPi / dev host — CDC-ECM net + CDC-ACM console + SDP recovery.
  **This is the only link the RPi manages per bench.**
- CP2104 UART debug (micro-USB) → break-glass console only.

## Host stack the image must carry (BSP work — `meta-bsp-929` / this repo)

- **Kernel:** USB host on the second controller (dr_mode host), **CDC-ACM**, **usb-storage**, **HID**
  (CMSIS-DAP), usbfs for pyOCD.
- **Userspace flashers (aarch64):**
  - **Pico (RP2040):** mount + `cp *.uf2` to the RPI-RP2 MSC, or `picotool`.
  - **micro:bit (DAPLink):** copy `.hex` to the MICROBIT MSC, or `pyocd`/`openocd` via CMSIS-DAP.
  - **nRF:** `nrfutil` USB-DFU (dongle) / `pyocd` (DK) / CDC.
  - **MSP430:** `mspdebug` over eZ-FET (open `ezfet`/`rf2500` driver, no closed libmsp430).
- **A thin `flash-peer <slot> <image>` abstraction** (script/systemd + udev by-id) so the HIL harness
  and `thepia hwd` can drive it non-interactively.

## Automated-reflash notes

- **Pico BOOTSEL is the one wrinkle:** hands-off re-flash needs `picotool reboot -u` (only if the
  running firmware exposes the reset iface) or a **GPIO on RUN/BOOTSEL**. The other three flash with no
  button press.
- **Stable device paths:** udev rules / `/dev/serial/by-id` so each board maps to a fixed bench slot
  across replug (serials are known: micro:bit DAPLink, nRF, CP210x `0236DC3C`, TI eZ-FET).

## Ties / next steps

- **HIL:** extend `hil/` (labgrid) so a test can have the SoM flash its peers, RPi supervising only the
  SoM — evolves the `raspbian` hardware-test model in `CONTINUOUS_INTEGRATION.md`.
- **`thepia hwd`:** a "flash peer" verb could route through the SoM (`exec`) rather than the host.
- **Open:** confirm J3-host + J5-gadget co-exist (dr_mode per controller); powered-hub selection + power
  budget; and — for production — the internal host link's form factor, device authorization, and
  whether M7 or A53 owns it.
