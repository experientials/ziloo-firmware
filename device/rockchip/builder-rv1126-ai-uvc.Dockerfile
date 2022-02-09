FROM base-repo-image as rv1126-ai-uvc

RUN .repo/repo/repo sync -m rv1126_rv1109_linux_ai_camera_20210904.xml -c
RUN ./build.sh cam-crv1126s2u-uvcc.mk
RUN FORCE_UNSAFE_CONFIGURE=1 ./build.sh
COPY copy_dist.sh /copy_dist.sh

ENTRYPOINT /copy_dist.sh

