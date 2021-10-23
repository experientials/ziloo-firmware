cmake_minimum_required(VERSION 3.0)		#指定cmake版本 
project(AFCFaceDemo_Linux)				#指定项目的名称，一般和项目的文件夹名称对应

set(CMAKE_CXX_STANDARD 11)				#设置c++标准

#这里配置rk1109交叉编译环境
#set(TOOLCHAIN  "/root/lay/rk1109/rv1109-linux/prebuilts/gcc/linux-x86/arm/gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf/bin")
#set(PREFIX  "${TOOLCHAIN}/arm-linux-gnueabihf")
#
#set(TOOLCHAIN_CC "${PREFIX}-gcc")
#set(TOOLCHAIN_CXX  "${PREFIX}-g++")
#
#set(CMAKE_CROSSCOMPILING TRUE)
#set(CMAKE_SYSTEM_NAME "Linux")
#set(CMAKE_C_COMPILER ${TOOLCHAIN_CC})
#set(CMAKE_CXX_COMPILER ${TOOLCHAIN_CXX})
#
#set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
#set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
#set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
#set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)


#指定头文件目录
include_directories(./)	
include_directories(./inc)

#指定静态和动态文件目录
link_directories(./linux_so)

#该指令的主要作用就是将指定的源文件生成链接文件，然后添加到工程中去。
#arcsoft_face生成的库文件名		[STATIC | SHARED | MODULE] 库类型
add_executable(arcsoft_face_engine_test 
        ./inc/amcomdef.h
        ./inc/arcsoft_face_sdk.h
		./inc/asvloffscreen.h
		./inc/merror.h
		./samplecode.cpp)

#-fPIC	在给定的作用域内设置一个命名的属性
set_property(TARGET arcsoft_face_engine_test PROPERTY POSITION_INDEPENDENT_CODE ON)


#链接库文件
target_link_libraries(arcsoft_face_engine_test	
		arcsoft_face
		arcsoft_face_engine
		rknn_api
        )