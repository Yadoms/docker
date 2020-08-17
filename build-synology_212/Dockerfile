FROM yadoms/synology_marvel_kirkwood_88f6281_cross_toolchain:armv6
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42

ENV YADOMS_BUILD_BRANCH develop
ENV MAKE_PACKAGE false
ENV YADOMS_BUILD_TOOLS_PATH /yadoms-build-tools
ENV YADOMS_DEPS_PATH /yadoms-deps/synology

RUN echo "deb http://deb.debian.org/debian/ stretch main contrib non-free" | tee -a /etc/apt/sources.list \
&&  echo "deb http://security.debian.org/ stretch/updates main contrib non-free" | tee -a /etc/apt/sources.list \
&& echo "deb http://deb.debian.org/debian/ stretch-updates main contrib non-free" | tee -a /etc/apt/sources.list \
&& echo "deb http://deb.debian.org/debian stretch-backports main contrib non-free" | tee -a /etc/apt/sources.list
 
RUN apt-get update \
	&& apt-get install -q -y g++ libbz2-dev python-dev python3-dev wget build-essential libssl-dev \
	libopencv-gpu-dev autoconf automake libtool curl make g++ unzip \
	libpcre3 libpcre3-dev libreadline-dev libpq5 \
	postgresql-server-dev-all git rpm zip gcc gcc-doc libc6-dev \
	lib32z1 lib32ncurses5


RUN mkdir -p $YADOMS_BUILD_TOOLS_PATH
RUN mkdir -p $YADOMS_DEPS_PATH

# Check GCC version
RUN arm-marvell-linux-gnueabi-gcc --version

# CMake
ARG cmake_version=3.15.2
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose https://github.com/Kitware/CMake/releases/download/v$cmake_version/cmake-$cmake_version.tar.gz  > /dev/null\
	&& tar xzf cmake-$cmake_version.tar.gz && cd cmake-$cmake_version  > /dev/null\
	&& ./bootstrap > /dev/null && make > /dev/null && make install > /dev/null\
	&& cd .. && rm -Rf cmake-$cmake_version && rm $YADOMS_DEPS_PATH/cmake-$cmake_version.tar.gz

# Boost
ARG boost_version=1_71_0
ARG boost_version_dot=1.71.0
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose https://dl.bintray.com/boostorg/release/$boost_version_dot/source/boost_$boost_version.tar.bz2  > /dev/null\
	&& tar xjf boost_$boost_version.tar.bz2 && cd boost_$boost_version  > /dev/null\
	&& echo "using gcc : arm : arm-marvell-linux-gnueabi-g++ ;" > /root/user-config.jam \
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
	&& ./Configure linux-generic32 --prefix=$YADOMS_DEPS_PATH/openssl --cross-compile-prefix=/opt/cross-pi-gcc-9.1.0-2/bin/arm-marvell-linux-gnueabi-  > /dev/null\
	&& make CC="arm-marvell-linux-gnueabi-gcc" AR="arm-marvell-linux-gnueabi-ar" RANLIB="arm-marvell-linux-gnueabi-ranlib"  > /dev/null\
	&& make install  > /dev/null\
	&& cd .. && rm -Rf openssl-$openssl_version && rm $YADOMS_DEPS_PATH/openssl-$openssl_version.tar.gz
	

# Poco
ARG poco_version=1.9.4
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose http://pocoproject.org/releases/poco-$poco_version/poco-$poco_version-all.tar.gz  > /dev/null\
	&& tar xzf poco-$poco_version-all.tar.gz && cd poco-$poco_version-all  > /dev/null\
	&& echo 'TOOL = arm-marvell-linux-gnueabi' > build/config/RaspberryPI \
	&& cat build/config/ARM-Linux >> build/config/RaspberryPI \
	&& echo 'STATICOPT_CC = -fPIC' >> build/config/RaspberryPI \
	&& echo 'STATICOPT_CXX = -fPIC' >> build/config/RaspberryPI \
	&& ./configure --static --config=RaspberryPI --no-samples --no-tests --omit=CppUnit,CppUnit/WinTestRunner,Data,Data/SQLite,Data/ODBCData/MySQL,MongoDB,PageCompiler,PageCompiler/File2Page --include-path=$YADOMS_DEPS_PATH/openssl/include --library-path=$YADOMS_DEPS_PATH/openssl/lib  > /dev/null\
	&& make  > /dev/null\
	&& cd .. \
	&& find . -name obj -type d -print0 | xargs -0 rm -rf  > /dev/null\
	&& rm $YADOMS_DEPS_PATH/poco-$poco_version-all.tar.gz


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
# Protobuf (Pi)
RUN mv protobuf-$protobuf_version $YADOMS_DEPS_PATH/protobuf-$protobuf_version \
	&& cd $YADOMS_DEPS_PATH/protobuf-$protobuf_version \
	&& ./autogen.sh  > /dev/null\
	&& ./configure --enable-shared=no --host=arm-linux CC=arm-marvell-linux-gnueabi-gcc CXX=arm-marvell-linux-gnueabi-g++ AR=arm-marvell-linux-gnueabi-ar STRIP=arm-marvell-linux-gnueabi-strip RANLIB=arm-marvell-linux-gnueabi-ranlib --prefix=$YADOMS_DEPS_PATH/protobuf --with-protoc=protoc --with-pic  > /dev/null\
	&& make  > /dev/null\
	&& make install  > /dev/null\
    && cd .. && rm -Rf $YADOMS_DEPS_PATH/protobuf-protobuf_version


