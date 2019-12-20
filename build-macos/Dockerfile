FROM yadoms/toolchain_for_macos
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42
ENV DEBIAN_FRONTEND noninteractive

ENV YADOMS_BUILD_BRANCH develop
ENV MAKE_PACKAGE false
ENV YADOMS_BUILD_TOOLS_PATH /yadoms-build-tools
ENV YADOMS_DEPS_PATH /yadoms-deps/macos

USER root

RUN cp /dev/null /etc/apt/sources.list \
 && echo "deb http://deb.debian.org/debian/ stretch main contrib non-free" | tee -a /etc/apt/sources.list \
 && echo "deb http://security.debian.org/ stretch/updates main contrib non-free" | tee -a /etc/apt/sources.list \
 && echo "deb http://deb.debian.org/debian/ stretch-updates main contrib non-free" | tee -a /etc/apt/sources.list \
 && echo "deb http://deb.debian.org/debian stretch-backports main contrib non-free" | tee -a /etc/apt/sources.list
 
RUN apt-get update  > /dev/null\
	&& apt-get install -y g++ libbz2-dev python-dev wget build-essential libssl-dev \
	libopencv-gpu-dev autoconf automake libtool curl make g++ unzip \
	libpcre3 libpcre3-dev libreadline-dev libpq5 \
	postgresql-server-dev-all git rpm zip gcc gcc-doc libc6-dev > /dev/null

RUN mkdir -p $YADOMS_BUILD_TOOLS_PATH
RUN mkdir -p $YADOMS_DEPS_PATH

# CMake
ARG cmake_version=3.15.2
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate -d --no-verbose https://github.com/Kitware/CMake/releases/download/v$cmake_version/cmake-$cmake_version.tar.gz \
	&& tar xzf cmake-$cmake_version.tar.gz && cd cmake-$cmake_version\
	&& ./bootstrap && make > /dev/null && make install\
	&& cd .. && rm -Rf cmake-$cmake_version && rm $YADOMS_DEPS_PATH/cmake-$cmake_version.tar.gz

# Boost
ARG boost_version=1_71_0
ARG boost_version_dot=1.71.0
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose https://dl.bintray.com/boostorg/release/$boost_version_dot/source/boost_$boost_version.tar.bz2\
	&& tar xjf boost_$boost_version.tar.bz2 && cd boost_$boost_version  > /dev/null\
	&& echo "using gcc : o64 : o64-g++ : <archiver>x86_64-apple-darwin16-ar <ranlib>x86_64-apple-darwin16-ranlib ;" > ~/user-config.jam \
	&& ./bootstrap.sh\
	&& ./b2 --with-atomic --with-chrono --with-date_time --with-filesystem --with-locale --with-regex --with-thread --with-system link=static runtime-link=static --no-samples --no-tests toolset=gcc-o64 target-os=darwin cxxflags="-fPIC" visibility=global \
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
ARG protobuf_version=3.11.1
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
	&& ./configure --enable-shared=no --host=x86_64-apple-darwin16 CC=x86_64-apple-darwin16-gcc CXX=x86_64-apple-darwin16-g++ AR=x86_64-apple-darwin16-ar STRIP=x86_64-apple-darwin16-strip RANLIB=x86_64-apple-darwin16-ranlib --prefix=$YADOMS_DEPS_PATH/protobuf --with-protoc=protoc --with-pic  > /dev/null\
	&& make  > /dev/null\
	&& make install  > /dev/null\
    && cd .. && rm -Rf $YADOMS_DEPS_PATH/protobuf-$protobuf_version

# Swig
ARG swig_version=4.0.1
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose http://prdownloads.sourceforge.net/swig/swig-$swig_version.tar.gz  > /dev/null\
	&& tar xzf swig-$swig_version.tar.gz  > /dev/null\
	&& cd $YADOMS_DEPS_PATH/swig-$swig_version  > /dev/null\
	&& ./configure  > /dev/null\
	&& make  > /dev/null\
	&& make install  > /dev/null\
	&& cd .. \
	&& rm -f swig-$swig_version\Source\Modules\*.o \
	&& rm -Rf swig-$swig_version\Examples \
	&& rm -Rf swig-$swig_version\Docs \
	&& rm $YADOMS_DEPS_PATH/swig-$swig_version.tar.gz

# Python 2.7 (Host)
ARG python2_version=2.7.16
RUN wget --no-check-certificate --no-verbose https://www.python.org/ftp/python/$python2_version/Python-$python2_version.tgz  > /dev/null\
	&& tar xzf Python-$python2_version.tgz && rm Python-$python2_version.tgz  > /dev/null\
        && cd Python-$python2_version  > /dev/null\
	&& ./configure  > /dev/null\
	&& make  > /dev/null\
	&& make install  > /dev/null\
	&& cd .. && rm -Rf Python-$python2_version

# Python 2.7 (macports)
RUN UNATTENDED=1 MACOSX_DEPLOYMENT_TARGET=${DARWIN_OSX_VERSION_MIN} WGETOPTS=--no-check-certificate osxcross-macports install -s -v python27

RUN apt-get install -y libffi-dev

