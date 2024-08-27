FROM debian:stable
LABEL org.opencontainers.image.authors="jano42"
ENV DEBIAN_FRONTEND=noninteractive

ENV YADOMS_BUILD_BRANCH=develop
ENV MAKE_PACKAGE=false
ENV YADOMS_BUILD_TOOLS_PATH=/yadoms-build-tools
ENV YADOMS_DEPS_PATH=/yadoms-deps/raspberry


#############################################################
## Build yadoms dependencies
#############################################################

RUN mkdir -p $YADOMS_BUILD_TOOLS_PATH
RUN mkdir -p $YADOMS_DEPS_PATH


#############################################################
## Install all needed packages
#############################################################


RUN echo "deb http://archive.debian.org/debian/ buster main contrib non-free" | tee -a /etc/apt/sources.list \
&&  echo "deb http://security.debian.org/ buster/updates main contrib non-free" | tee -a /etc/apt/sources.list \
&& echo "deb http://archive.debian.org/debian/ buster-updates main contrib non-free" | tee -a /etc/apt/sources.list \
&& echo "deb http://archive.debian.org/debian buster-backports main contrib non-free" | tee -a /etc/apt/sources.list
 
RUN apt-get update \
	&& apt-get dist-upgrade -q -y \
	&& apt-get install -q -y gawk gfortran texinfo bison libncurses-dev nano ncdu \
	g++ libbz2-dev wget build-essential \
	autoconf automake libtool curl make g++ unzip \
	libpcre3 libpcre3-dev libreadline-dev libpq5 \
	postgresql-server-dev-all git rpm zip gcc gcc-doc libc6-dev \
	libffi-dev libssl-dev zlib1g-dev
 
########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################
####
####    #############################################################
####    ## Install toolchain with GCC v10 (raspbian buster only...)
####    #############################################################
####    
####    # Cross toolchain for raspberryPI
####    # based on https://github.com/abhiTronix/raspberry-pi-cross-compilers
####    # -> comptible with all RapsberryPI
####    # -> GCC 10.2
####    # -> X86_64 COMPILER
####    # https://github.com/abhiTronix/raspberry-pi-cross-compiler
####    RUN wget 'https://master.dl.sourceforge.net/project/raspberry-pi-cross-compilers/Raspberry%20Pi%20GCC%20Cross-Compiler%20Toolchains/Buster/GCC%2010.2.0/Raspberry%20Pi%203A%2B%2C%203B%2B%2C%204/cross-gcc-10.2.0-pi_3%2B.tar.gz' \
####     && tar xf cross-gcc-10.2.0-pi_3+.tar.gz \
####     && mv cross-pi-gcc-10.2.0-2 /opt/cross-pi-gcc-10.2.0-2 \
####     && rm -f cross-gcc-10.2.0-pi_3+.tar.gz
####    ENV PATH /opt/cross-pi-gcc-10.2.0-2/bin:$PATH
####    ENV LD_LIBRARY_PATH /opt/cross-pi-gcc-10.2.0-2/lib:$LD_LIBRARY_PATH
####    
########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################



#############################################################
## Install toolchain (generic 4.9.3)
#############################################################
# Installing arm-linux-gnueabihf cross toolchain
RUN mkdir -p $YADOMS_BUILD_TOOLS_PATH \
	&& cd $YADOMS_BUILD_TOOLS_PATH \
	&& git clone --depth=1 https://github.com/raspberrypi/tools.git
ENV PATH=$PATH:$YADOMS_BUILD_TOOLS_PATH/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/bin

# CMake
ARG cmake_version=3.30.2
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose https://github.com/Kitware/CMake/releases/download/v$cmake_version/cmake-$cmake_version.tar.gz  > /dev/null\
	&& tar xzf cmake-$cmake_version.tar.gz && cd cmake-$cmake_version  > /dev/null\
	&& ./bootstrap > /dev/null && make > /dev/null && make install > /dev/null\
	&& cd .. && rm -Rf cmake-$cmake_version && rm $YADOMS_DEPS_PATH/cmake-$cmake_version.tar.gz

