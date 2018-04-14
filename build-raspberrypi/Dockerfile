FROM ubuntu:16.04
MAINTAINER sgallou "https://github.com/sgallou"
LABEL authors=sgallou

ENV YADOMS_BUILD_BRANCH develop
ENV MAKE_PACKAGE false
ENV YADOMS_DEPS_PATH /yadoms-deps

RUN apt-get update \
	&& apt-get install -y g++ libbz2-dev python-dev wget build-essential libssl-dev \
	libopencv-gpu-dev libgnutls-dev autoconf automake libtool curl make g++ unzip \
	libudev-dev libpcre3 libpcre3-dev libreadline6 libreadline6-dev libpq5 \
	postgresql-server-dev-all git rpm zip

RUN mkdir $YADOMS_DEPS_PATH

# CMake
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://cmake.org/files/v3.11/cmake-3.11.0.tar.gz \
	&& tar xzf cmake-3.11.0.tar.gz
RUN cd $YADOMS_DEPS_PATH/cmake-3.11.0 \
	&& ./bootstrap \
	&& make \
	&& make install
RUN rm $YADOMS_DEPS_PATH/cmake-3.11.0.tar.gz

# Installing arm-linux-gnueabihf cross toolchain
RUN cd $YADOMS_DEPS_PATH \
	&& git clone --depth=1 git://github.com/raspberrypi/tools.git
ENV PATH $PATH:$YADOMS_DEPS_PATH/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/bin

# Check GCC version
RUN arm-linux-gnueabihf-gcc --version

# Boost
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose http://netcologne.dl.sourceforge.net/project/boost/boost/1.66.0/boost_1_66_0.tar.bz2 \
	&& tar xjf boost_1_66_0.tar.bz2
COPY boost/user-config.jam /root
RUN cd $YADOMS_DEPS_PATH/boost_1_66_0 \
	&& ./bootstrap.sh \
	&& ./b2 --with-atomic --with-chrono --with-date_time --with-filesystem --with-regex --with-thread --with-system link=static --no-samples --no-tests toolset=gcc-arm cxxflags=-fPIC
RUN rm $YADOMS_DEPS_PATH/boost_1_66_0.tar.bz2

# OpenSSL
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://www.openssl.org/source/openssl-1.1.0g.tar.gz \
	&& tar xzf openssl-1.1.0g.tar.gz
RUN cd $YADOMS_DEPS_PATH/openssl-1.1.0g \
	&& ./Configure linux-generic32 --prefix=$HOME/depsBuild/openssl --cross-compile-prefix=$YADOMS_DEPS_PATH/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/bin/arm-linux-gnueabihf- \
	&& make CC="arm-linux-gnueabihf-gcc" AR="arm-linux-gnueabihf-ar r" RANLIB="arm-linux-gnueabihf-ranlib" \
	&& make install
RUN rm $YADOMS_DEPS_PATH/openssl-1.1.0g.tar.gz

# Poco
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose http://pocoproject.org/releases/poco-1.8.1/poco-1.8.1-all.tar.gz \
	&& tar xzf poco-1.8.1-all.tar.gz
RUN cd $YADOMS_DEPS_PATH/poco-1.8.1-all \
	&& echo 'TOOL = arm-linux-gnueabihf' > build/config/RaspberryPI \
	&& cat build/config/ARM-Linux >> build/config/RaspberryPI \
	&& echo 'STATICOPT_CC = -fPIC' >> build/config/RaspberryPI \
	&& echo 'STATICOPT_CXX = -fPIC' >> build/config/RaspberryPI \
	&& ./configure --static --config=RaspberryPI --no-samples --no-tests --omit=CppUnit,CppUnit/WinTestRunner,Data,Data/SQLite,Data/ODBCData/MySQL,MongoDB,PageCompiler,PageCompiler/File2Page --include-path=$HOME/depsBuild/openssl/include --library-path=$HOME/depsBuild/openssl/lib \
	&& make
RUN rm $YADOMS_DEPS_PATH/poco-1.8.1-all.tar.gz

# Protobuf (Host)
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://github.com/google/protobuf/releases/download/v3.5.1/protobuf-cpp-3.5.1.tar.gz \
	&& tar xzf protobuf-cpp-3.5.1.tar.gz \
	&& cp -R protobuf-3.5.1 protobuf-3.5.1-host
RUN cd $YADOMS_DEPS_PATH/protobuf-3.5.1-host \
	&& mkdir build \
	&& cd build \
	&& cmake -Dprotobuf_BUILD_TESTS=OFF ../cmake \
	&& cmake -Dprotobuf_BUILD_TESTS=OFF --build . \
	&& make install \
	&& ldconfig
# Protobuf (Pi)
RUN cd $YADOMS_DEPS_PATH/protobuf-3.5.1 \
	&& ./autogen.sh \
	&& ./configure --enable-shared=no --host=arm-linux CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ AR=arm-linux-gnueabihf-ar STRIP=arm-linux-gnueabihf-strip RANLIB=arm-linux-gnueabihf-ranlib --prefix=$HOME/depsBuild/protobuf --with-protoc=protoc --with-pic \
	&& make \
	&& make install
RUN rm $YADOMS_DEPS_PATH/protobuf-cpp-3.5.1.tar.gz


