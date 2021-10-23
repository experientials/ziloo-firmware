## ARM Firmware Boot

* [DIY Root of Trust using ARM Trusted Firmware on the 96Boards Hikey](https://casualhacking.io/blog/2018/7/8/diy-root-of-trust-using-arm-trusted-firmware-on-the-96boards-hikey)


## Camera Switching

Texas Instruments
* [TS5MP646NYFPR 2:1 (SPDT), 10-channel MIPI switch](https://www.ti.com/store/ti/en/p/product/?p=TS5MP646NYFPR) $1
    The TS5MP646 is a four data lane MIPI switch. This device is an optimized 10-channel (5differential) single-pole, double-throw switch for use in high speed applications. The TS5MP646 isdesigned to facilitate multiple MIPI compliant devices to connect to a single CSI/DSI, C-PHY/D-PHYmodule.
    [datasheet](https://www.ti.com/lit/ds/symlink/ts5mp646.pdf?HQS=TI-null-null-mousermode-df-pf-null-wwe&DCM=yes&ref_url=https%253A%252F%252Fwww.mouser.com%252F)


## Firware updates OTA

* [Ubuntu BuildYourOwnKernel](https://wiki.ubuntu.com/Kernel/BuildYourOwnKernel)
* [Mender The ultimate guide to software updates on embedded linux devices](https://www.slideshare.net/MenderOTA/the-ultimate-guide-to-software-updates-on-embedded-linux-devices)
* [RAUC Updating an embedded system](https://rauc.readthedocs.io/en/latest/)
* [Safe and Secure OTA Updates for Embedded Linux!](https://rauc.io)
* [U Boot IMX](https://github.com/varigit/uboot-imx)


## Alpine Linux Support

* [On Rock64](https://forum.pine64.org/showthread.php?tid=5881)


## Elixir Support

* https://elixirforum.com/t/erlang-and-elixir-on-apple-silicon-m1-chip/35699
* [Nerves Project](https://github.com/nerves-project)
* [Nerves Docs](https://www.nerves-project.org/documentation.html)

## U-Boot SquashFS

* [U-Boot SquashFS](https://lists.denx.de/pipermail/eldk/2013-January/002259.html)
* [Open Source U-Boot Bootloader Now Supports SquashFS Filesystem](https://fossbytes.com/open-source-u-boot-bootloader-now-supports-squashfs-filesystem/)


## RK3588

* https://www.cnx-software.com/2020/11/26/rockchip-rk3588-specifications-revealed-8k-video-6-tops-npu-pcie-3-0-up-to-32gb-ram/


## QEMU

* [HOWTO: Use BuildRoot to create a Linux image for QEMU](https://www.osadl.org/Use-BuildRoot-to-create-a-Linux-image-fo.buildroot-qemu.0.html)
* [QEMU ARM Linux system using Buildroot and GPIO emulation](http://phwl.org/2021/emulated-ARM-Linux-with-Buildroot-and-QEMU/)


## Use ADB Platform Tools?

Android Debug Bridge
> brew install android-platform-tools
> sudo apt install android-platform-tools-base android-platform-tools-common

https://developer.android.com/studio/releases/platform-tools.html

```
$ adb devices
* daemon not running; starting now at tcp:5037
* daemon started successfully
List of devices attached
2020	device
ba773bcbc0c11c28	device
```


over WiFi: https://github.com/alfredobs97/adb-wlan-vscode

> adb shell

Gives a busybox shell into the device!!


Use PhotoBooth to use the UVC webcam!!
