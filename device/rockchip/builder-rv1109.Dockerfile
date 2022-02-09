FROM ziloo/image-builder

COPY device /device
COPY manifests /manifests

RUN mkdir -p /workspace && mkdir -p /workspace/rockdev
WORKDIR /workspace

RUN repo init -u https://github.com/experientials/ziloo-firmware -m manifests/rv1126_rv1109_linux_ai_camera_20210806.xml
RUN repo sync -c

# CMD ./build.sh 