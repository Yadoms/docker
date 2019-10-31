FROM debian:stretch
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42
ENV DEBIAN_FRONTEND noninteractive

# Cross toolcahin for synology218p_cross_toolchain
# -> comptible with all RapsberryPI
# -> GCC 4.9.3
# -> X86_64 COMPILER : ApolloLake toolchain (official)


RUN echo "check_certificate = off" >> ~/.wgetrc

RUN apt-get update && apt-get dist-upgrade -q -y && apt-get install -q -y build-essential gawk gcc g++ gfortran git texinfo bison libncurses-dev wget nano ncdu

RUN wget 'https://sourceforge.net/projects/dsgpl/files/DSM%206.1%20Tool%20Chains/Intel%20x86%20Linux%204.4.15%20%28Apollolake%29/apollolake-gcc493_glibc220_linaro_x86_64-GPL.txz' \
 && tar xf apollolake-gcc493_glibc220_linaro_x86_64-GPL.txz \
 && mv x86_64-pc-linux-gnu /opt/x86_64-pc-linux-gnu \
 && rm -f apollolake-gcc493_glibc220_linaro_x86_64-GPL.txz

ENV PATH /opt/x86_64-pc-linux-gnu/bin:$PATH
ENV LD_LIBRARY_PATH /opt/x86_64-pc-linux-gnu/lib/gcc/x86_64-pc-linux-gnu/4.9.3:$LD_LIBRARY_PATH



