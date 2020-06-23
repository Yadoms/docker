FROM debian:stable
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42
ENV DEBIAN_FRONTEND noninteractive
ENV OSXCROSS_SDK_VERSION 10.15

#Build arguments
ARG darwin_sdk_version="10.15"
ARG darwin_osx_version_min="10.9"
ARG darwin_version="15"
ARG sdk_file="MacOSX10.15.sdk.tar.xz"

# ENV available in docker image
ENV DARWIN_SDK_VERSION="${darwin_sdk_version}"         \
    DARWIN_VERSION="${darwin_version}"                 \
    DARWIN_OSX_VERSION_MIN="${darwin_osx_version_min}" \
    DARWIN_SDK_URL="${darwin_sdk_url}"

USER root

RUN apt-get update \
	&& apt-get install -y -q autoconf automake autotools-dev bc binfmt-support binutils-multiarch \
		binutils-multiarch-dev build-essential clang curl devscripts gdb git-core libtool llvm \
		mercurial multistrap patch software-properties-common subversion wget xz-utils cmake \
		qemu-user-static gcc-multilib libxml2-dev libssl-dev libz-dev gcc g++ zlib1g-dev \
		libmpc-dev libmpfr-dev libgmp-dev  \
	&& apt-get clean

RUN git config --global http.sslVerify false \
    && cd /opt \
    && git clone --depth=1 https://github.com/tpoechtrager/osxcross.git \
	&& cd osxcross \
    && ./tools/get_dependencies.sh
	
COPY $sdk_file /
RUN cd /opt/osxcross \
	&& mv /$sdk_file tarballs/MacOSX${DARWIN_SDK_VERSION}.sdk.tar.xz \
    && UNATTENDED=1 PORTABLE=true SDK_VERSION="${DARWIN_SDK_VERSION}" OSX_VERSION_MIN="${DARWIN_OSX_VERSION_MIN}" ./build.sh \
    && UNATTENDED=1 PORTABLE=true SDK_VERSION="${DARWIN_SDK_VERSION}" OSX_VERSION_MIN="${DARWIN_OSX_VERSION_MIN}" ./build_gcc.sh \
    && rm -Rf /opt/osxcross/build

ENV PATH $PATH:/opt/osxcross/target/bin

RUN UNATTENDED=1 MACOSX_DEPLOYMENT_TARGET=${DARWIN_OSX_VERSION_MIN} WGETOPTS=--no-check-certificate osxcross-macports install -s -v libtool
RUN UNATTENDED=1 MACOSX_DEPLOYMENT_TARGET=${DARWIN_OSX_VERSION_MIN} WGETOPTS=--no-check-certificate osxcross-macports install -s -v openssl
RUN UNATTENDED=1 MACOSX_DEPLOYMENT_TARGET=${DARWIN_OSX_VERSION_MIN} WGETOPTS=--no-check-certificate osxcross-macports install -v mpfr libmpc gmp llvm-8.0

CMD /bin/bash
