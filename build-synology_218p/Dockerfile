FROM debian:stretch
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42

ENV YADOMS_BUILD_BRANCH develop
ENV MAKE_PACKAGE false
ENV YADOMS_BUILD_TOOLS_PATH /yadoms-build-tools
ENV YADOMS_DEPS_PATH /yadoms-deps/synology

#############################################################
## Install all needed packages
#############################################################

RUN echo "deb http://deb.debian.org/debian/ stretch main contrib non-free" | tee -a /etc/apt/sources.list \
&&  echo "deb http://security.debian.org/ stretch/updates main contrib non-free" | tee -a /etc/apt/sources.list \
&& echo "deb http://deb.debian.org/debian/ stretch-updates main contrib non-free" | tee -a /etc/apt/sources.list \
&& echo "deb http://deb.debian.org/debian stretch-backports main contrib non-free" | tee -a /etc/apt/sources.list
 
RUN apt-get update \
	&& apt-get dist-upgrade -q -y \
	&& apt-get install -q -y build-essential gawk gfortran texinfo bison libncurses-dev nano ncdu \
	g++ libbz2-dev python-dev python3-dev wget build-essential libssl-dev \
	libopencv-gpu-dev autoconf automake libtool curl make g++ unzip \
	libpcre3 libpcre3-dev libreadline-dev libpq5 \
	postgresql-server-dev-all git rpm zip gcc gcc-doc libc6-dev

#############################################################
## Install toolchain
#############################################################

/download

RUN wget 'https://sourceforge.net/projects/dsgpl/files/Tool%20Chain/DSM%206.2.2%20Tool%20Chains/Intel%20x86%20Linux%204.4.59%20%28Apollolake%29/apollolake-gcc493_glibc220_linaro_x86_64-GPL.txz' \
 && tar xf apollolake-gcc493_glibc220_linaro_x86_64-GPL.txz \
 && mv x86_64-pc-linux-gnu /opt/x86_64-pc-linux-gnu \
 && rm -f apollolake-gcc493_glibc220_linaro_x86_64-GPL.txz

ENV PATH /opt/x86_64-pc-linux-gnu/bin:$PATH
ENV LD_LIBRARY_PATH /opt/x86_64-pc-linux-gnu/lib/gcc/x86_64-pc-linux-gnu/4.9.3:$LD_LIBRARY_PATH

#############################################################
## Build yadoms dependencies
#############################################################

RUN mkdir -p $YADOMS_BUILD_TOOLS_PATH
RUN mkdir -p $YADOMS_DEPS_PATH

# CMake
ARG cmake_version=3.17.3
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose https://github.com/Kitware/CMake/releases/download/v$cmake_version/cmake-$cmake_version.tar.gz  > /dev/null\
	&& tar xzf cmake-$cmake_version.tar.gz && cd cmake-$cmake_version  > /dev/null\
	&& ./bootstrap > /dev/null && make > /dev/null && make install > /dev/null\
	&& cd .. && rm -Rf cmake-$cmake_version && rm $YADOMS_DEPS_PATH/cmake-$cmake_version.tar.gz

# Check GCC version
RUN x86_64-pc-linux-gnu-gcc --version

# Boost
ARG boost_version=1_73_0
ARG boost_version_dot=1.73.0
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose https://dl.bintray.com/boostorg/release/$boost_version_dot/source/boost_$boost_version.tar.bz2  > /dev/null\
	&& tar xjf boost_$boost_version.tar.bz2 && cd boost_$boost_version  > /dev/null\
	&& echo "using gcc : arm : x86_64-pc-linux-gnu-g++ ;" > /root/user-config.jam \
	&& ./bootstrap.sh > /dev/null\
	&& ./b2 --with-atomic --with-locale --with-chrono --with-date_time --with-filesystem --with-regex --with-thread --with-system link=static runtime-link=static --no-samples --no-tests toolset=gcc-arm cxxflags=-fPIC  > /dev/null\
	&& rm -Rf bin.v2 \
	&& rm -Rf doc \
	&& rm -Rf libs \
	&& rm -Rf tools \
	&& cd .. && rm $YADOMS_DEPS_PATH/boost_$boost_version.tar.bz2
	

