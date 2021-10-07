# Ziloo Firmware

Ziloo is an independent device that sees and senses the environment. It recognises objects and behavior based on what it has been taught. It outputs an event log describing what is perceived.

The firmware is loosely Linux based. The essential parts are bundled as packages to be run in an
embedded Posix environment.

Key building blocks are:

- Log based storage
- muslc static library
- busybox shell
- Base Firmware from read-only squashfs
- [F2FS](https://www.kernel.org/doc/html/latest/filesystems/f2fs.html) storage (requires Linux Kernel 5.7)


## SD Card Format

For development and debugging use an SD Card or USB stick. It must be partitioned,

- With MBR FAT32 (diskutil eraseDisk FAT32 ALPINE MBR $(DISK))
- 1Gb FAT32 boot partition
- 3.4Gb extFS 4 rootfs partition

An empty SD Card image is generated with `make ziloo-raw-image`, which will generate `ziloo-dev-card.img.zip`.



## Alpine based

The main variant is based on [Alpine](https://alpinelinux.org/downloads/). It provides a clean based for reliable packaging. It has a [Build Infrastructure](https://gitlab.alpinelinux.org/alpine).
The Ziloo packages are built as .apk packages for this variant.

Alpine are made to run in memory so the storage can be removed while running. This means that it
has a higher memory footprint than OpenWRT, but it should be managable. Thread Stack = 80Kb.
Disk based boot, but not default. We will use [Data Disk Mode](https://wiki.alpinelinux.org/wiki/Installation#Data_Disk_Mode).

The install process for Raspberry Pi is ridicuously simple. Copy the files to a FAT formatted USB stick
or SD Card and use it!

- [Create a bootable SDHC from a Mac](https://wiki.alpinelinux.org/wiki/Create_a_bootable_SDHC_from_a_Mac)
- [Default password](https://techoverflow.net/2021/01/09/what-is-the-alpine-linux-default-login-password/)

The current build doesn't support

- Setup on SD Card (Do initial setup on USB)


## Supported platforms

- Raspberry Pi 3 running [Alpine Linux](https://alpinelinux.org/downloads/)
- Generic Arm running [Alpine Linux](https://alpinelinux.org/downloads/)


## Add plugins to VSCode

* Docker
* Python
* CMake & CMake Tools
* Docker Explorer
* Cortex-Debug
* Remote - Containers
* Jupyter
* Better TOML

## Docker

The build and testing is run primarily in Docker. The firmware can be tested with QEMU in a dedicated docker container. Building the firmware also takes place in a Docker container. To rebuild the foundation docker containers run `make docker-push`. This will build and push docker images to Docker Hub. The password for
the ziloo docker hub user will be needed.

> sudo docker build --target base -t thepia/ziloo-base:v1 .
> sudo docker images

To open a builder shell run `docker compose run --rm builder-amd` or `docker compose run --rm builder-arm`.

Boards builds:

> docker compose run --rm builder-rv1109

## Building with one call:

> COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose up builder-rv1126-facial-gate 
> COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose up builder-rv1126-ai-uvc

or 

> COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose up builder-rv1109-facial-gate
> COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose up builder-rv1109-ai-uvc

or put both targets in the command.

For other targets see [docker-compose.yml](./docker-compose.yml).


## Windows Programming Machine

Things to install

* [Adroid SDK Platform Tools](https://developer.android.com/studio/releases/platform-tools)
* [Docker Desktop on Windows](https://www.docker.com/products/docker-desktop)
* [Git for Windows](gitforwindows.org)

Open powershell in the `platform-tools` folder. Run adb commands with `adb.exe`.
