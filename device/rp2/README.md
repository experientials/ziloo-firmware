# RP2040 firmware

> make fetch-submodules
> make -C mpy-cross -j2
> cd ports/ziloo
> make BOARD=ziloo_auto


## Build Images

Build images are uploaded to [Docker Hub](https://hub.docker.com) under ziloo/image-builder


## Development hacks

List USB devices on macOS

> ioreg -p IOUSB

Lit USB devices on Linux

> lsusb


