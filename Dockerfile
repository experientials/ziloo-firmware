#
# The builder is based on Ubuntu to get the biggest range of tools
# > docker build -f builder.Dockerfile --target image-builder .
#
FROM ubuntu:20.04 as base-builder

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    binutils bash gzip bzip2 tar lzop cpio python python-dev zip unzip file bc chrpath screen \
    u-boot-tools device-tree-compiler time tcl \
	autoconf libtool automake coreutils \
    time lz4 device-tree-compiler fakeroot gnupg \
    mtools parted libyaml-dev libxml2-utils libudev-dev libusb-1.0-0-dev \
    curl wget sed asciidoc git git-core rsync openssh-client \

    perl ruby \
	python3 python3-dev \
    python3-markdown python3-pip \
    python3-pexpect \
	python3-distutils python3-setuptools \
    python3-pexpect python3-git python3-jinja2 python3-subunit \

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

    # QEMU emulation
    qemu qemu-user-static

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \

    # Docs generation
    xmlto help2man groff libreoffice-writer vim \
    # missing packages: fop dblatex texi2html docbook-utils   

    # GCC
    gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf libssl-dev liblz4-tool genext2fs xsltproc \
    g++-7 libstdc++-7-dev autotools-dev 

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

ENTRYPOINT [ "/etc/hello.sh" ]