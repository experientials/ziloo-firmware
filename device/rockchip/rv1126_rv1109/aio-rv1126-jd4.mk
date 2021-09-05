#!/bin/bash

CMD=`realpath $BASH_SOURCE`
CUR_DIR=`dirname $CMD`

source $CUR_DIR/BoardConfig.mk

# Kernel defconfig
export RK_KERNEL_DEFCONFIG=rv1126_firefly_defconfig
# Kernel dts
export RK_KERNEL_DTS=rv1126-firefly-jd4
# Buildroot config
export RK_CFG_BUILDROOT=firefly_rv1126_rv1109
# Recovery config
export RK_CFG_RECOVERY=firefly_rv1126_rv1109_recovery
# Set rootfs type, including ext2 ext4 squashfs
export RK_ROOTFS_TYPE=ext4
#OEM config
export RK_OEM_DIR=oem_ipc_firefly
# update spl
export RK_LOADER_UPDATE_SPL=true