# Check GCC version
RUN arm-linux-gnueabihf-gcc --version


# OpenSSL (both cross compile and for host)
ARG openssl_version=1.1.1k
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose https://www.openssl.org/source/openssl-$openssl_version.tar.gz  > /dev/null\
	&& tar xzf openssl-$openssl_version.tar.gz && cd openssl-$openssl_version  > /dev/null\
	&& ./Configure linux-generic32 --prefix=$YADOMS_DEPS_PATH/openssl --cross-compile-prefix=$YADOMS_BUILD_TOOLS_PATH/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/bin/arm-linux-gnueabihf- > /dev/null\
	&& make CC="arm-linux-gnueabihf-gcc" AR="arm-linux-gnueabihf-ar" RANLIB="arm-linux-gnueabihf-ranlib"  > /dev/null\
	&& make install  > /dev/null\
	&& cd .. && rm -Rf openssl-$openssl_version \
	&& tar xzf openssl-$openssl_version.tar.gz && cd openssl-$openssl_version  > /dev/null\
	&& ./config && make && make install\
	&& cd .. && rm -Rf openssl-$openssl_version && rm $YADOMS_DEPS_PATH/openssl-$openssl_version.tar.gz
	

# Boost
ARG boost_version_major=1
ARG boost_version_minor=83
ARG boost_version_patch=0
ARG boost_underscore=_
ARG boost_version=$boost_version_major$boost_underscore$boost_version_minor$boost_underscore$boost_version_patch
ARG boost_version_dot=$boost_version_major.$boost_version_minor.$boost_version_patch
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose https://boostorg.jfrog.io/artifactory/main/release/$boost_version_dot/source/boost_$boost_version.tar.bz2  > /dev/null\
	&& tar xjf boost_$boost_version.tar.bz2 && cd boost_$boost_version  > /dev/null\
	&& echo "using gcc : arm : arm-linux-gnueabihf-g++ ;" > /root/user-config.jam \
	&& ./bootstrap.sh > /dev/null\
	&& ./b2 --with-atomic --with-chrono --with-date_time --with-filesystem --with-locale --with-regex --with-test --with-thread --with-system --with-json link=static runtime-link=static --no-samples --no-tests toolset=gcc-arm cxxflags=-fPIC  > /dev/null\
	&& rm -Rf bin.v2 \
	&& rm -Rf doc \
	&& rm -Rf libs \
	&& rm -Rf tools \
	&& cd .. && rm $YADOMS_DEPS_PATH/boost_$boost_version.tar.bz2
	
# Poco
ARG poco_version=1.13.3
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose http://pocoproject.org/releases/poco-$poco_version/poco-$poco_version-all.tar.gz  > /dev/null\
	&& tar xzf poco-$poco_version-all.tar.gz && cd poco-$poco_version-all  > /dev/null\
	&& echo 'TOOL = arm-linux-gnueabihf' > build/config/RaspberryPI \
	&& cat build/config/ARM-Linux >> build/config/RaspberryPI \
	&& echo 'STATICOPT_CC = -fPIC' >> build/config/RaspberryPI \
	&& echo 'STATICOPT_CXX = -fPIC' >> build/config/RaspberryPI \
	&& ./configure --static --config=RaspberryPI --no-samples --no-tests --omit=CppUnit,CppUnit/WinTestRunner,Data,Data/SQLite,Data/ODBCData/MySQL,MongoDB,PageCompiler,PageCompiler/File2Page --include-path=$YADOMS_DEPS_PATH/openssl/include --library-path=$YADOMS_DEPS_PATH/openssl/lib  > /dev/null\
	&& make  > /dev/null\
	&& cd .. \
	&& find . -name obj -type d -print0 | xargs -0 rm -rf  > /dev/null\
	&& rm $YADOMS_DEPS_PATH/poco-$poco_version-all.tar.gz