# Swig
ARG swig_version=4.0.1
RUN cd $YADOMS_DEPS_PATH \
	&& echo "http://prdownloads.sourceforge.net/swig/swig-$swig_version.tar.gz" \
	&& wget --no-check-certificate --no-verbose http://prdownloads.sourceforge.net/swig/swig-$swig_version.tar.gz  > /dev/null\
	&& tar xzf swig-$swig_version.tar.gz  > /dev/null\
	&& cd $YADOMS_DEPS_PATH/swig-$swig_version  > /dev/null\
	&& ./configure  > /dev/null\
	&& make  > /dev/null\
	&& make install  > /dev/null\
	&& cd .. \
	&& rm -f swig-4.0.1\Source\Modules\*.o \
	&& rm -Rf swig-4.0.1\Examples \
	&& rm -Rf swig-4.0.1\Docs \
	&& rm $YADOMS_DEPS_PATH/swig-$swig_version.tar.gz


# Python 2.7 (Host)
ARG python2_version=2.7.16
RUN wget --no-check-certificate --no-check-certificate --no-verbose https://www.python.org/ftp/python/$python2_version/Python-$python2_version.tgz  > /dev/null\
	&& tar xzf Python-$python2_version.tgz && rm Python-$python2_version.tgz  > /dev/null\
    && cp -R Python-$python2_version Python-$python2_version-host  > /dev/null\
	&& cd Python-$python2_version-host  > /dev/null\
	&& ./configure  > /dev/null\
	&& make python Parser/pgen > /dev/null\
	&& make install  > /dev/null\
	&& mkdir -p $YADOMS_BUILD_TOOLS_PATH/pythonhost27 \
	&& cp python $YADOMS_BUILD_TOOLS_PATH/pythonhost27/ \
	&& cp Parser/pgen $YADOMS_BUILD_TOOLS_PATH/pythonhost27/ \
	&& cd .. && rm -Rf Python-$python2_version-host
# Python 2.7 (Pi)
RUN mv Python-$python2_version $YADOMS_DEPS_PATH/Python-$python2_version  > /dev/null\
	&& cd $YADOMS_DEPS_PATH/Python-$python2_version  > /dev/null\
	&& ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no ac_cv_have_long_long_format=yes CC=arm-marvell-linux-gnueabi-gcc CXX=arm-marvell-linux-gnueabi-g++ AR=arm-marvell-linux-gnueabi-ar RANLIB=arm-marvell-linux-gnueabi-ranlib ./configure --host=arm-marvell-linux-gnueabi --target=arm-marvell-linux-gnueabi --build=x86_64-linux-gnu --prefix=$YADOMS_DEPS_PATH/python27 --disable-ipv6 --enable-shared\
	&& make HOSTPYTHON=$YADOMS_BUILD_TOOLS_PATH/pythonhost/python HOSTPGEN=$YADOMS_BUILD_TOOLS_PATH/pythonhost/Parser/pgen BLDSHARED="arm-marvell-linux-gnueabi-gcc -shared" CROSS-COMPILE=arm-marvell-linux-gnueabi- CROSS_COMPILE_TARGET=yes HOSTARCH=arm-linux BUILDARCH=arm-marvell-linux-gnueabi 

RUN apt-get install -y libffi-dev

# Python 3.7 (Host)
ARG python3_version=3.7.3
RUN wget --no-check-certificate --no-check-certificate --no-verbose https://www.python.org/ftp/python/$python3_version/Python-$python3_version.tgz  > /dev/null\
	&& tar xzf Python-$python3_version.tgz && rm Python-$python3_version.tgz  > /dev/null\
    && cp -R Python-$python3_version Python-$python3_version-host  > /dev/null\
	&& cd Python-$python3_version-host  > /dev/null\
	&& ./configure \
	&& make python Parser/pgen > /dev/null\
	&& make install  > /dev/null\
	&& mkdir -p $YADOMS_BUILD_TOOLS_PATH/pythonhost37 \
	&& cp python $YADOMS_BUILD_TOOLS_PATH/pythonhost37/ \
	&& cp Parser/pgen $YADOMS_BUILD_TOOLS_PATH/pythonhost37/ \
	&& cd .. && rm -Rf Python-$python3_version-host