# OpenSSL
ARG openssl_version=1.1.1g
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose https://www.openssl.org/source/openssl-$openssl_version.tar.gz  > /dev/null\
	&& tar xzf openssl-$openssl_version.tar.gz && cd openssl-$openssl_version  > /dev/null\
	&& ./Configure linux-generic32 --prefix=$YADOMS_DEPS_PATH/openssl --cross-compile-prefix=x86_64-pc-linux-gnu-  > /dev/null\
	&& make CC="x86_64-pc-linux-gnu-gcc" AR="x86_64-pc-linux-gnu-ar" RANLIB="x86_64-pc-linux-gnu-ranlib"  > /dev/null\
	&& make install  > /dev/null\
	&& cd .. && rm -Rf openssl-$openssl_version && rm $YADOMS_DEPS_PATH/openssl-$openssl_version.tar.gz
	

# Poco
ARG poco_version=1.9.4
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose http://pocoproject.org/releases/poco-$poco_version/poco-$poco_version-all.tar.gz  > /dev/null\
	&& tar xzf poco-$poco_version-all.tar.gz && cd poco-$poco_version-all  > /dev/null\
	&& echo 'TOOL = x86_64-pc-linux-gnu' > build/config/RaspberryPI \
	&& cat build/config/ARM-Linux >> build/config/RaspberryPI \
	&& echo 'STATICOPT_CC = -fPIC' >> build/config/RaspberryPI \
	&& echo 'STATICOPT_CXX = -fPIC' >> build/config/RaspberryPI \
	&& ./configure --static --config=RaspberryPI --no-samples --no-tests --omit=CppUnit,CppUnit/WinTestRunner,Data,Data/SQLite,Data/ODBCData/MySQL,MongoDB,PageCompiler,PageCompiler/File2Page --include-path=$YADOMS_DEPS_PATH/openssl/include --library-path=$YADOMS_DEPS_PATH/openssl/lib  > /dev/null\
	&& make  > /dev/null\
	&& cd .. \
	&& find . -name obj -type d -print0 | xargs -0 rm -rf  > /dev/null\
	&& rm $YADOMS_DEPS_PATH/poco-$poco_version-all.tar.gz


# Protobuf (Host)
ARG protobuf_version=3.12.3
RUN wget --no-check-certificate --no-verbose https://github.com/google/protobuf/releases/download/v$protobuf_version/protobuf-cpp-$protobuf_version.tar.gz  > /dev/null\
	&& tar xzf protobuf-cpp-$protobuf_version.tar.gz && rm protobuf-cpp-$protobuf_version.tar.gz > /dev/null\
        && cp -R protobuf-$protobuf_version $YADOMS_BUILD_TOOLS_PATH/protobuf-$protobuf_version-host > /dev/null \
	&& cd $YADOMS_BUILD_TOOLS_PATH/protobuf-$protobuf_version-host \
	&& mkdir build \
	&& cd build \
	&& cmake -Dprotobuf_BUILD_TESTS=OFF ../cmake  > /dev/null\
	&& cmake -Dprotobuf_BUILD_TESTS=OFF --build .  > /dev/null\
	&& make install  > /dev/null\
	&& ldconfig  > /dev/null
