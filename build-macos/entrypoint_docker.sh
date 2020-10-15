#!/bin/bash
set -e

cd /work

echo "Copy build config file"
cp $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt sources/
cp /ccmacos.cmake sources

echo "Create makefile"
sh cmake_macosx.sh d

echo "Build Yadoms"
cd projects
OSXCROSS_MP_INC=1 make all_unity
cd -

if [ $MAKE_PACKAGE == "true" ]; then
	echo "Build Yadoms package"
	cd projects
	make package
	cd -
	
	cd update
	sh make_package.sh Darwin
	
fi
