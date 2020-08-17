FROM debian:stable
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42

#############################################################
## Setup env var && arguments
#############################################################


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


ENV YADOMS_BUILD_BRANCH develop
ENV MAKE_PACKAGE false
ENV YADOMS_BUILD_TOOLS_PATH /yadoms-build-tools
ENV YADOMS_DEPS_PATH /yadoms-deps/macos
ENV YADOMS_CCMACOS_TRIPLET x86_64-apple-darwin19
ENV YADOMS_CCMACOS_CONFTOOL $YADOMS_CCMACOS_TRIPLET-osxcross-conf

USER root

#############################################################
## Install all needed packages
#############################################################

RUN cp /dev/null /etc/apt/sources.list \
 && echo "deb http://deb.debian.org/debian/ buster main contrib non-free" | tee -a /etc/apt/sources.list \
 && echo "deb http://security.debian.org/ buster/updates main contrib non-free" | tee -a /etc/apt/sources.list \
 && echo "deb http://deb.debian.org/debian/ buster-updates main contrib non-free" | tee -a /etc/apt/sources.list \
 && echo "deb http://deb.debian.org/debian buster-backports main contrib non-free" | tee -a /etc/apt/sources.list
 
RUN apt-get update\
	&& apt-get install -y g++ libbz2-dev python-dev wget build-essential libssl-dev \
	autoconf automake libtool curl make g++ unzip \
	libpcre3 libpcre3-dev libreadline-dev libpq5 \
	postgresql-server-dev-all git rpm zip gcc gcc-doc libc6-dev \
	libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev \
	python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev \
	libudev-dev usbutils libffi-dev cmake apt-utils \
	&& apt-get purge -y postgresql* && apt autoremove -y
	&& apt-get clean
	
#############################################################
## Install toolchain
#############################################################
RUN git config --global http.sslVerify false \
    && cd /opt \
    && git clone --depth=1 https://github.com/tpoechtrager/osxcross.git \
	&& cd osxcross \
    && ./tools/get_dependencies.sh
	
COPY $sdk_file /
RUN cd /opt/osxcross \
	&& mv /$sdk_file tarballs/MacOSX${DARWIN_SDK_VERSION}.sdk.tar.xz \
    && UNATTENDED=1 PORTABLE=true SDK_VERSION="${DARWIN_SDK_VERSION}" OSX_VERSION_MIN="${DARWIN_OSX_VERSION_MIN}" ./build.sh \
    && rm -Rf /opt/osxcross/build

ENV PATH $PATH:/opt/osxcross/target/bin

RUN UNATTENDED=1 MACOSX_DEPLOYMENT_TARGET=${DARWIN_OSX_VERSION_MIN} WGETOPTS=--no-check-certificate osxcross-macports install -s -v libtool
RUN UNATTENDED=1 MACOSX_DEPLOYMENT_TARGET=${DARWIN_OSX_VERSION_MIN} WGETOPTS=--no-check-certificate osxcross-macports install -s -v openssl

#############################################################
## Build yadoms dependencies
#############################################################

RUN mkdir -p $YADOMS_BUILD_TOOLS_PATH
RUN mkdir -p $YADOMS_DEPS_PATH

# CMake
ARG cmake_version=3.18.1
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate https://github.com/Kitware/CMake/releases/download/v$cmake_version/cmake-$cmake_version.tar.gz \
	&& tar xzf cmake-$cmake_version.tar.gz && cd cmake-$cmake_version\
	&& ./bootstrap && make > /dev/null && make install\
	&& cd .. && rm -Rf cmake-$cmake_version && rm $YADOMS_DEPS_PATH/cmake-$cmake_version.tar.gz

# Setup osxcross environnement
RUN eval `$YADOMS_CCMACOS_TRIPLET-osxcross-conf` \
	&& export OSXCROSS_HOST="$YADOMS_CCMACOS_TRIPLET"

# Boost
ARG boost_version_major=1
ARG boost_version_minor=74
ARG boost_version_patch=0
ARG boost_underscore=_
ARG boost_version=$boost_version_major$boost_underscore$boost_version_minor$boost_underscore$boost_version_patch
ARG boost_version_dot=$boost_version_major.$boost_version_minor.$boost_version_patch
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose https://dl.bintray.com/boostorg/release/$boost_version_dot/source/boost_$boost_version.tar.bz2\
	&& tar xjf boost_$boost_version.tar.bz2 && cd boost_$boost_version  > /dev/null \
	&& echo "using clang : o64 : o64-clang++ : <archiver>$YADOMS_CCMACOS_TRIPLET-ar <ranlib>$YADOMS_CCMACOS_TRIPLET-ranlib ;" > ~/user-config.jam \
	&& ./bootstrap.sh\
	&& ./b2 --with-atomic --with-chrono --with-date_time --with-filesystem --with-regex --with-thread --with-system link=static runtime-link=static --no-samples --no-tests toolset=clang-o64 target-os=darwin cxxflags="-fPIC" visibility=global \
	&& rm -Rf bin.v2 \
	&& rm -Rf doc \
	&& rm -Rf libs \
	&& rm -Rf tools \
	&& cd .. && rm $YADOMS_DEPS_PATH/boost_$boost_version.tar.bz2
	
