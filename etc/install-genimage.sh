#!/bin/bash

# download and create genimage by nagel

#update ubuntu
apt install -y autoconf
apt install -y gcc
apt-get install -y make
apt-get install -y genext2fs
apt-get update -y
apt-get install -y libconfuse-dev

rm -rf download

git clone https://github.com/pengutronix/genimage.git download

pushd download 

./autogen.sh

./configure CFLAGS='-g -O0' --prefix=/usr

make

popd

if [ -e download/genimage ]
then
    cp download/genimage /usr/bin/
    rm -rf download
    echo "creation of genimage successful"
else
    echo "creation of genimage failed"
fi;