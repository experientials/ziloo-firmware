# i.MX8 Development


## Building Full Firmware

Build cache can be 200GB, so cleaning it may be required with [a script](https://stackoverflow.com/questions/45341760/how-should-the-sstate-cache-directory-be-deleted-in-yocto)

    ./scripts/sstate-cache-management.sh --remove-duplicated -d --cache-dir=<path to sstate-cached>

Use repo tool to set up the source code to be cloned with Git. This can be synced multiple times

    repo init -u https://github.com/experientials/ziloo-firmware -b imx-linux-honister -m imx-5.15.5-1.0.0_experientials.xml
    mkdir -p downloads
    mkdir -p cache
    mkdir -p sstate-cache
    mkdir -p sources

The `repo sync` will link scripts and pull git repositories to `sources`.
This can initially be done outside the docker container.

    repo sync

To make this usable the files must be accessable by the build user, and symlinks must be replicated.
If repo is called within docker, it also needs git user configs. A script is made to take these steps.

    docker exec ziloo-builder-user source ./etc/inside-docker

From hereon the `build` user must be used. `setup-bitbake` will set up a build directory used by the `build` user within docker.
If you attach to the container, make sure to call `su build`.

    docker exec -e MACHINE=ucm-imx8-plus --user build ziloo-builder-user source setup-bitbake -b build-${MACHINE}

Now you can build the image:

    docker exec --user build ziloo-builder-user bitbake -k imx-image-multimedia

Or you can bitbake specific projects

If dependencies(sources upstream) change they can be updated within the docker container(user: build)
or outside.

    docker exec --user build ziloo-builder-user repo sync

If the bitbake server fails to start properly, remove the .lock and .sock files within the build directory.

    docker exec --user build ziloo-builder-user rm bitbake.lock bitbake.sock



### Building Docker container locally

You can build a docker image locally by,

> docker buildx build --platform linux/amd64 -f Dockerfile -t ziloo/image-builder --target ziloo-builder --tag ziloo/image-builder:latest --tag ziloo/image-builder .   
> docker buildx build --platform linux/amd64 -f Dockerfile -t ziloo/image-builder-user --target ziloo-builder-user --tag ziloo/image-builder-user:latest --tag ziloo/image-builder-user .   

To push result image into registry use --push or to load image into docker use --load 


### Build variations

Machine | Environment |
--- | --- |
`ucm-imx8m-mini` | `export MACHINE=ucm-imx8m-mini LREPO=compulab-bsp-setup-imx8mm.xml`
`iot-gate-imx8`  | `export MACHINE=iot-gate-imx8 LREPO=compulab-bsp-setup-iot.xml`
`ucm-imx8m-plus` | `export MACHINE=ucm-imx8m-plus LREPO=compulab-bsp-setup-imx8mp.xml`
`iot-gate-imx8plus` | `export MACHINE=iot-gate-imx8plus	 LREPO=compulab-bsp-setup-imx8mp.xml`


Distro | Setup command  | Build command |
--- | --- | --- |
fslc-xwayland | DISTRO=fslc-xwayland source compulab-setup-environment build-fslc-${MACHINE} | ```bitbake -k fsl-image-multimedia-full```
fslc-framebuffer | DISTRO=fslc-framebuffer source compulab-setup-environment build-fslc-${MACHINE} | ```bitbake -k fsl-image-network-full-cmdline```
fsl-imx-<backend> | DISTRO=fsl-imx-<backend> source setup-bitbake -b build-${MACHINE} |


For more see [meta-imx](https://github.com/nxp-imx/meta-imx)


DISTROs are new and the way to configure for any backends.  Use DISTRO= instead of the -e on the setup script.
The -e parameter gets converted to the appropriate distro configuration.

Note: 
DirectFB is no longer supported in i.MX graphic builds.
The X11 and Framebuffer distros are only supported for i.MX 6 and i.MX 7.  i.MX 8 should use xwayland only.
XWayland is the default distro for all i.MX families.

- fls-image-machine-test
- fsl-image-mfgtool-initramfs: Seems to support uuu instead of mfgtool
- imx-image-core: Minimal image
- imx-image-multimedia: This image contains all the packages except QT6/OpenCV/Machine Learning packages.
- imx-image-full: This is the big image which includes imx-image-multimedia + OpenCV + QT6 + Machine Learning packages.


### Configuring u-boot

From the ziloo-firmware directory

> source etc/setup-bitbake -b build-ucm-imx8m-plus
> bitbake u-boot -c devshell
> cd ../build/ucm-imx8m-plus_defconfig/
> make menuconfig

See porting guide [Linux Documentation](./imx8/IMX_LINUX_USERS_GUIDE.pdf) ([How to get to menuconfig for u-boot in Yocto environment](https://stackoverflow.com/questions/43211384/how-to-get-to-menuconfig-for-u-boot-in-yocto-environment), [U-Boot customization using devshell](https://community.nxp.com/t5/i-MX-Processors/U-Boot-customization-using-devshell/m-p/1000673))

Device drivers

- USB controller number 0 (Should it be changed for Host USB instead of OTG?)
- U-Boot ethernet over USB (CONFIG_USB_HOST_ETHER) - [Post]() - [README.usb](https://github.com/lentinj/u-boot/blob/master/doc/README.usb) 
- Network device support. MII enabled, RGMII enable? 
- 1-wire controllers support?
- USB Support. Driver model Gadget? Driver model Gadget in SPL? USB Keyboard support? 
- USB Gadget Support. USB mass storage gadget? USB Ethernet Gadget with CDC-EMC?  [U-Boot USB Mass Storage gadget](https://boundarydevices.com/u-boot-usb-mass-storage-gadget/)
- File systems. ext4. FAT. SquashFS.

It seems to support [MCS7830 USB to Ethernet hardware](https://ecsoft2.org/moschip-mcs7830-usb-20-ethernet-driver) 
and [AX88179 usb 3.0 lan](https://oemdrivers.com/network-asix-ax88179-driver). There is a [AX88179 Driver for MacOS 11.5 update for macOS](https://developer.apple.com/forums/thread/685854).
This should allow a TFTP server boot via USB/Ethernet.

Guides

- [Comfortable kernel workflow on Beagleboard XM with nfsroot](https://www.veterobot.org/2012/03/comfortable-kernel-workflow-on.html)
- [Can USB-OTG be used for U-Boot and Linux consoles?](https://stackoverflow.com/questions/63104542/can-usb-otg-be-used-for-u-boot-and-linux-consoles)


## USB Stick / SD Card Format

The card or stick has two partitions the first FAT, the second Ext4.
It is burned by using `imx-image-full-ucm-imx8m-plus.rootfs.wic` using balena Etcher or similar.
The boot sector contains the linux kernel, TEE and device tree with 87MB capacity and 50MB available.


For development and debugging use an SD Card or USB stick. It must be partitioned,

- With MBR FAT32 (diskutil eraseDisk FAT32 ALPINE MBR $(DISK))
- 1Gb FAT32 boot partition
- 3.4Gb extFS 4 rootfs partition

An empty SD Card image is generated with `make ziloo-raw-image`, which will generate `ziloo-dev-card.img.zip`.

