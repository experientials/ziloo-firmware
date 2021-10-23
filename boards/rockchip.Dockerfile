#
# The builder is based on Debian to get the biggest range of tools
# > docker build -f builder.Dockerfile --target image-builder .
#
FROM ubuntu:18.04 as base-builder

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    binutils bash gzip bzip2 tar lzop cpio python python-dev zip unzip rsync file bc \
    u-boot-tools device-tree-compiler time tcl \
	autoconf libtool \
    mtools parted libyaml-dev libxml2-utils libudev-dev libusb-1.0-0-dev \
    curl wget sed asciidoc git  rsync openssh-client \

    perl \
	python3 \
	python3-dev \
    python3-markdown python3-pip \
	python3-distutils \
	python3-setuptools \

	# Disk Image building
    binfmt-support \
    debootstrap \
    dosfstools \
    fdisk \
    gdisk \
    kpartx \
    parted \
	xxd \
    squashfs-tools \
    u-boot-tools \

    m4 bison flex fakeroot libparse-yapp-perl \
    build-essential gcc g++ make cmake intltool pkg-config patch patchutils

FROM base-builder as rockchip-builder

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    #
    # https://wiki.t-firefly.com/en/Firefly-RK3399/linux_compile_gpt.html    
    linaro-image-tools \
    python-linaro-image-tools \
    # repo git-core gitk git-gui \
    mercurial subversion cvs \
    # libqt4-dev \
	liblscp-dev \
    gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf libssl-dev liblz4-tool genext2fs xsltproc \
    libc6-i386 lib32stdc++6 \
    lib32gcc-7-dev g++-7 libstdc++-7-dev autotools-dev \
    libsigsegv2  libdrm-dev \
    libncurses5 libncurses5-dev libglib2.0-dev libgtk2.0-dev libglade2-dev 

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \ 
    # w3m dblatex graphviz python-matplotlib texinfo g+conf \

    # for compiling rkdeveloptool
    dh-autoreconf \ 
    default-jre-headless \

	# Install dependencies
	# See https://buildroot.org/downloads/manual/manual.html#requirement
	# MANDATORY build tools
	# autoconf libtool \
	# which sed make binutils build-essential gcc-aarch64-linux-gnu libudev-dev \
	# MANDATORY source fetching tools
    # curl wget \
	# OPTIONAL recommended dependencies
	# python \
	# OPTIONAL configuration interface dependencies
	#libqt5-dev \
	#libglib2.0-dev libgtk2.0-dev libglade2-dev \
	# OPTIONAL source fetching tools
	# OPTIONAL java related packages
	#javacc \
	#jarwrapper \
	# OPTIONAL documentation generation tools
	#asciidoc \
	#w3m \
	#dblatex \

	# QEMU emulation
    qemu \
    qemu-user-static \

	# OPTIONAL graph generation tools
	#graphviz \
	#python-matplotlib \
	#
	# ADDITIONAL dependency to get root certificates
	ca-certificates \
	# ADDITIONAL dependency to get unbuffer
	expect \
	# ADDITIONAL dependency to get locale-gen
	locales \

	# More Build tools
    gcc-arm* \
	pkg-config \
    swig && \

	## Done
	echo Packages installed.

COPY rkbin rkbin

ENV RK_CFG_TOOLCHAIN = "arm-br-linux-gnueabihf"

