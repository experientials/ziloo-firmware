#!/bin/bash

.repo/repo/repo sync -m rv1126_rv1109_linux_ai_camera_20210904.xml -c
./build.sh cam-crv1109s2u-uvcc.mk
FORCE_UNSAFE_CONFIGURE=1 ./build.sh


cp rockdev/{parameter.txt,recovery.img,rootfs.ext4,rootfs.img,uboot.img,userdata.img,MiniLoaderAll.bin,boot.img,misc.img,oem.img} /dist/rv1109-ai-uvc
cp rockdev/pack/*.img /dist/rv1109-ai-uvc
rm -rf rockdev/pack/*.img
rm -rf rockdev/{parameter.txt,recovery.img,rootfs.ext4,rootfs.img,uboot.img,userdata.img,MiniLoaderAll.bin,boot.img,misc.img,oem.img}

./repo/repo/repo sync -m rv1126_rv1109_linux_20210904_facial_gate.xml -c
./build.sh cam-crv1109s2u-facial_gate.mk
FORCE_UNSAFE_CONFIGURE=1 ./build.sh
cp rockdev/{parameter.txt,recovery.img,rootfs.ext4,rootfs.img,uboot.img,userdata.img,MiniLoaderAll.bin,boot.img,misc.img,oem.img} /dist/rv1109-facial-gate
cp rockdev/pack/*.img /dist/rv1109-facial-gate
rm -rf rockdev/pack/*.img
rm -rf rockdev/{parameter.txt,recovery.img,rootfs.ext4,rootfs.img,uboot.img,userdata.img,MiniLoaderAll.bin,boot.img,misc.img,oem.img}


.repo/repo/repo sync -m rv1126_rv1109_linux_ai_camera_20210904.xml -c
./build.sh cam-crv1126s2u-uvcc.mk
FORCE_UNSAFE_CONFIGURE=1 ./build.sh
cp rockdev/{parameter.txt,recovery.img,rootfs.ext4,rootfs.img,uboot.img,userdata.img,MiniLoaderAll.bin,boot.img,misc.img,oem.img} /dist/rv1126-ai-uvc
cp rockdev/pack/*.img /dist/rv1126-ai-uvc
rm -rf rockdev/pack/*.img
rm -rf rockdev/{parameter.txt,recovery.img,rootfs.ext4,rootfs.img,uboot.img,userdata.img,MiniLoaderAll.bin,boot.img,misc.img,oem.img}

.repo/repo/repo sync -m rv1126_rv1109_linux_20210904_facial_gate.xml -c
./build.sh cam-crv1126s2u-facial_gate.mk
FORCE_UNSAFE_CONFIGURE=1 ./build.sh
cp rockdev/{parameter.txt,recovery.img,rootfs.ext4,rootfs.img,uboot.img,userdata.img,MiniLoaderAll.bin,boot.img,misc.img,oem.img} /dist/rv1126-facial-gate
cp rockdev/pack/*.img /dist/rv1126-facial-gate
rm -rf rockdev/pack/*.img
rm -rf rockdev/{parameter.txt,recovery.img,rootfs.ext4,rootfs.img,uboot.img,userdata.img,MiniLoaderAll.bin,boot.img,misc.img,oem.img}
