# i.MX8 Plus firmware

The github actions will build the full firmware based on pushes to `main`.
The branch `hw/imx8` is meant for speculative changes and more temporary builds.

* The `.github/workflows/imx8-firmware.yml` action
* Attempt to build the iMX firmware. If successful artifacts will be uploaded.
* If successful(with artifacts an) the commit has tag starting with `r` create a release with the artifacts and the release_name using the tag

![Compute Engine Structure](../../docs/imx8/arm-nn-sw-stack.png)

Compute Engine Structure on i.MX 8M

- **For the CPU:** there is the NEON backend, which uses Arm Compute Library with the Arm NEON SIMD extension. 
- **For the GPUs and NPUs:** NXP provides the VSI NPU backend, which leverages the full capabilities of i.MX 8's GPUs/ NPUs using OpenVX and provides a great performance boost. ACL OpenCL backend, which you might notice in the source codes, is not supported due to Arm NN OpenCL requirements not being fulfilled by the i.MX 8 GPUs.

 
## Artifacts

* `imx-image-full-lec-imx8mp.tar.bz2` (`imx-image-full-lec-imx8mp-*.rootfs.tar.bz2`)
* `imx-image-full-lec-imx8mp.wic.bz2` (`imx-image-full-lec-imx8mp-*.rootfs.wic.bz2`)
* `Image-lec-imx8mp.bin` (`Image--5.4-r0-lec-imx8mp-*.bin`)
* `imx-boot` (`imx-boot-lec-imx8mp-sd.bin-flash_evk`)
* `imx8mp_m7_TCM_sai_low_power_audio.bin`
* `imx8mp_m7_TCM_rpmsg_lite_pingpong_rtos_linux_remote.bin`
* `u-boot.bin` (`u-boot-sd-2020.04-r0.bin`)

On boot partition (`fatls mmc 2`)

* `tee.bin`
* `ucm-imx8-plus.dtb`
* `ucm-imx8m-plus_mipi-csi1.dtb`
* `ucm-imx8m-plus_mipi-csi2.dtb`

Candidates for boot partition

* `ucm-imx8m-plus-rpmsg.dtb`
* `ucm-imx8m-plus-hdmi.dtb`

TCM demo pages.

* meta-imx /  meta-bsp / recipes-fsl / mcore-demos / imx-m7-demos_2.11.0.bb

The sources are downloaded, but the URL is unclear.


### Device tree

Device tree binary files can be extracted using `pip install extract-dtb`.

Available Device Tree options listed in [Yocto Linux: How-To Guide](https://mediawiki.compulab.com/w/index.php?title=UCM-iMX8M-Plus:_Yocto_Linux:_How-To_Guide).
Note that the variable name should be `fdt_file`, so the command for enabling OTG is `setenv fdt_file ucm-imx8m-plus-usbdev.dtb; saveenv;`.


### U-Boot over Network

- [U-Boot example commands](https://docs.embeddedts.com/U-boot_commands)


## Open Tasks

* Make the Action publish all needed output as Artifacts ([plugin Action](https://trstringer.com/github-actions-create-release-upload-artifacts/))
* Yocto Hardknott based (use ziloo-firmware#manifests/lec-imx-yocto branch to init repo)
* Make the Action use the `ziloo/image-builder` container.
* Use `/workspace` to store build files enabling switching to docker compose later
* Add [Camera Support](./camera/README.md)
* Make sure the firmware supports stereo CSI camera modules via V4L2
* Make sure the firmware supports USB camera module (either USB port)
* Board can boot from USB stick
* Board can boot from SD Card
* [NXP eIQ enabled](https://www.ipi.wiki/pages/imx8mp-docs?page=HowToEnableeIQ.html)
* Latest tensorflow-lite (doc refers to 2.5.0)
* GPU/NPU enabled
* Working NXP demos
* Add kernel support for [F2FS](https://en.wikipedia.org/wiki/F2FS), [UBIFS](https://en.wikipedia.org/wiki/UBIFS) and squashfs
* Add driver support for OV2735
* Audio monitoring by Cortex M [Low Power Voice Control Solution](../m7/Audio-AN13201.pdf) - [SAI Low Power Audio](https://community.nxp.com/t5/i-MX-Processors-Knowledge-Base/Running-the-SAI-Low-Power-Audio-Example-using-GStreamer-Using/ta-p/1486458) - [AN implement Low Power Audio](https://www.nxp.com/docs/en/application-note/AN12195.pdf)
* Booting from USB stick. [Microchip notes](https://microchipsupport.force.com/s/article/How-to-use-USB-stick-to-update-kernel-and-rootfs-based-on-u-boot) - 
* [Add Package Manager](https://community.nxp.com/t5/i-MX-Processors-Knowledge-Base/Yocto-Project-Package-Management-smart/ta-p/1106337)


Docker compose config example [workflow](https://github.com/peter-evans/docker-compose-actions-workflow)

