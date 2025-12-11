# === Target : Raspberry Pi 2 (ARMv7 / armhf, cortex-A7) ===
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR armv7)

#define the systemname (for good package name)
set(CMAKE_PACKAGE_PLATFORM_NAME "RaspberryPI")

# Cross-toolchain
set(TOOLCHAIN_PREFIX arm-linux-gnueabihf)
set(CMAKE_C_COMPILER   ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}-g++)
# (Optional but useful)
set(CMAKE_C_COMPILER_TARGET   ${TOOLCHAIN_PREFIX})
set(CMAKE_CXX_COMPILER_TARGET ${TOOLCHAIN_PREFIX})

# RaspberryPI sysroot
set(RPI_SYSROOT $ENV{RPI_SYSROOT})
set(CMAKE_SYSROOT "${RPI_SYSROOT}")

# Where to look at includes/libs (don't go out of sysroot)
set(CMAKE_FIND_ROOT_PATH "${RPI_SYSROOT}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Arch triplet Debian for armhf
set(CMAKE_LIBRARY_ARCHITECTURE arm-linux-gnueabihf)

# Optimized CPU/ABI flags for RPi2 (Cortex-A7, ARMv7, hard-float NEON)
set(RPI_CPU_FLAGS "-mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -marm")
# Secure link against sysroot libs
set(RPI_LINK_FLAGS "-Wl,-rpath-link,${RPI_SYSROOT}/usr/lib/arm-linux-gnueabihf \
                    -Wl,-rpath-link,${RPI_SYSROOT}/lib/arm-linux-gnueabihf \
                    -Wl,-rpath-link,${RPI_SYSROOT}/usr/lib \
                    -Wl,-rpath-link,${RPI_SYSROOT}/lib")

# Apply flags
set(CMAKE_C_FLAGS_INIT   "--sysroot=${RPI_SYSROOT} ${RPI_CPU_FLAGS}")
set(CMAKE_CXX_FLAGS_INIT "--sysroot=${RPI_SYSROOT} ${RPI_CPU_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS_INIT   "${RPI_LINK_FLAGS}")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "${RPI_LINK_FLAGS}")

# PKG-CONFIG target-side
set(ENV{PKG_CONFIG_DIR} "")
set(ENV{PKG_CONFIG_SYSROOT_DIR} "${RPI_SYSROOT}")
set(ENV{PKG_CONFIG_LIBDIR} "${RPI_SYSROOT}/usr/lib/arm-linux-gnueabihf/pkgconfig:${RPI_SYSROOT}/usr/lib/pkgconfig:${RPI_SYSROOT}/usr/share/pkgconfig:${RPI_SYSROOT}/lib/arm-linux-gnueabihf/pkgconfig:${RPI_SYSROOT}/lib/pkgconfig")


# To make CMake using right compilers from the first run
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

