# Adjusting i.MX8 Yocto configuration

The aim in to deliver a Pull Request to our existing Yocto build setup that build firmware for [Compulab UCM i.MX8M Plus](https://mediawiki.compulab.com/w/index.php?title=UCM-iMX8M-Plus_NXP_iMX8M-Plus_Yocto_Linux).
The source for the build are GitHub repositories.
You must fork and modify the existing build to configure the new functionality.

- Test and Document USB Gadget setup with kernel module for combined: Serial, ECM Ethernet, MSG over USB OTG connector
- Test and Document Configuration for Console over USB OTG connector
- Configure Kernel modules to keep support, but get kernel below 10MBytes
- Adjust [default U-Boot environment variables](./boot/env.txt)
- Bundle base OS (bin,lib,etc) with SquashFS on boot drive
- Configure U-Boot fallback images for Kernel + FDT


## U-Boot Process

Adjust the U-Boot environment to have a slightly different boot logic. If it fails find anything to load it should expose
USB Mass Storage Gadget for the boot partition over USB OTG connector.

The boot order should be:

- USB
- SD Card (SD2)
- `kernel-x8.img` on eMMC
- `fallback-x8.img` on eMMC
- U-Boot Mass Storage Gadget for eMMC boot partition


Add in U-Boot build config:

- [SquashFS sqfsls/sqfsload](https://fossbytes.com/open-source-u-boot-bootloader-now-supports-squashfs-filesystem/)
- [EROFS](https://elixir.bootlin.com/u-boot/latest/source/fs/erofs) if available
- Console over USB1 OTG port

Make sure to document the steps needed in hush to:

- boot from USB
- boot from SD Card
- boot from NFS
- load USB Mass Storage Gadget

Compulab already has some documentation for [network booting](https://github.com/compulab-yokneam/Documentation/blob/master/etc/internal/boot), but is isn't detailed enough. 
Your delivery should also include instructions for setting up the TFTP/NFS server up on a Debian developent box such as Raspberry Pi. I would like to be able to follow your instructions to connect a development board and a Raspberry Pi and
boot a Yocto image on the development board.


### U-Boot Additionally

If possible describe how the environment partition on the eMMC can be exanded to 8K.
If possible describe how the boot partition on the eMMC can be expanded to 2GB.

In order to verify the work the existing mmcblk2p1 needs to be expanded from 83.2M to 2G.


## Device Tree Adjustment

The sound pins have been reassigned from the default development config.
The pins are allocated as SAI5 TX and RX.
What reviewing the Device Tree Source it seemed to me that UART4 isn't mapped to a
device driver. Is that due to it being used by the Cortex M7 as console?


### GPIO Pin Allocations

:[P1 Function Allocation](./P1-FUNCTION-ALLOCATION.md)

:[P2 Function Allocation](./P2-FUNCTION-ALLOCATION.md)


## Linux Installation

The existing Yocto build should be adjusted.

Break out features as kernel modules to get Kernel below 10Mbyte.

Expose the `boot` partition as a [Mass Storage Gadget](https://www.kernel.org/doc/html/latest/usb/mass-storage.html) over USB OTG.

- Add libcamera API in addition to V4L2.
- Add kernel support for F2FS and SquashFS.
- [EROFS - Enhanced Read-Only File System](https://www.kernel.org/doc/html/latest/filesystems/erofs.html) if available
- Console over USB1 OTG port
- Core linux commands are bundled in a mounted SquashFS image
- Bundle Kernel, Device Tree and Core Linux Commands SquashFS for single file to load

Refs

- [Yocto UUU & SDP](https://github.com/compulab-yokneam/Documentation/blob/d8d83c090593d9f48e31348af7740e6a9dfc71f4/etc/internal/yocto.md)
- [How to update U-Boot on the board](https://mediawiki.compulab.com/w/index.php?title=IOT-GATE-iMX8_and_SBC-IOT-iMX8:_U-Boot:_Update)
- [How to recover from corrupted eMMC U-Boot](https://mediawiki.compulab.com/w/index.php?title=IOT-GATE-iMX8_and_SBC-IOT-iMX8:_U-Boot:_Recovery)


## Partition Structure

:[Boot Partition](../../docs/BOOT-PARTITION.md)
