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
echo "Build Yadoms package"
OSXCROSS_MP_INC=1 make package
cd -

echo "Build Yadoms update package"
cd update
sh make_package.sh Darwin
