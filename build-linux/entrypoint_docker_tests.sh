#!/bin/bash
set -e

cd /work/tests/unit

echo "Create makefile"
cmake -S sources \
    -B projects-Linux \
    -DDEBUG_WITH_GCC=OFF \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DCMAKE_BUILD_TYPE="Release" \
    -DBOOST_ROOT="$YADOMS_DEPS/boost" \
    -DPOCO_ROOT="$YADOMS_DEPS/poco" \
    -DPROTOBUF_ROOT="$YADOMS_DEPS/protobuf" \
    -DOPENSSL_ROOT="$YADOMS_DEPS/openssl" \
    -DPython3_ManualSetup=ON \
    -DPython3_INCLUDE_DIRS="$YADOMS_DEPS/python-lib/include/python3.11" \
    -DPython3_LIBRARIES="$YADOMS_DEPS/python-lib/lib/python3.11/config-3.11-x86_64-linux-gnu/libpython3.11.a" \
    -DPython3_EXECUTABLE="/usr/bin/python3" \
    -DOPENCV_ROOT="$YADOMS_DEPS/opencv" \
    -DGAMMU_ROOT="$YADOMS_DEPS/gammu" \
    -DLIBUDEV_ROOT="$YADOMS_DEPS/libudev"

echo "Build Yadoms Unit Tests"
cmake --build projects-Linux \
    -j$(nproc)
