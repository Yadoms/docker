#!/bin/bash
set -e

#fix binfmt (cannot be done in Dockerfile, so do it in entrypoint)
mount -v binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc/
dpkg-reconfigure -u binfmt-support qemu qemu-user-static
update-binfmts --enable qemu-arm

#clone the repo
git -c http.sslVerify=false clone --depth=1 -b $CURBRANCH https://github.com/Yadoms/yadoms-build_raspberrypi_image.git
cd yadoms-build_raspberrypi_image

#fix execution flags
chmod +x ./fsckoptlist

#make the image
./create-yadoms-pi-image $YADOMS_VERSION

#upload it if credentials are provided
if [ ! -z "$UPLOAD_FTP_CREDENTIALS" ]; then
   echo "Upload image"
   curl --ftp-create-dirs -T Yadoms-$YADOMS_VERSION-RaspberryPI.img.zip -k sftp://$UPLOAD_FTP_CREDENTIALS@ssh.cluster010.ovh.net:22/~/travis_build/raspberry_pi/
fi