# Protobuf (Pi)
RUN mv protobuf-$protobuf_version $YADOMS_DEPS_PATH/protobuf-$protobuf_version \
	&& cd $YADOMS_DEPS_PATH/protobuf-$protobuf_version \
	&& ./autogen.sh  > /dev/null\
	&& ./configure --enable-shared=no --host=arm-linux CC=x86_64-pc-linux-gnu-gcc CXX=x86_64-pc-linux-gnu-g++ AR=x86_64-pc-linux-gnu-ar STRIP=x86_64-pc-linux-gnu-strip RANLIB=x86_64-pc-linux-gnu-ranlib --prefix=$YADOMS_DEPS_PATH/protobuf --with-protoc=protoc --with-pic  > /dev/null\
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
	&& ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no ac_cv_have_long_long_format=yes CC=x86_64-pc-linux-gnu-gcc CXX=x86_64-pc-linux-gnu-g++ AR=x86_64-pc-linux-gnu-ar RANLIB=x86_64-pc-linux-gnu-ranlib ./configure --host=x86_64-pc-linux-gnu --target=x86_64-pc-linux-gnu --build=x86_64-linux-gnu --prefix=$YADOMS_DEPS_PATH/pythonpython$python2_version_maj$python2_version_min --disable-ipv6 --enable-shared\
	&& make HOSTPYTHON=$YADOMS_BUILD_TOOLS_PATH/pythonhost$python2_version_maj$python2_version_min/python HOSTPGEN=$YADOMS_BUILD_TOOLS_PATH/pythonhost$python2_version_maj$python2_version_min/Parser/pgen BLDSHARED="x86_64-pc-linux-gnu-gcc -shared" CROSS-COMPILE=x86_64-pc-linux-gnu- CROSS_COMPILE_TARGET=yes HOSTARCH=arm-linux BUILDARCH=x86_64-pc-linux-gnu 

RUN apt-get install -y libffi-dev

# Python 3.7 (Host)
ARG python3_version_maj=3
ARG python3_version_min=8
ARG python3_version_patch=3
ARG python3_version=$python3_version_maj.$python3_version_min.$python3_version_patch
RUN wget --no-check-certificate --no-check-certificate --no-verbose https://www.python.org/ftp/python/$python3_version/Python-$python3_version.tgz  > /dev/null\
	&& tar xzf Python-$python3_version.tgz && rm Python-$python3_version.tgz  > /dev/null\
    && cp -R Python-$python3_version Python-$python3_version-host  > /dev/null\
	&& cd Python-$python3_version-host  > /dev/null\
	&& ./configure \
	&& make python Parser/pgen > /dev/null\
	&& make install  > /dev/null\
	&& mkdir -p $YADOMS_BUILD_TOOLS_PATH/pythonhost$python3_version_maj$python3_version_min \
	&& cp python $YADOMS_BUILD_TOOLS_PATH/pythonhost$python3_version_maj$python3_version_min/ \
	&& cp Parser/pgen $YADOMS_BUILD_TOOLS_PATH/pythonhost$python3_version_maj$python3_version_min/ \
	&& cd .. && rm -Rf Python-$python3_version-host
# Python 3.7 (Pi)
RUN mv Python-$python3_version $YADOMS_DEPS_PATH/Python-$python3_version  > /dev/null\
	&& cd $YADOMS_DEPS_PATH/Python-$python3_version  > /dev/null\
	&& CC=x86_64-pc-linux-gnu-gcc CXX=x86_64-pc-linux-gnu-g++ AR=x86_64-pc-linux-gnu-ar RANLIB=x86_64-pc-linux-gnu-ranlib ./configure --host=x86_64-pc-linux-gnu --target=x86_64-pc-linux-gnu --build=x86_64-linux-gnu --prefix=$YADOMS_DEPS_PATH/python37 --disable-ipv6 ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no ac_cv_have_long_long_format=yes --enable-shared  --without-pymalloc  > /dev/null\
	&& make HOSTPYTHON=$YADOMS_BUILD_TOOLS_PATH/pythonhost$python3_version_maj$python3_version_min/python HOSTPGEN=$YADOMS_BUILD_TOOLS_PATH/pythonhost$python3_version_maj$python3_version_min/Parser/pgen BLDSHARED="x86_64-pc-linux-gnu-gcc -shared" CROSS-COMPILE=x86_64-pc-linux-gnu- CROSS_COMPILE_TARGET=yes HOSTARCH=arm-linux BUILDARCH=x86_64-pc-linux-gnu  > /dev/null



