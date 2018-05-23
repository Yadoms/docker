#!/bin/bash
set -e

git clone --depth=1 https://github.com/Yadoms/yadoms-build_raspberrypi_image.git
cd yadoms-build_raspberrypi_image
./create-yadoms-pi-image $YADOMS_VERSION
    
if [ ! -z "$UPLOAD_FTP_CREDENTIALS" ]; then
   echo "Upload image"
   curl --ftp-create-dirs -T Yadoms-$YADOMS_VERSION-RaspberryPI.img.zip -k sftp://$UPLOAD_FTP_CREDENTIALS@ssh.cluster010.ovh.net:22/~/travis_build/raspberry_pi/
fi
