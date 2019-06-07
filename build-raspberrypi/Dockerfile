FROM debian:stretch
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42

ENV YADOMS_BUILD_BRANCH develop
ENV MAKE_PACKAGE false
ENV YADOMS_BUILD_TOOLS_PATH /yadoms-build-tools
ENV YADOMS_DEPS_PATH /yadoms-deps/raspberry

RUN echo "deb http://deb.debian.org/debian/ stretch main contrib non-free" | tee -a /etc/apt/sources.list \
&&  echo "deb http://security.debian.org/ stretch/updates main contrib non-free" | tee -a /etc/apt/sources.list \
&& echo "deb http://deb.debian.org/debian/ stretch-updates main contrib non-free" | tee -a /etc/apt/sources.list \
&& echo "deb http://deb.debian.org/debian stretch-backports main contrib non-free" | tee -a /etc/apt/sources.list
 
RUN apt-get update > /dev/null\
	&& apt-get install -y g++ libbz2-dev python-dev wget build-essential libssl-dev \
	libopencv-gpu-dev autoconf automake libtool curl make g++ unzip \
	libudev-dev libpcre3 libpcre3-dev libreadline-dev libpq5 \
	postgresql-server-dev-all git rpm zip gcc gcc-doc libc6-dev > /dev/null

RUN mkdir -p $YADOMS_BUILD_TOOLS_PATH
RUN mkdir -p $YADOMS_DEPS_PATH

# CMake
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://github.com/Kitware/CMake/releases/download/v3.14.5/cmake-3.14.5.tar.gz  > /dev/null\
	&& tar xzf cmake-3.14.5.tar.gz && cd cmake-3.14.5  > /dev/null\
	&& travis_wait ./bootstrap > /dev/null && travis_wait make > /dev/null && travis_wait make install > /dev/null\
	&& cd .. && rm -Rf cmake-3.14.5 && rm $YADOMS_DEPS_PATH/cmake-3.14.5.tar.gz

# Installing arm-linux-gnueabihf cross toolchain
RUN cd $YADOMS_BUILD_TOOLS_PATH \
	&& git clone --depth=1 git://github.com/raspberrypi/tools.git  > /dev/null
ENV PATH $PATH:$YADOMS_BUILD_TOOLS_PATH/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/bin

# Check GCC version
RUN arm-linux-gnueabihf-gcc --version


# Boost
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_70_0.tar.bz2  > /dev/null\
	&& tar xjf boost_1_70_0.tar.bz2 && cd boost_1_70_0  > /dev/null\
	&& echo "using gcc : arm : arm-linux-gnueabihf-g++ ;" > /root/user-config.jam \
	&& ./bootstrap.sh > /dev/null\
	&& travis_wait ./b2 --with-atomic --with-chrono --with-date_time --with-filesystem --with-regex --with-thread --with-system link=static runtime-link=static --no-samples --no-tests toolset=gcc-arm cxxflags=-fPIC  > /dev/null\
	&& rm -Rf bin.v2 \
	&& rm -Rf doc \
	&& rm -Rf libs \
	&& rm -Rf tools \
	&& cd .. && rm $YADOMS_DEPS_PATH/boost_1_70_0.tar.bz2
	

# OpenSSL
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://www.openssl.org/source/openssl-1.1.0g.tar.gz  > /dev/null\
	&& tar xzf openssl-1.1.0g.tar.gz && cd openssl-1.1.0g  > /dev/null\
	&& travis_wait ./Configure linux-generic32 --prefix=$YADOMS_DEPS_PATH/openssl --cross-compile-prefix=$YADOMS_BUILD_TOOLS_PATH/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/bin/arm-linux-gnueabihf-  > /dev/null\
	&& travis_wait make CC="arm-linux-gnueabihf-gcc" AR="arm-linux-gnueabihf-ar r" RANLIB="arm-linux-gnueabihf-ranlib"  > /dev/null\
	&& travis_wait make install  > /dev/null\
	&& cd .. && rm -Rf openssl-1.1.0g && rm $YADOMS_DEPS_PATH/openssl-1.1.0g.tar.gz
	

