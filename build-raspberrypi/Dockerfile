FROM debian:stable-slim
LABEL org.opencontainers.image.authors="sgallou"
ENV DEBIAN_FRONTEND=noninteractive

ENV YADOMS_BUILD_BRANCH=develop
ENV MAKE_PACKAGE=false
ENV RPI_SYSROOT=/rpi_sysroot
ENV YADOMS_DEPS=${RPI_SYSROOT}/yadoms-deps
ENV WORK_DIR=/tmp/yadoms_workdir

# Log current distribution version
RUN cat /etc/*-release

#############################################################
## Build yadoms dependencies
#############################################################

RUN mkdir -p {$YADOMS_DEPS}
RUN mkdir -p ${RPI_SYSROOT}

COPY toolchain-rpi2.cmake ${YADOMS_DEPS}/toolchain-rpi2.cmake

#############################################################
## Install all needed packages
#############################################################

RUN apt-get update
RUN apt-get install -q -y --no-install-recommends \
        build-essential gcc g++ autoconf automake libtool \
		gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf binutils-arm-linux-gnueabihf cmake \
		ca-certificates wget coreutils bzip2 python3 python3-venv python3-pip \
        perl swig unzip git
RUN rm -rf /var/lib/apt/lists/*

# Check CMake version
RUN cmake --version


#############################################################
## Download and extract minimal RaspberryPi sysroot (created by extract-sysroot-raspberrypi docker)
#############################################################

ARG RPI_SYSROOT_GOOGLEDRIVE_FILE_ID=1OHgyVJljewb-gIryf8cCTS3abb_kcQ1D

# Create a virtualenv and install gdown inside (needed on debian:stable-slim)
# Add venv to PATH and download file from Google Drive
RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir gdown  > /dev/null
ENV PATH="/opt/venv/bin:${PATH}"
WORKDIR ${WORK_DIR}
RUN gdown --id ${RPI_SYSROOT_GOOGLEDRIVE_FILE_ID} -O rpi2-sysroot.tar.gz  > /dev/null
RUN tar -xvzf rpi2-sysroot.tar.gz -C ${RPI_SYSROOT}  > /dev/null
RUN rm rpi2-sysroot.tar.gz  > /dev/null


#############################################################
## Boost
#############################################################
ARG boost_version_major=1
ARG boost_version_minor=89
ARG boost_version_patch=0
ARG boost_underscore=_
ARG boost_version=$boost_version_major$boost_underscore$boost_version_minor$boost_underscore$boost_version_patch
ARG boost_version_dot=$boost_version_major.$boost_version_minor.$boost_version_patch
WORKDIR ${WORK_DIR}
RUN wget --no-check-certificate --no-verbose https://archives.boost.io/release/$boost_version_dot/source/boost_$boost_version.tar.bz2  > /dev/null\
	&& tar xjf boost_$boost_version.tar.bz2  > /dev/null
WORKDIR ${WORK_DIR}/boost_$boost_version
RUN echo "using gcc : arm : arm-linux-gnueabihf-g++ ;" > /tmp/user-config.jam \
    && ./bootstrap.sh  > /dev/null \
	&& ./b2 -j$(nproc) \
		toolset=gcc-arm \
		target-os=linux \
        --user-config=/tmp/user-config.jam \
		architecture=arm address-model=32 abi=aapcs binary-format=elf \
		threading=multi link=static runtime-link=static \
		cxxflags="-march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard -fPIC" \
		--with-atomic --with-chrono --with-date_time --with-filesystem --with-locale --with-process --with-regex --with-system --with-test --with-thread \
		--no-samples --no-tests \
		--prefix=${YADOMS_DEPS}/boost-rpi2-armhf install  > /dev/null
WORKDIR ${WORK_DIR}
RUN	rm -Rf boost_$boost_version \
	&& rm boost_$boost_version.tar.bz2  > /dev/null


#############################################################
## OpenSSL (cross compile only)
#############################################################
#TODO tester version plus récente
ARG openssl_version=1.1.1k
WORKDIR ${WORK_DIR}
RUN wget --no-check-certificate --no-verbose https://www.openssl.org/source/openssl-1.1.1k.tar.gz \
    && tar xzf openssl-${openssl_version}.tar.gz  > /dev/null
WORKDIR ${WORK_DIR}/openssl-${openssl_version}
RUN ./Configure linux-generic32 --prefix=${YADOMS_DEPS}/openssl-rpi2-armhf --cross-compile-prefix=arm-linux-gnueabihf-  > /dev/null
RUN make CC="arm-linux-gnueabihf-gcc" AR="arm-linux-gnueabihf-ar" RANLIB="arm-linux-gnueabihf-ranlib" -j$(nproc) \
    && make install  > /dev/null
WORKDIR ${WORK_DIR}
RUN rm -Rf openssl-${openssl_version} && rm openssl-${openssl_version}.tar.gz  > /dev/null

	
#############################################################
## Poco
#############################################################
ARG poco_version=1.13.3
WORKDIR ${WORK_DIR}
RUN wget --no-check-certificate --no-verbose http://pocoproject.org/releases/poco-${poco_version}/poco-${poco_version}-all.tar.gz \
	&& tar xzf poco-${poco_version}-all.tar.gz  > /dev/null
WORKDIR ${WORK_DIR}/poco-${poco_version}-all/
RUN cmake \
    -S . \
    -B build-rpi2-static \
    -DCMAKE_TOOLCHAIN_FILE=${YADOMS_DEPS}/toolchain-rpi2.cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DENABLE_JSON=OFF \
    -DENABLE_MONGODB=OFF \
    -DENABLE_DATA_SQLITE=OFF \
    -DENABLE_REDIS=OFF \
    -DENABLE_PROMETHEUS=OFF \
    -DENABLE_PDF=OFF \
    -DENABLE_SEVENZIP=OFF \
    -DENABLE_CPPPARSER=OFF \
    -DENABLE_POCODOC=OFF \
    -DENABLE_PAGECOMPILER=OFF \
    -DENABLE_PAGECOMPILER_FILE2PAGE=OFF \
    -DENABLE_ACTIVERECORD=OFF \
    -DENABLE_ACTIVERECORD_COMPILER=OFF \
    -DOPENSSL_ROOT_DIR=$YADOMS_DEPS/openssl-rpi2-armhf \
    -DCMAKE_INSTALL_PREFIX=${YADOMS_DEPS}/poco-rpi2-armhf
RUN cmake \
    --build build-rpi2-static \
    --target all \
    -j$(nproc)
RUN cmake \
    --install build-rpi2-static
WORKDIR ${WORK_DIR}
RUN rm -Rf poco-${poco_version}-all/ \
	&& rm poco-${poco_version}-all.tar.gz


#############################################################
## Protobuf
#############################################################
# Protobuf (Host)
ARG protobuf_version=3.15.8
WORKDIR ${WORK_DIR}
RUN wget --no-verbose https://github.com/google/protobuf/releases/download/v${protobuf_version}/protobuf-cpp-${protobuf_version}.tar.gz \
	&& tar xzf protobuf-cpp-${protobuf_version}.tar.gz
RUN cp -R protobuf-${protobuf_version} protobuf-${protobuf_version}-host
WORKDIR ${WORK_DIR}/protobuf-${protobuf_version}-host
RUN mkdir build
WORKDIR ${WORK_DIR}/protobuf-${protobuf_version}-host/build
RUN cmake -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release ../cmake
RUN make -j$(nproc) \
	&& make install \
	&& ldconfig

# Protobuf (Pi)	
WORKDIR ${WORK_DIR}/protobuf-${protobuf_version}
RUN ./autogen.sh
RUN	./configure \
	--enable-shared=no \
	--host=arm-linux \
	CC=arm-linux-gnueabihf-gcc \
	CXX=arm-linux-gnueabihf-g++ \
	AR=arm-linux-gnueabihf-ar \
	STRIP=arm-linux-gnueabihf-strip \
	RANLIB=arm-linux-gnueabihf-ranlib \
	--prefix=${YADOMS_DEPS}/protobuf-rpi2-armhf \
	--with-protoc=protoc \
	--with-pic
RUN make -j$(nproc) \
	&& make install

# Cleanup
WORKDIR ${WORK_DIR}
RUN rm -Rf protobuf-${protobuf_version} \
	&& rm -Rf protobuf-${protobuf_version}-host \
	&& rm protobuf-cpp-${protobuf_version}.tar.gz


#############################################################
## Python
#############################################################
ARG python3_version=3.13.7
WORKDIR ${WORK_DIR}
RUN wget --no-check-certificate --no-verbose https://www.python.org/ftp/python/${python3_version}/Python-${python3_version}.tar.xz \
	&& tar xf Python-${python3_version}.tar.xz
WORKDIR ${WORK_DIR}/Python-${python3_version}
RUN CC=arm-linux-gnueabihf-gcc \
	CXX=arm-linux-gnueabihf-g++ \
	AR=arm-linux-gnueabihf-ar \
	RANLIB=arm-linux-gnueabihf-ranlib \
	./configure \
	--host=arm-linux-gnueabihf \
	--target=arm-linux-gnueabihf \
	--build=x86_64-linux-gnu \
	--disable-ipv6 \
    ac_cv_file__dev_ptmx=no \
	ac_cv_file__dev_ptc=no \
	ac_cv_have_long_long_format=yes \
	--enable-shared \
	--without-pymalloc \
	--with-openssl=${YADOMS_DEPS}/openssl-rpi2-armhf \
	--with-build-python \
	--prefix=${YADOMS_DEPS}/python-lib-rpi2-armhf
RUN make HOSTPYTHON=/usr/local/bin/python3 \
	BLDSHARED="arm-linux-gnueabihf-gcc -shared" \
	CROSS-COMPILE=arm-linux-gnueabihf- \
	CROSS_COMPILE_TARGET=yes \
	HOSTARCH=arm-linux \
	BUILDARCH=arm-linux-gnueabihf \
    -j$(nproc)
RUN make install
WORKDIR ${WORK_DIR}
RUN rm -Rf Python-${python3_version} \
	&& rm Python-${python3_version}.tar.xz


#############################################################
## OpenCV
#############################################################
ARG opencv_version=4.5.2
WORKDIR ${WORK_DIR}
RUN wget --no-verbose --no-check-certificate https://github.com/opencv/opencv/archive/${opencv_version}.zip \
	&& unzip ${opencv_version}.zip
WORKDIR ${WORK_DIR}/opencv-${opencv_version}
RUN mkdir build
WORKDIR ${WORK_DIR}/opencv-${opencv_version}/build
RUN cmake -DCC_RPI_GCC=arm-linux-gnueabihf-gcc \
   -DCC_RPI_GXX=arm-linux-gnueabihf-g++ \
   -DBUILD_SHARED_LIBS=OFF \
   -DCMAKE_TOOLCHAIN_FILE=${YADOMS_DEPS}/toolchain-rpi2.cmake \
   -DWITH_EIGEN:BOOL="0" \
   -DWITH_IMGCODEC_HDR:BOOL="0" \
   -DBUILD_opencv_ts:BOOL="0" \
   -DBUILD_opencv_video:BOOL="0" \
   -DWITH_TIFF:BOOL="0" \
   -DBUILD_PACKAGE:BOOL="0" \
   -DBUILD_opencv_features2d:BOOL="0" \
   -DBUILD_ITT:BOOL="0" \
   -Dthunder:BOOL="0" \
   -Dlzw:BOOL="0" \
   -DCV_TRACE:BOOL="0" \
   -DWITH_MSMF:BOOL="0" \
   -DWITH_FFMPEG:BOOL="0" \
   -DWITH_IMGCODEC_PXM:BOOL="0" \
   -DWITH_MSMF_DXVA:BOOL="0" \
   -DCPACK_SOURCE_ZIP:BOOL="0" \
   -Dpackbits:BOOL="0" \
   -DBUILD_opencv_apps:BOOL="0" \
   -DBUILD_PROTOBUF:BOOL="0" \
   -DBUILD_opencv_objdetect:BOOL="0" \
   -DBUILD_IPP_IW:BOOL="0" \
   -DBUILD_opencv_videoio:BOOL="0" \
   -DBUILD_PERF_TESTS:BOOL="0" \
   -Dmdi:BOOL="0" \
   -DWITH_1394:BOOL="0" \
   -DINSTALL_PDB:BOOL="0" \
   -DWITH_OPENCL:BOOL="0" \
   -DM_LIBRARY:FILEPATH="M_LIBRARY-NOTFOUND" \
   -DUSE_WIN32_FILEIO:BOOL="1" \
   -DCPACK_SOURCE_7Z:BOOL="0" \
   -DBUILD_opencv_stitching:BOOL="0" \
   -Dccitt:BOOL="0" \
   -DVIDEOIO_ENABLE_STRICT_PLUGIN_CHECK:BOOL="0" \
   -DWITH_IPP:BOOL="0" \
   -DBUILD_opencv_dnn:BOOL="0" \
   -DWITH_ITT:BOOL="0" \
   -DCPACK_BINARY_NSIS:BOOL="0" \
   -DBUILD_opencv_photo:BOOL="0" \
   -DBUILD_opencv_calib3d:BOOL="0" \
   -DWITH_QUIRC:BOOL="0" \
   -DWITH_WEBP:BOOL="0" \
   -DBUILD_opencv_python_bindings_generator:BOOL="0" \
   -DWITH_PROTOBUF:BOOL="0" \
   -DBUILD_JASPER:BOOL="1" \
   -DWITH_OPENCLAMDBLAS:BOOL="0" \
   -DBUILD_JAVA:BOOL="0" \
   -DWITH_VTK:BOOL="0" \
   -DBUILD_opencv_java_bindings_generator:BOOL="0" \
   -DBUILD_opencv_highgui:BOOL="0" \
   -DWITH_ARITH_DEC:BOOL="0" \
   -DWITH_IMGCODEC_SUNRASTER:BOOL="0" \
   -DWITH_ADE:BOOL="0" \
   -DBUILD_OPENEXR:BOOL="0" \
   -DWITH_OPENEXR:BOOL="0" \
   -DWITH_OPENCLAMDFFT:BOOL="0" \
   -DVIDEOIO_ENABLE_PLUGINS:BOOL="0" \
   -DWITH_DSHOW:BOOL="0" \
   -DOPENCV_DNN_OPENCL:BOOL="0" \
   -DWITH_LAPACK:BOOL="0" \
   -DWITH_IMGCODEC_PFM:BOOL="0" \
   -Dlogluv:BOOL="0" \
   -DINSTALL_PDB_COMPONENT_EXCLUDE_FROM_ALL:BOOL="0" \
   -DBUILD_opencv_ml:BOOL="0" \
   -DOPENCV_ENABLE_MEMALIGN:BOOL="0" \
   -DBUILD_opencv_python_tests:BOOL="0" \
   -DCV_ENABLE_INTRINSICS:BOOL="0" \
   -DOPENCL_FOUND:BOOL="0" \
   -DWITH_OPENCL_D3D11_NV:BOOL="0" \
   -Dnext:BOOL="0" \
   -DBUILD_opencv_gapi:BOOL="0" \
   -DBUILD_opencv_flann:BOOL="0" \
   -DBUILD_TESTS:BOOL="0" \
   -DWITH_DIRECTX:BOOL="0" \
   -DCMAKE_BUILD_TYPE=Release \
   -DCMAKE_INSTALL_PREFIX=${YADOMS_DEPS}/opencv-rpi2-armhf \
   ..
RUN make -j$(nproc) \
	&& make install
WORKDIR ${WORK_DIR}
RUN rm -Rf opencv-${opencv_version}* \
	&& rm -f ${opencv_version}.zip


#############################################################
## Libudev
#############################################################
WORKDIR ${WORK_DIR}
COPY libudev.tar.gz .
RUN tar xf libudev.tar.gz
RUN cp -R libudev ${YADOMS_DEPS}
RUN rm libudev.tar.gz


#############################################################
## Copy entry point
#############################################################
COPY entrypoint_docker.sh /
WORKDIR /

#TODO strip tous les binaires/libs
# En CMmake : placer, après le "cmake --build" et avant le "cmake --install" :
#    cmake --strip