# Python 3.7 (Host)
ARG python3_version=3.7.3
RUN wget --no-check-certificate --no-verbose https://www.python.org/ftp/python/$python3_version/Python-$python3_version.tgz  > /dev/null\
	&& tar xzf Python-$python3_version.tgz && rm Python-$python3_version.tgz  > /dev/null\
        && cd Python-$python3_version  > /dev/null\
	&& ./configure  > /dev/null\
	&& make  > /dev/null\
	&& make install  > /dev/null\
	&& cd .. && rm -Rf Python-$python3_version
# Python 3.7 (macports)
RUN UNATTENDED=1 MACOSX_DEPLOYMENT_TARGET=${DARWIN_OSX_VERSION_MIN} WGETOPTS=--no-check-certificate osxcross-macports install -s -v python37

# PostgreSQL
#remove already installed package on host
RUN apt-get purge -y postgresql* && apt autoremove -y
RUN UNATTENDED=1 MACOSX_DEPLOYMENT_TARGET=${DARWIN_OSX_VERSION_MIN} WGETOPTS=--no-check-certificate osxcross-macports install -s -v postgresql96 postgresql96-server

# Gammu
#copy cross compile toolchain
COPY gammu.cmake /
ARG gammu_version=1.40.0
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose https://dl.cihar.com/gammu/releases/gammu-$gammu_version.tar.bz2  > /dev/null\
	&& tar xjf gammu-$gammu_version.tar.bz2  > /dev/null\
	&& cd gammu-$gammu_version \
	&& mkdir rpicc \
	&& cd rpicc \
	&& eval `x86_64-apple-darwin16-osxcross-conf` \
	&& export OSXCROSS_HOST="x86_64-apple-darwin16" \
	&& cmake -DCMAKE_C_COMPILER=x86_64-apple-darwin16-gcc -DCMAKE_CXX_COMPILER=x86_64-apple-darwin16-g++ -DICONV_LIBRARIES="/opt/osxcross/target/macports/pkgs/opt/local/lib/libiconv.a" -DBUILD_SHARED_LIBS=OFF -DCMAKE_TOOLCHAIN_FILE=/gammu.cmake -DCMAKE_STAGING_PREFIX=$YADOMS_DEPS_PATH/gammu ..  > /dev/null\
	&& make  > /dev/null\
	&& make install  > /dev/null\
	&& cd ../.. && rm -Rf gammu-1.40.*





# Yadoms configuration file
RUN echo 'Configuring Yadoms CMakeListsUserConfig.txt' \
	&& echo 'set(BOOST_ROOT "'$YADOMS_DEPS_PATH'/boost_$boost_version")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(POCO_ROOT "'$YADOMS_DEPS_PATH'/poco-$poco_version-all")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_ROOT "'$YADOMS_DEPS_PATH'/protobuf")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_PROTOC_EXECUTABLE "'`which protoc`'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_INSTALLED_TO_CUSTOM_DIRECTORY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(DEBUG_WITH_GCC OFF)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_USE_PKGCONFIG OFF)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_ManualSetup ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_EXECUTABLE "/usr/local/bin/python3.7")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_LIBRARIES "/opt/osxcross/target/macports/pkgs/opt/local/Library/Frameworks/Python.framework/Versions/3.7/lib/python3.7/config-3.7m-darwin/libpython3.7.a")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_INCLUDE_DIRS "/opt/osxcross/target/macports/pkgs/opt/local/Library/Frameworks/Python.framework/Versions/3.7/include/python3.7m")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python2_ManualSetup ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python2_EXECUTABLE "/usr/local/bin/python2.7")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python2_LIBRARIES "/opt/osxcross/target/macports/pkgs/opt/local/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/config/libpython2.7.a")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python2_INCLUDE_DIRS "/opt/osxcross/target/macports/pkgs/opt/local/Library/Frameworks/Python.framework/Versions/2.7/include/python2.7")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PostgreSQL_ROOT ' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "/opt/osxcross/target/macports/pkgs/opt/local/include/postgresql96"' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "/opt/osxcross/target/macports/pkgs/opt/local/include/postgresql96/server"' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "/opt/osxcross/target/macports/pkgs/opt/local/lib/postgresql96")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PostgreSQL_INCLUDE_DIR "/opt/osxcross/target/macports/pkgs/opt/local/include/postgresql96")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PostgreSQL_LIBRARY_DIR "/opt/osxcross/target/macports/pkgs/opt/local/lib/postgresql96")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(GAMMU_ROOT "'$YADOMS_DEPS_PATH'/gammu")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(GAMMU_LINK_DEPS "/opt/osxcross/target/macports/pkgs/opt/local/lib/libiconv.a" "/opt/osxcross/target/macports/pkgs/opt/local/lib/libintl.a")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(SWIG_ROOT "'$YADOMS_DEPS_PATH'/swig-$swig_version")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'SET(COTIRE_USE ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'SET(COTIRE_USE_UNITY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(CC_RPI_ROOT "/opt/osxcross/target/SDK")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt

COPY entrypoint.sh /

#ensure entrypoint is executable (force flags update, because file flags may change if a commit is made under Windows)
RUN chmod +x /entrypoint.sh