# PostgreSQL
ARG postgresql_version=9.6.2
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose https://ftp.postgresql.org/pub/source/v$postgresql_version/postgresql-$postgresql_version.tar.bz2  > /dev/null\
	&& tar xjf postgresql-$postgresql_version.tar.bz2 && rm postgresql-$postgresql_version.tar.bz2  > /dev/null\
	&& cd postgresql-$postgresql_version  > /dev/null\
	&& CC=x86_64-pc-linux-gnu-gcc CXX=x86_64-pc-linux-gnu-g++ AR=x86_64-pc-linux-gnu-ar RANLIB=x86_64-pc-linux-gnu-ranlib ./configure --host=arm-linux --build=x86_64-pc-linux-gnu --without-readline --without-zlib --disable-spinlocks  > /dev/null\
	&& cd src/interfaces/libpq \
	&& make  > /dev/null\
	&& cd ../../../.. && rm -Rf postgresql-$postgresql_version/doc


COPY synology218p.cmake /
ARG gammu_version=1.41.0
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose https://dl.cihar.com/gammu/releases/gammu-$gammu_version.tar.bz2  > /dev/null\
	&& tar xjf gammu-$gammu_version.tar.bz2  > /dev/null\
	&& cd gammu-$gammu_version \
	&& mkdir rpicc \
	&& cd rpicc \
	&& cmake -DCC_RPI_GCC=x86_64-pc-linux-gnu-gcc -DCC_RPI_GXX=x86_64-pc-linux-gnu-g++ -DBUILD_SHARED_LIBS=OFF -DCMAKE_TOOLCHAIN_FILE=/synology218p.cmake -DCMAKE_STAGING_PREFIX=$YADOMS_DEPS_PATH/gammu ..  > /dev/null\
	&& make  > /dev/null\
	&& make install  > /dev/null\
	&& cd ../.. && rm -Rf gammu-1.40.*

