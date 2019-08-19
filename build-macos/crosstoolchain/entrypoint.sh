#!/bin/bash
set -e


echo "Update Yadoms Git repository for $YADOMS_BUILD_BRANCH branch"
# Yadoms sources
git clone --depth=1 -b $YADOMS_BUILD_BRANCH https://github.com/Yadoms/yadoms.git

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
	
	echo "Build Yadoms update package"
	mkdir updatepackage
	yadomsVersion=$(grep -oP '###[[:space:]]\K.*' sources/server/changelog.md -m 1)
	# Copy script
	cp update/scripts/update.sh updatepackage/update.sh
	# Generate package.json
	cp update/package.json.in updatepackage/package.json
	sed -i -- 's/__version__/'$yadomsVersion'/g' updatepackage/package.json
	sed -i -- 's/__gitdate__/'`git log -1 --format=%cI `'/g' updatepackage/package.json
	cp sources/server/changelog.md updatepackage/changelog.md
	mv builds/package packagetomove
	mv builds updatepackage/package
	rm -f updatepackage/package/yadoms.ini
	cd updatepackage
	zip -r ../package.zip ./ -x \*.gitignore
	cd -
	mkdir builds
	mv packagetomove builds/package
	mv package.zip builds/package
	
	if [ ! -z "$UPLOAD_FTP_CREDENTIALS" ]; then
		echo "Upload packages"
		curl --ftp-create-dirs -T "{$(echo builds/package/* | tr ' ' ',')}" -k sftp://$UPLOAD_FTP_CREDENTIALS@ssh.cluster010.ovh.net:22/~/builds/raspberry_pi/
	fi
fi
