#!/bin/bash
set -e

echo "Update Yadoms Git repository for $YADOMS_BUILD_BRANCH branch"
# Yadoms sources
if [ -z "$YADOMS_REPO" ]
then
	echo "Update Yadoms Git repository for $YADOMS_BUILD_BRANCH branch"
	git clone --depth=1 -b $YADOMS_BUILD_BRANCH https://github.com/Yadoms/yadoms.git
else
	echo "Update Yadoms Git repository for $YADOMS_REPO:$YADOMS_BUILD_BRANCH branch"
	git clone --depth=1 -b $YADOMS_BUILD_BRANCH https://github.com/$YADOMS_REPO
fi

cd yadoms

echo "Copy build config file"
cp $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt sources/

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
	
	if [ ! -z "$UPLOAD_FTP_CREDENTIALS" ]; then
		echo "Upload packages"
		curl --ftp-create-dirs -T "{$(echo builds/package/* | tr ' ' ',')}" -k sftp://$UPLOAD_FTP_CREDENTIALS@ssh.cluster010.ovh.net:22/~/builds/macos/
	fi
fi
