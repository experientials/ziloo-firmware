#!/bin/sh -l
# Build selected SDK Examples

export ZIL_BASE_DIR=`pwd` 
cd mcuxsdk/examples/evkmimx8mp/multicore_examples/rpmsg_lite_pingpong_rtos/linux_remote/armgcc/
sh ./build_all.sh
cp ./release ../../../../../../../dist
cd $ZIL_BASE_DIR
cd mcuxsdk/examples/evkmimx8mp/multicore_examples/rpmsg_lite_str_echo_rtos/armgcc/
sh ./build_all.sh
cp ./release ../../../../../../../dist
cd $ZIL_BASE_DIR

# cp mcuxsdk/examples/evkmimx8mp/multicore_examples/rpmsg_lite_pingpong_rtos/linux_remote/armgcc/release/* dist
# cp mcuxsdk/examples/evkmimx8mp/multicore_examples/rpmsg_lite_str_echo_rtos/armgcc/release/* dist
