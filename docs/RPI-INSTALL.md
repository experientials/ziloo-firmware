# Raspberry Builder

The raspberry pi is set up by installing required packages and adding it as an actions runner to GitHub.

The RPi can be accessed via

> ssh pi@ziloo-test

The ziloo-firmware repository can be synced with the RPi by adding it as origin.

> git remote add ziloo-test pi@ziloo-test:~

This allows pushing changes the home repository on the Pi. Note that it doesn't check out the changes.


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

Run install commands in the `pi` home directory:

> curl -L https://raw.githubusercontent.com/experientials/ziloo-firmware/main/.gitignore
> curl -L https://raw.githubusercontent.com/experientials/ziloo-firmware/main/etc/setup-rpi-builder.sh | bash

The script should now have set up [`etckeeper`](http://etckeeper.branchable.com/README/) to share `/etc`.
After making changes to etc, it can be shared with `cd /etc && sudo git push`.

Expand rootfs using gparted

> sudo gparted

Upload the SSH key with GitHub account. Generate a unique key, or get it from equal SD Card.

> ssh-keygen -t ed25519 -C "ziloo@thepia.com"


## /usr experiment

This turned out to add 
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


## GitHub Actions Runner

1. [Create self-hosted runner](https://github.com/organizations/experientials/settings/actions/runners/new?arch=arm64&os=linux)
2. [Configuring the self-hosted runner application as a service](https://docs.github.com/en/actions/hosting-your-own-runners/configuring-the-self-hosted-runner-application-as-a-service)

Run configure with additional label `raspbian`, and id `RPi-n`.


```sh
cd ~/actions-runner
sudo ./svc.sh install
sudo ./svc.sh start
```


## Ethernet Internet gate

- [Raspberry Pi 4 Model B WiFi Ethernet Bridge](https://www.willhaley.com/blog/raspberry-pi-wifi-ethernet-bridge/)
- [Bridge internet to Ethernet from WiFi - Raspberry PI](https://www.elementzonline.com/blog/sharing-or-bridging-internet-to-ethernet-from-wifi-raspberry-pI)
- [Raspberry Pi WiFi-to-ethernet bridge](https://github.com/mangefoo/wifi-ethernet-bridge)
- 

The `/etc` settings can be set up by `builder/etc` branch application.

> cd ~
> sudo source etc/setup-rpi-bridge.sh
> sudo reboot


### Packages to install

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python python-dev ruby chrpath screen time \
    time fakeroot \
    libyaml-dev libxml2-utils \
    net-toolsd openssh-client \

    python3-markdown python3-git python3-subunit \
    language-pack-en fakeroot libparse-yapp-perl python-pysqlite2 \

    mercurial subversion cvs liblscp-dev \
    libsigsegv2  libdrm-dev \
    libncurses5 libncurses5-dev libglib2.0-dev libgtk2.0-dev libglade2-dev \
    libegl1-mesa libgl1-mesa-dev libsdl1.2-dev pylint3 mesa-common-dev \
    gcc-multilib zstd \
    swig expect expect-dev \
    # zstd provides pzstd \

    # QEMU emulation
    qemu qemu-user-static \

    # Docs generation
    libreoffice-writer vim bash-completion \
    # missing packages: fop dblatex texi2html docbook-utils \  

    # GCC
    gcc-aarch64-linux-gnu \
    gcc-arm-linux-gnueabihf libssl-dev  xsltproc \
    g++-7 libstdc++-7-dev autotools-dev
