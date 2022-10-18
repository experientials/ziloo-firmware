# Ziloo Firmware

Ziloo is an independent device that sees and senses the environment. It recognises objects and behavior based on what it has been taught. It outputs an event log describing what is perceived.

The firmware is made for the various processors contained. 

Key building blocks are:

- Log based storage
- muslc static library
- busybox shell
- Base Firmware from read-only squashfs
- [F2FS](https://www.kernel.org/doc/html/latest/filesystems/f2fs.html) storage (requires Linux Kernel 5.7)


For more information see,

- [Manual Development environment](./docs/DEVELOP.md)
- [Continuous Integration setup](./docs/CONTINUOUS_INTEGRATION.md)
- [image-builder-user docker image](https://hub.docker.com/repository/docker/ziloo/image-builder-user)
- [SD Card Format](./docs/DEVELOP.md#SD_Card_Format)
- [Building with Docker](./docs/DEVELOP.md#Docker)
- [i.MX8 Yocto Docs](./docs/imx8/README.md)
- [Built with GitHub Actions](https://github.com/features/actions)



## Structure

USB Devices
- CDC Command Console
- Ethernet 
- Mass Storage for firmware updates and scripts
- Video Stream (V4L2 based)


## Kernel Support

The kernel booted must support connectivity primarily over the two USB ports

- [CDC ECM Ethernet](https://www.kernel.org/doc/html/v5.3/usb/gadget_multi.html)
- [RNDIS Ethernet](https://www.kernel.org/doc/html/v5.3/usb/gadget_multi.html)
- [USB CDC ACM Serial](https://www.kernel.org/doc/html/v5.3/usb/gadget_multi.html)



## Adding New Firmware + Hardware combination

To add a new hardware core to build for create a new branch under `hw/` naming it.
It is best to base it on the `hw/-template-` branch.
 