# Poco
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose http://pocoproject.org/releases/poco-1.9.0/poco-1.9.0-all.tar.gz  > /dev/null\
	&& tar xzf poco-1.9.0-all.tar.gz && cd poco-1.9.0-all  > /dev/null\
	&& echo 'TOOL = arm-linux-gnueabihf' > build/config/RaspberryPI \
	&& cat build/config/ARM-Linux >> build/config/RaspberryPI \
	&& echo 'STATICOPT_CC = -fPIC' >> build/config/RaspberryPI \
	&& echo 'STATICOPT_CXX = -fPIC' >> build/config/RaspberryPI \
	&& travis_wait ./configure --static --config=RaspberryPI --no-samples --no-tests --omit=CppUnit,CppUnit/WinTestRunner,Data,Data/SQLite,Data/ODBCData/MySQL,MongoDB,PageCompiler,PageCompiler/File2Page --include-path=$YADOMS_DEPS_PATH/openssl/include --library-path=$YADOMS_DEPS_PATH/openssl/lib  > /dev/null\
	&& travis_wait make  > /dev/null\
	&& cd .. \
	&& find . -name obj -type d -print0 | xargs -0 rm -rf  > /dev/null\
	&& rm $YADOMS_DEPS_PATH/poco-1.9.0-all.tar.gz


# Protobuf (Host)
RUN wget --no-verbose https://github.com/google/protobuf/releases/download/v3.7.1/protobuf-cpp-3.7.1.tar.gz  > /dev/null\
	&& tar xzf protobuf-cpp-3.7.1.tar.gz && rm protobuf-cpp-3.7.1.tar.gz > /dev/null\
    && cp -R protobuf-3.7.1 $YADOMS_BUILD_TOOLS_PATH/protobuf-3.7.1-host > /dev/null \
	&& cd $YADOMS_BUILD_TOOLS_PATH/protobuf-3.7.1-host \
	&& mkdir build \
	&& cd build \
	&& travis_wait cmake -Dprotobuf_BUILD_TESTS=OFF ../cmake  > /dev/null\
	&& travis_wait cmake -Dprotobuf_BUILD_TESTS=OFF --build .  > /dev/null\
	&& travis_wait make install  > /dev/null\
	&& ldconfig  > /dev/null
# Protobuf (Pi)
RUN mv protobuf-3.7.1 $YADOMS_DEPS_PATH/protobuf-3.7.1 \
	&& cd $YADOMS_DEPS_PATH/protobuf-3.7.1 \
	&& travis_wait ./autogen.sh  > /dev/null\
	&& travis_wait ./configure --enable-shared=no --host=arm-linux CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ AR=arm-linux-gnueabihf-ar STRIP=arm-linux-gnueabihf-strip RANLIB=arm-linux-gnueabihf-ranlib --prefix=$YADOMS_DEPS_PATH/protobuf --with-protoc=protoc --with-pic  > /dev/null\
	&& travis_wait make  > /dev/null\
	&& travis_wait make install  > /dev/null\
    && cd .. && rm -Rf $YADOMS_DEPS_PATH/protobuf-3.7.1


# Libudev TODO : must be cross-compiled
RUN cd $YADOMS_DEPS_PATH \
	&& wget -U 'Yadoms/1.0.0' --no-verbose http://yadoms.com/builds/raspberry_pi/libs/libudev.tar.gz \
	&& tar xzf libudev.tar.gz -C $YADOMS_DEPS_PATH \
    && rm $YADOMS_DEPS_PATH/libudev.tar.gz


# Swig
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose http://prdownloads.sourceforge.net/swig/swig-3.0.12.tar.gz  > /dev/null\
	&& tar xzf swig-3.0.12.tar.gz  > /dev/null\
	&& cd $YADOMS_DEPS_PATH/swig-3.0.12  > /dev/null\
	&& travis_wait ./configure  > /dev/null\
	&& travis_wait make  > /dev/null\
	&& travis_wait make install  > /dev/null\
	&& cd .. \
	&& rm -f swig-3.0.12\Source\Modules\*.o \
	&& rm -Rf swig-3.0.12\Examples \
	&& rm -Rf swig-3.0.12\Docs \
	&& rm $YADOMS_DEPS_PATH/swig-3.0.12.tar.gz

# Python (Host)
RUN wget --no-verbose https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tgz  > /dev/null\
	&& tar xzf Python-2.7.13.tgz && rm Python-2.7.13.tgz  > /dev/null\
    && cp -R Python-2.7.13 Python-2.7.13-host  > /dev/null\
	&& cd Python-2.7.13-host  > /dev/null\
	&& travis_wait ./configure  > /dev/null\
	&& travis_wait make python Parser/pgen  > /dev/null\
	&& travis_wait make install  > /dev/null\
	&& mkdir -p $YADOMS_BUILD_TOOLS_PATH/pythonhost \
	&& cp python $YADOMS_BUILD_TOOLS_PATH/pythonhost/ \
	&& cp Parser/pgen $YADOMS_BUILD_TOOLS_PATH/pythonhost/ \
	&& cd .. && rm -Rf Python-2.7.13-host
