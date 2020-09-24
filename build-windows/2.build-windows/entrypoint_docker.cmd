cd /work

echo "Copy build config file"
copy %YADOMS_DEPS_PATH:/=\%\CMakeListsUserConfig.txt sources

echo "Create makefile"
cmake_windows.cmd

echo "Build Yadoms"
cd projects
make all_unity
echo "Build Yadoms package"
make package
cd -