# Protobuf (Host)
ARG protobuf_version=3.15.8
RUN wget --no-verbose https://github.com/google/protobuf/releases/download/v$protobuf_version/protobuf-cpp-$protobuf_version.tar.gz \
	&& tar xzf protobuf-cpp-$protobuf_version.tar.gz && rm protobuf-cpp-$protobuf_version.tar.gz > /dev/null\
        && cp -R protobuf-$protobuf_version $YADOMS_BUILD_TOOLS_PATH/protobuf-$protobuf_version-host > /dev/null \
	&& cd $YADOMS_BUILD_TOOLS_PATH/protobuf-$protobuf_version-host \
	&& mkdir build \
	&& cd build \
	&& cmake -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release ../cmake && make && make install \
	&& ldconfig  > /dev/null
# Protobuf (Pi)
RUN mv protobuf-$protobuf_version $YADOMS_DEPS_PATH/protobuf-$protobuf_version \
	&& cd $YADOMS_DEPS_PATH/protobuf-$protobuf_version \
	&& ./autogen.sh  > /dev/null\
	&& ./configure --enable-shared=no --host=arm-linux CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ AR=arm-linux-gnueabihf-ar STRIP=arm-linux-gnueabihf-strip RANLIB=arm-linux-gnueabihf-ranlib --prefix=$YADOMS_DEPS_PATH/protobuf --with-protoc=protoc --with-pic  > /dev/null\
	&& make  > /dev/null\
	&& make install  > /dev/null\
    && cd .. && rm -Rf $YADOMS_DEPS_PATH/protobuf-protobuf_version


