FROM debian:stretch
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42
ENV DEBIAN_FRONTEND noninteractive

RUN echo "check_certificate = off" >> ~/.wgetrc

RUN apt-get update && apt-get dist-upgrade -q -y && apt-get install -q -y build-essential gawk gcc g++ gfortran git texinfo bison libncurses-dev wget nano ncdu

# download Raspberri PI cross compiler gcc 9.1 compatible with all RaspberryPI
# https://github.com/abhiTronix/raspberry-pi-cross-compiler
RUN wget 'https://sourceforge.net/projects/raspberry-pi-cross-compilers/files/Raspberry%20Pi%20GCC%20Cross-Compiler%20Toolchains/GCC%209.1.0/Raspberry%20Pi%203A%2B%2C%203B%2B/cross-gcc-9.1.0-pi_3%2B.tar.gz' \
 && tar xf cross-gcc-9.1.0-pi_3+.tar.gz \
 && mv cross-pi-gcc-9.1.0-2 /opt/cross-pi-gcc-9.1.0-2 \
 && rm -f cross-gcc-9.1.0-pi_3+.tar.gz

ENV PATH /opt/cross-pi-gcc-9.1.0-2/bin:$PATH
ENV LD_LIBRARY_PATH /opt/cross-pi-gcc-9.1.0-2/lib:$LD_LIBRARY_PATH