# Libudev TODO : must be cross-compiled
RUN cd $YADOMS_DEPS_PATH \
	&& wget -U 'Yadoms/1.0.0' --no-verbose http://yadoms.com/travis_build/raspberry_pi/libudev.tar.gz \
	&& tar xzf libudev.tar.gz -C $HOME/depsBuild
RUN rm $YADOMS_DEPS_PATH/libudev.tar.gz


# Swig
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose http://prdownloads.sourceforge.net/swig/swig-3.0.12.tar.gz \
	&& tar xzf swig-3.0.12.tar.gz
RUN cd $YADOMS_DEPS_PATH/swig-3.0.12 \
	&& ./configure \
	&& make \
	&& make install
RUN rm $YADOMS_DEPS_PATH/swig-3.0.12.tar.gz

# Python (Host)
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tgz \
	&& tar xzf Python-2.7.13.tgz
RUN cd $YADOMS_DEPS_PATH/Python-2.7.13 \
	&& ./configure \
	&& make python Parser/pgen \
	&& make install \
	&& mkdir -p $HOME/depsBuild/pythonhost \
	&& cp python $HOME/depsBuild/pythonhost/ \
	&& cp Parser/pgen $HOME/depsBuild/pythonhost/
# Python (Pi)
RUN cd $YADOMS_DEPS_PATH/Python-2.7.13 \
	&& CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ AR=arm-linux-gnueabihf-ar RANLIB=arm-linux-gnueabihf-ranlib ./configure --host=arm-linux-gnueabihf --target=arm-linux-gnueabihf --build=x86_64-linux-gnu --prefix=$HOME/depsBuild/python --disable-ipv6 ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no ac_cv_have_long_long_format=yes --enable-shared \
	&& make HOSTPYTHON=$HOME/depsBuild/pythonhost/python HOSTPGEN=$HOME/depsBuild/pythonhost/pgen BLDSHARED="arm-linux-gnueabihf-cc -shared" CROSS-COMPILE=arm-linux-gnueabihf- CROSS_COMPILE_TARGET=yes HOSTARCH=arm-linux BUILDARCH=arm-linux-gnueabihf
RUN rm $YADOMS_DEPS_PATH/Python-2.7.13.tgz


# PostgreSQL
# TODO ne fonctionne pas, à voir...
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://ftp.postgresql.org/pub/source/v9.6.2/postgresql-9.6.2.tar.bz2 \
	&& tar xjf postgresql-9.6.2.tar.bz2
RUN cd $YADOMS_DEPS_PATH/postgresql-9.6.2 \
	&& CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ AR=arm-linux-gnueabihf-ar RANLIB=arm-linux-gnueabihf-ranlib ./configure --host=arm-linux --build=arm-linux-gnueabihf --without-readline --without-zlib --disable-spinlocks \
	&& cd src/interfaces/libpq \
	&& make
RUN rm $YADOMS_DEPS_PATH/postgresql-9.6.2.tar.bz2

# Yadoms sources
RUN git clone git://github.com/Yadoms/yadoms.git

# Yadoms configuration file
RUN echo 'Configuring Yadoms CMakeListsUserConfig.txt' \
	&& echo 'set(ALTERNATIVE_CMAKE_ROOT "'$YADOMS_DEPS_PATH'/cmake-3.11.0")' > $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(BOOST_ROOT "'$YADOMS_DEPS_PATH'/boost_1_66_0")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(POCO_ROOT "'$YADOMS_DEPS_PATH'/poco-1.8.1-all")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_ROOT "'$HOME'/depsBuild/protobuf")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_PROTOC_EXECUTABLE "'`which protoc`'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_INSTALLED_TO_CUSTOM_DIRECTORY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(OPENSSL_ROOT "'$HOME'/depsBuild/openssl")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(DEBUG_WITH_GCC OFF)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_USE_PKGCONFIG OFF)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_USE_SOURCES ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_ROOT "'$YADOMS_DEPS_PATH'/Python-2.7.13")' >> yadoms/sources/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_LIBRARIES "'$YADOMS_DEPS_PATH'/Python-2.7.13/libpython2.7.so")' >> yadoms/sources/CMakeListsUserConfig.txt \
	&& echo 'set(PostgreSQL_ROOT ' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "'$YADOMS_DEPS_PATH'/postgresql-9.6.2/src/interfaces/libpq"' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "'$YADOMS_DEPS_PATH'/postgresql-9.6.2/src/include")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(GAMMU_ROOT "'$YADOMS_DEPS_PATH'/gammu-1.38.4")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(SWIG_ROOT "'$YADOMS_DEPS_PATH'/swig-3.0.12")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'SET(COTIRE_USE ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'SET(COTIRE_USE_UNITY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(LIBUDEV_ROOT "'$HOME'/depsBuild/libudev")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(UDEV_PATH_LIB "'$HOME'/depsBuild/libudev")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(UDEV_PATH_INCLUDES "'$HOME'/depsBuild/libudev")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(CC_RPI_ROOT "'$YADOMS_DEPS_PATH'/tools/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt
RUN echo 'Result:' \
	&& cat $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt

COPY entrypoint.sh /

CMD /entrypoint.sh

