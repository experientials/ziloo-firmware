#!/bin/sh -l
# Download Sources for the MCUXpresso SDK. It can be used incrementally.

pip3 install west
west init -m https://github.com/NXPmicro/mcux-sdk --mr MCUX_2.12.0 mcuxsdk
cd mcuxsdk
west update
cd ..
