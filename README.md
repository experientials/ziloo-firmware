# Ziloo Firmware

Ziloo is an independent device that sees and senses the environment. It recognises objects and behavior based on what it has been taught. It outputs an event log describing what is perceived.

The firmware is made for the various processors contained. 

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


## Structure

USB Devices
- CDC Command Console
- Ethernet 
- Mass Storage for firmware updates and scripts
- Video Stream (V4L2 based)


## Adding New Firmware + Hardware combination

To add a new hardware core to build for create a new branch under `hw/` naming it.
It is best to base it on the `hw/-template-` branch.
 

## Building

The firmware is automatically built using [GitHub Actions](https://github.com/features/actions).
For details on the active pipelines see [Continuous Integration](.github/workflows/CONTINUOUS_INTEGRATION.md)
In addition to firmware an [image-builder docker image](https://hub.docker.com/repository/docker/ziloo/image-builder) is also created by CI.
There is an example hello build to demonstrate using docker.


## Developing locally

The default setup on the native dev machine assumes

- Python 3.9
- Miniforge3

> brew install miniforge

This allows compatibility with ML toolchains.
