#!/bin/bash
set -e
echo "==================================================="
echo "================ Docker Entrypoint ================"
echo "==================================================="

echo "Update conan"
pip install conan --upgrade

cd yadoms

echo "Update Yadoms Git repository for $YADOMS_BUILD_BRANCH branch"
git fetch
git checkout $YADOMS_BUILD_BRANCH
git clean -d -x -f
git pull

echo "redo conan (simple formality, already done in donctainer => regnerate conanfiles)"
cd projects
conan install --build missing -s build_type=Debug -o Poco:fPIC=True -o boost:fPIC=True ../sources
conan install --build missing -s build_type=Release -o Poco:fPIC=True -o boost:fPIC=True ../sources
cd ..

echo "Copy build config file"
cp $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt sources/

echo "Create makefile"
sh cmake_linux.sh r

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
		curl --ftp-create-dirs -T "{$(echo builds/package/* | tr ' ' ',')}" -k sftp://$UPLOAD_FTP_CREDENTIALS@ssh.cluster010.ovh.net:22/~/builds/linux/
	fi
fi
