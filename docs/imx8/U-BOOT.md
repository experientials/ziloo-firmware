
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
