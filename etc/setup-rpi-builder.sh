#!/bin/sh
@echo off
sudo systemctl enable ssh
sudo systemctl start ssh
echo SSH ip address
hostname -i

sudo apt install gparted etckeeper minicom code

sudo locale-gen en_GB.UTF-8 UTF-8
sudo update-locale en_GB.UTF-8 UTF-8
export LANGUAGE=en_GB.UTF-8
export LC_ALL=en_GB.UTF-8

sudo apt install tex-common
sudo dpkg --configure tex-common

# Docs generation support
sudo apt install xmlto help2man groff libreoffice-writer vim bash-completion fop dblatex texi2html docbook-utils asciidoc xmlto help2man groff  

# Networking support
sudo apt install dnsmasq u-boot-tools tftpd-hpa tftp sshpass ssh-askpass socat parprouted dhcp-helper nfs-kernel-server rpcbind

# Disk Image building
sudo apt install mtools parted binfmt-support debootstrap dosfstools fdisk gdisk kpartx xxd squashfs-tools u-boot-tools genext2fs xz-utils lz4 liblz4-tool 

# Compiling
sudo apt install autoconf libtool automake diffstat libudev-dev libusb-1.0-0-dev gawk \
    cmake intltool pkg-config patch patchutils m4 bison flex tcl lzop texinfo xterm

# Git user
sudo git config --global user.email "henrik@thepia.com"
sudo git config --global user.name "Henrik Vendelbo"

cd ~
git init
git remote add origin https://github.com/experientials/ziloo-firmware.git
git fetch origin builder/home:builder/home
git branch --set-upstream-to=origin/builder/home builder/home
git symbolic-ref HEAD refs/heads/builder/home
git reset --hard


# etckeeper
sudo etckeeper init /etc
sudo git branch -m hw/builder
sudo git remote add origin git@github.com:experientials/ziloo-firmware.git
sudo git push --set-upstream origin hw/builder
cd /etc
sudo git status

# NFS