# Opencv
ARG opencv_version=4.3.0
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://github.com/opencv/opencv/archive/$opencv_version.zip  > /dev/null\
	&& unzip $opencv_version.zip  > /dev/null\
	&& cd opencv-$opencv_version \
	&& mkdir build \
	&& cd build \
	&& cmake -DWITH_EIGEN:BOOL="0" -DWITH_IMGCODEC_HDR:BOOL="0" -DBUILD_opencv_ts:BOOL="0" -DBUILD_opencv_video:BOOL="0" -DWITH_TIFF:BOOL="0" -DBUILD_PACKAGE:BOOL="0" -DBUILD_opencv_features2d:BOOL="0" -DBUILD_ITT:BOOL="0" -Dthunder:BOOL="0" -Dlzw:BOOL="0" -DCV_TRACE:BOOL="0" -DWITH_MSMF:BOOL="0" -DWITH_FFMPEG:BOOL="0" -DWITH_IMGCODEC_PXM:BOOL="0" -DWITH_MSMF_DXVA:BOOL="0" -DCPACK_SOURCE_ZIP:BOOL="0" -Dpackbits:BOOL="0" -DBUILD_opencv_apps:BOOL="0" -DBUILD_PROTOBUF:BOOL="0" -DBUILD_opencv_objdetect:BOOL="0" -DBUILD_IPP_IW:BOOL="0" -DBUILD_opencv_videoio:BOOL="0" -DBUILD_PERF_TESTS:BOOL="0" -Dmdi:BOOL="0" -DWITH_1394:BOOL="0" -DINSTALL_PDB:BOOL="0" -DWITH_OPENCL:BOOL="0" -DM_LIBRARY:FILEPATH="M_LIBRARY-NOTFOUND" -DUSE_WIN32_FILEIO:BOOL="1" -DCPACK_SOURCE_7Z:BOOL="0" -DBUILD_opencv_stitching:BOOL="0" -Dccitt:BOOL="0" -DVIDEOIO_ENABLE_STRICT_PLUGIN_CHECK:BOOL="0" -DWITH_IPP:BOOL="0" -DBUILD_opencv_dnn:BOOL="0" -DWITH_ITT:BOOL="0" -DCPACK_BINARY_NSIS:BOOL="0" -DBUILD_opencv_photo:BOOL="0" -DBUILD_opencv_calib3d:BOOL="0" -DWITH_QUIRC:BOOL="0" -DWITH_WEBP:BOOL="0" -DBUILD_opencv_python_bindings_generator:BOOL="0" -DWITH_PROTOBUF:BOOL="0" -DBUILD_JASPER:BOOL="1" -DWITH_OPENCLAMDBLAS:BOOL="0" -DBUILD_JAVA:BOOL="0" -DWITH_VTK:BOOL="0" -DBUILD_opencv_java_bindings_generator:BOOL="0" -DBUILD_opencv_highgui:BOOL="0" -DWITH_ARITH_DEC:BOOL="0" -DWITH_IMGCODEC_SUNRASTER:BOOL="0" -DWITH_ADE:BOOL="0" -DBUILD_OPENEXR:BOOL="0" -DWITH_OPENEXR:BOOL="0" -DWITH_OPENCLAMDFFT:BOOL="0" -DVIDEOIO_ENABLE_PLUGINS:BOOL="0" -DWITH_DSHOW:BOOL="0" -DOPENCV_DNN_OPENCL:BOOL="0" -DWITH_LAPACK:BOOL="0" -DWITH_IMGCODEC_PFM:BOOL="0" -Dlogluv:BOOL="0" -DINSTALL_PDB_COMPONENT_EXCLUDE_FROM_ALL:BOOL="0" -DBUILD_opencv_ml:BOOL="0" -DOPENCV_ENABLE_MEMALIGN:BOOL="0" -DBUILD_opencv_python_tests:BOOL="0" -DCV_ENABLE_INTRINSICS:BOOL="0" -DOPENCL_FOUND:BOOL="0" -DWITH_OPENCL_D3D11_NV:BOOL="0" -Dnext:BOOL="0" -DBUILD_opencv_gapi:BOOL="0" -DBUILD_opencv_flann:BOOL="0" -DBUILD_TESTS:BOOL="0" -DWITH_DIRECTX:BOOL="0" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$YADOMS_DEPS_PATH/opencv .. >/dev/null \
	&& make  > /dev/null\
	&& make install  > /dev/null\
	&& cmake -DWITH_EIGEN:BOOL="0" -DWITH_IMGCODEC_HDR:BOOL="0" -DBUILD_opencv_ts:BOOL="0" -DBUILD_opencv_video:BOOL="0" -DWITH_TIFF:BOOL="0" -DBUILD_PACKAGE:BOOL="0" -DBUILD_opencv_features2d:BOOL="0" -DBUILD_ITT:BOOL="0" -Dthunder:BOOL="0" -Dlzw:BOOL="0" -DCV_TRACE:BOOL="0" -DWITH_MSMF:BOOL="0" -DWITH_FFMPEG:BOOL="0" -DWITH_IMGCODEC_PXM:BOOL="0" -DWITH_MSMF_DXVA:BOOL="0" -DCPACK_SOURCE_ZIP:BOOL="0" -Dpackbits:BOOL="0" -DBUILD_opencv_apps:BOOL="0" -DBUILD_PROTOBUF:BOOL="0" -DBUILD_opencv_objdetect:BOOL="0" -DBUILD_IPP_IW:BOOL="0" -DBUILD_opencv_videoio:BOOL="0" -DBUILD_PERF_TESTS:BOOL="0" -Dmdi:BOOL="0" -DWITH_1394:BOOL="0" -DINSTALL_PDB:BOOL="0" -DWITH_OPENCL:BOOL="0" -DM_LIBRARY:FILEPATH="M_LIBRARY-NOTFOUND" -DUSE_WIN32_FILEIO:BOOL="1" -DCPACK_SOURCE_7Z:BOOL="0" -DBUILD_opencv_stitching:BOOL="0" -Dccitt:BOOL="0" -DVIDEOIO_ENABLE_STRICT_PLUGIN_CHECK:BOOL="0" -DWITH_IPP:BOOL="0" -DBUILD_opencv_dnn:BOOL="0" -DWITH_ITT:BOOL="0" -DCPACK_BINARY_NSIS:BOOL="0" -DBUILD_opencv_photo:BOOL="0" -DBUILD_opencv_calib3d:BOOL="0" -DWITH_QUIRC:BOOL="0" -DWITH_WEBP:BOOL="0" -DBUILD_opencv_python_bindings_generator:BOOL="0" -DWITH_PROTOBUF:BOOL="0" -DBUILD_JASPER:BOOL="1" -DWITH_OPENCLAMDBLAS:BOOL="0" -DBUILD_JAVA:BOOL="0" -DWITH_VTK:BOOL="0" -DBUILD_opencv_java_bindings_generator:BOOL="0" -DBUILD_opencv_highgui:BOOL="0" -DWITH_ARITH_DEC:BOOL="0" -DWITH_IMGCODEC_SUNRASTER:BOOL="0" -DWITH_ADE:BOOL="0" -DBUILD_OPENEXR:BOOL="0" -DWITH_OPENEXR:BOOL="0" -DWITH_OPENCLAMDFFT:BOOL="0" -DVIDEOIO_ENABLE_PLUGINS:BOOL="0" -DWITH_DSHOW:BOOL="0" -DOPENCV_DNN_OPENCL:BOOL="0" -DWITH_LAPACK:BOOL="0" -DWITH_IMGCODEC_PFM:BOOL="0" -Dlogluv:BOOL="0" -DINSTALL_PDB_COMPONENT_EXCLUDE_FROM_ALL:BOOL="0" -DBUILD_opencv_ml:BOOL="0" -DOPENCV_ENABLE_MEMALIGN:BOOL="0" -DBUILD_opencv_python_tests:BOOL="0" -DCV_ENABLE_INTRINSICS:BOOL="0" -DOPENCL_FOUND:BOOL="0" -DWITH_OPENCL_D3D11_NV:BOOL="0" -Dnext:BOOL="0" -DBUILD_opencv_gapi:BOOL="0" -DBUILD_opencv_flann:BOOL="0" -DBUILD_TESTS:BOOL="0" -DWITH_DIRECTX:BOOL="0" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$YADOMS_DEPS_PATH/opencv .. >/dev/null \
	&& make  > /dev/null\
	&& make install  > /dev/null\	
	&& cd ../.. && rm -Rf opencv-$opencv_version* && rm -f $opencv_version.zip
	
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
	&& echo 'set(Python2_EXECUTABLE "'$YADOMS_DEPS_PATH'/python'$python2_version_maj$python2_version_min'/bin/python'$python2_version_maj'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python2_LIBRARIES "'$YADOMS_DEPS_PATH'/python'$python2_version_maj$python2_version_min'/lib/libpython'$python2_version_maj'.'$python2_version_min'.so")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python2_INCLUDE_DIRS "'$YADOMS_DEPS_PATH'/python'$python2_version_maj$python2_version_min'/include/python'$python2_version_maj'.'$python2_version_min'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_ManualSetup ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_EXECUTABLE "'$YADOMS_DEPS_PATH'/python'$python3_version_maj$python3_version_min'/bin/python'$python3_version_maj'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_LIBRARIES "'$YADOMS_DEPS_PATH'/python'$python3_version_maj$python3_version_min'/lib/libpython'$python3_version_maj'.'$python3_version_min'.so")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_INCLUDE_DIRS "'$YADOMS_DEPS_PATH'/python'$python3_version_maj$python3_version_min'/include/python'$python3_version_maj'.'$python3_version_min'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PostgreSQL_ROOT ' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "'$YADOMS_DEPS_PATH'/postgresql-'$postgresql_version'/src/interfaces/libpq"' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "'$YADOMS_DEPS_PATH'/postgresql-'$postgresql_version'/src/include")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(GAMMU_ROOT "'$YADOMS_DEPS_PATH'/gammu")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(SWIG_ROOT "'$YADOMS_DEPS_PATH'/swig-'$swig_version'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(OPENCV_ROOT "'$YADOMS_DEPS_PATH'/opencv")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'SET(COTIRE_USE ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'SET(COTIRE_USE_UNITY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(CC_RPI_ROOT "/opt/x86_64-pc-linux-gnu")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt

#copy entrypoint at root
COPY entrypoint.sh /

#ensure entrypoint is executable (force flags update, because file flags may change if a commit is made under Windows)
RUN chmod +x /entrypoint.sh


