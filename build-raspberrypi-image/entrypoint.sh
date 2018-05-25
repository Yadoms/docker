#!/bin/bash
set -e
echo `id`

mount -v binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc/
dpkg-reconfigure -u binfmt-support qemu qemu-user-static
update-binfmts --enable qemu-arm

git -c http.sslVerify=false clone --depth=1 -b $CURBRANCH https://github.com/Yadoms/yadoms-build_raspberrypi_image.git
cd yadoms-build_raspberrypi_image

#fix execution flags
chmod +x ./fsckoptlist

echo "[START] Listing files"
ls -al
echo "[END] Listing files"

./create-yadoms-pi-image $YADOMS_VERSION
    
if [ ! -z "$UPLOAD_FTP_CREDENTIALS" ]; then
   echo "Upload image"
   curl --ftp-create-dirs -T Yadoms-$YADOMS_VERSION-RaspberryPI.img.zip -k sftp://$UPLOAD_FTP_CREDENTIALS@ssh.cluster010.ovh.net:22/~/travis_build/raspberry_pi/
fi
