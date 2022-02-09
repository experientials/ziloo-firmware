FROM ziloo-builder as base-repo-image

RUN mkdir -p /workspace/rockdev
WORKDIR /workspace
RUN repo init -u https://github.com/experientials/ziloo-firmware -m manifests/rv1126_rv1109_linux_20210904.xml
COPY manifests /workspace/.repo/manifests
RUN repo sync -m rv1126_rv1109_linux_20210904.xml -c

