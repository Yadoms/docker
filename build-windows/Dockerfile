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

COPY toolchain-win32.cmake ${YADOMS_DEPS}/toolchain-win32.cmake

#############################################################
## Install all needed packages
#############################################################
RUN apt-get update
RUN apt-get install -q -y --no-install-recommends \
   g++ libbz2-dev wget build-essential cmake ninja-build \
   mingw-w64 mingw-w64-tools gcc-mingw-w64 g++-mingw-w64 \
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
RUN echo "using gcc : mingw : i686-w64-mingw32-g++ : <rc>i686-w64-mingw32-windres ;" > /tmp/user-config.jam
RUN ./bootstrap.sh
RUN ./b2 -j$(nproc) \
   toolset=gcc-mingw \
   target-os=windows \
   abi=ms \
   binary-format=pe \
   architecture=x86 \
   --user-config=/tmp/user-config.jam \
   address-model=32 \
   variant=release \
   threading=multi link=static runtime-link=static \
   --with-atomic --with-chrono --with-date_time --with-filesystem --with-locale --with-process --with-regex --with-system --with-test --with-thread \
   --no-samples --no-tests \
   --prefix=${YADOMS_DEPS}/boost \
   install
WORKDIR ${WORK_DIR}
RUN rm -Rf boost_$boost_version \
   && rm boost_$boost_version.tar.bz2


#############################################################
## OpenSSL
#############################################################
ARG openssl_version=3.6.0
WORKDIR ${WORK_DIR}
RUN wget --no-check-certificate --no-verbose https://github.com/openssl/openssl/releases/download/openssl-${openssl_version}/openssl-${openssl_version}.tar.gz
RUN tar xzf openssl-${openssl_version}.tar.gz
WORKDIR ${WORK_DIR}/openssl-${openssl_version}
RUN ./Configure \
   mingw \
   no-shared \
   no-module \
   no-tests \
   --cross-compile-prefix=i686-w64-mingw32- \
   -D_WIN32_WINNT=0x0601 \
   --prefix=${YADOMS_DEPS}/openssl
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

# Some workarounds on Poco 1.14.2
RUN sed -i 's/#include <Windows.h>/#include <windows.h>/' \
    Foundation/include/Poco/FileStreamRWLock_WIN32.h
RUN sed -i '/#include "Poco\/UnWindows.h"/a #include <limits>' \
   Foundation/src/SharedMemory_WIN32.cpp
RUN sed -i '/#include <sql.h>/a #include <sqlext.h>' \
   Data/ODBC/src/Binder.cpp
RUN sed -i '/#include "Poco\/Data\/ODBC\/Utility.h"/a #include <sqlext.h>' \
   Data/ODBC/src/ODBCMetaColumn.cpp

   ### TODO J'en suis là

   ### Issue Poco en cours de rédaction (enfin pour l'instant ça marche pas)
#    I'm trying to build Poco 1.14.2 from Linux (Debian-12) for Windows.

# I encounter some issues :

# - in `Foundation/src/SharedMemory_WIN32.cpp`, `std::numeric_limits` is used but `<limits>`is not included.
# - in `Data/ODBC/src/Binder.cpp`, `SQL_GUID` is used but `<sqlext.h>` is not included
# - in `Data/ODBC/src/ODBCMetaColumn.cpp`, `SQL_GUID` is used but `<sqlext.h>` is not included




RUN cmake \
   -G Ninja \
   -S . \
   -B build \
   -DCMAKE_TOOLCHAIN_FILE=${YADOMS_DEPS}/toolchain-win32.cmake \
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
   --config Release \
   -j$(nproc)
RUN cmake \
   --install build \
   --config Release
WORKDIR ${WORK_DIR}
RUN rm -Rf poco-${poco_version}-all/ \
   && rm poco-${poco_version}-all.tar.gz


#############################################################
## Protobuf
#############################################################
# Protobuf compiler (Host)
ARG protobuf_version=3.15.8
WORKDIR ${WORK_DIR}
RUN wget --no-verbose https://github.com/google/protobuf/releases/download/v${protobuf_version}/protobuf-cpp-${protobuf_version}.tar.gz \
   && tar xzf protobuf-cpp-${protobuf_version}.tar.gz
RUN cp -R protobuf-${protobuf_version} protobuf-${protobuf_version}-host
WORKDIR ${WORK_DIR}/protobuf-${protobuf_version}-host
RUN cmake -S cmake \
   -B build \
   -DCMAKE_BUILD_TYPE=Release \
   -DBUILD_SHARED_LIBS=OFF \
   -Dprotobuf_DISABLE_RTTI=ON \
   -Dprotobuf_BUILD_TESTS=OFF
RUN cmake --build build --target protoc -j$(nproc)
RUN cmake --build build --target install/strip

# Protobuf library (Win32)	
WORKDIR ${WORK_DIR}/protobuf-${protobuf_version}
RUN cmake \
   -G Ninja \
   -S cmake \
   -B build \
   -DCMAKE_TOOLCHAIN_FILE=${YADOMS_DEPS}/toolchain-win32.cmake \
   -DBUILD_SHARED_LIBS=OFF \
   -Dprotobuf_DISABLE_RTTI=ON \
   -Dprotobuf_BUILD_TESTS=OFF \
   -Dprotobuf_WITH_ZLIB=OFF \
   -Dprotobuf_BUILD_PROTOC=OFF \
   -DProtobuf_PROTOC_EXECUTABLE=/usr/local/bin/protoc \
   -DCMAKE_BUILD_TYPE=Release \
   -DCMAKE_INSTALL_PREFIX=${YADOMS_DEPS}/protobuf
RUN cmake --build build -j$(nproc) --target install


#TODO merger les workflow github