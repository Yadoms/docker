FROM debian:stretch
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42
ENV DEBIAN_FRONTEND noninteractive

# Cross toolcahin for synology_marvel_kirkwood_88F6281_cross_toolchain
# -> comptible with many Synology NAS (DS212, DS211,...)
# -> https://www.synology.com/en-global/knowledgebase/DSM/tutorial/Compatibility_Peripherals/What_kind_of_CPU_does_my_NAS_have
# -> Marvell Kirkwood 88F6281

RUN echo "check_certificate = off" >> ~/.wgetrc

RUN apt-get update && apt-get dist-upgrade -q -y && apt-get install -q -y build-essential gawk gcc g++ gfortran git texinfo bison libncurses-dev wget nano ncdu

COPY arm-marvell-linux-gnueabi.tar.xz /arm-marvell-linux-gnueabi.tar.xz

RUN tar xf arm-marvell-linux-gnueabi.tar.xz \
 && mv arm-marvell-linux-gnueabi /opt/arm-marvell-linux-gnueabi \
 && rm -f arm-marvell-linux-gnueabi.tar.xz

ENV PATH /opt/arm-marvell-linux-gnueabi/bin:$PATH
ENV LD_LIBRARY_PATH /opt/arm-marvell-linux-gnueabi/lib/gcc/arm-marvell-linux-gnueabi/4.9.4:$LD_LIBRARY_PATH



