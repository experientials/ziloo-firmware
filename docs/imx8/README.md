# i.MX8 Plus

The i.MX8 will have two systems running in parallel; Both booted by u-boot. A Yocto Linux OS is run on the A53 cores and a Zephyr Awareness Firmware
is run on the [M7 core](M7.md). u-boot and [M7](M7.md) firmware is loaded from the eMMC, while Yocto can boot from USB, SD Card or eMMC; Tried in that order.

This is concerned with getting up and running on two carrier boards and later on our own.

- [SB-UCM-iMX8PLUS](https://www.compulab.com/products/carrier-boards/sb-ucmimx8plus-carrier-board/#diagram).
- [I-Pi_SMARC-IMX8M-PLUS](https://www.ipi.wiki/pages/imx8mp-docs)
- [SMARC Modules](https://sget.org/standards/)
- [NXP Embedded Linux Releases](https://www.nxp.com/design/software/embedded-software/i-mx-software/embedded-linux-for-i-mx-applications-processors:IMXLINUX?)
- [NXP i.MX Repo Manifest](https://github.com/nxp-imx/imx-manifest/blob/imx-linux-kirkstone/)
- [Building i.MX BSP in Docker](https://github.com/nxp-imx/imx-docker)
- [Build NXP Desktop Linux for the i.MX 8MPlus using Yocto](https://www.hackster.io/flint-weller/build-nxp-desktop-linux-for-the-i-mx-8mplus-using-yocto-438922)
- [Docker Builds are slow on M1](https://blog.driftingruby.com/docker-builds/)
- [This setup helps to build i.MX BSP in an isolated environment with docker](https://github.com/nxp-imx/imx-docker)

Make sure to consider [Needed Hardware support](./HARDWARE-SUPPORT.md)
Source code and build scripts are found under [device/imx8](./device/imx8/README.md)

![SB-UCM-iMX8PLUS](./SB-UCMIMX8PLUS-carrier-board.jpg)


![I-Pi_SMARC-IMX8M-PLUS](./I-Pi_SMARC-IMX8M-PLUS-Float_cbe8788c-a020-40f6-91d7-7b350d4ba85c.png)


### MCUXpresso SDK

The SDK is maintained on the [GitHub Project](https://github.com/NXPmicro/mcux-sdk)

- [Getting Start with MCUXpresso SDK](https://github.com/NXPmicro/mcux-sdk/blob/main/docs/Getting_Started.md)
- [Run a project using ARMGCC](https://github.com/NXPmicro/mcux-sdk/blob/main/docs/run_a_project_using_armgcc.md)
- [MCUXpresso SDK: mcux-sdk on GitHub](https://github.com/NXPmicro/mcux-sdk)


NXP also provides SDK downloads for compiling firmware

- [i.MX8MP SDK 2.12.1 for macOS](https://mcuxpresso.nxp.com/download/9fe9de1c081fae9eda84707b33b4f4a2)
- [i.MX8MP SDK 2.12.1 for Linux](https://mcuxpresso.nxp.com/download/42280ac93421512766e1e0c294df9868)
- [MCUXpresso SDK API Reference Manual  Rev 2.12.1](https://mcuxpresso.nxp.com/api_doc/dev/3330/)

Compiler on macOS

    export CMAKE_ASM_COMPILER=`which arm-none-eabi-as`
    export CMAKE_C_COMPILER=`which arm-none-eabi-gcc`
    export CMAKE_CPP_COMPILER=`which arm-none-eabi-g++`
    export ARMGCC_DIR=/usr/local
    

Compiler in Docker

    wget -qO- https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2 | tar -xj
    export PATH=/workspace/gcc-arm-none-eabi-9-2019-q4-major/bin:$PATH
    export ARMGCC_DIR=/workspace/gcc-arm-none-eabi-9-2019-q4-major

Compiling

```
export ZIL_BASE_DIR=`pwd` 
cd mcuxsdk/examples/evkmimx8mp/multicore_examples/rpmsg_lite_pingpong_rtos/linux_remote/armgcc/
sh ./build_all.sh
cd $ZIL_BASE_DIR
cd mcuxsdk/examples/evkmimx8mp/multicore_examples# cd rpmsg_lite_str_echo_rtos/armgcc/
sh ./build_all.sh
cd $ZIL_BASE_DIR
```


### u-boot

- [U-Boot for the NXP i.MX8MP EVK board](https://u-boot.readthedocs.io/en/latest/board/nxp/imx8mp_evk.html)
- [u-boot for imx8mp_evk](https://github.com/u-boot/u-boot/blob/master/doc/board/nxp/imx8mp_evk.rst)
- [Trusted Firmware-A for i.MX](https://source.codeaurora.org/external/imx/imx-atf/tree/readme.rst?h=github.com/master)
- [Generating u-boot env file (for MfgTool) from Yocto](https://community.nxp.com/t5/i-MX-Processors/Generating-u-boot-env-file-for-MfgTool-from-Yocto/m-p/676218)
- [How Does Yocto Fill In UBOOT_MACHINE?](https://yocto.yoctoproject.narkive.com/N0sNR90n/how-does-fill-in-uboot-machine)
- [iMX8 Yocto U-Boot Configurations - Select Boot Device](https://community.nxp.com/t5/i-MX-Processors/iMX8-Yocto-U-Boot-Configurations-Select-Boot-Device/m-p/961873)

[eMMC/SD mmc command](https://u-boot.readthedocs.io/en/latest/usage/cmd/mmc.html)

```sh
u-boot=> mmc part

Partition Map for MMC device 2  --   Partition Type: DOS

Part    Start Sector    Num Sectors     UUID            Type
  1     16384           170392          13cf7554-01     0c Boot
  2     196608          60874752        13cf7554-02     83
```

[File System Support](https://github.com/nxp-imx/uboot-imx/tree/lf_v2022.04/fs) on IMX

- [FAT](https://www.kernel.org/doc/html/latest/filesystems/vfat.html) / ext4
- SquashFS
- [UBI FS](https://www.kernel.org/doc/html/latest/filesystems/ubifs.html)

UBIFS has a journal.


## i.MX8 build

Be aware that `bitbake` doesn't want to run as root. Docker can execute under a user by specifying `--user build`.

```bash
repo init -u https://github.com/experientials/ziloo-firmware -b imx-linux-honister -m imx-5.15.5-1.0.0_desktop.xml
repo sync
EULA=1 DISTRO=imx-desktop-xwayland MACHINE=imx8mpevk source imx-setup-desktop.sh -b bld-imx8mpevk-desktop
```

- [OE-core's config sanity checker detected a potential misconfiguration](https://tutorialadda.com/blog/oe-core-s-config-sanity-checker-error-in-yocto-project)


## I-Pi_SMARC-IMX8M-PLUS Build

The board build runs within `imx-yocto-bsp` based on https://github.com/ADLINK/adlink-manifest. See [build instructions](https://www.ipi.wiki/pages/imx8mp-docs?page=HowToBuildYocto.html).

Run the following command on your host system to provoke the yocto image building process.

> $ bitbake imx-image-full

After the build is complete, disk images will be located at work-dir/build-dir/tmp/deploy/image/lec-imx8mp/

The build should generate the following firmware `imx-image-full-lec-imx8mp.wic.bz2`.
This has the file system image (without bootloader). 
The twin file ending in `.tar.bz2` holds the file system tree.

Boot pins,

- SD Card 0110
- eMMC 1000
- Recovery 0001


## Flashing Firmware I-Pi SMART

The I-Pi card supports all the boot modes of the i.MX8M Plus.
This allows network booting and uploading via USB CDC Serial.

The easy approach is to burn the image to an SD Card. Use,

- balena Etcher
- `dd`
- rufus

Otherwise put board in recovery mode to flash eMMC with `mfgtool`/`uuu`.

- [Flash Yocto or Android Image to eMMC](https://docs.ipi.wiki/SMARC/ipi-smarc-imx8mp/HowToFlashImageeMMC.html#Flash-Yocto-or-Android-Image)
- 


Install mfgtool

```
git clone https://github.com/NXPmicro/mfgtools.git
cd mfgtools
sudo apt-get install libusb-1.0-0-dev libbz2-dev zlib1g-dev libzstd-dev pkg-config cmake libssl-dev g++
cmake . && make
```


## Flashing Firmware SB UCM iMX8PLUS

* Prepare a bootable SD card (Use balenaEtcher to write *.wic image)
* Insert the card in the SD slot
* Connect monitor mouse and keyboard
* Enable ALT_BOOT while triggering RESET
* Open `cl-deploy` via terminal or task bar
* Select `dev/mmcblk*` as destination and continue

This will erase and overwrite the internal eMMC. 
Expect it to take 30 minutes.
Make sure to remove the SD card before rebooting.


## UART2 Debug Output / Low Level Access

The Debug USB port connects to UART2 via CP2104. It shares the port with the RS232 connector.

When the A53 Linux cores aren't running an MSP430 can be connected to UART2 during SYS_PRG mode.
When breaking u-boot to enter the console, it will expose the terminal on UART2.
When booting to Linux a terminal will be exposed on UART2.

The UART2 console on the UCM iMX8PLUS is logged with hardware flow control 115k 8n1

In VSCode the Extension named 'nRF Serial' can be used to connect to the console.


## Notes to integrate

The I-Pi board has 4 dip switches on the board hidden near the Ethernet connectors. Use 1000 for eMMC / 0110 for SD booting.

- [Using an SSD via mPCIe on our i.MX8 Nitrogen boards](https://boundarydevices.com/using-an-ssd-via-mpcie-on-our-i-mx8-nitrogen-boards/)


## V4L2 vs libcamera

The cameras must be have working drivers and commandline tools. For now the focus will be [V4L2](https://www.linuxtv.org) as it matures we will adopt [libcamera](https://libcamera.org). Ziloo is simple as it has a single Camera Device.
