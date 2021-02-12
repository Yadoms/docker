#!/bin/bash
set -e

cd /work

echo "Copy build config file"
cp $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt sources/

echo "Display config content"
cat sources/CMakeListsUserConfig.txt

echo "Create makefile"
sh cmake_linux.sh r

echo "Build Yadoms"
cd projects
make all_unity
echo "Build Yadoms package"
make package
cd -

echo "Build Yadoms update package"
cd update
sh make_package.sh Linux
