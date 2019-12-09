# OSXCross toolchain
set(CMAKE_SYSTEM_NAME Darwin)
#define the systemname (for good package name)
set(CMAKE_PACKAGE_PLATFORM_NAME "Darwin")
#this one not so much
SET(CMAKE_SYSTEM_VERSION 1)
SET(CMAKE_CROSSCOMPILING True)

macro(osxcross_getconf VAR)
  if(NOT ${VAR})
    set(${VAR} "$ENV{${VAR}}")
    if(${VAR})
      set(${VAR} "${${VAR}}" CACHE STRING "${VAR}")
      message(STATUS "Found ${VAR}: ${${VAR}}")
    else()
      message(FATAL_ERROR "Cannot determine \"${VAR}\"")
    endif()
  endif()
endmacro()

osxcross_getconf(OSXCROSS_HOST)
osxcross_getconf(OSXCROSS_TARGET_DIR)
osxcross_getconf(OSXCROSS_TARGET)
osxcross_getconf(OSXCROSS_SDK)

string(REGEX REPLACE "-.*" "" CMAKE_SYSTEM_PROCESSOR "${OSXCROSS_HOST}")

# where is the target environment
set(CMAKE_FIND_ROOT_PATH
  "${OSXCROSS_SDK}"
  "${OSXCROSS_TARGET_DIR}/macports/pkgs/opt/local")

set(CMAKE_SYSROOT ${OSXCROSS_SDK})

# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(ENV{PKG_CONFIG_LIBDIR} "${OSXCROSS_TARGET_DIR}/macports/pkgs/opt/local/lib/pkgconfig")
set(ENV{PKG_CONFIG_SYSROOT_DIR} "${OSXCROSS_TARGET_DIR}/macports/pkgs")
