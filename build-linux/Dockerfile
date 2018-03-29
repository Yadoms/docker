FROM ubuntu:16.04
MAINTAINER sgallou "https://github.com/sgallou"
LABEL authors=sgallou

ENV YADOMS_BUILD_BRANCH develop
ENV YADOMS_DEPS_PATH /yadoms-deps

RUN apt-get update \
	&& apt-get install -y g++ libbz2-dev python-dev wget build-essential libssl-dev \
	libopencv-gpu-dev libgnutls-dev autoconf automake libtool curl make g++ unzip \
	libudev-dev libpcre3 libpcre3-dev libreadline6 libreadline6-dev libpq5 \
	postgresql-server-dev-all git 

RUN mkdir $YADOMS_DEPS_PATH

# CMake
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://cmake.org/files/v3.11/cmake-3.11.0-rc4.tar.gz \
	&& tar zxvf cmake-3.11.0-rc4.tar.gz
RUN cd $YADOMS_DEPS_PATH/cmake-3.11.0-rc4 \
	&& ./bootstrap \
	&& make \
	&& make install
RUN rm $YADOMS_DEPS_PATH/cmake-3.11.0-rc4.tar.gz

# Boost
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose http://netcologne.dl.sourceforge.net/project/boost/boost/1.66.0/boost_1_66_0.tar.bz2 \
	&& tar xvjf boost_1_66_0.tar.bz2
RUN cd $YADOMS_DEPS_PATH/boost_1_66_0 \
	&& ./bootstrap.sh \
	&& ./b2 --with-atomic --with-chrono --with-date_time --with-filesystem --with-regex --with-thread --with-system link=static runtime-link=static cxxflags=-fPIC
RUN rm $YADOMS_DEPS_PATH/boost_1_66_0.tar.bz2

# OpenSSL
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://www.openssl.org/source/openssl-1.1.0g.tar.gz \
	&& tar xzf openssl-1.1.0g.tar.gz
RUN cd $YADOMS_DEPS_PATH/openssl-1.1.0g \
	&& ./config --prefix=$HOME/depsBuild/openssl \
	&& make \
	&& make install
RUN rm $YADOMS_DEPS_PATH/openssl-1.1.0g.tar.gz

# Poco
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose http://pocoproject.org/releases/poco-1.8.1/poco-1.8.1-all.tar.gz \
	&& tar xzf poco-1.8.1-all.tar.gz
RUN cd $YADOMS_DEPS_PATH/poco-1.8.1-all \
	&& echo 'STATICOPT_CC = -fPIC' >> build/config/Linux \
	&& echo 'STATICOPT_CXX = -fPIC' >> build/config/Linux \
	&& ./configure --static --config=Linux --no-samples --no-tests --omit=CppUnit,CppUnit/WinTestRunner,Data,Data/SQLite,Data/ODBCData/MySQL,MongoDB,PageCompiler,PageCompiler/File2Page --include-path=$HOME/depsBuild/openssl/include --library-path=$HOME/depsBuild/openssl/lib \
	&& make
RUN rm $YADOMS_DEPS_PATH/poco-1.8.1-all.tar.gz

# Protobuf
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://github.com/google/protobuf/releases/download/v3.4.1/protobuf-cpp-3.4.1.tar.gz \
	&& tar xzf protobuf-cpp-3.4.1.tar.gz
RUN cd $YADOMS_DEPS_PATH/protobuf-3.4.1 \
	&& ./autogen.sh \
	&& ./configure --enable-shared=no --prefix=$HOME/depsBuild/protobuf --with-pic \
	&& make \
	&& make install \
	&& ldconfig
RUN rm $YADOMS_DEPS_PATH/protobuf-cpp-3.4.1.tar.gz

# Swig
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose http://prdownloads.sourceforge.net/swig/swig-3.0.12.tar.gz \
	&& tar xzf swig-3.0.12.tar.gz
RUN cd $YADOMS_DEPS_PATH/swig-3.0.12 \
	&& ./configure \
	&& make
RUN rm $YADOMS_DEPS_PATH/swig-3.0.12.tar.gz

# PostgreSQL
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://ftp.postgresql.org/pub/source/v9.6.2/postgresql-9.6.2.tar.bz2 \
	&& tar xjf postgresql-9.6.2.tar.bz2
RUN cd $YADOMS_DEPS_PATH/postgresql-9.6.2 \
	&& ./configure \
	&& cd src/interfaces/libpq \
	&& make
RUN rm $YADOMS_DEPS_PATH/postgresql-9.6.2.tar.bz2

# Yadoms sources
RUN echo 'Branche Yadoms = $YADOMS_BUILD_BRANCH'
RUN git clone --depth=1 -b $YADOMS_BUILD_BRANCH git://github.com/Yadoms/yadoms.git

# Yadoms configuration file
RUN echo 'Configuring Yadoms CMakeListsUserConfig.txt' \
	&& echo 'set(ALTERNATIVE_CMAKE_ROOT "'$YADOMS_DEPS_PATH'/cmake-3.11.0-rc4")' > $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(BOOST_ROOT "'$YADOMS_DEPS_PATH'/boost_1_66_0")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(POCO_ROOT "'$YADOMS_DEPS_PATH'/poco-1.8.1-all")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_ROOT "'$HOME'/depsBuild/protobuf")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_PROTOC_EXECUTABLE "'$HOME'/depsBuild/protobuf/bin/protoc")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_INSTALLED_TO_CUSTOM_DIRECTORY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(OPENSSL_ROOT "'$HOME'/depsBuild/openssl")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(DEBUG_WITH_GCC OFF)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_USE_PKGCONFIG ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_USE_SOURCES OFF)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PostgreSQL_ROOT ' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "'$YADOMS_DEPS_PATH'/postgresql-9.6.2/src/interfaces/libpq"' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "'$YADOMS_DEPS_PATH'/postgresql-9.6.2/src/include")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(GAMMU_ROOT "'$YADOMS_DEPS_PATH'/gammu-1.38.4")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(SWIG_ROOT "'$YADOMS_DEPS_PATH'/swig-3.0.12")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'SET(COTIRE_USE ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'SET(COTIRE_USE_UNITY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt
RUN echo 'Result:' \
	&& cat $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt


# Update Yadoms Git repository
CMD cd yadoms \
	&& git fetch \
	&& git checkout $YADOMS_BUILD_BRANCH \
	&& git clean -d -x -f \
	&& cp $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt sources/ \
	&& sh cmake_linux.sh m \
	&& cd projects \
	&& make all_unity
