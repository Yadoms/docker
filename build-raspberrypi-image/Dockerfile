FROM debian:stable
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -y
RUN apt-get install -y dialog apt-utils
RUN apt-get install -y --allow-unauthenticated build-essential wget git lzop u-boot-tools binfmt-support qemu qemu-user-static multistrap parted dosfstools file udev zip curl
COPY entrypoint.sh /
USER root
CMD /entrypoint.sh

