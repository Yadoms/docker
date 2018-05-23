FROM ubuntu:17.04
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42

RUN apt-get install build-essential wget git lzop u-boot-tools binfmt-support qemu qemu-user-static multistrap parted dosfstools

COPY entrypoint.sh /

CMD /entrypoint.sh

