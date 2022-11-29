# SD Card Tinkering




### eMMC storage

```sh
root@ucm-imx8m-plus:~> df -h

Filesystem      Size  Used Avail Use% Mounted on
/dev/root        29G  4.4G   23G  16% /
devtmpfs        1.5G  4.0K  1.5G   1% /dev
tmpfs           1.8G     0  1.8G   0% /dev/shm
tmpfs           720M  9.1M  711M   2% /run
tmpfs           4.0M     0  4.0M   0% /sys/fs/cgroup
tmpfs           1.8G  4.0K  1.8G   1% /tmp
tmpfs           1.8G  196K  1.8G   1% /var/volatile
/dev/mmcblk2p1   84M   32M   52M  38% /run/media/mmcblk2p1
tmpfs           360M  4.0K  360M   1% /run/user/0

root@ucm-imx8m-plus:~> lsblk
NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
mmcblk2      179:0    0 29.1G  0 disk 
|-mmcblk2p1  179:1    0 83.2M  0 part /run/media/mmcblk2p1
`-mmcblk2p2  179:2    0   29G  0 part /
mmcblk2boot0 179:32   0    4M  1 disk 
mmcblk2boot1 179:64   0    4M  1 disk 
```

Note that the boot partition is mounted on /run/media/mmcblk2p1/



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


## On Mac OS

Create a new SD Card with install files

```
diskutil partitionDisk /dev/disk2 MBR "FAT32" ALPINE 512MB "Free Space" SYS R
sudo fdisk -e /dev/disk2
> f 1
> w
> exit
tar -xzvf alpine-rpi-3.14.0-aarch64.tar.gz -C /Volumes/ALPINE --no-same-owner
cp ./setup/setup-alpine.in /Volumes/ALPINE
cp ./setup/setup.sh /Volumes/ALPINE
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