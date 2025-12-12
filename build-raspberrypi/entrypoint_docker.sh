#!/bin/bash
set -e

cd /work

echo "Copy build config file"
#TODO ménage
# cp $YADOMS_DEPS/CMakeListsUserConfig.txt sources/
# cp $YADOMS_DEPS/toolchain-rpi2.cmake sources

echo "Create makefile"
cmake -S sources \
    -B projects \
    -DCMAKE_TOOLCHAIN_FILE=$YADOMS_DEPS/toolchain-rpi2.cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCOTIRE_USE=ON \
    -DCOTIRE_USE_UNITY=ON \
    -DDEBUG_WITH_GCC=OFF \
    -DBOOST_ROOT "$YADOMS_DEPS/boost-rpi2-armhf" \
    -DPOCO_ROOT "$YADOMS_DEPS/poco-rpi2-armhf" \
    -DPROTOBUF_ROOT "$YADOMS_DEPS/protobuf-rpi2-armhf" \
    -DPROTOBUF_PROTOC_EXECUTABLE "protoc" \
    -DPROTOBUF_INSTALLED_TO_CUSTOM_DIRECTORY=ON \
    -DOPENSSL_ROOT "$YADOMS_DEPS/openssl-rpi2-armhf" \
    -DPYTHON_USE_PKGCONFIG=OFF \
    -DPYTHON_USE_SOURCES=ON \
    -DPython3_ManualSetup=ON \
    -DPython3_EXECUTABLE="/usr/local/bin/python3" \
    -DPython3_LIBRARIES="$YADOMS_DEPS/Python-${python3_version}/libpython$(echo ${python3_version} | awk -F. '{print $1 "." $2}').a\")" \
    -DPython3_INCLUDE_DIRS="$YADOMS_DEPS/Python-${python3_version}" \
    -DOPENCV_ROOT="$YADOMS_DEPS/opencv-rpi2-armhf" \
    -DLIBUDEV_ROOT="$YADOMS_DEPS/libudev"

echo "Build Yadoms"
cmake --build projects --target all_unity -j$(nproc)

echo "Build Yadoms package"
cmake --build projects --target package -j$(nproc)

echo "Build Yadoms update package"
cd update
sh make_package.sh RaspberryPI
cd -
