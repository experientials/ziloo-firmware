#!/bin/bash

.repo/repo/repo sync -m rv1126_rv1109_linux_ai_camera_20210904.xml -c
./build.sh cam-crv1109s2u-uvcc.mk
FORCE_UNSAFE_CONFIGURE=1 ./build.sh


cp rockdev/{parameter.txt,recovery.img,rootfs.ext4,rootfs.img,uboot.img,userdata.img,MiniLoaderAll.bin,boot.img,misc.img,oem.img} /dist
cp rockdev/pack/*.img /dist/
