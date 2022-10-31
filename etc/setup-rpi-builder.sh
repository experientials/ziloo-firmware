#!/bin/sh
@echo off
sudo systemctl enable ssh
sudo systemctl start ssh
echo SSH ip address
hostname -i

sudo apt install gparted etckeeper minicom code

# Docs generation support
sudo apt install xmlto help2man groff libreoffice-writer vim bash-completion fop dblatex texi2html docbook-utils   

# Networking support
sudo apt install dnsmasq u-boot-tools tftp tftpd sshpass ssh-askpass

# Disk Image building
sudo apt install mtools parted binfmt-support debootstrap dosfstools fdisk gdisk kpartx xxd squashfs-tools u-boot-tools

# Git user
sudo git config --global user.email "henrik@thepia.com"
sudo git config --global user.name "Henrik Vendelbo"

cd ~
git init
git remote add origin https://github.com/experientials/ziloo-firmware.git
git fetch
git branch builder/home

# etckeeper
sudo etckeeper init /etc
sudo git branch -m hw/builder
sudo git remote add origin git@github.com:experientials/ziloo-firmware.git
sudo git push --set-upstream origin hw/builder
cd /etc
sudo git status