# Poco
ARG poco_version=1.9.4
COPY ./Darwin64-osxcross $YADOMS_DEPS_PATH/Darwin64-osxcross
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose http://pocoproject.org/releases/poco-$poco_version/poco-$poco_version-all.tar.gz\
	&& tar xzf poco-$poco_version-all.tar.gz && cd poco-$poco_version-all\
        && cp $YADOMS_DEPS_PATH/Darwin64-osxcross build/config/Darwin64-osxcross \
	&& OSXCROSS_MP_INC=1 ./configure --static --config=Darwin64-osxcross --no-samples --no-tests --omit=CppUnit,CppUnit/WinTestRunner,Data,Data/SQLite,Data/ODBCData/MySQL,MongoDB,PageCompiler,PageCompiler/File2Page\
	&& OSXCROSS_MP_INC=1 make\
	&& cd .. \
	&& find . -name obj -type d -print0 | xargs -0 rm -rf  > /dev/null\
	&& rm $YADOMS_DEPS_PATH/poco-$poco_version-all.tar.gz && rm -f $YADOMS_DEPS_PATH/Darwin64-osxcross



# Protobuf (Host)
ARG protobuf_version=3.13.0
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
# Protobuf (Darwin)
RUN mv protobuf-$protobuf_version $YADOMS_DEPS_PATH/protobuf-$protobuf_version \
	&& cd $YADOMS_DEPS_PATH/protobuf-$protobuf_version \
	&& ./autogen.sh  > /dev/null\
	&& ./configure --enable-shared=no --host=$YADOMS_CCMACOS_TRIPLET CC=$YADOMS_CCMACOS_TRIPLET-clang CXX=$YADOMS_CCMACOS_TRIPLET-clang++ AR=$YADOMS_CCMACOS_TRIPLET-ar STRIP=$YADOMS_CCMACOS_TRIPLET-strip RANLIB=$YADOMS_CCMACOS_TRIPLET-ranlib --prefix=$YADOMS_DEPS_PATH/protobuf --with-protoc=protoc --with-pic  > /dev/null\
	&& make  > /dev/null\
	&& make install  > /dev/null\
    && cd .. && rm -Rf $YADOMS_DEPS_PATH/protobuf-$protobuf_version \
	&& rm -f $YADOMS_DEPS_PATH/protobuf/lib/libprotoc.* && rm -f $YADOMS_DEPS_PATH/protobuf/lib/libprotobuf-lite.*

# Swig
ARG swig_version=4.0.2
RUN cd $YADOMS_DEPS_PATH \
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

# Gammu

#copy cross compile toolchain
ARG gammu_version=1.41.0
COPY gammu.cmake /
COPY gammu_osx.patch /

#build gammu
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose https://dl.cihar.com/gammu/releases/gammu-$gammu_version.tar.bz2  > /dev/null\
	&& tar xjf gammu-$gammu_version.tar.bz2  > /dev/null\
	&& cd gammu-$gammu_version \
	&& patch -p1 < /gammu_osx.patch \
	&& mkdir rpicc \
	&& cd rpicc \
	&& eval `$YADOMS_CCMACOS_CONFTOOL` \
	&& export OSXCROSS_HOST="$YADOMS_CCMACOS_TRIPLET" \	
	&& cmake -DCMAKE_C_COMPILER=$YADOMS_CCMACOS_TRIPLET-clang -DCMAKE_CXX_COMPILER=$YADOMS_CCMACOS_TRIPLET-clang++ -DICONV_LIBRARIES="/opt/osxcross/target/macports/pkgs/opt/local/lib/libiconv.a" -DBUILD_SHARED_LIBS=OFF -DCMAKE_TOOLCHAIN_FILE=/gammu.cmake -DWITH_Iconv=OFF -DCMAKE_STAGING_PREFIX=$YADOMS_DEPS_PATH/gammu ..  \
	&& make\
	&& make install  > /dev/null\
	&& cd ../.. && rm -Rf gammu-$gammu_version*


# Python 2.7 (Host)
ARG python2_version_maj=2
ARG python2_version_min=7
ARG python2_version_patch=18
ARG python2_version=$python2_version_maj.$python2_version_min.$python2_version_patch
RUN wget --no-check-certificate --no-verbose https://www.python.org/ftp/python/$python2_version/Python-$python2_version.tgz  > /dev/null\
	&& tar xzf Python-$python2_version.tgz && rm Python-$python2_version.tgz  > /dev/null\
        && cd Python-$python2_version  > /dev/null\
	&& ./configure  > /dev/null\
	&& make  > /dev/null\
	&& make install  > /dev/null\
	&& cd .. && rm -Rf Python-$python2_version

