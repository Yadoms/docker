#!/bin/bash
set -e

echo "Cloning Yadoms sources"
git clone --depth=1 -b feature/usertest_headless git://github.com/Yadoms/yadoms.git 

echo "Get Yadoms current version"
yadomsVersion=$(grep -oP '###[[:space:]]\K.*' yadoms/sources/server/changelog.md -m 1)

echo "Using Yadoms : $yadomsVersion. Download linux binaries"

wget --no-check-certificate --no-verbose -U 'Yadoms/1.0.0' http://yadoms.com/builds/linux/Yadoms-$yadomsVersion-Linux.tar.gz
tar xzf Yadoms-$yadomsVersion-Linux.tar.gz
rm -Rf yadoms/builds/*
mv Yadoms-$yadomsVersion-Linux/bin/* yadoms/builds

echo "Listing content of executable folder"
ls -alh yadoms/builds

echo "Run tests..."
cd yadoms/tests/user

python -v -d suite-html.py --headless 

echo "End of tests. Push report to ftp server"
cp report/index.html /report.html
chmod 777 /report.html
cd /
python report.py

