#!/bin/bash
set -e

cd /work

echo "Create makefile"
cmake -S sources \
    -B projects-Linux \
    -DYADOMS_BINARY_DIR=bin-Linux \
    -DCMAKE_BUILD_TYPE=Release \
    -DCOTIRE_USE=ON \
    -DCOTIRE_USE_UNITY=ON \
    -DDEBUG_WITH_GCC=OFF \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DBOOST_ROOT="$YADOMS_DEPS/boost" \
    -DDCMAKE_BUILD_TYPE="Release"
    # -DPOCO_ROOT="$YADOMS_DEPS/poco-rpi2-armhf" \
    # -DPROTOBUF_ROOT="$YADOMS_DEPS/protobuf-rpi2-armhf" \
    # -DPROTOBUF_PROTOC_EXECUTABLE="/usr/local/bin/protoc" \
    # -DPROTOBUF_INSTALLED_TO_CUSTOM_DIRECTORY=ON \
    # -DOPENSSL_ROOT="$YADOMS_DEPS/openssl-rpi2-armhf" \
    # -DPYTHON_USE_PKGCONFIG=OFF \
    # -DPYTHON_USE_SOURCES=ON \
    # -DPython3_ManualSetup=ON \
    # -DPython3_EXECUTABLE="/opt/venv/bin/python" \
    # -DPython3_LIBRARIES="$YADOMS_DEPS/python-lib-rpi2-armhf/lib/python3.11/config-3.11-arm-linux-gnueabihf/libpython3.11.a" \
    # -DPython3_INCLUDE_DIRS="$YADOMS_DEPS/python-lib-rpi2-armhf/include/python3.11" \
    # -DOPENCV_ROOT="$YADOMS_DEPS/opencv-rpi2-armhf" \
    # -DLIBUDEV_ROOT="$YADOMS_DEPS/libudev"

#TODO utiliser ou faire le ménage de COTIRE_USE et COTIRE_USE_UNITY (voir ce que ça donne avec --target all_unity )
echo "Build Yadoms"
cmake --build projects-Linux \
    -j$(nproc)

echo "Build Yadoms package"
cmake --build projects-Linux \
    --target package \
    -j$(nproc)

echo "Build Yadoms update package"
cd update
sh make_package.sh Linux
cd -

