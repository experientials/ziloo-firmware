# Booting

The default boot will continue the current activities running the default Device Tree, Subconciousness and Linux Kernel.

Alternative
- 
- 
- 
- 

```u-boot
run loadimage
run bootcmd_mfg
```


```u-boot
run loadbootscript
```

```u-boot
run usb_ul
run ulbootscript
```

## TFTP Booting

- [Compulab Doc Netboot](https://github.com/compulab-yokneam/Documentation/blob/master/etc/internal/netboot.md)
- [i.MX8 - iMX8MEVK - Yocto - Alternative image loading](https://developer.ridgerun.com/wiki/index.php?title=IMX8/iMX8MEVK/Yocto/Alternative_image_loading)
- 

## IMX USB Loader / Serial Downloader

- [Booting Linux through USB on the i.MX6](https://community.nxp.com/t5/i-MX-Processors-Knowledge-Base/Booting-Linux-through-USB-on-the-i-MX6-sabre-sd-platform-in-a/ta-p/1104434)
- [Installing Linux Using USB Serial Downloader](https://www.emcraft.com/som/imx8m-mini-som/installing-linux-using-usbserial-downloader)
- [imx8 UUU example](https://community.nxp.com/t5/i-MX-Processors/imx8-UUU/m-p/1198952)
- [UUU doesn't work with iMX8 but does with iMX7](https://community.nxp.com/t5/i-MX-Processors/UUU-doesn-t-work-with-iMX8-but-does-with-iMX7/m-p/1532667)


## U-Boot maintenance

- [U-Boot tools build](https://u-boot.readthedocs.io/en/latest/build/tools.html)
- [U-Boot Network console](https://u-boot.readthedocs.io/en/latest/usage/netconsole.html)
- [U-Boot/Tools](https://linux-sunxi.org/U-Boot/Tools)
- [mkenvimage](https://bootlin.com/blog/mkenvimage-uboot-binary-env-generator/)
- [mkimage more info](https://linux-sunxi.org/U-Boot#Install_U-Boot)


`boot.scr` for mx6cubox

```u-boot
setenv finduuid "part uuid mmc 0:1 uuid"
run finduuid
run findfdt
setenv bootargs "console=ttymxc0,115200 root=PARTUUID=${uuid} rootwait rootfstype=ext4"
load mmc 0:1 ${fdt_addr} boot/${fdtfile}
load mmc 0:1 ${loadaddr} boot/zImage
bootz ${loadaddr} - ${fdt_addr}
```

## U-Boot Environment Variables

[U-Boot Environment Variables](https://www.vermasachin.com/posts/3-u-boot-environment-variables/)


### Notes

```sh
u-boot=> mmc dev 0
MMC Device 0 not found
no mmc device at slot 0
u-boot=> mmcinfo
Device: FSL_SDHC
Manufacturer ID: 45
OEM: 100
Name: DG403 
Bus Speed: 200000000
Mode: HS400ES (200MHz)
Rd Block Len: 512
MMC version 5.1
High Capacity: Yes
Capacity: 29.1 GiB
Bus Width: 8-bit DDR
Erase Group Size: 512 KiB
HC WP Group Size: 8 MiB
User Capacity: 29.1 GiB WRREL
Boot Capacity: 4 MiB ENH
RPMB Capacity: 4 MiB ENH
```

```sh
u-boot=> mmc dev 1
MMC: no card present
```
