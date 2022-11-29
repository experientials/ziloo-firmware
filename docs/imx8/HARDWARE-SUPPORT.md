# Hardware Support

The final hardware is a faceboard with modules:

- UCM i.MX8 SoM
- USB Delivery/Power Delivery with TPS65988
- SmartCam splitting CSI1, CSI2, SAI5 RX, I2C in Left and Right Sides

Firmware configuration task:



### Networking

- Ethernet ETH0 2 pairs 100BASE-TX
- USB dongle based on AX88179 Gigabit Ethernet over Host connector
- USB WiFi dongle over Host connector
- USB CDC ECM over OTG connector
- USB RNDIS over OTG connector
- nRF Bluetooth dongles


### Serial Communication

- U-Boot console over USB OTG connector
- Linux console over USB OTG connector


### Storage Devices

- eMMC
- USB MSC via Host connector
- SD Card via SD2
- 

### USB HID and HCI

- USB Keyboard over Host connector
- USB Mouse/trackpad over Host connector
- HDMI USB-C dongle ANX7688 like [PinePhone USB-C HDMI bridge](https://xnux.eu/devices/feature/anx7688.html)


### Camera Support

- OV2735
- AR1335
- V4L2
- libcamera


### Filesystems

- FAT
- Ext4
- SquashFS
- UBI FS (not appropriate for MMC)
- [F2FS](https://en.wikipedia.org/wiki/F2FS) - [Reddit comments](https://www.reddit.com/r/linux/comments/6bngw0/refuting_the_myth_about_f2fs/)
- OverlayFS

## Structure

Device Tree/Drivers/API

- CDC Command Console
- Ethernet 
- Mass Storage for firmware updates and scripts
- Video Stream (V4L2 based)
- libcamera


## Kernel Support

The kernel booted must support connectivity primarily over the two USB ports

- [CDC ECM Ethernet](https://www.kernel.org/doc/html/v5.3/usb/gadget_multi.html)
- [RNDIS Ethernet](https://www.kernel.org/doc/html/v5.3/usb/gadget_multi.html)
- [USB CDC ACM Serial](https://www.kernel.org/doc/html/v5.3/usb/gadget_multi.html)


