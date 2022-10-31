# Raspberry Builder

The raspberry pi is set up by installing required packages and adding it as an actions runner to GitHub.

1. Setup script

> curl -L https://raw.githubusercontent.com/experientials/ziloo-firmware/main/etc/setup-rpi-builder.sh | bash


The RPi can be accessed via

> ssh pi@ziloo-test


## Raspberry Pi demo environment

Branch `builder/home` and `builder/etc` hold repositories for `/home/pi` and `/etc`.

Use "Raspberry Pi Imager" Advanced options

- hostname `ziloo-test.local`
- SSH with public-key auth only
- username: pi
- password: zilootest
- locale: Zurich/gb

Write card

Boot partition (capacity 268.4 MB) will contain

- firstrun.sh
- config.txt
- cmdline.txt

To be used for updates to Bob and Ziloo enough space
must be present to hold

- Base images for Raspberry Pi 55 MB
- recent stream history
- u-boot patches
- Yocto Kernel Image 31 MB
- tee.bin 2 MB
- Overlays 1+ MB

Expand the boot partition keeping it Fat32 from 256MB up to 1024MB.
Reserve the second half of the SD Card for UBIFS or F2FS
Expand the rootfs (extFS4) to fill up the rest of the first half

Open raspi-config to enable SSH, Serial Port, 1-Wire, I2C.

> curl -L https://raw.githubusercontent.com/experientials/ziloo-firmware/main/etc/setup-rpi-builder.sh | bash

The script should now have set up [`etckeeper`](http://etckeeper.branchable.com/README/) to share `/etc`.
After making changes to etc, it can be shared with `cd /etc && sudo git push`.

Expand rootfs using gparted

> sudo gparted

Upload the SSH key with GitHub account. Generate a unique key, or get it from equal SD Card.

> ssh-keygen -t ed25519 -C "ziloo@thepia.com"

Setup the `usr` domain with all relevant software. In the future this would be linked to a separate partition
with Git repository and working directory.

```
cd /usr
sudo git init .
sudo git branch -m builder/etc
sudo git remote add origin git@github.com:experientials/ziloo-firmware.git
sudo git add .
sudo git config --global user.email "henrik@thepia.com"
sudo git config --global user.name "Henrik Vendelbo"
sudo git commit -m "usr base files" 
sudo git push --set-upstream origin builder/etc
```



## Ethernet Internet gate

- [Bridge internet to Ethernet from WiFi - Raspberry PI](https://www.elementzonline.com/blog/sharing-or-bridging-internet-to-ethernet-from-wifi-raspberry-pI)

The `/etc` settings can be set up by `builder/etc` branch application.

> sudo apt install dnsmasq


### Packages to install

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    lzop python python-dev chrpath screen \
    u-boot-tools device-tree-compiler time tcl \
	autoconf libtool automake coreutils \
    time lz4 fakeroot \
    libyaml-dev libxml2-utils libudev-dev libusb-1.0-0-dev \
    net-tools sed asciidoc openssh-client \

    ruby \
    python3-markdown \
    python3-git python3-subunit \

    language-pack-en m4 bison flex fakeroot libparse-yapp-perl python-pysqlite2 \
    cmake intltool pkg-config patch patchutils

    mercurial subversion cvs liblscp-dev \
    libsigsegv2  libdrm-dev \
    libncurses5 libncurses5-dev libglib2.0-dev libgtk2.0-dev libglade2-dev \
    gawk socat xz-utils libegl1-mesa libgl1-mesa-dev libsdl1.2-dev pylint3 mesa-common-dev \
    texinfo xterm \
    diffstat gcc-multilib zstd desktop-file-utils \
    swig expect expect-dev \
    # zstd provides pzstd

    # QEMU emulation
    qemu qemu-user-static

    # Docs generation
    xmlto help2man groff libreoffice-writer vim bash-completion \
    # missing packages: fop dblatex texi2html docbook-utils   

    # GCC
    gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf libssl-dev liblz4-tool genext2fs xsltproc \
    g++-7 libstdc++-7-dev autotools-dev 
    # liblz4-tool provides lz4c and lz4