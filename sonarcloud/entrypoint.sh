#!/bin/bash
set -e

cd yadoms

echo "Update Yadoms Git repository for $YADOMS_BUILD_BRANCH branch"
git fetch --depth=1
git checkout $YADOMS_BUILD_BRANCH
git clean -d -x -f
git pull


echo "Copy build config file"
cp $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt sources/

echo "Create makefile"
sh cmake_linux.sh m

echo "Build Yadoms"
cd projects
build-wrapper-linux-x86-64 --out-dir bw-output make all_unity

sonar-scanner \
  -Dsonar.projectKey=yadoms \
  -Dsonar.organization=yadoms \
  -Dsonar.sources=. \
  -Dsonar.cfamily.build-wrapper-output=bw-output \
  -Dsonar.host.url=https://sonarcloud.io \
  -Dsonar.login=c47b676210cf444e16cb6f8e131a766ceb703333
  
cd -

