cd /work

echo "Copy build config file"
cp %YADOMS_DEPS_PATH%/CMakeListsUserConfig.txt sources/

echo "Create makefile"
cmake_windows.cmd

echo "Build Yadoms"
cd projects
make all_unity
cd -

echo "Build Yadoms package"
cd projects
make package
cd -

