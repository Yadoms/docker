#!/bin/bash
set -e

cd /work

echo "Copy build config file"
cp $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt sources/
cp $YADOMS_DEPS_PATH/synology218p.cmake sources

echo "Create makefile"
#sh cmake_cross.sh Synology218p /work/sources/synology218p.cmake Release
sh cmake_synology218p.sh r

echo "Build Yadoms"
cd projects
make all_unity
echo "Build Yadoms package"
make package
cd -

echo "Build Yadoms update package"
cd update
sh make_package.sh Synology218p
cd -
