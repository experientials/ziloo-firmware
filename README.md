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


