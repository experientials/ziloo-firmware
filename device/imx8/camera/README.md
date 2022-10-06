# Camera Support

Ziloo will need to support multiple image sensors to keep up with technology improvements and support different applications.
Review on different [Image Sensor](IMAGE-SENSORS.md) options.

Module variants

- 201-IR with OV2735 landscape orientation for IR filter lens
- 201-RGB with OV2735 portrait orientation for RGB filter lens
- 201-IR75 with OV2775 landscape orientation for IR filter lens
- 201-RGB35 with AR1335 portrait orientation for RGB filter lens
- 201-IR34 with AR0234CS landscape orientation for IR filter lens
- 201-IR89 with OV4689 landscape orientation for IR filter lens
- 201-NIR with OS04C10 landscape orientation for lens without filter or IR filter



## Porting Documentation

- [IMX BSP Porting Guide](../../../docs/imx8/i.MX_BSP_Porting_Guide_Linux.pdf)
- [IMX 8MP Camera Guide](../../../docs/imx8/iMX8MP_CAMERA_DISPLAY_GUIDE.pdf)
- [IMX Porting Guide](../../../docs/imx8/i.MX_Porting_Guide.pdf)


## Linux Device driver locations

The setup of NXP Embedded Linux is a [imx8_all.conf](https://github.com/nxp-imx/meta-imx/blob/912c0d83d08d467ec04c057b591a922d0ea872c1/meta-bsp/conf/machine/imx8_all.conf).
Other places to find implementations are,

- [Freescale Linux IMX](https://github.com/Freescale/linux-fslc/tree/5.4-2.3.x-imx)
- [varigit MXC capture](https://github.com/varigit/linux-imx/tree/5.4-2.3.x-imx_var01/drivers/media/platform/mxc/capture)
- [varigit I2C](https://github.com/varigit/linux-imx/tree/5.4-2.3.x-imx_var01/drivers/media/i2c)
- [TEV-iMX8_EVK_BSP](https://github.com/TechNexion-Vision/TEV-iMX8_EVK_BSP)
- 


## Near infrared sensor support

[RGB-InfraRed](https://www.avnet.com/wps/portal/us/products/product-highlights/on-semiconductor-low-light-imaging/rgb-infrared/)

Nyxel does this!
