FROM debian:stable-slim
LABEL org.opencontainers.image.authors="sgallou"
ENV DEBIAN_FRONTEND=noninteractive

ENV YADOMS_BUILD_BRANCH=develop
ENV MAKE_PACKAGE=false
ENV YADOMS_DEPS=/yadoms-deps
 #TODO à utiliser partout
ENV WORK_DIR=/tmp/yadoms_workdir

# Log current distribution version
RUN cat /etc/*-release

RUN mkdir -p {$YADOMS_DEPS}

#############################################################
## Install all needed packages
#############################################################
RUN apt-get update
RUN apt-get install -q -y --no-install-recommends \
	g++ libbz2-dev python3-dev wget build-essential libssl-dev \
	autoconf automake libtool curl make g++ unzip \
	libpcre2-32-0 libpcre2-dev git rpm zip ca-certificates \
	libreadline-dev libffi-dev build-essential \
	libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev \
	python3-numpy libtbbmalloc2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev \
	libudev-dev usbutils
#TODO remettre RUN rm -rf /var/lib/apt/lists/*

RUN echo "check_certificate = off" >> ~/.wgetrc


#############################################################
## Update CMake
#############################################################
ARG cmake_version=3.31.10
WORKDIR ${WORK_DIR}
RUN wget --no-verbose https://github.com/Kitware/CMake/releases/download/v$cmake_version/cmake-$cmake_version.tar.gz
RUN tar xzf cmake-$cmake_version.tar.gz
WORKDIR ${WORK_DIR}/cmake-${cmake_version}
RUN	./bootstrap
RUN make -j$(nproc)
RUN make install
WORKDIR ${WORK_DIR}
RUN rm -Rf cmake-$cmake_version \
    rm cmake-$cmake_version.tar.gz


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
RUN ./bootstrap.sh  > /dev/null
RUN	./b2 -j$(nproc) \
	threading=multi link=static runtime-link=static \
	cxxflags=-fPIC \
	--with-atomic --with-chrono --with-date_time --with-filesystem --with-locale --with-process --with-regex --with-system --with-test --with-thread \
	--no-samples --no-tests \
	--prefix=${YADOMS_DEPS}/boost install  > /dev/null
WORKDIR ${WORK_DIR}
RUN	rm -Rf boost_$boost_version \
	&& rm boost_$boost_version.tar.bz2  > /dev/null


#############################################################
## OpenSSL
#############################################################
#TODO tester version plus récente (voire installée par apt-get)
ARG openssl_version=1.1.1k
WORKDIR ${WORK_DIR}
RUN wget --no-check-certificate --no-verbose https://www.openssl.org/source/openssl-1.1.1k.tar.gz \
    && tar xzf openssl-${openssl_version}.tar.gz
WORKDIR ${WORK_DIR}/openssl-${openssl_version}
RUN ./Configure linux-x86_64 -fPIC --prefix=${YADOMS_DEPS}/openssl
RUN make -j$(nproc)
RUN make install
WORKDIR ${WORK_DIR}
RUN rm -Rf openssl-${openssl_version} \
	&& rm openssl-${openssl_version}.tar.gz

	
#############################################################
## Poco
#############################################################
#TODO à intégrer plus haut
RUN apt-get install -q -y --no-install-recommends libpoco-dev
# ARG poco_version=1.13.3
# WORKDIR ${WORK_DIR}
# RUN wget --no-check-certificate --no-verbose http://pocoproject.org/releases/poco-${poco_version}/poco-${poco_version}-all.tar.gz \
# 	&& tar xzf poco-${poco_version}-all.tar.gz
# WORKDIR ${WORK_DIR}/poco-${poco_version}-all/
# RUN cmake \
#     -S . \
#     -B build \
#     -DCMAKE_BUILD_TYPE=Release \
#     -DBUILD_SHARED_LIBS=OFF \
#     -DENABLE_JSON=OFF \
#     -DENABLE_MONGODB=OFF \
#     -DENABLE_DATA_SQLITE=OFF \
#     -DENABLE_REDIS=OFF \
#     -DENABLE_PROMETHEUS=OFF \
#     -DENABLE_PDF=OFF \
#     -DENABLE_SEVENZIP=OFF \
#     -DENABLE_CPPPARSER=OFF \
#     -DENABLE_POCODOC=OFF \
#     -DENABLE_PAGECOMPILER=OFF \
#     -DENABLE_PAGECOMPILER_FILE2PAGE=OFF \
#     -DENABLE_ACTIVERECORD=OFF \
#     -DENABLE_ACTIVERECORD_COMPILER=OFF \
#     -DOPENSSL_ROOT_DIR=$YADOMS_DEPS/openssl \
#     -DCMAKE_INSTALL_PREFIX=${YADOMS_DEPS}/poco
# RUN cmake \
#     --build build \
#     --target all \
#     -j$(nproc)
# RUN cmake \
#     --install build --strip
# WORKDIR ${WORK_DIR}
# RUN rm -Rf poco-${poco_version}-all/ \
# 	&& rm poco-${poco_version}-all.tar.gz


#############################################################
## Protobuf
#############################################################
RUN apt-get install -q -y --no-install-recommends protobuf-compiler libprotobuf-dev
# ARG protobuf_version=3.15.8
# RUN cd $YADOMS_DEPS_PATH \
# 	&& wget --no-verbose https://github.com/google/protobuf/releases/download/v$protobuf_version/protobuf-cpp-$protobuf_version.tar.gz \
# 	&& tar xzf protobuf-cpp-$protobuf_version.tar.gz && cd protobuf-$protobuf_version \
# 	&& ./autogen.sh \
# 	&& ./configure --enable-shared=no --prefix=$YADOMS_DEPS_PATH/protobuf --with-pic \
# 	&& make \
# 	&& make install \
# 	&& ldconfig \
# 	&& cd .. && rm -Rf protobuf-$protobuf_version && rm $YADOMS_DEPS_PATH/protobuf-cpp-$protobuf_version.tar.gz \
# 	&& rm -f $YADOMS_DEPS_PATH/protobuf/lib/libprotoc.* && rm -f $YADOMS_DEPS_PATH/protobuf/lib/libprotobuf-lite.*


# Swig
#TODO méange
RUN apt-get install -q -y --no-install-recommends swig
# ARG swig_version=4.0.2
# RUN cd $YADOMS_DEPS_PATH \
# 	&& wget --no-verbose http://prdownloads.sourceforge.net/swig/swig-$swig_version.tar.gz \
# 	&& tar xzf swig-$swig_version.tar.gz \
# 	&& cd swig-$swig_version \
# 	&& ./configure \
# 	&& make \
# 	&& make install \
# 	&& cd .. \
# 	&& rm -f swig-$swig_version/Source/Modules/*.o \
# 	&& rm -Rf swig-$swig_version/Examples \
# 	&& rm -Rf swig-$swig_version/Docs \
# 	&& rm $YADOMS_DEPS_PATH/swig-$swig_version.tar.gz

# Python $python3_version
#TODO
# ARG python3_version_maj=3
# ARG python3_version_min=9
# ARG python3_version_patch=4
# ARG python3_version=$python3_version_maj.$python3_version_min.$python3_version_patch
# RUN wget --no-verbose https://www.python.org/ftp/python/$python3_version/Python-$python3_version.tgz  > /dev/null\
# 	&& tar xzf Python-$python3_version.tgz && rm Python-$python3_version.tgz  > /dev/null\
# 	&& cd Python-$python3_version \
# 	&& ./configure --enable-shared --without-pymalloc --prefix=$YADOMS_DEPS_PATH/python$python3_version_maj$python3_version_min > /dev/null\
# 	&& make > /dev/null\
# 	&& make install  > /dev/null\
# 	&& cd ..\
# 	&& rm -Rf Python-$python3_version && rm -Rf $YADOMS_DEPS_PATH/python$python3_version_maj$python3_version_min/lib/python$python3_version_maj.$python3_version_min

# Gammu
RUN apt-get install -q -y --no-install-recommends gammu libgammu-dev
# ARG gammu_version=1.41.0
# RUN cd $YADOMS_DEPS_PATH \
# 	&& wget --no-verbose https://dl.cihar.com/gammu/releases/gammu-$gammu_version.tar.bz2  > /dev/null\
# 	&& tar xjf gammu-$gammu_version.tar.bz2  > /dev/null\
# 	&& cd gammu-$gammu_version \
# 	&& mkdir rpicc \
# 	&& cd rpicc \
# 	&& cmake -DBUILD_SHARED_LIBS=OFF -DWITH_Glib=OFF -DCMAKE_STAGING_PREFIX=$YADOMS_DEPS_PATH/gammu ..  > /dev/null\
# 	&& make  > /dev/null\
# 	&& make install  > /dev/null\
# 	&& cd ../.. && rm -Rf gammu-$gammu_version*

# Opencv
RUN apt-get install -q -y --no-install-recommends libopencv-dev
# ARG opencv_version=4.5.2
# RUN cd $YADOMS_DEPS_PATH \
# 	&& wget --no-verbose https://github.com/opencv/opencv/archive/$opencv_version.zip  > /dev/null\
# 	&& unzip $opencv_version.zip  > /dev/null\
# 	&& cd opencv-$opencv_version \
# 	&& mkdir build \
# 	&& cd build \
# 	&& cmake -DWITH_EIGEN:BOOL="0" -DWITH_IMGCODEC_HDR:BOOL="0" -DBUILD_opencv_ts:BOOL="0" -DBUILD_opencv_video:BOOL="0" -DWITH_TIFF:BOOL="0" -DBUILD_PACKAGE:BOOL="0" -DBUILD_opencv_features2d:BOOL="0" -DBUILD_ITT:BOOL="0" -Dthunder:BOOL="0" -Dlzw:BOOL="0" -DCV_TRACE:BOOL="0" -DWITH_MSMF:BOOL="0" -DWITH_FFMPEG:BOOL="0" -DWITH_IMGCODEC_PXM:BOOL="0" -DWITH_MSMF_DXVA:BOOL="0" -DCPACK_SOURCE_ZIP:BOOL="0" -Dpackbits:BOOL="0" -DBUILD_opencv_apps:BOOL="0" -DBUILD_PROTOBUF:BOOL="0" -DBUILD_opencv_objdetect:BOOL="0" -DBUILD_IPP_IW:BOOL="0" -DBUILD_opencv_videoio:BOOL="0" -DBUILD_PERF_TESTS:BOOL="0" -Dmdi:BOOL="0" -DWITH_1394:BOOL="0" -DINSTALL_PDB:BOOL="0" -DWITH_OPENCL:BOOL="0" -DM_LIBRARY:FILEPATH="M_LIBRARY-NOTFOUND" -DUSE_WIN32_FILEIO:BOOL="1" -DCPACK_SOURCE_7Z:BOOL="0" -DBUILD_opencv_stitching:BOOL="0" -Dccitt:BOOL="0" -DVIDEOIO_ENABLE_STRICT_PLUGIN_CHECK:BOOL="0" -DWITH_IPP:BOOL="0" -DBUILD_opencv_dnn:BOOL="0" -DWITH_ITT:BOOL="0" -DCPACK_BINARY_NSIS:BOOL="0" -DBUILD_opencv_photo:BOOL="0" -DBUILD_opencv_calib3d:BOOL="0" -DWITH_QUIRC:BOOL="0" -DWITH_WEBP:BOOL="0" -DBUILD_opencv_python_bindings_generator:BOOL="0" -DWITH_PROTOBUF:BOOL="0" -DBUILD_JASPER:BOOL="1" -DWITH_OPENCLAMDBLAS:BOOL="0" -DBUILD_JAVA:BOOL="0" -DWITH_VTK:BOOL="0" -DBUILD_opencv_java_bindings_generator:BOOL="0" -DBUILD_opencv_highgui:BOOL="0" -DWITH_ARITH_DEC:BOOL="0" -DWITH_IMGCODEC_SUNRASTER:BOOL="0" -DWITH_ADE:BOOL="0" -DBUILD_OPENEXR:BOOL="0" -DWITH_OPENEXR:BOOL="0" -DWITH_OPENCLAMDFFT:BOOL="0" -DVIDEOIO_ENABLE_PLUGINS:BOOL="0" -DWITH_DSHOW:BOOL="0" -DOPENCV_DNN_OPENCL:BOOL="0" -DWITH_LAPACK:BOOL="0" -DWITH_IMGCODEC_PFM:BOOL="0" -Dlogluv:BOOL="0" -DINSTALL_PDB_COMPONENT_EXCLUDE_FROM_ALL:BOOL="0" -DBUILD_opencv_ml:BOOL="0" -DOPENCV_ENABLE_MEMALIGN:BOOL="0" -DBUILD_opencv_python_tests:BOOL="0" -DCV_ENABLE_INTRINSICS:BOOL="0" -DOPENCL_FOUND:BOOL="0" -DWITH_OPENCL_D3D11_NV:BOOL="0" -Dnext:BOOL="0" -DBUILD_opencv_gapi:BOOL="0" -DBUILD_opencv_flann:BOOL="0" -DBUILD_TESTS:BOOL="0" -DWITH_DIRECTX:BOOL="0" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$YADOMS_DEPS_PATH/opencv .. >/dev/null \
# 	&& make  > /dev/null\
# 	&& make install  > /dev/null\
# 	&& cmake -DWITH_EIGEN:BOOL="0" -DWITH_IMGCODEC_HDR:BOOL="0" -DBUILD_opencv_ts:BOOL="0" -DBUILD_opencv_video:BOOL="0" -DWITH_TIFF:BOOL="0" -DBUILD_PACKAGE:BOOL="0" -DBUILD_opencv_features2d:BOOL="0" -DBUILD_ITT:BOOL="0" -Dthunder:BOOL="0" -Dlzw:BOOL="0" -DCV_TRACE:BOOL="0" -DWITH_MSMF:BOOL="0" -DWITH_FFMPEG:BOOL="0" -DWITH_IMGCODEC_PXM:BOOL="0" -DWITH_MSMF_DXVA:BOOL="0" -DCPACK_SOURCE_ZIP:BOOL="0" -Dpackbits:BOOL="0" -DBUILD_opencv_apps:BOOL="0" -DBUILD_PROTOBUF:BOOL="0" -DBUILD_opencv_objdetect:BOOL="0" -DBUILD_IPP_IW:BOOL="0" -DBUILD_opencv_videoio:BOOL="0" -DBUILD_PERF_TESTS:BOOL="0" -Dmdi:BOOL="0" -DWITH_1394:BOOL="0" -DINSTALL_PDB:BOOL="0" -DWITH_OPENCL:BOOL="0" -DM_LIBRARY:FILEPATH="M_LIBRARY-NOTFOUND" -DUSE_WIN32_FILEIO:BOOL="1" -DCPACK_SOURCE_7Z:BOOL="0" -DBUILD_opencv_stitching:BOOL="0" -Dccitt:BOOL="0" -DVIDEOIO_ENABLE_STRICT_PLUGIN_CHECK:BOOL="0" -DWITH_IPP:BOOL="0" -DBUILD_opencv_dnn:BOOL="0" -DWITH_ITT:BOOL="0" -DCPACK_BINARY_NSIS:BOOL="0" -DBUILD_opencv_photo:BOOL="0" -DBUILD_opencv_calib3d:BOOL="0" -DWITH_QUIRC:BOOL="0" -DWITH_WEBP:BOOL="0" -DBUILD_opencv_python_bindings_generator:BOOL="0" -DWITH_PROTOBUF:BOOL="0" -DBUILD_JASPER:BOOL="1" -DWITH_OPENCLAMDBLAS:BOOL="0" -DBUILD_JAVA:BOOL="0" -DWITH_VTK:BOOL="0" -DBUILD_opencv_java_bindings_generator:BOOL="0" -DBUILD_opencv_highgui:BOOL="0" -DWITH_ARITH_DEC:BOOL="0" -DWITH_IMGCODEC_SUNRASTER:BOOL="0" -DWITH_ADE:BOOL="0" -DBUILD_OPENEXR:BOOL="0" -DWITH_OPENEXR:BOOL="0" -DWITH_OPENCLAMDFFT:BOOL="0" -DVIDEOIO_ENABLE_PLUGINS:BOOL="0" -DWITH_DSHOW:BOOL="0" -DOPENCV_DNN_OPENCL:BOOL="0" -DWITH_LAPACK:BOOL="0" -DWITH_IMGCODEC_PFM:BOOL="0" -Dlogluv:BOOL="0" -DINSTALL_PDB_COMPONENT_EXCLUDE_FROM_ALL:BOOL="0" -DBUILD_opencv_ml:BOOL="0" -DOPENCV_ENABLE_MEMALIGN:BOOL="0" -DBUILD_opencv_python_tests:BOOL="0" -DCV_ENABLE_INTRINSICS:BOOL="0" -DOPENCL_FOUND:BOOL="0" -DWITH_OPENCL_D3D11_NV:BOOL="0" -Dnext:BOOL="0" -DBUILD_opencv_gapi:BOOL="0" -DBUILD_opencv_flann:BOOL="0" -DBUILD_TESTS:BOOL="0" -DWITH_DIRECTX:BOOL="0" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$YADOMS_DEPS_PATH/opencv .. >/dev/null \
# 	&& make  > /dev/null\
# 	&& make install  > /dev/null\
# 	&& cd ../.. && rm -Rf opencv-$opencv_version* && rm -f $opencv_version.zip

##TODO j'en suis là
# Yadoms configuration file
# RUN echo 'Configuring Yadoms CMakeListsUserConfig.txt' \
# 	&& echo 'set(BOOST_ROOT "'$YADOMS_DEPS_PATH'/boost_'$boost_version'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'set(POCO_ROOT "'$YADOMS_DEPS_PATH'/poco-'$poco_version-all'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'set(PROTOBUF_ROOT "'$YADOMS_DEPS_PATH'/protobuf")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'set(PROTOBUF_PROTOC_EXECUTABLE "'$YADOMS_DEPS_PATH'/protobuf/bin/protoc")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'set(PROTOBUF_INSTALLED_TO_CUSTOM_DIRECTORY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'set(OPENSSL_ROOT "'$YADOMS_DEPS_PATH'/openssl")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'set(DEBUG_WITH_GCC OFF)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'set(PYTHON_USE_PKGCONFIG OFF)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'set(PYTHON_USE_SOURCES ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'set(Python2_ManualSetup ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'set(Python2_EXECUTABLE "'$YADOMS_DEPS_PATH'/python'$python2_version_maj$python2_version_min'/bin/python'$python2_version_maj'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'set(Python2_LIBRARIES "'$YADOMS_DEPS_PATH'/python'$python2_version_maj$python2_version_min'/lib/libpython'$python2_version_maj'.'$python2_version_min'.so")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'set(Python2_INCLUDE_DIRS "'$YADOMS_DEPS_PATH'/python'$python2_version_maj$python2_version_min'/include/python'$python2_version_maj'.'$python2_version_min'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'set(Python3_ManualSetup ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'set(Python3_EXECUTABLE "'$YADOMS_DEPS_PATH'/python'$python3_version_maj$python3_version_min'/bin/python'$python3_version_maj'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'set(Python3_LIBRARIES "'$YADOMS_DEPS_PATH'/python'$python3_version_maj$python3_version_min'/lib/libpython'$python3_version_maj'.'$python3_version_min'.so")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'set(Python3_INCLUDE_DIRS "'$YADOMS_DEPS_PATH'/python'$python3_version_maj$python3_version_min'/include/python'$python3_version_maj'.'$python3_version_min'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'set(PostgreSQL_ROOT ' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo '       "'$YADOMS_DEPS_PATH'/postgresql-'$postgresql_version'/src/interfaces/libpq"' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo '       "'$YADOMS_DEPS_PATH'/postgresql-'$postgresql_version'/src/include")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'set(GAMMU_ROOT "'$YADOMS_DEPS_PATH'/gammu")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'set(SWIG_ROOT "'$YADOMS_DEPS_PATH'/swig-'$swig_version'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'set(OPENCV_ROOT "'$YADOMS_DEPS_PATH'/opencv")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'SET(COTIRE_USE ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
# 	&& echo 'SET(COTIRE_USE_UNITY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt


#############################################################
## Copy entry point
#############################################################
COPY entrypoint_docker.sh /
WORKDIR /
RUN chmod +x /entrypoint_docker.sh
ENTRYPOINT ["/entrypoint_docker.sh"]
