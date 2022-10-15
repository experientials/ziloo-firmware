#
# The builder is based on Ubuntu to get the biggest range of tools
# > docker buildx build -f Dockerfile --platform linux/amd64 --target image-builder .
# TODO future enhancement: https://blog.driftingruby.com/docker-builds/
#
FROM ubuntu:20.04 as base-builder

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    binutils bash gzip bzip2 tar lzop cpio python python-dev zip unzip file bc chrpath screen \
    u-boot-tools device-tree-compiler time tcl \
	autoconf libtool automake coreutils less \
    time lz4 device-tree-compiler fakeroot gnupg \
    mtools parted libyaml-dev libxml2-utils libudev-dev libusb-1.0-0-dev \
    curl wget net-tools sed asciidoc git git-core rsync openssh-client \

    perl ruby \
	python3 python3-dev \
    python3-markdown python3-pip \
    python3-pexpect \
	python3-distutils python3-setuptools \
    python3-git python3-jinja2 python3-subunit \

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

    language-pack-en m4 bison flex fakeroot libparse-yapp-perl python-pysqlite2 \
    build-essential gcc g++ make cmake intltool pkg-config patch patchutils
#   git-core is a dummy package that calls git

RUN gem update --system && \
    gem install --no-document serverspec

# RUN pip3 install setup-tools

COPY etc/ /workspace/etc/

RUN /workspace/etc/install-genimage.sh


FROM base-builder as ziloo-builder

RUN apt-get update && apt upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    mercurial subversion cvs liblscp-dev \
    sshpass ssh-askpass \
    libsigsegv2  libdrm-dev \
    libncurses5 libncurses5-dev libglib2.0-dev libgtk2.0-dev libglade2-dev \
    gawk socat xz-utils libegl1-mesa libgl1-mesa-dev libsdl1.2-dev pylint3 mesa-common-dev debianutils \
    texinfo xterm file iputils-ping iproute2 \
    diffstat gcc-multilib locales zstd desktop-file-utils \
    pkg-config swig expect expect-dev \
    # zstd provides pzstd

    # QEMU emulation
    qemu qemu-user-static

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \

    # Docs generation
    xmlto help2man groff libreoffice-writer vim bash-completion \
    # missing packages: fop dblatex texi2html docbook-utils   

    # GCC
    gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf libssl-dev liblz4-tool genext2fs xsltproc \
    g++-7 libstdc++-7-dev autotools-dev 
    # liblz4-tool provides lz4c and lz4

# In order to enable derived images to install more we leave apt config alone
#  rm -rf /var/lib/apt/lists/*

RUN pip3 install -r /workspace/etc/requirements-ci.txt

# Installed via apt
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo
RUN chmod a+rx /usr/bin/repo
RUN git config --global user.email hello@thepia.com && git config --global user.name "Ziloo Avatar" && git config --global color.ui false

RUN git clone https://github.com/NXPmicro/mfgtools.git /mfgtools
RUN apt-get install -y libusb-1.0-0-dev libbz2-dev zlib1g-dev libzstd-dev pkg-config cmake libssl-dev g++
RUN cd /mfgtools && cmake . && make
RUN cp /mfgtools/uuu/uuu /usr/bin
RUN chmod a+rx /usr/bin/uuu

WORKDIR /workspace

# Embedded ARM toolchain
# https://github.com/strongly-typed/docker-arm-none-eabi-gcc/blob/master/Dockerfile
RUN cd /workspace
RUN wget -qO- https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2019q4/gcc-arm-none-eabi-9-2019-q4-major-x86_64-linux.tar.bz2 | tar -xj
ENV ARMGCC_DIR=/workspace/gcc-arm-none-eabi-9-2019-q4-major


ENTRYPOINT [ "/workspace/etc/hello.sh" ]


FROM ziloo-builder as ziloo-builder-user

# ----------------------------------------------------------------------
# Handle the tzdata prompt
RUN ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends tzdata


# ----------------------------------------------------------------------
# Put everything we want to install here
RUN DEBIAN_FRONTEND=noninteractive apt install \
  -y --no-install-recommends --fix-missing \
  apt-utils sudo  ca-certificates

# ----------------------------------------------------------------------
# Clean up after the installs
RUN DEBIAN_FRONTEND=noninteractive apt clean -y --no-install-recommends \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ----------------------------------------------------------------------
# Set up locales
RUN locale-gen en_US.UTF-8 \
  && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8


# ----------------------------------------------------------------------
# Create user called build (because we can not run Yocto Project as root)
# Change uid and gid, to match my account on my workstation
# Username is not all that important
ENV UID=1000
ENV GID=1000
ENV USER=build
RUN groupadd -g $GID $USER && \
useradd -u $UID -g $GID -ms /bin/bash $USER && \
usermod -a -G sudo $USER && \
usermod -a -G users $USER 
