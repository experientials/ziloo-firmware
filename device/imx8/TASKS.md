## Open tasks task

Like for the RV1126 we need a firmware build for the i.MX8 Plus.
The two interesting builds are Yocto and Android.
Documentation should be done in Markdown files like this on a ziloo-firmware Git branch and delivered with a Pull Request.

- [Evaluation Kit Getting Started](https://developer.ridgerun.com/wiki/index.php?title=IMX8/iMX8MEVK/Getting_Started)
- [Yocto User Guide](../../docs/imx8/IMX_YOCTO_PROJECT_USERS_GUIDE.pdf)
- [Linux User Guide](../../docs/imx8/IMX_LINUX_USERS_GUIDE.pdf)

## Make vanilly distributions for Yocto and Android

* Create a build for a Yocto image in a new branch based on ziloo-firmware main branch.
* Create a build for an Android image in a new branch based on zilo-firmware main branch.
* Ensure that these images are built on the build server when pushing changes
* Ensure we have a clear documentation for what the build does and how it is triggered.
* Test and Document how to install GitHub actions runner on the iMX module.

## Test and Document

* Test and Document packages to install on the Wayland Desktop to test Camera Input, Audio Input and Audio Output.
* Test installation of OpenCV demo
* Test and Document remote desktop options that can show OpenCV output
* Find the Yocto/Linux setup that determines which MIPI CSI Camera Sensors are supported
* Test Recovery mode booting and carefully document how it is done. What needs to be connected? 
  Are there Desktop PC software that can manage this?
  Can it be used to push Test builds without changing the eMMC/SD.


