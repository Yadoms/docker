# this one is important
SET(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

#this one not so much
SET(CMAKE_SYSTEM_VERSION 1)
SET(CMAKE_CROSSCOMPILING True)
set(CMAKE_COMPILER_IS_RASPBERRY_CROSS_COMPILER ON)

# User specific configuration
include(CMakeListsUserConfig.txt OPTIONAL)

# cross compiler tools
set(CC_RPI_ROOT /yadoms-build-tools/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf)
set(CC_RPI_GCC ${CC_RPI_ROOT}/bin/arm-linux-gnueabihf-gcc)
set(CC_RPI_GXX ${CC_RPI_ROOT}/bin/arm-linux-gnueabihf-g++)
set(CC_RPI_LIBS ${CC_RPI_ROOT}/arm-linux-gnueabihf/libc)
set(CMAKE_SYSROOT ${CC_RPI_ROOT}/arm-linux-gnueabihf/sysroot)


unset(CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES)
unset(CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES)

# specify the cross compiler
SET(CMAKE_C_COMPILER   ${CC_RPI_GCC})
SET(CMAKE_CXX_COMPILER ${CC_RPI_GXX})

message(STATUS "Cross building for RaspberryPI")
message(STATUS "CC_RPI_ROOT : ${CC_RPI_ROOT}")
message(STATUS "CC_RPI_GCC : ${CC_RPI_GCC}")
message(STATUS "CC_RPI_GXX : ${CC_RPI_GXX}")
message(STATUS "CC_RPI_LIBS : ${CC_RPI_LIBS}")

# search for programs in the build host directories
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

#define the systemname (for good package name)
set(CMAKE_PACKAGE_PLATFORM_NAME "RaspberryPI")