# Python 2.7 (macports)
RUN UNATTENDED=1 MACOSX_DEPLOYMENT_TARGET=${DARWIN_OSX_VERSION_MIN} WGETOPTS=--no-check-certificate osxcross-macports install -s -v python$python2_version_maj$python2_version_min


# Python 3 (Host)
ARG python3_version_maj=3
ARG python3_version_min=8
ARG python3_version_patch=5
ARG python3_version=$python3_version_maj.$python3_version_min.$python3_version_patch
RUN wget --no-check-certificate --no-verbose https://www.python.org/ftp/python/$python3_version/Python-$python3_version.tgz  > /dev/null\
	&& tar xzf Python-$python3_version.tgz && rm Python-$python3_version.tgz  > /dev/null\
        && cd Python-$python3_version  > /dev/null\
	&& ./configure  > /dev/null\
	&& make  > /dev/null\
	&& make install  > /dev/null\
	&& cd .. && rm -Rf Python-$python3_version
# Python 3 (macports)
RUN UNATTENDED=1 MACOSX_DEPLOYMENT_TARGET=${DARWIN_OSX_VERSION_MIN} WGETOPTS=--no-check-certificate osxcross-macports install -s -v python$python3_version_maj$python3_version_min

# PostgreSQL
RUN UNATTENDED=1 MACOSX_DEPLOYMENT_TARGET=${DARWIN_OSX_VERSION_MIN} WGETOPTS=--no-check-certificate osxcross-macports install -s -v postgresql96 postgresql96-server


# Opencv
RUN UNATTENDED=1 MACOSX_DEPLOYMENT_TARGET="10.14" WGETOPTS=--no-check-certificate osxcross-macports install -s -v opencv4

# Yadoms configuration file
RUN echo 'Configuring Yadoms CMakeListsUserConfig.txt' \
	&& echo 'set(BOOST_ROOT "'$YADOMS_DEPS_PATH'/boost_'$boost_version'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(POCO_ROOT "'$YADOMS_DEPS_PATH'/poco-'$poco_version'-all")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_ROOT "'$YADOMS_DEPS_PATH'/protobuf")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_PROTOC_EXECUTABLE "'`which protoc`'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_INSTALLED_TO_CUSTOM_DIRECTORY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(DEBUG_WITH_GCC OFF)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_USE_PKGCONFIG OFF)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_ManualSetup ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_EXECUTABLE "/usr/local/bin/python'$python3_version_maj'.'$python3_version_min'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_LIBRARIES "/opt/osxcross/target/macports/pkgs/opt/local/Library/Frameworks/Python.framework/Versions/'$python3_version_maj'.'$python3_version_min'/lib/python'$python3_version_maj'.'$python3_version_min'/config-'$python3_version_maj'.'$python3_version_min'-darwin/libpython'$python3_version_maj'.'$python3_version_min'.a")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_INCLUDE_DIRS "/opt/osxcross/target/macports/pkgs/opt/local/Library/Frameworks/Python.framework/Versions/'$python3_version_maj'.'$python3_version_min'/include/python'$python3_version_maj'.'$python3_version_min'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python2_ManualSetup ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python2_EXECUTABLE "/usr/local/bin/python'$python2_version_maj'.'$python2_version_min'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python2_LIBRARIES "/opt/osxcross/target/macports/pkgs/opt/local/Library/Frameworks/Python.framework/Versions/'$python2_version_maj'.'$python2_version_min'/lib/python'$python2_version_maj'.'$python2_version_min'/config/libpython'$python2_version_maj'.'$python2_version_min'.a")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python2_INCLUDE_DIRS "/opt/osxcross/target/macports/pkgs/opt/local/Library/Frameworks/Python.framework/Versions/'$python2_version_maj'.'$python2_version_min'/include/python'$python2_version_maj'.'$python2_version_min'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PostgreSQL_ROOT ' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "/opt/osxcross/target/macports/pkgs/opt/local/include/postgresql96"' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "/opt/osxcross/target/macports/pkgs/opt/local/include/postgresql96/server"' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "/opt/osxcross/target/macports/pkgs/opt/local/lib/postgresql96")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PostgreSQL_INCLUDE_DIR "/opt/osxcross/target/macports/pkgs/opt/local/include/postgresql96")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PostgreSQL_LIBRARY_DIR "/opt/osxcross/target/macports/pkgs/opt/local/lib/postgresql96")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(GAMMU_ROOT "'$YADOMS_DEPS_PATH'/gammu")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(GAMMU_LINK_DEPS "/opt/osxcross/target/macports/pkgs/opt/local/lib/libiconv.a" "/opt/osxcross/target/macports/pkgs/opt/local/lib/libintl.a")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(SWIG_ROOT "'$YADOMS_DEPS_PATH'/swig-'$swig_version'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'SET(COTIRE_USE ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'SET(COTIRE_USE_UNITY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(CC_RPI_ROOT "/opt/osxcross/target/SDK")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt

COPY entrypoint.sh /

#ensure entrypoint is executable (force flags update, because file flags may change if a commit is made under Windows)
RUN chmod +x /entrypoint.sh
