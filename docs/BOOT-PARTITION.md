## Boot Partition

The boot partition can be found on the internal eMMC, SD Card, USB Stick or NFS server.
The format of boot is FAT and must be at least 256MB, preferably 1GB+.

The boot partition contains

- `kernel-x8.img` FIT image of Linux Kernel
- `kernel-x8.fdt` containing: Linux Kernel, Default Device Tree
- `base-x8.squashfs.img` containing essential executables and default configuration files
- `sdk-x8.squashfs.img` containing SDK executables and default configuration files
- `Assets` directory with Device Tree, Overlays and Kernel Modules
- `Packages` directory with installable packages
- 
- 

A U-Boot environment variable defines the `image` name `kernel-x8.img` that will be loaded.
Another variable determines the `fdt_file` name `ucm-imx8m-plus-usbdev.dtb` that will be loaded.

Flattened device trees should ideally be placed in `/Assets` if U-Boot can load it from there.
[EROFS](https://www.kernel.org/doc/html/latest/filesystems/erofs.html) should be reviewed as an alternative to SquashFS. Support for [EROFS](https://elixir.bootlin.com/u-boot/latest/source/fs/erofs) should be added to our U-Boot/Kernel config asap.

- [What is EROFS file system that Google will reportedly implement in Android 13?](https://pocketnow.com/erofs-android-13-explained/)
- [EROFS - Enhanced Read-Only File System](https://www.kernel.org/doc/html/latest/filesystems/erofs.html)


### Existing eMMC boot partition

```hush
root@ucm-imx8m-plus:~> lsblk
NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
mmcblk2      179:0    0 29.1G  0 disk 
|-mmcblk2p1  179:1    0 83.2M  0 part /run/media/mmcblk2p1
`-mmcblk2p2  179:2    0   29G  0 part /
mmcblk2boot0 179:32   0    4M  1 disk 
mmcblk2boot1 179:64   0    4M  1 disk 
root@ucm-imx8m-plus:~> ls /run/media/mmcblk2p1/
Image					    tee.bin		       
ucm-imx8m-plus_mipi-csi1.dtb
imx8mp_m7_TCM_hello_world.bin		    
ucm-imx8m-plus-usbdev.dtb  ucm-imx8m-plus_mipi-csi2.dtb
imx8mp_m7_TCM_rpmsg_lite_str_echo_rtos.bin  ucm-imx8m-plus.dtb
```

### Kernel Image

The kernel image is saved as a Flattened Device Tree file containing

- Linux Image
- Device Tree
- Kernel Configuration

TODO Device Tree. Sound SAI5. OTG.

### Base Image

The base image contains `/bin`, `/lib` and `/etc` with binaries and default configs for ,

- Networking if/dropbear/nfs/resolv/avahi/bluetooth/..
- Busybox
- Fonts
- Systemd
- X11/Weston

So largely the output of the bitbake target `imx-image-core`.
As that is quite large some modules will have to be excluded from the image to get it down to a good size.
Since `/sbin` is a legacy name, the files should be merged in `/bin`.

Parts not included in base image, but instead in the SDK image,

- gnu compiler collection
- gdb/gdbserver
- cmake
- Docker
- Containerd
- /usr/include

Bitbake can also build an SDK, perhaps that output should also be included in the SDK SquashFS image.


## Linux Logical Directory Structure

OverlayFS is used to combine `/media/base` and `/media/apps`. 

`/media/base` mounts `base-x8.squashfs.img` on i.MX8 systems.
`/media/apps` mounts the Ext2 partition that would traditionally be called root.
`/media/sdk` mounts the `sdk-x8.squashfs.img`.
`/boot` mounts the Boot FAT partition.
`/` is a combination of sys or apps.
`/home` is on the Ext2 partition.
`/sys` mounts the Linux sysfs.
`/proc` mounts the Linux procfs.
`/dev` has available devices. Contains `/dev/console`, `/dev/null`, and `/dev/tty`.
`/tmp` is an in-memory drive.
