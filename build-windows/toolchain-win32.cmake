# === Target : Windows x86 32 bits ===
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_VERSION 10)           # useful for find_package/version checks

#define the systemname (for good package name)
set(CMAKE_PACKAGE_PLATFORM_NAME "RaspberryPI")

# Cross-toolchain
set(CMAKE_C_COMPILER   i686-w64-mingw32-gcc)
set(CMAKE_CXX_COMPILER i686-w64-mingw32-g++)
set(CMAKE_RC_COMPILER  i686-w64-mingw32-windres)

# Where to look at includes/libs (don't go out of sysroot)
set(CMAKE_FIND_ROOT_PATH "${RPI_SYSROOT}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Force static CRT and static libs by default
set(CMAKE_C_FLAGS_INIT   "-static -static-libgcc -D_WIN32_WINNT=0x0601")
set(CMAKE_CXX_FLAGS_INIT "-static -static-libgcc -static-libstdc++ -D_WIN32_WINNT=0x0601")
set(CMAKE_EXE_LINKER_FLAGS_INIT "-Wl,--whole-archive -Wl,--no-whole-archive")

