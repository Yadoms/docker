#!/bin/bash
set -e

cd /work

echo "Copy build config file"
cp $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt sources/
cp $YADOMS_DEPS_PATH/raspberrypi.cmake sources

echo "Create makefile"
#sh cmake_cross.sh Raspberry /work/sources/raspberrypi.cmake Release
sh cmake_raspberry.sh r

echo "Build Yadoms"
cd projects
make all_unity
echo "Build Yadoms package"
make package
cd -

echo "Build Yadoms update package"
cd update
sh make_package.sh RaspberryPI
cd -
