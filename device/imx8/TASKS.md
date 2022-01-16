## Firmware build for NXP i.MX 8M Plus with Stereo Vision/Audio

Our existing GitHub repository has the source and build for Rockchip RV1126, it must be expanded
with a Yocto and Android Firmware build for the i.MX8 on a dedicated branch. To support your development
and testing we will send you an i.MX development board.

Documentation should be done in Markdown files like this on a ziloo-firmware Git branch and delivered with a Pull Request.

- [Ziloo Firmware repository](https://github.com/experientials/ziloo-firmware/tree/hw/imx8)
- [Evaluation Kit Getting Started](https://developer.ridgerun.com/wiki/index.php?title=IMX8/iMX8MEVK/Getting_Started)
- [Yocto User Guide](../../docs/imx8/IMX_YOCTO_PROJECT_USERS_GUIDE.pdf)
- [Linux User Guide](../../docs/imx8/IMX_LINUX_USERS_GUIDE.pdf)

For more details see [YOCTO instructions](https://github.com/experientials/ziloo-firmware/blob/hw/imx8/device/imx8/YOCTO.md).
This document is also found in [TASKS (most recent)](https://github.com/experientials/ziloo-firmware/blob/hw/imx8/device/imx8/TASKS.md).


## Make vanilla distributions for Yocto and Android $300

When pushing to the `hw/imx8` the `.github/workflows/imx8-firmware.yml` triggers build script with the builder-imx8 docker file.

Firmware source and build should be delivered as a Pull request against `hw/imx8` branch.

* Create a build for a Yocto image in a new branch based on ziloo-firmware main branch.
* Create a build for an Android image in a new branch based on zilo-firmware main branch.
* Configure Kernel with appropriate file system
* Ensure that these images are built on the build server when pushing changes
* Ensure we have a clear documentation for what the build does and how it is triggered.
* Test and Document how to install GitHub actions runner on the iMX module.
* When receiving the dev board test that the firmware can be installed and boots correctly
* Remove or replace modules `buildroot` and `u-boot` in the Git repo if appropriate.


## Create Device Drivers for support $500

Stereo camera video/still with sound

* Camera Module support (Support OV2735, OV5647, IMX477, SAI5 DATA0, V4L2)
* System bootup configuration & test
* Add source code and instructions for testing OpenCV with stereo camera

You should be able to verify OV5647 and IMX477 with Raspberry Pi Camera Modules.

For OV2735 I can provide you with a Datasheet and a module. The module we have uses a Hirose DF40C-34DS-0.4V connector.
So you'd need a bit of solding together some connector breakout boards, or I may be able to find a 22 pin compatible module.


## Self test $300

Implement Ziloo Self test.


## Wayland desktop $300

Make sure that a wayland desktop can be booted on the device

* Running directly on development board with HDMI, Keyboard, Mouse
* Running remotely over a network connection
* Configure and Document


## Test and refine upgrade procedure $200

Upgrading eMMC via USB or SD Card


## Define and Test installation of eIQ and Vision $300

- Install eIQ Machine Vision
- Install TensorFlow Lite, ONNX, OpenCV, TVM
- Install MediaPipe


## T-USB / USB-C $400

USB Gaget ethernet, webcam, msc, adb

* Accessing desktop remotely over USB connection.
* Modifying files on file system over USB MSC Gadget
* Installing modules on system via Android Debug Bridge
* Monitor connected experimentally using DisplayLink over USB


## Test and Document $200

* Test and Document packages to install on the Wayland Desktop to test Camera Input, Audio Input and Audio Output.
* Test installation of OpenCV, TensorFlow Lite, eIQ GStreamer demo
* Test and Document remote desktop options that can show OpenCV output
* Find the Yocto/Linux setup that determines which MIPI CSI Camera Sensors are supported
* Test Recovery mode booting and carefully document how it is done. What needs to be connected? 
  Are there Desktop PC software that can manage this?
  Can it be used to push Test builds without changing the eMMC/SD.
* Load firmware on the carrier board and show the functioning of two connected cameras.
* Log running `ziloo_selftest`.
* Verify running Tensorflow Lite examples


