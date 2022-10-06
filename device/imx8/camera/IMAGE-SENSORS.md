# image sensors considered

Needed qualities

- Large pixel size 3um / 1/3" sensor
- 720p + 1080p
- 2 lane mipi + parallel for night sensor
- Low light performance
- Device driver support [Jetsson V4L2](https://developer.ridgerun.com/wiki/index.php/V4L2_drivers_available_for_Jetson_SoCs)




## Not relevant though has Device Driver

- IMX219 1/4"
- IMX230 21MP 1/2.4"
- IMX264 2/3" squarish 5MP, otherwise interesting
- IMX274 1/2.5" 1.6um
- IMX283 big 16mm x 12mm
- IMX296LQR 1/2.9" 1.6MP 3.45um
- IMX334LQR 1/1.8"?, near-infrared though!
- IMX344 obsolete?
- IMX377 7.8mm diagonal, a bit too big
- IMX385LQR 1/2"
- IMX397 1/6"
- IMX477 7.8mm diagonal, a bit too big
- AR0144 1/4" monochrome
- AR0521 1/2.5"
- AR1820HS 1/2.3" 18MP, 2:1 summing/binning to 1080p for low light performance
- OS08A10 1/2"
- ov02a10 1/6"
- OV3640 1/4"
- OV2640 1/4"
- OVM6211 eye tracking 400x400 sensor
- OV7251 1/6"
- OV7670 1/5"
- OV9640 1/2.7" 1280x800
- OV9650 2004 1/3" 1280x960 720p 3.75um NIR-sensitive 1/2-lane mipi+DVP 
- OV9281/82 1/4"
- AR0330 from 2013. superior low light performance 3MP 1/3" MIPI + DVP

OV13b10
OV13858
OV2740
OV5695
OV8865

AR0430 ?

NXP Embedded Linux supports

- OV2775
- OV5640
- os08a20
- ar1335


## [OV2775](https://www.ovt.com/products/ov02775-e77y-1e/) 1/2.9 MIPI+DVP 2.8um 1080p

Could be used for night camera with RP2040 low power monitoring.

360 Degree surround view system, lane departure warning/ lane keep assist, blind spot detection, pedestrian detection, traffic sign recognition, occupant sensor, camera monitoring system, autonomous driving

- analog 3.3V
- digital 1.2 - 1.4V
- D0VDD 1.7 - 1.9V
- AVDD 1.7 - 1.9V

Does it need 1.3V input? pin 9?
Could an LDO be added past the image sensor?

- [TI reference design](https://www.ti.com/lit/ug/tidud51a/tidud51a.pdf)
- [V4L2 support](https://github.com/nxp-imx/isp-vvcam/blob/lf-5.15.y_2.0.0/vvcam/v4l2/sensor/ov2775/)


## [AR0234CS](https://www.onsemi.com/products/sensors/image-sensors/ar0234cs) 1200p 2MP 1/2.6" 3um

Intended as Gesture/3D scan/Machine vision sensor.
Suited as night time

- [AR0234CS-STEREO-GMSL2_Xavier_EV A_R32.6.1_202100812_Driver_Guide](https://www.leopardimaging.com/wp-content/uploads/AR0234CS-STEREO-GMSL2_Xavier_EVA_Driver_Guide.pdf)
- [TEV iMX8 I2C driver](https://github.com/TechNexion-Vision/TEV-iMX8_EVK_BSP/tree/imx-lf-5.10.x/linux-imx/src/drivers/media/i2c/tevi-ar0234)


## OV4689 1/3" 4MP 2um 4lane 720p 1080p 

Suited as nighttime

Upgrade OS04C10 addes Nyxel NIR 850nm 940nm support

* [Jetson Linux Driver support](https://developer.ridgerun.com/wiki/index.php?title=OmniVision_OV4689_Linux_driver_for_Jetson)
* [Nyxel Near Infrared, Driver Monitoring, Eye tracking](https://www.ovt.com/technologies/nyxel-technology/)
* [Command to capture video or image for 10 bit RGB layer with OV4689 IC](https://community.nxp.com/t5/i-MX-Processors/Command-to-capture-video-or-image-for-10-bit-RGB-layer-with/m-p/1077808)

The OV4689 is a high performance 4-megapixel CameraChip™ sensor in a native 16:9 format designed for next-generation surveillance and security systems. The sensor utilizes an advanced 2-micron OmniBSI™-2 pixel to provide best-in-class low-light sensitivity and high dynamic range (HDR).

Wide. Staggered HDR. 4MP. 4-lane. Automatic black level calibration (ABLC). 5440 x 3072 µm

Programmable controls for:
- Frame rate
- Mirror and flip
- Cropping
- Windowing


## IMX214 1/3" 1um 1080p RGB 14MP

Suited as daytime 201-RGB module
[IMX214 compact module f/2.2, EFL: 2.262mm, FoV: 117° (D)](https://www.arducam.com/product/imx214-13mp-wide-angle-camera-oak/)

[Linux I2C support](https://github.com/varigit/linux-imx/blob/5.4-2.3.x-imx_var01/drivers/media/i2c/imx214.c)


## [AR1335](https://www.gophotonics.com/products/cmos-image-sensors/on-semiconductor/21-119-ar1335) 13MP 1/3.2" 1um RGB

Suited as daytime RGB module

- [V4L2 driver](https://github.com/nxp-imx/isp-vvcam/tree/lf-5.15.y_2.0.0/vvcam/v4l2/sensor/ar1335)


## [OS08A20](https://www.ovt.com/products/os08a20-h92a-1b/) 1/1.8" 2um 4K Nyxel

Could be an unfiltered daytime cam.
Supported by NXP Embedded Linux.


## [AR0430](https://www.onsemi.com/products/sensors/image-sensors/ar0430) 4MP 1/3" 3D-depth

The innovative depth mode gives the user the ability to develop a depth map of anything within approximately one meter of the camera while still shooting video at 30 fps.


## IMX258 1/3" 1um 13MP 2/4 lane MIPI

- [Existing module 127deg autofocus mipi](https://cbritech.com/product/13mp-sony-sensor-imx258-cmos-4k-mipi-camera-module/)
- [Linux I2C support (varigit)](https://github.com/varigit/linux-imx/blob/5.4-2.3.x-imx_var01/drivers/media/i2c/imx258.c)
- [Linux I2C support (phytec)](https://github.com/phytec/linux-phytec-imx/blob/v5.15.32_2.2.0-phy/drivers/media/i2c/imx258.c)

2-wire serial?

## IMX290NQV 2MP 1/2.8" RGB 3um


## [IMX327LQR](https://www.gophotonics.com/products/cmos-image-sensors/sony-corporation/21-209-imx327lqr-lqr1) 2MP 1/2.8" 3um RGB 1080p


## IMX390 1080p LFM+HDR 2 lane MIPI 1/2.7"


## IMX456 / IMX590 ToF range measurement

## OV2732

## OV2718  

OmniVision's OV2718 is a native 16:9 high definition (HD) CameraChip™ sensor that delivers best-in-class low-light sensitivity, high dynamic range (HDR), and 1080p HD video. These capabilities make the OV2718 an ideal camera solution for mainstream security and surveillance systems. [more](https://www.ovt.com/sensors/OV2718)


## OV2740


## [IMX298](https://www.arducam.com/docs/camera-breakout-board/16mp-imx298/) 1/2.8" 1um RGBW 16MP 2021?

Sony's unique “RGBW Coding” function enabling clear shooting in dark rooms or at night
While the addition of W (White) pixels improves sensitivity, it has the problem of degrading image quality. However, Sony's own device technology and signal processing realizes superior sensitivity without hurting image quality.

## [IMX327LQR](https://www.gophotonics.com/products/cmos-image-sensors/sony-corporation/21-209-imx327lqr-lqr1) 1/2.8" 2MP 3um RGB 


## IMX274 1/2.5" 8MP 1.6um

Claims good low light. Existing modules. Linux driver support.

- [Linux I2C driver](https://github.com/varigit/linux-imx/blob/5.4-2.3.x-imx_var01/drivers/media/i2c/imx274.c)
- [Linux I2C driver phytec](https://github.com/phytec/linux-phytec-imx/blob/v5.15.32_2.2.0-phy/drivers/media/i2c/imx274.c)
- 