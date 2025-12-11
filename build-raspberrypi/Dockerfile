FROM debian:stable-slim
LABEL org.opencontainers.image.authors="sgallou"
ENV DEBIAN_FRONTEND=noninteractive

ENV YADOMS_BUILD_BRANCH=develop
ENV MAKE_PACKAGE=false
ENV YADOMS_BUILD_TOOLS_PATH=/yadoms-build-tools
#TODO YADOMS_BUILD_TOOLS_PATH est utile ?
ENV YADOMS_DEPS=/yadoms-deps/raspberry
ENV RPI_SYSROOT=/rpi_sysroot


#############################################################
## Build yadoms dependencies
#############################################################

RUN mkdir -p $YADOMS_BUILD_TOOLS_PATH
RUN mkdir -p $YADOMS_DEPS
RUN mkdir -p $RPI_SYSROOT

COPY toolchain-rpi2.cmake ${YADOMS_DEPS}/toolchain-rpi2.cmake

#############################################################
## Install all needed packages
#############################################################

# Log current distribution version
RUN cat /etc/*-release

# TODO utile ?
# RUN echo "deb http://archive.debian.org/debian/ bullseye main contrib non-free" | tee -a /etc/apt/sources.list \
# &&  echo "deb http://security.debian.org/ bullseye/updates main contrib non-free" | tee -a /etc/apt/sources.list \
# && echo "deb http://archive.debian.org/debian/ bullseye-updates main contrib non-free" | tee -a /etc/apt/sources.list \
# && echo "deb http://archive.debian.org/debian bullseye-backports main contrib non-free" | tee -a /etc/apt/sources.list
 
# RUN dpkg --add-architecture armhf \
#     && apt-get update \
# 	&& apt-get install -q -y --no-install-recommends \
# 		gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf binutils-arm-linux-gnueabihf cmake \
# 		pkg-config ca-certificates wget coreutils bzip2 \
#     && rm -rf /var/lib/apt/lists/*
#TODO regrouper toutes ces lignes :
RUN apt-get update
RUN apt-get install -q -y --no-install-recommends \
        build-essential gcc g++ autoconf automake libtool \
		gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf binutils-arm-linux-gnueabihf cmake \
		ca-certificates wget coreutils bzip2 python3 python3-venv python3-pip \
        perl swig unzip
RUN rm -rf /var/lib/apt/lists/*
	# TODO besoin ?     && apt-get dist-upgrade -q -y \
	# TODO besoin ?     pkg-config-arm-linux-gnueabihf



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
WORKDIR ${YADOMS_DEPS}
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
WORKDIR $YADOMS_DEPS
RUN wget --no-check-certificate --no-verbose https://archives.boost.io/release/$boost_version_dot/source/boost_$boost_version.tar.bz2  > /dev/null\
	&& tar xjf boost_$boost_version.tar.bz2  > /dev/null
WORKDIR $YADOMS_DEPS/boost_$boost_version
RUN echo "using gcc : arm : arm-linux-gnueabihf-g++ ;" > /tmp/user-config.jam \
    && ./bootstrap.sh  > /dev/null \
	&& ./b2 -j$(nproc) \
		toolset=gcc-arm \
		target-os=linux \
        --user-config=/tmp/user-config.jam \
		architecture=arm address-model=32 abi=aapcs binary-format=elf \
		threading=multi link=static runtime-link=static \
		cxxflags="-march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard -fPIC" \
		--with-atomic --with-chrono --with-date_time --with-filesystem --with-locale --with-regex --with-system --with-test --with-thread \
		--no-samples --no-tests \
		--prefix=$YADOMS_DEPS/boost-rpi2-armhf install  > /dev/null
WORKDIR $YADOMS_DEPS
RUN	rm -Rf boost_$boost_version \
	&& rm boost_$boost_version.tar.bz2  > /dev/null


#############################################################
## OpenSSL (cross compile only)
#############################################################
#TODO tester version plus récente
ARG openssl_version=1.1.1k
WORKDIR $YADOMS_DEPS
RUN wget --no-check-certificate --no-verbose https://www.openssl.org/source/openssl-1.1.1k.tar.gz \
    && tar xzf openssl-${openssl_version}.tar.gz  > /dev/null
WORKDIR $YADOMS_DEPS/openssl-${openssl_version}
RUN ./Configure linux-generic32 --prefix=$YADOMS_DEPS/openssl-rpi2-armhf --cross-compile-prefix=arm-linux-gnueabihf-  > /dev/null
RUN make CC="arm-linux-gnueabihf-gcc" AR="arm-linux-gnueabihf-ar" RANLIB="arm-linux-gnueabihf-ranlib" \
    && make install  > /dev/null
WORKDIR $YADOMS_DEPS
RUN rm -Rf openssl-${openssl_version} && rm openssl-${openssl_version}.tar.gz  > /dev/null

#TODO mettre dans le readme : pour debugger le build, appeler ça :
# export BUILDKIT_PROGRESS=plain
# Pour builder :
# clear && docker build -t build_for_raspberrypi --progress plain .

	
#############################################################
## Poco
#############################################################
ARG poco_version=1.11.8p2
WORKDIR $YADOMS_DEPS
RUN wget --no-check-certificate --no-verbose http://pocoproject.org/releases/poco-${poco_version}/poco-${poco_version}-all.tar.gz \
	&& tar xzf poco-${poco_version}-all.tar.gz  > /dev/null
WORKDIR $YADOMS_DEPS/poco-${poco_version}-all/
RUN echo 'TOOL = arm-linux-gnueabihf' > build/config/RaspberryPI \
	&& cat build/config/ARM-Linux >> build/config/RaspberryPI \
	&& echo 'STATICOPT_CC = -fPIC' >> build/config/RaspberryPI \
	&& echo 'STATICOPT_CXX = -fPIC' >> build/config/RaspberryPI
RUN ./configure \
	--static \
	--config=RaspberryPI \
	--prefix=$YADOMS_DEPS/poco-rpi2-armhf \
	--no-samples \
	--no-tests \
	--omit=CppUnit,CppUnit/WinTestRunner,Data,Data/SQLite,Data/ODBCData/MySQL,MongoDB,PageCompiler,PageCompiler/File2Page \
	--include-path=$YADOMS_DEPS/openssl-rpi2-armhf/include \
	--library-path=$YADOMS_DEPS/openssl-rpi2-armhf/lib
RUN make \
	&& make install
RUN cp VERSION $YADOMS_DEPS/poco-rpi2-armhf
WORKDIR $YADOMS_DEPS
RUN rm -Rf poco-${poco_version}-all/ \
	&& rm poco-${poco_version}-all.tar.gz



# Poco (1.11.8p2 is the last version compatible with current toolchain based on GCC 4.9.3)
#TODO remettre
# ARG poco_version=1.11.8p2
# RUN cd $YADOMS_DEPS \
# 	&& wget --no-check-certificate --no-verbose http://pocoproject.org/releases/poco-$poco_version/poco-$poco_version-all.tar.gz  > /dev/null\
# 	&& tar xzf poco-$poco_version-all.tar.gz && cd poco-$poco_version-all  > /dev/null\
# 	&& echo 'TOOL = arm-linux-gnueabihf' > build/config/RaspberryPI \
# 	&& cat build/config/ARM-Linux >> build/config/RaspberryPI \
# 	&& echo 'STATICOPT_CC = -fPIC' >> build/config/RaspberryPI \
# 	&& echo 'STATICOPT_CXX = -fPIC' >> build/config/RaspberryPI \
# 	&& ./configure --static --config=RaspberryPI --no-samples --no-tests --omit=CppUnit,CppUnit/WinTestRunner,Data,Data/SQLite,Data/ODBCData/MySQL,MongoDB,PageCompiler,PageCompiler/File2Page --include-path=$YADOMS_DEPS/openssl/include --library-path=$YADOMS_DEPS/openssl/lib  > /dev/null\
# 	&& make  > /dev/null\
# 	&& cd .. \
# 	&& find . -name obj -type d -print0 | xargs -0 rm -rf  > /dev/null\
# 	&& rm $YADOMS_DEPS/poco-$poco_version-all.tar.gz



#############################################################
## Protobuf
#############################################################
# Protobuf (Host)
ARG protobuf_version=3.15.8
WORKDIR $YADOMS_DEPS
RUN wget --no-verbose https://github.com/google/protobuf/releases/download/v${protobuf_version}/protobuf-cpp-${protobuf_version}.tar.gz \
	&& tar xzf protobuf-cpp-${protobuf_version}.tar.gz
RUN cp -R protobuf-${protobuf_version} protobuf-${protobuf_version}-host
WORKDIR $YADOMS_DEPS/protobuf-${protobuf_version}-host
RUN mkdir build
WORKDIR $YADOMS_DEPS/protobuf-${protobuf_version}-host/build
RUN cmake -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release ../cmake
RUN make \
	&& make install \
	&& ldconfig

# Protobuf (Pi)	
WORKDIR $YADOMS_DEPS/protobuf-${protobuf_version}
RUN ./autogen.sh
RUN	./configure \
	--enable-shared=no \
	--host=arm-linux \
	CC=arm-linux-gnueabihf-gcc \
	CXX=arm-linux-gnueabihf-g++ \
	AR=arm-linux-gnueabihf-ar \
	STRIP=arm-linux-gnueabihf-strip \
	RANLIB=arm-linux-gnueabihf-ranlib \
	--prefix=$YADOMS_DEPS/protobuf-rpi2-armhf \
	--with-protoc=protoc \
	--with-pic
RUN make \
	&& make install

# Cleanup
WORKDIR $YADOMS_DEPS
RUN rm -Rf protobuf-${protobuf_version} \
	&& rm -Rf protobuf-${protobuf_version}-host \
	&& rm protobuf-cpp-${protobuf_version}.tar.gz


# Protobuf (Host)
#TODO remettre
# ARG protobuf_version=3.15.8
# RUN wget --no-verbose https://github.com/google/protobuf/releases/download/v$protobuf_version/protobuf-cpp-$protobuf_version.tar.gz \
# 	&& tar xzf protobuf-cpp-$protobuf_version.tar.gz && rm protobuf-cpp-$protobuf_version.tar.gz > /dev/null\
#         && cp -R protobuf-$protobuf_version $YADOMS_BUILD_TOOLS_PATH/protobuf-$protobuf_version-host > /dev/null \
# 	&& cd $YADOMS_BUILD_TOOLS_PATH/protobuf-$protobuf_version-host \
# 	&& mkdir build \
# 	&& cd build \
# 	&& cmake -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release ../cmake && make && make install \
# 	&& ldconfig  > /dev/null


# Protobuf (Pi)
#TODO remettre
# RUN mv protobuf-$protobuf_version $YADOMS_DEPS/protobuf-$protobuf_version \
# 	&& cd $YADOMS_DEPS/protobuf-$protobuf_version \
# 	&& ./autogen.sh  > /dev/null\
# 	&& ./configure --enable-shared=no --host=arm-linux CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ AR=arm-linux-gnueabihf-ar STRIP=arm-linux-gnueabihf-strip RANLIB=arm-linux-gnueabihf-ranlib --prefix=$YADOMS_DEPS/protobuf --with-protoc=protoc --with-pic  > /dev/null\
# 	&& make  > /dev/null\
# 	&& make install  > /dev/null\
#     && cd .. && rm -Rf $YADOMS_DEPS/protobuf-protobuf_version




# TODO désactivé car on utilise le Swig installé (de apt-get)
# #############################################################
# ## Swig
# #############################################################
# ARG swig_version=4.0.2
# WORKDIR $YADOMS_DEPS
# RUN wget --no-check-certificate --no-verbose http://prdownloads.sourceforge.net/swig/swig-${swig_version}.tar.gz \
# 	&& tar xzf swig-${swig_version}.tar.gz
# WORKDIR $YADOMS_DEPS/swig-${swig_version}
# RUN ./configure \
# 	&& make \
# 	&& make install
# WORKDIR $YADOMS_DEPS
# RUN rm -f swig-${swig_version}/Source/Modules/*.o \
# 	&& rm -Rf swig-${swig_version}/Examples \
# 	&& rm -Rf swig-${swig_version}/Docs \
# 	&& rm swig-${swig_version}.tar.gz



# RUN cd $YADOMS_DEPS \
# 	&& echo "http://prdownloads.sourceforge.net/swig/swig-$swig_version.tar.gz" \
# 	&& wget --no-check-certificate --no-verbose http://prdownloads.sourceforge.net/swig/swig-$swig_version.tar.gz  > /dev/null\
# 	&& tar xzf swig-$swig_version.tar.gz  > /dev/null\
# 	&& cd $YADOMS_DEPS/swig-$swig_version  > /dev/null\
# 	&& ./configure  > /dev/null\
# 	&& make  > /dev/null\
# 	&& make install  > /dev/null\
# 	&& cd .. \
# 	&& rm -f swig-$swig_version/Source/Modules/*.o \
# 	&& rm -Rf swig-$swig_version/Examples \
# 	&& rm -Rf swig-$swig_version/Docs \
# 	&& rm $YADOMS_DEPS/swig-$swig_version.tar.gz




#############################################################
## Python
#############################################################
ARG python3_version=3.13.7
WORKDIR $YADOMS_DEPS
RUN wget --no-check-certificate --no-verbose https://www.python.org/ftp/python/${python3_version}/Python-${python3_version}.tar.xz \
	&& tar xf Python-${python3_version}.tar.xz
WORKDIR $YADOMS_DEPS/Python-${python3_version}
RUN CC=arm-linux-gnueabihf-gcc \
	CXX=arm-linux-gnueabihf-g++ \
	AR=arm-linux-gnueabihf-ar \
	RANLIB=arm-linux-gnueabihf-ranlib \
	./configure \
	--host=arm-linux-gnueabihf \
	--target=arm-linux-gnueabihf \
	--build=x86_64-linux-gnu \
	--disable-ipv6 ac_cv_file__dev_ptmx=no \
	ac_cv_file__dev_ptc=no \
	ac_cv_have_long_long_format=yes \
	--enable-shared \
	--without-pymalloc \
	--with-openssl=$YADOMS_DEPS/openssl-rpi2-armhf \
	--with-build-python
RUN make HOSTPYTHON=/usr/local/bin/python3 \
	BLDSHARED="arm-linux-gnueabihf-gcc -shared" \
	CROSS-COMPILE=arm-linux-gnueabihf- \
	CROSS_COMPILE_TARGET=yes \
	HOSTARCH=arm-linux \
	BUILDARCH=arm-linux-gnueabihf
WORKDIR $YADOMS_DEPS
RUN rm Python-${python3_version}.tar.xz


	
# Python 3.7 (Host)
#TODO remettre
# ARG python3_version_maj=3
# ARG python3_version_min=9
# ARG python3_version_patch=4
# ARG python3_version=$python3_version_maj.$python3_version_min.$python3_version_patch
# RUN wget --no-check-certificate --no-check-certificate --no-verbose https://www.python.org/ftp/python/$python3_version/Python-$python3_version.tgz\
# 	&& tar xzf Python-$python3_version.tgz && rm Python-$python3_version.tgz\
#     && cp -R Python-$python3_version Python-$python3_version-host\
# 	&& cd Python-$python3_version-host\
# 	&& ./configure \
# 	&& make python Parser/pgen\
# 	&& make install\
# 	&& mkdir -p $YADOMS_BUILD_TOOLS_PATH/pythonhost$python3_version_maj$python3_version_min \
# 	&& cp python $YADOMS_BUILD_TOOLS_PATH/pythonhost$python3_version_maj$python3_version_min/ \
# 	&& cd .. && rm -Rf Python-$python3_version-host

# Python 3.7 (Pi)
#TODO remettre
# RUN mv Python-$python3_version $YADOMS_DEPS/Python-$python3_version\
# 	&& cd $YADOMS_DEPS/Python-$python3_version\
# 	&& CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ AR=arm-linux-gnueabihf-ar RANLIB=arm-linux-gnueabihf-ranlib ./configure --host=arm-linux-gnueabihf --target=arm-linux-gnueabihf --build=x86_64-linux-gnu --disable-ipv6 ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no ac_cv_have_long_long_format=yes --enable-shared  --without-pymalloc --with-openssl=$YADOMS_DEPS/openssl > /dev/null\
# 	&& make HOSTPYTHON=$YADOMS_BUILD_TOOLS_PATH/pythonhost$python3_version_maj$python3_version_min/python BLDSHARED="arm-linux-gnueabihf-gcc -shared" CROSS-COMPILE=arm-linux-gnueabihf- CROSS_COMPILE_TARGET=yes HOSTARCH=arm-linux BUILDARCH=arm-linux-gnueabihf  > /dev/null
	
# PostgreSQL
#TODO remettre
# ARG postgresql_version=9.6.2
# RUN cd $YADOMS_DEPS \
# 	&& wget --no-check-certificate --no-verbose https://ftp.postgresql.org/pub/source/v$postgresql_version/postgresql-$postgresql_version.tar.bz2  > /dev/null\
# 	&& tar xjf postgresql-$postgresql_version.tar.bz2 && rm postgresql-$postgresql_version.tar.bz2  > /dev/null\
# 	&& cd postgresql-$postgresql_version  > /dev/null\
# 	&& CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ AR=arm-linux-gnueabihf-ar RANLIB=arm-linux-gnueabihf-ranlib ./configure --host=arm-linux --build=arm-linux-gnueabihf --without-readline --without-zlib --disable-spinlocks  > /dev/null\
# 	&& cd src/interfaces/libpq \
# 	&& make  > /dev/null\
# 	&& cd ../../../.. && rm -Rf postgresql-$postgresql_version/doc


#TODO remettre
# COPY raspberrypi.gammu.cmake /raspberrypi.cmake
# ARG gammu_version=1.41.0
# RUN cd $YADOMS_DEPS \
# 	&& wget --no-check-certificate --no-verbose https://dl.cihar.com/gammu/releases/gammu-$gammu_version.tar.bz2  > /dev/null\
# 	&& tar xjf gammu-$gammu_version.tar.bz2  > /dev/null\
# 	&& cd gammu-$gammu_version \
# 	&& mkdir rpicc \
# 	&& cd rpicc \
# 	&& cmake -DCC_RPI_GCC=arm-linux-gnueabihf-gcc -DCC_RPI_GXX=arm-linux-gnueabihf-g++ -DBUILD_SHARED_LIBS=OFF -DCMAKE_TOOLCHAIN_FILE=/raspberrypi.cmake -DCMAKE_STAGING_PREFIX=$YADOMS_DEPS/gammu ..  > /dev/null\
# 	&& make  > /dev/null\
# 	&& make install  > /dev/null\
# 	&& cd ../.. && rm -Rf gammu-1.40.*


#############################################################
## OpenCV
#############################################################
ARG opencv_version=4.5.2
WORKDIR $YADOMS_DEPS
RUN wget --no-verbose --no-check-certificate https://github.com/opencv/opencv/archive/${opencv_version}.zip \
	&& unzip ${opencv_version}.zip
WORKDIR $YADOMS_DEPS/opencv-${opencv_version}
RUN mkdir build
WORKDIR $YADOMS_DEPS/opencv-${opencv_version}/build
RUN cmake -DCC_RPI_GCC=arm-linux-gnueabihf-gcc \
   -DCC_RPI_GXX=arm-linux-gnueabihf-g++ \
   -DBUILD_SHARED_LIBS=OFF \
   -DCMAKE_TOOLCHAIN_FILE=$YADOMS_DEPS/toolchain-rpi2.cmake \
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
   -DCMAKE_INSTALL_PREFIX=$YADOMS_DEPS/opencv-rpi2-armhf \
   ..
RUN make \
	&& make install
WORKDIR $YADOMS_DEPS
RUN rm -Rf opencv-${opencv_version}* \
	&& rm -f ${opencv_version}.zip


# Opencv
#TODO remettre
# ARG opencv_version=4.5.2
# RUN cd $YADOMS_DEPS \
# 	&& wget --no-verbose https://github.com/opencv/opencv/archive/$opencv_version.zip  > /dev/null\
# 	&& unzip $opencv_version.zip  > /dev/null\
# 	&& cd opencv-$opencv_version \
# 	&& mkdir build \
# 	&& cd build \
# 	&& cmake -DCC_RPI_GCC=arm-linux-gnueabihf-gcc -DCC_RPI_GXX=arm-linux-gnueabihf-g++ -DBUILD_SHARED_LIBS=OFF -DCMAKE_TOOLCHAIN_FILE=/raspberrypi.cmake -DWITH_EIGEN:BOOL="0" -DWITH_IMGCODEC_HDR:BOOL="0" -DBUILD_opencv_ts:BOOL="0" -DBUILD_opencv_video:BOOL="0" -DWITH_TIFF:BOOL="0" -DBUILD_PACKAGE:BOOL="0" -DBUILD_opencv_features2d:BOOL="0" -DBUILD_ITT:BOOL="0" -Dthunder:BOOL="0" -Dlzw:BOOL="0" -DCV_TRACE:BOOL="0" -DWITH_MSMF:BOOL="0" -DWITH_FFMPEG:BOOL="0" -DWITH_IMGCODEC_PXM:BOOL="0" -DWITH_MSMF_DXVA:BOOL="0" -DCPACK_SOURCE_ZIP:BOOL="0" -Dpackbits:BOOL="0" -DBUILD_opencv_apps:BOOL="0" -DBUILD_PROTOBUF:BOOL="0" -DBUILD_opencv_objdetect:BOOL="0" -DBUILD_IPP_IW:BOOL="0" -DBUILD_opencv_videoio:BOOL="0" -DBUILD_PERF_TESTS:BOOL="0" -Dmdi:BOOL="0" -DWITH_1394:BOOL="0" -DINSTALL_PDB:BOOL="0" -DWITH_OPENCL:BOOL="0" -DM_LIBRARY:FILEPATH="M_LIBRARY-NOTFOUND" -DUSE_WIN32_FILEIO:BOOL="1" -DCPACK_SOURCE_7Z:BOOL="0" -DBUILD_opencv_stitching:BOOL="0" -Dccitt:BOOL="0" -DVIDEOIO_ENABLE_STRICT_PLUGIN_CHECK:BOOL="0" -DWITH_IPP:BOOL="0" -DBUILD_opencv_dnn:BOOL="0" -DWITH_ITT:BOOL="0" -DCPACK_BINARY_NSIS:BOOL="0" -DBUILD_opencv_photo:BOOL="0" -DBUILD_opencv_calib3d:BOOL="0" -DWITH_QUIRC:BOOL="0" -DWITH_WEBP:BOOL="0" -DBUILD_opencv_python_bindings_generator:BOOL="0" -DWITH_PROTOBUF:BOOL="0" -DBUILD_JASPER:BOOL="1" -DWITH_OPENCLAMDBLAS:BOOL="0" -DBUILD_JAVA:BOOL="0" -DWITH_VTK:BOOL="0" -DBUILD_opencv_java_bindings_generator:BOOL="0" -DBUILD_opencv_highgui:BOOL="0" -DWITH_ARITH_DEC:BOOL="0" -DWITH_IMGCODEC_SUNRASTER:BOOL="0" -DWITH_ADE:BOOL="0" -DBUILD_OPENEXR:BOOL="0" -DWITH_OPENEXR:BOOL="0" -DWITH_OPENCLAMDFFT:BOOL="0" -DVIDEOIO_ENABLE_PLUGINS:BOOL="0" -DWITH_DSHOW:BOOL="0" -DOPENCV_DNN_OPENCL:BOOL="0" -DWITH_LAPACK:BOOL="0" -DWITH_IMGCODEC_PFM:BOOL="0" -Dlogluv:BOOL="0" -DINSTALL_PDB_COMPONENT_EXCLUDE_FROM_ALL:BOOL="0" -DBUILD_opencv_ml:BOOL="0" -DOPENCV_ENABLE_MEMALIGN:BOOL="0" -DBUILD_opencv_python_tests:BOOL="0" -DCV_ENABLE_INTRINSICS:BOOL="0" -DOPENCL_FOUND:BOOL="0" -DWITH_OPENCL_D3D11_NV:BOOL="0" -Dnext:BOOL="0" -DBUILD_opencv_gapi:BOOL="0" -DBUILD_opencv_flann:BOOL="0" -DBUILD_TESTS:BOOL="0" -DWITH_DIRECTX:BOOL="0" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$YADOMS_DEPS/opencv .. >/dev/null \
# 	&& make  > /dev/null\
# 	&& make install  > /dev/null\
# 	&& cmake -DCC_RPI_GCC=arm-linux-gnueabihf-gcc -DCC_RPI_GXX=arm-linux-gnueabihf-g++ -DBUILD_SHARED_LIBS=OFF -DCMAKE_TOOLCHAIN_FILE=/raspberrypi.cmake -DWITH_EIGEN:BOOL="0" -DWITH_IMGCODEC_HDR:BOOL="0" -DBUILD_opencv_ts:BOOL="0" -DBUILD_opencv_video:BOOL="0" -DWITH_TIFF:BOOL="0" -DBUILD_PACKAGE:BOOL="0" -DBUILD_opencv_features2d:BOOL="0" -DBUILD_ITT:BOOL="0" -Dthunder:BOOL="0" -Dlzw:BOOL="0" -DCV_TRACE:BOOL="0" -DWITH_MSMF:BOOL="0" -DWITH_FFMPEG:BOOL="0" -DWITH_IMGCODEC_PXM:BOOL="0" -DWITH_MSMF_DXVA:BOOL="0" -DCPACK_SOURCE_ZIP:BOOL="0" -Dpackbits:BOOL="0" -DBUILD_opencv_apps:BOOL="0" -DBUILD_PROTOBUF:BOOL="0" -DBUILD_opencv_objdetect:BOOL="0" -DBUILD_IPP_IW:BOOL="0" -DBUILD_opencv_videoio:BOOL="0" -DBUILD_PERF_TESTS:BOOL="0" -Dmdi:BOOL="0" -DWITH_1394:BOOL="0" -DINSTALL_PDB:BOOL="0" -DWITH_OPENCL:BOOL="0" -DM_LIBRARY:FILEPATH="M_LIBRARY-NOTFOUND" -DUSE_WIN32_FILEIO:BOOL="1" -DCPACK_SOURCE_7Z:BOOL="0" -DBUILD_opencv_stitching:BOOL="0" -Dccitt:BOOL="0" -DVIDEOIO_ENABLE_STRICT_PLUGIN_CHECK:BOOL="0" -DWITH_IPP:BOOL="0" -DBUILD_opencv_dnn:BOOL="0" -DWITH_ITT:BOOL="0" -DCPACK_BINARY_NSIS:BOOL="0" -DBUILD_opencv_photo:BOOL="0" -DBUILD_opencv_calib3d:BOOL="0" -DWITH_QUIRC:BOOL="0" -DWITH_WEBP:BOOL="0" -DBUILD_opencv_python_bindings_generator:BOOL="0" -DWITH_PROTOBUF:BOOL="0" -DBUILD_JASPER:BOOL="1" -DWITH_OPENCLAMDBLAS:BOOL="0" -DBUILD_JAVA:BOOL="0" -DWITH_VTK:BOOL="0" -DBUILD_opencv_java_bindings_generator:BOOL="0" -DBUILD_opencv_highgui:BOOL="0" -DWITH_ARITH_DEC:BOOL="0" -DWITH_IMGCODEC_SUNRASTER:BOOL="0" -DWITH_ADE:BOOL="0" -DBUILD_OPENEXR:BOOL="0" -DWITH_OPENEXR:BOOL="0" -DWITH_OPENCLAMDFFT:BOOL="0" -DVIDEOIO_ENABLE_PLUGINS:BOOL="0" -DWITH_DSHOW:BOOL="0" -DOPENCV_DNN_OPENCL:BOOL="0" -DWITH_LAPACK:BOOL="0" -DWITH_IMGCODEC_PFM:BOOL="0" -Dlogluv:BOOL="0" -DINSTALL_PDB_COMPONENT_EXCLUDE_FROM_ALL:BOOL="0" -DBUILD_opencv_ml:BOOL="0" -DOPENCV_ENABLE_MEMALIGN:BOOL="0" -DBUILD_opencv_python_tests:BOOL="0" -DCV_ENABLE_INTRINSICS:BOOL="0" -DOPENCL_FOUND:BOOL="0" -DWITH_OPENCL_D3D11_NV:BOOL="0" -Dnext:BOOL="0" -DBUILD_opencv_gapi:BOOL="0" -DBUILD_opencv_flann:BOOL="0" -DBUILD_TESTS:BOOL="0" -DWITH_DIRECTX:BOOL="0" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$YADOMS_DEPS/opencv .. >/dev/null \
# 	&& make  > /dev/null\
# 	&& make install  > /dev/null\
# 	&& cd ../.. && rm -Rf opencv-$opencv_version* && rm -f $opencv_version.zip

#TODO remettre
WORKDIR $YADOMS_DEPS
COPY libudev.tar.gz .
RUN tar xf libudev.tar.gz
RUN rm libudev.tar.gz
	
	 

# Yadoms configuration file
#TODO remettre
# RUN echo 'Configuring Yadoms CMakeListsUserConfig.txt' \
# 	&& echo 'set(BOOST_ROOT "'$YADOMS_DEPS'/boost_'$boost_version'")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(POCO_ROOT "'$YADOMS_DEPS'/poco-'$poco_version'-all")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(PROTOBUF_ROOT "'$YADOMS_DEPS'/protobuf")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(PROTOBUF_PROTOC_EXECUTABLE "'`which protoc`'")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(PROTOBUF_INSTALLED_TO_CUSTOM_DIRECTORY ON)' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(OPENSSL_ROOT "'$YADOMS_DEPS'/openssl")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(DEBUG_WITH_GCC OFF)' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(PYTHON_USE_PKGCONFIG OFF)' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(PYTHON_USE_SOURCES ON)' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(Python2_ManualSetup ON)' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(Python2_EXECUTABLE "/usr/local/bin/python'$python2_version_maj'.'$python2_version_min'")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(Python2_LIBRARIES "'$YADOMS_DEPS'/Python-'$python2_version'/libpython'$python2_version_maj'.'$python2_version_min'.a")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(Python2_INCLUDE_DIRS "'$YADOMS_DEPS'/Python-'$python2_version'")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(Python3_ManualSetup ON)' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(Python3_EXECUTABLE "/usr/local/bin/python'$python3_version_maj'.'$python3_version_min'")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(Python3_LIBRARIES "'$YADOMS_DEPS'/Python-'$python3_version'/libpython'$python3_version_maj'.'$python3_version_min'.a")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(Python3_INCLUDE_DIRS "'$YADOMS_DEPS'/Python-'$python3_version'")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(PostgreSQL_ROOT ' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo '       "'$YADOMS_DEPS'/postgresql-'$postgresql_version'/src/interfaces/libpq"' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo '       "'$YADOMS_DEPS'/postgresql-'$postgresql_version'/src/include")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(GAMMU_ROOT "'$YADOMS_DEPS'/gammu")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(SWIG_ROOT "'$YADOMS_DEPS'/swig-'$swig_version'")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(OPENCV_ROOT "'$YADOMS_DEPS'/opencv")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(LIBUDEV_ROOT "'$YADOMS_DEPS'/libudev")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'SET(COTIRE_USE ON)' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'SET(COTIRE_USE_UNITY ON)' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
# 	&& echo 'set(CC_RPI_ROOT "'$YADOMS_BUILD_TOOLS_PATH'/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt

RUN echo 'Configuring Yadoms CMakeListsUserConfig.txt' \
   && echo 'set(COTIRE_USE ON)' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
   && echo 'set(COTIRE_USE_UNITY ON)' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
   && echo 'set(DEBUG_WITH_GCC OFF)' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
   && echo 'set(BOOST_ROOT "$YADOMS_DEPS/boost-rpi2-armhf")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
   && echo 'set(POCO_ROOT "$YADOMS_DEPS/poco-rpi2-armhf")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
   && echo 'set(PROTOBUF_ROOT "$YADOMS_DEPS/protobuf-rpi2-armhf")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
   && echo 'set(PROTOBUF_PROTOC_EXECUTABLE "protoc")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
   && echo 'set(PROTOBUF_INSTALLED_TO_CUSTOM_DIRECTORY ON)' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
   && echo 'set(OPENSSL_ROOT "$YADOMS_DEPS/openssl-rpi2-armhf")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
   && echo 'set(PYTHON_USE_PKGCONFIG OFF)' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
   && echo 'set(PYTHON_USE_SOURCES ON)' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
   && echo 'set(Python3_ManualSetup ON)' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
   && echo 'set(Python3_EXECUTABLE "/usr/local/bin/python3")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
   && echo "set(Python3_LIBRARIES \"\$YADOMS_DEPS/Python-${python3_version}/libpython$(echo ${python3_version} | awk -F. '{print $1 "." $2}').a\")" >> CMakeListsUserConfig.txt \
   && echo 'set(Python3_INCLUDE_DIRS "$YADOMS_DEPS/Python-${python3_version}")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
   && echo 'set(USE_PGSQL_DATABASE OFF)' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
   && echo 'set(OPENCV_ROOT "$YADOMS_DEPS/opencv-rpi2-armhf")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt \
   && echo 'set(LIBUDEV_ROOT "$YADOMS_DEPS/libudev")' >> $YADOMS_DEPS/CMakeListsUserConfig.txt


#For debug purpose only
RUN cat $YADOMS_DEPS/CMakeListsUserConfig.txt

#TODO remettre
#TODO à virer ? COPY raspberrypi.yadoms.cmake $YADOMS_DEPS/raspberrypi.cmake
COPY entrypoint_docker.sh /entrypoint_docker.sh
