FROM base-repo-image as rv1126-face-gate

WORKDIR /workspace

RUN repo sync -m rv1126_rv1109_linux_20210904_facial_gate.xml -c
RUN ./build.sh cam-crv1126s2u-facial_gate.mk
RUN FORCE_UNSAFE_CONFIGURE=1 ./build.sh
# TODO copy artifacts out of container

# rockdev/{MiniLoaderAll.bin,boot.img,misc.img,oem.img,parameter.txt,recovery.img,rootfs.ext4,rootfs.img,uboot.img,userdata.img}

# rockdev/pack/CAM-CRV1126S2U-FACIAL_GATE-GPT-20210922-1126.img 
COPY copy_dist.sh /copy_dist.sh
ENTRYPOINT /copy_dist.sh
