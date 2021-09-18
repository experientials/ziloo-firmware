# SD Card Tinkering

## Production Layout

Cards for the official product have a layout without support for iterative development and debugging.

TBD


## Development Layout

Cards for development can be moved between the product and a Raspberry Pi and used to boot both.

On the Raspberry Pi the card will enable direct Desktop debugging, log inspection and re-configuration.

start  | size   | Usage
-------|--------|--------
0      | 8KB    | [MBR](https://www.easeus.com/resource/fat32-disk-structure.htm) partition table
8KB    | 4MB    | SPL + U-Boot area for all supported hardware. Not a partition, just burn using dd.
?      | ?      | GPT data for mixed mode could be allocated
4MB    | 1GB    | "boot" partition. FAT32 format. Development boot for Raspberry Pi. (marked bootable)
1GB    | 6GB    | "raspbian" partition. extFS 4 format. Development OS for Raspberry Pi. Desktop Linux
6GB    | end    | extended partion
?      | ?      | "var" data partition mounted as /var
6GB    | 6.25GB | "firmware_a" readonly partition (FAT or squashfs) marked bootable
6.25GB | 6.5GB  | "firmware_b" readonly partition (FAT or squashfs) marked bootable
6.5GB  | 6.75GB | "firmware_c" readonly partition (FAT or squashfs) marked bootable
6.75GB | 7GB    | "firmware_d" readonly partition (FAT or squashfs) marked bootable
7GB    | 16GB   | "log" upgrade and data log (737 MB)


Booting over USB or Ether?

boot configuration files [extlinux.conf](https://wiki.syslinux.org/wiki/index.php?title=EXTLINUX) (or bootable flag)

## GPT Hybrid MBR

https://en.wikipedia.org/wiki/GUID_Partition_Table

Not currently using due to sync risks. Easiest to just use MBR.


## Sunxi ARM first run

> diskutil partitionDisk /dev/disk2 MBR FREE GAP 4MB "FAT32" ALPINE 1GB "FAT32" FIRMWARES 2048MB "Free Space" SYS R
sudo fdisk -e /dev/disk2
> f 1
> w
> exit

Make sure that ALPINE has boot flag set

> tar -xzvf alpine-uboot-3.14.0-armv7.tar -C /Volumes/ALPINE --no-same-owner

https://linux-sunxi.org/Bootable_SD_card

> dd if=alpine-uboot-3.14.0-arm7/u-boot/Bananapi/u-boot-sunxi-with-spl.bin of=/dev/disk2 bs=1024 seek=8

Place the SPL at 8KB and U-Boot at 40KB


start	sector	size	usage
0KB	0	8KB	Unused, available for MBR (partition table etc.)
8KB	16	32KB	Initial SPL loader
40KB	80	504KB	U-Boot
544KB	1088	128KB	environment
672KB	1344	128KB	Falcon mode boot params
800KB	1600	-	Falcon mode kernel start
1024KB	2048	-	Free for partitions



## On Mac OS

Create a new SD Card with install files

```
diskutil partitionDisk /dev/disk2 MBR "FAT32" ALPINE 512MB "Free Space" SYS R
sudo fdisk -e /dev/disk2
> f 1
> w
> exit
tar -xzvf alpine-rpi-3.14.0-aarch64.tar.gz -C /Volumes/ALPINE --no-same-owner
cp ./device/alpine-rpi/setup/setup-alpine.in /Volumes/ALPINE
cp ./device/alpine-rpi/setup/setup.sh /Volumes/ALPINE
mkdir /Volumes/ALPINE/cache
mkdir /Volumes/ALPINE/data
```


```
diskutil list
diskutil eraseDisk MS-DOS boot GPT /dev/disk2
diskutil partitionDisk /dev/disk2 GPT "FAT32" ALP 256MB "Free Space" SYS R
sudo fdisk -e /dev/disk2
> f 1
> w
> exit
```

add 4MB partition
add 1GB partition
add 5GB partition
add extended partition until end
remove 4MB partition
add 256MB var partition
add 256MB firmware_a partition
add 256MB firmware_b partition
add 256MB firmware_c partition
add 256MB firmware_d partition
add 256MB log partition


```
diskutil partitionDisk /dev/disk2 GPT "FAT32" BOOT 1GB "Free Space" SYS R
```