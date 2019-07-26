FROM debian:stretch
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42
ENV DEBIAN_FRONTEND noninteractive

COPY toolchain_ctng_gcc83.tar.gz /

RUN cd / \
   && tar xJf toolchain_ctng_gcc83.tar.xz \
   && chmod +x -R /x-tools

ENV PATH /x-tools/armv6-rpi-linux-gnueabihf/bin:$PATH

RUN armv6-rpi-linux-gnueabihf-g++ --version

