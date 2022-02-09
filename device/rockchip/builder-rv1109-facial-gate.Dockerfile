FROM base-repo-image as rv1109-face-gate

WORKDIR /workspace

RUN repo sync -m rv1126_rv1109_linux_20210904_facial_gate.xml -c
RUN ./build.sh cam-crv1109s2u-facial_gate.mk
RUN FORCE_UNSAFE_CONFIGURE=1 ./build.sh
COPY rockchip/copy_dist.sh /copy_dist.sh
# TODO copy artifacts out of container

# rockdev/MiniLoaderAll.bin
# rockdev/boot.img
# rockdev/misc.img
# rockdev/oem.img
# rockdev/{parameter.txt,recovery.img,rootfs.ext4,rootfs.img,uboot.img,userdata.img}
# rockdev/pack/CAM-CRV1109S2U-FACIAL_GATE-GPT-20210922-1123.img

# CMD ./build.sh 
ENTRYPOINT /copy_dist.sh
