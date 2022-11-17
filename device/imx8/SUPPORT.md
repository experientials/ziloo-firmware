# Captured UCM Support log


m.2 support
Igor Derzhavets on 08-Aug-2022 12:05

My aim is to plan a support list for compact NVMe SSD on UCM-iMX8M-Plus.
Secondly if a Bluetooth/WiFi m.2 module can be supported that would be great.

I'm particularily concerned with which pins must be 1.8V domain and which 3.3V

You very limited in SSD M2 KeyB 2230. We tested evalkit with Kingston® NVME SSD OU3PDP3/OUSPDP3.
You can order OU3PDP364B from Compulab for evaluation purposes (contact sales).

USB and/or PCI-express interfaced cellular modems (2G/3G/4G etc.) can be plugged into M.2 (Key B) socket P9. 
For M.2 Key E devices use dedicated adapter (EB-M2B2E).
You have to short E14 jumper on base board in order to enable USB2.0/3.0 of M.2 (USB2 port J3 will be disabled).

M.2 Key B slot was designed accordingly to "PCI Express M.2 Specification" document from PCI-SIG.
PCIe interface is 3.3V interface.

Kingston OU3PDP364B - Compulab P/N: 605DP6430

 Wifi card couldn't be Key B, at least I don't know that they exists.
We didn't test WiFi USB dongles with UCM-iMX8PLUS, but it should work OOB.


-----

Igor Derzhavets on 29-Aug-2022 08:37

Hendrik,

Booting from Quad SPI flash was optional feature and cancelled by Compulab.


Regards,
Igor

-----

 It seems that the default enviroment has a variable named fdt_file, but the documentation instructs setting fdtfile.
Is that an issue with the documentation?

Additionally I'm struggling somewhat with the boot options. Is booting from USB done if an usb stick is present or must the alt. boot button be pressed?
I didn't find any explanation on your site on this

Dear Customer,

Boot)
AltBoot – make the device read bootloader from the sd-card.

u-boot environment boot media order "usb, sdcard, emmc"
u-boot environment on media discovery "boot.scr, kerne/fdtfile"

USB-Device mode)
Please provide logs that show the issue.

Regards,
Valentin.