# Python 3.7 (Pi)
RUN mv Python-$python3_version $YADOMS_DEPS_PATH/Python-$python3_version  > /dev/null\
	&& cd $YADOMS_DEPS_PATH/Python-$python3_version  > /dev/null\
	&& CC=arm-marvell-linux-gnueabi-gcc CXX=arm-marvell-linux-gnueabi-g++ AR=arm-marvell-linux-gnueabi-ar RANLIB=arm-marvell-linux-gnueabi-ranlib ./configure --host=arm-marvell-linux-gnueabi --target=arm-marvell-linux-gnueabi --build=x86_64-linux-gnu --prefix=$YADOMS_DEPS_PATH/python37 --disable-ipv6 ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no ac_cv_have_long_long_format=yes --enable-shared  --without-pymalloc  > /dev/null\
	&& make HOSTPYTHON=$YADOMS_BUILD_TOOLS_PATH/pythonhost37/python HOSTPGEN=$YADOMS_BUILD_TOOLS_PATH/pythonhost37/Parser/pgen BLDSHARED="arm-marvell-linux-gnueabi-gcc -shared" CROSS-COMPILE=arm-marvell-linux-gnueabi- CROSS_COMPILE_TARGET=yes HOSTARCH=arm-linux BUILDARCH=arm-marvell-linux-gnueabi  > /dev/null



# PostgreSQL
ARG postgresql_version=9.6.2
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-check-certificate --no-verbose https://ftp.postgresql.org/pub/source/v$postgresql_version/postgresql-$postgresql_version.tar.bz2  > /dev/null\
	&& tar xjf postgresql-$postgresql_version.tar.bz2 && rm postgresql-$postgresql_version.tar.bz2  > /dev/null\
	&& cd postgresql-$postgresql_version  > /dev/null\
	&& CC=arm-marvell-linux-gnueabi-gcc CXX=arm-marvell-linux-gnueabi-g++ AR=arm-marvell-linux-gnueabi-ar RANLIB=arm-marvell-linux-gnueabi-ranlib ./configure --host=arm-linux --build=arm-marvell-linux-gnueabi --without-readline --without-zlib --disable-spinlocks  > /dev/null\
	&& cd src/interfaces/libpq \
	&& make  > /dev/null\
	&& cd ../../../.. && rm -Rf postgresql-$postgresql_version/doc


#COPY synology212.cmake /
#ARG gammu_version=1.40.0
#RUN cd $YADOMS_DEPS_PATH \
#	&& wget --no-check-certificate --no-verbose https://dl.cihar.com/gammu/releases/gammu-$gammu_version.tar.bz2  > /dev/null\
#	&& tar xjf gammu-$gammu_version.tar.bz2  > /dev/null\
#	&& cd gammu-$gammu_version \
#	&& mkdir rpicc \
#	&& cd rpicc \
#	&& cmake -DCC_RPI_GCC=arm-marvell-linux-gnueabi-gcc -DCC_RPI_GXX=arm-marvell-linux-gnueabi-g++ -DBUILD_SHARED_LIBS=OFF -DCMAKE_TOOLCHAIN_FILE=/synology212.cmake -DCMAKE_STAGING_PREFIX=$YADOMS_DEPS_PATH/gammu ..  > /dev/null\
#	&& make  > /dev/null\
#	&& make install  > /dev/null\
#	&& cd ../.. && rm -Rf gammu-1.40.*

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
	&& echo 'set(Python2_EXECUTABLE "/usr/local/bin/python2.7")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python2_LIBRARIES "'$YADOMS_DEPS_PATH'/Python-'$python2_version'/libpython2.7.a")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python2_INCLUDE_DIRS "'$YADOMS_DEPS_PATH'/Python-'$python2_version'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_ManualSetup ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_EXECUTABLE "/usr/local/bin/python3.7")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_LIBRARIES "'$YADOMS_DEPS_PATH'/Python-'$python3_version'/libpython3.7.a")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_INCLUDE_DIRS "'$YADOMS_DEPS_PATH'/Python-'$python3_version'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PostgreSQL_ROOT ' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "'$YADOMS_DEPS_PATH'/postgresql-'$postgresql_version'/src/interfaces/libpq"' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "'$YADOMS_DEPS_PATH'/postgresql-'$postgresql_version'/src/include")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(GAMMU_ROOT "'$YADOMS_DEPS_PATH'/gammu")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(SWIG_ROOT "'$YADOMS_DEPS_PATH'/swig-'$swig_version'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'SET(COTIRE_USE ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'SET(COTIRE_USE_UNITY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(CC_RPI_ROOT "/opt/arm-marvell-linux-gnueabi")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt

#copy entrypoint at root
COPY entrypoint.sh /

#ensure entrypoint is executable (force flags update, because file flags may change if a commit is made under Windows)
RUN chmod +x /entrypoint.sh