# Python (Pi)
RUN mv Python-2.7.13 $YADOMS_DEPS_PATH/Python-2.7.13  > /dev/null\
	&& cd $YADOMS_DEPS_PATH/Python-2.7.13  > /dev/null\
	&& travis_wait CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ AR=arm-linux-gnueabihf-ar RANLIB=arm-linux-gnueabihf-ranlib ./configure --host=arm-linux-gnueabihf --target=arm-linux-gnueabihf --build=x86_64-linux-gnu --prefix=$YADOMS_DEPS_PATH/python --disable-ipv6 ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no ac_cv_have_long_long_format=yes --enable-shared  > /dev/null\
	&& travis_wait make HOSTPYTHON=$YADOMS_BUILD_TOOLS_PATH/pythonhost/python HOSTPGEN=$YADOMS_BUILD_TOOLS_PATH/pythonhost/Parser/pgen BLDSHARED="arm-linux-gnueabihf-cc -shared" CROSS-COMPILE=arm-linux-gnueabihf- CROSS_COMPILE_TARGET=yes HOSTARCH=arm-linux BUILDARCH=arm-linux-gnueabihf  > /dev/null

# PostgreSQL
# TODO ne fonctionne pas, à voir...
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://ftp.postgresql.org/pub/source/v9.6.2/postgresql-9.6.2.tar.bz2  > /dev/null\
	&& tar xjf postgresql-9.6.2.tar.bz2 && rm postgresql-9.6.2.tar.bz2  > /dev/null\
	&& cd postgresql-9.6.2  > /dev/null\
	&& travis_wait CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ AR=arm-linux-gnueabihf-ar RANLIB=arm-linux-gnueabihf-ranlib ./configure --host=arm-linux --build=arm-linux-gnueabihf --without-readline --without-zlib --disable-spinlocks  > /dev/null\
	&& cd src/interfaces/libpq \
	&& travis_wait make  > /dev/null\
	&& cd ../../../.. && rm -Rf postgresql-9.6.2/doc

# Yadoms sources
RUN git clone git://github.com/Yadoms/yadoms.git  > /dev/null

# Yadoms configuration file
RUN echo 'Configuring Yadoms CMakeListsUserConfig.txt' \
	&& echo 'set(BOOST_ROOT "'$YADOMS_DEPS_PATH'/boost_1_70_0")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(POCO_ROOT "'$YADOMS_DEPS_PATH'/poco-1.9.0-all")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_ROOT "'$YADOMS_DEPS_PATH'/protobuf")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_PROTOC_EXECUTABLE "'`which protoc`'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_INSTALLED_TO_CUSTOM_DIRECTORY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(OPENSSL_ROOT "'$YADOMS_DEPS_PATH'/openssl")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(DEBUG_WITH_GCC OFF)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_USE_PKGCONFIG OFF)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_USE_SOURCES ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_ROOT "'$YADOMS_DEPS_PATH'/Python-2.7.13")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_LIBRARIES "'$YADOMS_DEPS_PATH'/Python-2.7.13/libpython2.7.so")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PostgreSQL_ROOT ' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "'$YADOMS_DEPS_PATH'/postgresql-9.6.2/src/interfaces/libpq"' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "'$YADOMS_DEPS_PATH'/postgresql-9.6.2/src/include")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(GAMMU_ROOT "'$YADOMS_DEPS_PATH'/gammu-1.38.4")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(SWIG_ROOT "'$YADOMS_DEPS_PATH'/swig-3.0.12")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'SET(COTIRE_USE ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'SET(COTIRE_USE_UNITY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(LIBUDEV_ROOT "'$YADOMS_DEPS_PATH'/libudev")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(UDEV_PATH_LIB "'$YADOMS_DEPS_PATH'/libudev")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(UDEV_PATH_INCLUDES "'$YADOMS_DEPS_PATH'/libudev")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(CC_RPI_ROOT "'$YADOMS_BUILD_TOOLS_PATH'/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt

COPY entrypoint.sh /

#ensure entrypoint is executable (force flags update, because file flags may change if a commit is made under Windows)
RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh
