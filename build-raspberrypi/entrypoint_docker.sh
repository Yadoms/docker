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
cd -

if [ $MAKE_PACKAGE == "true" ]; then
	echo "Build Yadoms package"
	cd projects
	make package
	cd -
	
	cd update
	sh make_package.sh RaspberryPI
	cd -
fi