# Swig
ARG swig_version=4.0.2
RUN cd $YADOMS_DEPS_PATH \
	&& echo "http://prdownloads.sourceforge.net/swig/swig-$swig_version.tar.gz" \
	&& wget --no-check-certificate --no-verbose http://prdownloads.sourceforge.net/swig/swig-$swig_version.tar.gz  > /dev/null\
	&& tar xzf swig-$swig_version.tar.gz  > /dev/null\
	&& cd $YADOMS_DEPS_PATH/swig-$swig_version  > /dev/null\
	&& ./configure  > /dev/null\
	&& make  > /dev/null\
	&& make install  > /dev/null\
	&& cd .. \
	&& rm -f swig-$swig_version/Source/Modules/*.o \
	&& rm -Rf swig-$swig_version/Examples \
	&& rm -Rf swig-$swig_version/Docs \
	&& rm $YADOMS_DEPS_PATH/swig-$swig_version.tar.gz


# Python 2.7 (Host)
ARG python2_version_maj=2
ARG python2_version_min=7
ARG python2_version_patch=18
ARG python2_version=$python2_version_maj.$python2_version_min.$python2_version_patch
RUN wget --no-check-certificate --no-check-certificate --no-verbose https://www.python.org/ftp/python/$python2_version/Python-$python2_version.tgz  > /dev/null\
	&& tar xzf Python-$python2_version.tgz && rm Python-$python2_version.tgz  > /dev/null\
    && cp -R Python-$python2_version Python-$python2_version-host  > /dev/null\
	&& cd Python-$python2_version-host  > /dev/null\
	&& ./configure  > /dev/null\
	&& make python Parser/pgen > /dev/null\
	&& make install  > /dev/null\
	&& mkdir -p $YADOMS_BUILD_TOOLS_PATH/pythonhost$python2_version_maj$python2_version_min \
	&& cp python $YADOMS_BUILD_TOOLS_PATH/pythonhost$python2_version_maj$python2_version_min/ \
	&& cp Parser/pgen $YADOMS_BUILD_TOOLS_PATH/pythonhost$python2_version_maj$python2_version_min/ \
	&& cd .. && rm -Rf Python-$python2_version-host
# Python 2.7 (Pi)
RUN mv Python-$python2_version $YADOMS_DEPS_PATH/Python-$python2_version  > /dev/null\
	&& cd $YADOMS_DEPS_PATH/Python-$python2_version  > /dev/null\
	&& ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no ac_cv_have_long_long_format=yes CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ AR=arm-linux-gnueabihf-ar RANLIB=arm-linux-gnueabihf-ranlib ./configure --host=arm-linux-gnueabihf --target=arm-linux-gnueabihf --build=x86_64-linux-gnu --disable-ipv6 --enable-shared\
	&& make HOSTPYTHON=$YADOMS_BUILD_TOOLS_PATH/pythonhost/python HOSTPGEN=$YADOMS_BUILD_TOOLS_PATH/pythonhost/Parser/pgen BLDSHARED="arm-linux-gnueabihf-gcc -shared" CROSS-COMPILE=arm-linux-gnueabihf- CROSS_COMPILE_TARGET=yes HOSTARCH=arm-linux BUILDARCH=arm-linux-gnueabihf 
	
# Python 3.7 (Host)
ARG python3_version_maj=3
ARG python3_version_min=9
ARG python3_version_patch=4
ARG python3_version=$python3_version_maj.$python3_version_min.$python3_version_patch
RUN wget --no-check-certificate --no-check-certificate --no-verbose https://www.python.org/ftp/python/$python3_version/Python-$python3_version.tgz\
	&& tar xzf Python-$python3_version.tgz && rm Python-$python3_version.tgz\
    && cp -R Python-$python3_version Python-$python3_version-host\
	&& cd Python-$python3_version-host\
	&& ./configure \
	&& make python Parser/pgen\
	&& make install\
	&& mkdir -p $YADOMS_BUILD_TOOLS_PATH/pythonhost$python3_version_maj$python3_version_min \
	&& cp python $YADOMS_BUILD_TOOLS_PATH/pythonhost$python3_version_maj$python3_version_min/ \
	&& cd .. && rm -Rf Python-$python3_version-host

# Python 3.7 (Pi)
RUN mv Python-$python3_version $YADOMS_DEPS_PATH/Python-$python3_version\
	&& cd $YADOMS_DEPS_PATH/Python-$python3_version\
	&& CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ AR=arm-linux-gnueabihf-ar RANLIB=arm-linux-gnueabihf-ranlib ./configure --host=arm-linux-gnueabihf --target=arm-linux-gnueabihf --build=x86_64-linux-gnu --disable-ipv6 ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no ac_cv_have_long_long_format=yes --enable-shared  --without-pymalloc --with-openssl=$YADOMS_DEPS_PATH/openssl > /dev/null\
	&& make HOSTPYTHON=$YADOMS_BUILD_TOOLS_PATH/pythonhost$python3_version_maj$python3_version_min/python BLDSHARED="arm-linux-gnueabihf-gcc -shared" CROSS-COMPILE=arm-linux-gnueabihf- CROSS_COMPILE_TARGET=yes HOSTARCH=arm-linux BUILDARCH=arm-linux-gnueabihf  > /dev/null
	
# PostgreSQL
ARG postgresql_version=9.6.2
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose https://ftp.postgresql.org/pub/source/v$postgresql_version/postgresql-$postgresql_version.tar.bz2  > /dev/null\
	&& tar xjf postgresql-$postgresql_version.tar.bz2 && rm postgresql-$postgresql_version.tar.bz2  > /dev/null\
	&& cd postgresql-$postgresql_version  > /dev/null\
	&& CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ AR=arm-linux-gnueabihf-ar RANLIB=arm-linux-gnueabihf-ranlib ./configure --host=arm-linux --build=arm-linux-gnueabihf --without-readline --without-zlib --disable-spinlocks  > /dev/null\
	&& cd src/interfaces/libpq \
	&& make  > /dev/null\
	&& cd ../../../.. && rm -Rf postgresql-$postgresql_version/doc


COPY raspberrypi.gammu.cmake /raspberrypi.cmake
ARG gammu_version=1.41.0
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose https://dl.cihar.com/gammu/releases/gammu-$gammu_version.tar.bz2  > /dev/null\
	&& tar xjf gammu-$gammu_version.tar.bz2  > /dev/null\
	&& cd gammu-$gammu_version \
	&& mkdir rpicc \
	&& cd rpicc \
	&& cmake -DCC_RPI_GCC=arm-linux-gnueabihf-gcc -DCC_RPI_GXX=arm-linux-gnueabihf-g++ -DBUILD_SHARED_LIBS=OFF -DCMAKE_TOOLCHAIN_FILE=/raspberrypi.cmake -DCMAKE_STAGING_PREFIX=$YADOMS_DEPS_PATH/gammu ..  > /dev/null\
	&& make  > /dev/null\
	&& make install  > /dev/null\
	&& cd ../.. && rm -Rf gammu-1.40.*

# Opencv
ARG opencv_version=4.5.2
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://github.com/opencv/opencv/archive/$opencv_version.zip  > /dev/null\
	&& unzip $opencv_version.zip  > /dev/null\
	&& cd opencv-$opencv_version \
	&& mkdir build \
	&& cd build \
	&& cmake -DCC_RPI_GCC=arm-linux-gnueabihf-gcc -DCC_RPI_GXX=arm-linux-gnueabihf-g++ -DBUILD_SHARED_LIBS=OFF -DCMAKE_TOOLCHAIN_FILE=/raspberrypi.cmake -DWITH_EIGEN:BOOL="0" -DWITH_IMGCODEC_HDR:BOOL="0" -DBUILD_opencv_ts:BOOL="0" -DBUILD_opencv_video:BOOL="0" -DWITH_TIFF:BOOL="0" -DBUILD_PACKAGE:BOOL="0" -DBUILD_opencv_features2d:BOOL="0" -DBUILD_ITT:BOOL="0" -Dthunder:BOOL="0" -Dlzw:BOOL="0" -DCV_TRACE:BOOL="0" -DWITH_MSMF:BOOL="0" -DWITH_FFMPEG:BOOL="0" -DWITH_IMGCODEC_PXM:BOOL="0" -DWITH_MSMF_DXVA:BOOL="0" -DCPACK_SOURCE_ZIP:BOOL="0" -Dpackbits:BOOL="0" -DBUILD_opencv_apps:BOOL="0" -DBUILD_PROTOBUF:BOOL="0" -DBUILD_opencv_objdetect:BOOL="0" -DBUILD_IPP_IW:BOOL="0" -DBUILD_opencv_videoio:BOOL="0" -DBUILD_PERF_TESTS:BOOL="0" -Dmdi:BOOL="0" -DWITH_1394:BOOL="0" -DINSTALL_PDB:BOOL="0" -DWITH_OPENCL:BOOL="0" -DM_LIBRARY:FILEPATH="M_LIBRARY-NOTFOUND" -DUSE_WIN32_FILEIO:BOOL="1" -DCPACK_SOURCE_7Z:BOOL="0" -DBUILD_opencv_stitching:BOOL="0" -Dccitt:BOOL="0" -DVIDEOIO_ENABLE_STRICT_PLUGIN_CHECK:BOOL="0" -DWITH_IPP:BOOL="0" -DBUILD_opencv_dnn:BOOL="0" -DWITH_ITT:BOOL="0" -DCPACK_BINARY_NSIS:BOOL="0" -DBUILD_opencv_photo:BOOL="0" -DBUILD_opencv_calib3d:BOOL="0" -DWITH_QUIRC:BOOL="0" -DWITH_WEBP:BOOL="0" -DBUILD_opencv_python_bindings_generator:BOOL="0" -DWITH_PROTOBUF:BOOL="0" -DBUILD_JASPER:BOOL="1" -DWITH_OPENCLAMDBLAS:BOOL="0" -DBUILD_JAVA:BOOL="0" -DWITH_VTK:BOOL="0" -DBUILD_opencv_java_bindings_generator:BOOL="0" -DBUILD_opencv_highgui:BOOL="0" -DWITH_ARITH_DEC:BOOL="0" -DWITH_IMGCODEC_SUNRASTER:BOOL="0" -DWITH_ADE:BOOL="0" -DBUILD_OPENEXR:BOOL="0" -DWITH_OPENEXR:BOOL="0" -DWITH_OPENCLAMDFFT:BOOL="0" -DVIDEOIO_ENABLE_PLUGINS:BOOL="0" -DWITH_DSHOW:BOOL="0" -DOPENCV_DNN_OPENCL:BOOL="0" -DWITH_LAPACK:BOOL="0" -DWITH_IMGCODEC_PFM:BOOL="0" -Dlogluv:BOOL="0" -DINSTALL_PDB_COMPONENT_EXCLUDE_FROM_ALL:BOOL="0" -DBUILD_opencv_ml:BOOL="0" -DOPENCV_ENABLE_MEMALIGN:BOOL="0" -DBUILD_opencv_python_tests:BOOL="0" -DCV_ENABLE_INTRINSICS:BOOL="0" -DOPENCL_FOUND:BOOL="0" -DWITH_OPENCL_D3D11_NV:BOOL="0" -Dnext:BOOL="0" -DBUILD_opencv_gapi:BOOL="0" -DBUILD_opencv_flann:BOOL="0" -DBUILD_TESTS:BOOL="0" -DWITH_DIRECTX:BOOL="0" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$YADOMS_DEPS_PATH/opencv .. >/dev/null \
	&& make  > /dev/null\
	&& make install  > /dev/null\
	&& cmake -DCC_RPI_GCC=arm-linux-gnueabihf-gcc -DCC_RPI_GXX=arm-linux-gnueabihf-g++ -DBUILD_SHARED_LIBS=OFF -DCMAKE_TOOLCHAIN_FILE=/raspberrypi.cmake -DWITH_EIGEN:BOOL="0" -DWITH_IMGCODEC_HDR:BOOL="0" -DBUILD_opencv_ts:BOOL="0" -DBUILD_opencv_video:BOOL="0" -DWITH_TIFF:BOOL="0" -DBUILD_PACKAGE:BOOL="0" -DBUILD_opencv_features2d:BOOL="0" -DBUILD_ITT:BOOL="0" -Dthunder:BOOL="0" -Dlzw:BOOL="0" -DCV_TRACE:BOOL="0" -DWITH_MSMF:BOOL="0" -DWITH_FFMPEG:BOOL="0" -DWITH_IMGCODEC_PXM:BOOL="0" -DWITH_MSMF_DXVA:BOOL="0" -DCPACK_SOURCE_ZIP:BOOL="0" -Dpackbits:BOOL="0" -DBUILD_opencv_apps:BOOL="0" -DBUILD_PROTOBUF:BOOL="0" -DBUILD_opencv_objdetect:BOOL="0" -DBUILD_IPP_IW:BOOL="0" -DBUILD_opencv_videoio:BOOL="0" -DBUILD_PERF_TESTS:BOOL="0" -Dmdi:BOOL="0" -DWITH_1394:BOOL="0" -DINSTALL_PDB:BOOL="0" -DWITH_OPENCL:BOOL="0" -DM_LIBRARY:FILEPATH="M_LIBRARY-NOTFOUND" -DUSE_WIN32_FILEIO:BOOL="1" -DCPACK_SOURCE_7Z:BOOL="0" -DBUILD_opencv_stitching:BOOL="0" -Dccitt:BOOL="0" -DVIDEOIO_ENABLE_STRICT_PLUGIN_CHECK:BOOL="0" -DWITH_IPP:BOOL="0" -DBUILD_opencv_dnn:BOOL="0" -DWITH_ITT:BOOL="0" -DCPACK_BINARY_NSIS:BOOL="0" -DBUILD_opencv_photo:BOOL="0" -DBUILD_opencv_calib3d:BOOL="0" -DWITH_QUIRC:BOOL="0" -DWITH_WEBP:BOOL="0" -DBUILD_opencv_python_bindings_generator:BOOL="0" -DWITH_PROTOBUF:BOOL="0" -DBUILD_JASPER:BOOL="1" -DWITH_OPENCLAMDBLAS:BOOL="0" -DBUILD_JAVA:BOOL="0" -DWITH_VTK:BOOL="0" -DBUILD_opencv_java_bindings_generator:BOOL="0" -DBUILD_opencv_highgui:BOOL="0" -DWITH_ARITH_DEC:BOOL="0" -DWITH_IMGCODEC_SUNRASTER:BOOL="0" -DWITH_ADE:BOOL="0" -DBUILD_OPENEXR:BOOL="0" -DWITH_OPENEXR:BOOL="0" -DWITH_OPENCLAMDFFT:BOOL="0" -DVIDEOIO_ENABLE_PLUGINS:BOOL="0" -DWITH_DSHOW:BOOL="0" -DOPENCV_DNN_OPENCL:BOOL="0" -DWITH_LAPACK:BOOL="0" -DWITH_IMGCODEC_PFM:BOOL="0" -Dlogluv:BOOL="0" -DINSTALL_PDB_COMPONENT_EXCLUDE_FROM_ALL:BOOL="0" -DBUILD_opencv_ml:BOOL="0" -DOPENCV_ENABLE_MEMALIGN:BOOL="0" -DBUILD_opencv_python_tests:BOOL="0" -DCV_ENABLE_INTRINSICS:BOOL="0" -DOPENCL_FOUND:BOOL="0" -DWITH_OPENCL_D3D11_NV:BOOL="0" -Dnext:BOOL="0" -DBUILD_opencv_gapi:BOOL="0" -DBUILD_opencv_flann:BOOL="0" -DBUILD_TESTS:BOOL="0" -DWITH_DIRECTX:BOOL="0" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$YADOMS_DEPS_PATH/opencv .. >/dev/null \
	&& make  > /dev/null\
	&& make install  > /dev/null\
	&& cd ../.. && rm -Rf opencv-$opencv_version* && rm -f $opencv_version.zip

COPY libudev.tar.gz $YADOMS_DEPS_PATH
RUN cd $YADOMS_DEPS_PATH \
	&& tar xf libudev.tar.gz
	
	 

# Yadoms configuration file
RUN echo 'Configuring Yadoms CMakeListsUserConfig.txt' \
	&& echo 'set(BOOST_ROOT "'$YADOMS_DEPS_PATH'/boost_'$boost_version'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(POCO_ROOT "'$YADOMS_DEPS_PATH'/poco-'$poco_version'-all")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_ROOT "'$YADOMS_DEPS_PATH'/protobuf")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_PROTOC_EXECUTABLE "'`which protoc`'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_INSTALLED_TO_CUSTOM_DIRECTORY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(OPENSSL_ROOT "'$YADOMS_DEPS_PATH'/openssl")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(DEBUG_WITH_GCC OFF)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_USE_PKGCONFIG OFF)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_USE_SOURCES ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python2_ManualSetup ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python2_EXECUTABLE "/usr/local/bin/python'$python2_version_maj'.'$python2_version_min'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python2_LIBRARIES "'$YADOMS_DEPS_PATH'/Python-'$python2_version'/libpython'$python2_version_maj'.'$python2_version_min'.a")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python2_INCLUDE_DIRS "'$YADOMS_DEPS_PATH'/Python-'$python2_version'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_ManualSetup ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_EXECUTABLE "/usr/local/bin/python'$python3_version_maj'.'$python3_version_min'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_LIBRARIES "'$YADOMS_DEPS_PATH'/Python-'$python3_version'/libpython'$python3_version_maj'.'$python3_version_min'.a")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_INCLUDE_DIRS "'$YADOMS_DEPS_PATH'/Python-'$python3_version'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PostgreSQL_ROOT ' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "'$YADOMS_DEPS_PATH'/postgresql-'$postgresql_version'/src/interfaces/libpq"' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "'$YADOMS_DEPS_PATH'/postgresql-'$postgresql_version'/src/include")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(GAMMU_ROOT "'$YADOMS_DEPS_PATH'/gammu")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(SWIG_ROOT "'$YADOMS_DEPS_PATH'/swig-'$swig_version'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(OPENCV_ROOT "'$YADOMS_DEPS_PATH'/opencv")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(LIBUDEV_ROOT "'$YADOMS_DEPS_PATH'/libudev")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'SET(COTIRE_USE ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'SET(COTIRE_USE_UNITY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(CC_RPI_ROOT "'$YADOMS_BUILD_TOOLS_PATH'/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt

#For debug purpose only
RUN cat $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt

COPY raspberrypi.yadoms.cmake $YADOMS_DEPS_PATH/raspberrypi.cmake
COPY entrypoint_docker.sh /entrypoint_docker.sh
