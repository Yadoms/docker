#!/bin/bash
set -e

echo "Update Yadoms Git repository for $YADOMS_BUILD_BRANCH branch"
# Yadoms sources
if [ -z "$YADOMS_REPO" ]
then
	echo "Update Yadoms Git repository for $YADOMS_BUILD_BRANCH branch"
	GIT_SSL_NO_VERIFY=true git clone --depth=1 -b $YADOMS_BUILD_BRANCH https://github.com/Yadoms/yadoms.git
else
	echo "Update Yadoms Git repository for $YADOMS_REPO:$YADOMS_BUILD_BRANCH branch"
	GIT_SSL_NO_VERIFY=true git clone --depth=1 -b $YADOMS_BUILD_BRANCH $YADOMS_REPO
fi


cd yadoms

echo "Copy build config file"
cp $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt sources/

echo "Create makefile"
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

	echo "Prepare to generate raspberryPI SD image"
	
	#fix binfmt (cannot be done in Dockerfile, so do it in entrypoint)
	mount -v binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc/
	dpkg-reconfigure -u binfmt-support qemu qemu-user-static
	update-binfmts --enable qemu-arm

	#clone the repo
	if [ -z "$PARAM1" ]
	then
		echo "Cloning Yadoms/yadoms-build_raspberrypi_image.git on default branch"
		git -c http.sslVerify=false clone --depth=1 https://github.com/Yadoms/yadoms-build_raspberrypi_image.git
	else
		echo "Cloning Yadoms/yadoms-build_raspberrypi_image.git on branch : $PARAM1"
		git -c http.sslVerify=false clone --depth=1 -b $PARAM1 https://github.com/Yadoms/yadoms-build_raspberrypi_image.git
	fi
	cd yadoms-build_raspberrypi_image

	#make the image
	./create-yadoms-pi-image

	#upload it if credentials are provided
	if [ ! -z "$UPLOAD_FTP_CREDENTIALS" ]; then
		echo "Upload packages"
		curl --ftp-create-dirs -T "{$(echo builds/package/* | tr ' ' ',')}" -k sftp://$UPLOAD_FTP_CREDENTIALS@ssh.cluster010.ovh.net:22/~/builds/raspberry_pi/
	fi
fi
