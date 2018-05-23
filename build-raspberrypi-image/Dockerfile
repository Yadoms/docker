FROM i386/debian:9.4
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42

RUN apt-get -qqy update && apt-get install -qqy apt-utils && apt-get install -qqy build-essential wget git lzop u-boot-tools binfmt-support qemu qemu-user-static multistrap parted dosfstools

COPY entrypoint.sh /
RUN chmod 777 /entrypoint.sh
CMD /entrypoint.sh

