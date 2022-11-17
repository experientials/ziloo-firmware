# Raspberry Builder


## Ethernet Internet gate

- [Bridge internet to Ethernet from WiFi - Raspberry PI](https://www.elementzonline.com/blog/sharing-or-bridging-internet-to-ethernet-from-wifi-raspberry-pI)

The `/etc` settings can be set up by `builder/etc` branch application.

> sudo apt install dnsmasq


### Packages

u-boot-tools 
dnsmasq
tftp
tftpd


RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    lzop cpio python python-dev zip unzip file bc chrpath screen \
    u-boot-tools device-tree-compiler time tcl \
	autoconf libtool automake coreutils less \
    time lz4 device-tree-compiler fakeroot gnupg \
    mtools parted libyaml-dev libxml2-utils libudev-dev libusb-1.0-0-dev \
    curl wget net-tools sed asciidoc git git-core rsync openssh-client \

    perl ruby \
    python3-markdown \
	python3-setuptools \
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