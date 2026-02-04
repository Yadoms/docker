FROM debian:stable-slim
LABEL org.opencontainers.image.authors="sgallou"
ENV DEBIAN_FRONTEND=noninteractive

ENV YADOMS_BUILD_BRANCH=develop
ENV MAKE_PACKAGE=false
ENV YADOMS_DEPS=/yadoms-deps
ENV WORK_DIR=/tmp/yadoms_workdir

# Log current distribution version
RUN cat /etc/*-release

RUN mkdir -p {$YADOMS_DEPS}

#############################################################
## Install all needed packages
#############################################################
RUN apt-get update
RUN apt-get install -q -y --no-install-recommends \
    g++ libbz2-dev wget build-essential \
    autoconf automake libtool curl make g++ unzip \
    libpcre2-32-0 libpcre2-dev git rpm zip ca-certificates \
    libreadline-dev libffi-dev build-essential \
    libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev \
    python3-numpy libtbbmalloc2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev \
    usbutils swig libssl-dev libudev-dev
RUN rm -rf /var/lib/apt/lists/*


#############################################################
## Update CMake
#############################################################
ARG cmake_version=3.31.10
WORKDIR ${WORK_DIR}
RUN wget --no-check-certificate --no-verbose https://github.com/Kitware/CMake/releases/download/v$cmake_version/cmake-$cmake_version.tar.gz
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
RUN wget --no-check-certificate --no-verbose https://archives.boost.io/release/$boost_version_dot/source/boost_$boost_version.tar.bz2
RUN tar xjf boost_$boost_version.tar.bz2
WORKDIR ${WORK_DIR}/boost_$boost_version
RUN ./bootstrap.sh
RUN	./b2 -j$(nproc) \
    threading=multi link=static runtime-link=static \
    cxxflags=-fPIC \
    --with-atomic --with-chrono --with-date_time --with-filesystem --with-locale --with-process --with-regex --with-system --with-test --with-thread \
    --no-samples --no-tests \
    --prefix=${YADOMS_DEPS}/boost \
    install
WORKDIR ${WORK_DIR}
RUN	rm -Rf boost_$boost_version \
    && rm boost_$boost_version.tar.bz2


#############################################################
## OpenSSL
#############################################################
ARG openssl_version=3.6.0
WORKDIR ${WORK_DIR}
RUN wget --no-check-certificate --no-verbose https://github.com/openssl/openssl/releases/download/openssl-${openssl_version}/openssl-${openssl_version}.tar.gz
RUN tar xzf openssl-${openssl_version}.tar.gz
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
ARG poco_version=1.14.2
WORKDIR ${WORK_DIR}
RUN wget --no-check-certificate --no-verbose http://pocoproject.org/releases/poco-${poco_version}/poco-${poco_version}-all.tar.gz
RUN tar xzf poco-${poco_version}-all.tar.gz
WORKDIR ${WORK_DIR}/poco-${poco_version}-all/
RUN cmake \
    -S . \
    -B build \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
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
    -DOPENSSL_ROOT_DIR=${YADOMS_DEPS}/openssl \
    -DCMAKE_INSTALL_PREFIX=${YADOMS_DEPS}/poco
RUN cmake \
    --build build \
    --target all \
    -j$(nproc)
RUN cmake \
    --install build --strip
WORKDIR ${WORK_DIR}
RUN rm -Rf poco-${poco_version}-all/ \
    && rm poco-${poco_version}-all.tar.gz


#############################################################
## Protobuf
#############################################################
ARG protobuf_version=3.15.8
WORKDIR ${WORK_DIR}
RUN	wget --no-verbose https://github.com/google/protobuf/releases/download/v$protobuf_version/protobuf-cpp-$protobuf_version.tar.gz
RUN tar xzf protobuf-cpp-$protobuf_version.tar.gz
WORKDIR ${WORK_DIR}/protobuf-$protobuf_version
RUN cmake -S cmake \
    -B build \
    -DBUILD_SHARED_LIBS=OFF \
    -Dprotobuf_DISABLE_RTTI=ON \
    -Dprotobuf_BUILD_TESTS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_INSTALL_PREFIX=${YADOMS_DEPS}/protobuf
RUN cmake --build build -j$(nproc)
RUN cmake --install build
WORKDIR ${WORK_DIR}
RUN rm -Rf protobuf-$protobuf_version \
    && rm ${WORK_DIR}/protobuf-cpp-$protobuf_version.tar.gz
RUN	rm -f ${WORK_DIR}/protobuf/lib/libprotoc.* \
    && rm -f ${WORK_DIR}/protobuf/lib/libprotobuf-lite.*


#############################################################
## Python
#############################################################
# Version must match python version installed on host
ARG python3_version=3.11.2
WORKDIR ${WORK_DIR}
RUN wget --no-check-certificate --no-verbose https://www.python.org/ftp/python/${python3_version}/Python-${python3_version}.tar.xz
RUN tar xf Python-${python3_version}.tar.xz
WORKDIR ${WORK_DIR}/Python-${python3_version}
RUN ./configure \
    --enable-shared \
    --without-pymalloc \
    --prefix=${YADOMS_DEPS}/python-lib
RUN make -j$(nproc)
RUN make install
WORKDIR ${WORK_DIR}
RUN rm -Rf Python-${python3_version} \
    && rm Python-${python3_version}.tar.xz


#############################################################
## Gammu
#############################################################
ARG gammu_version=1.41.0
WORKDIR ${WORK_DIR}
RUN wget --no-verbose https://dl.cihar.com/gammu/releases/gammu-$gammu_version.tar.bz2
RUN tar xjf gammu-$gammu_version.tar.bz2
WORKDIR ${WORK_DIR}/gammu-$gammu_version
RUN cmake \
    -S . \
    -B build \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DBUILD_SHARED_LIBS=OFF \
    -DWITH_Glib=OFF \
    -DCMAKE_INSTALL_PREFIX=${YADOMS_DEPS_PATH}/gammu
RUN cmake --build build -j$(nproc)
RUN cmake --install build --strip
WORKDIR ${WORK_DIR}
RUN rm -Rf gammu-$gammu_version*


#############################################################
## OpenCV
#############################################################
ARG opencv_version=4.5.2
WORKDIR ${WORK_DIR}
RUN wget --no-verbose --no-check-certificate https://github.com/opencv/opencv/archive/${opencv_version}.zip
RUN unzip ${opencv_version}.zip
WORKDIR ${WORK_DIR}/opencv-${opencv_version}
RUN mkdir build
WORKDIR ${WORK_DIR}/opencv-${opencv_version}/build
RUN cmake \
    -DBUILD_SHARED_LIBS=OFF \
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
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${YADOMS_DEPS}/opencv \
    ..
RUN cmake --build . -j$(nproc)
RUN cmake --install . --strip
WORKDIR ${WORK_DIR}
RUN rm -Rf opencv-${opencv_version}* \
    && rm -f ${opencv_version}.zip


#############################################################
## Copy entry point
#############################################################
COPY entrypoint_docker.sh /
COPY entrypoint_docker_tests.sh /
WORKDIR /
RUN chmod +x /entrypoint_docker.sh
RUN chmod +x /entrypoint_docker_tests.sh
ENTRYPOINT ["/entrypoint_docker.sh"]
