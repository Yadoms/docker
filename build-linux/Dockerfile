FROM debian:stretch
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42,sgallou

ENV YADOMS_BUILD_BRANCH develop
ENV MAKE_PACKAGE false
ENV YADOMS_DEPS_PATH /yadoms-deps

RUN apt-get update \
	&& apt-get install -y g++ libbz2-dev python-dev python3-dev wget build-essential libssl-dev \
	libopencv-gpu-dev autoconf automake libtool curl make g++ unzip \
	libpcre3 libpcre3-dev libpq5 \
	postgresql-server-dev-all git rpm zip

RUN mkdir $YADOMS_DEPS_PATH

RUN echo "check_certificate = off" >> ~/.wgetrc

# CMake
ARG cmake_version=3.15.2
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://github.com/Kitware/CMake/releases/download/v$cmake_version/cmake-$cmake_version.tar.gz \
	&& tar xzf cmake-$cmake_version.tar.gz && cd cmake-$cmake_version \
	&& ./bootstrap && make && make install \
	&& cd .. && rm -Rf cmake-$cmake_version && rm $YADOMS_DEPS_PATH/cmake-$cmake_version.tar.gz

# Boost
ARG boost_version=1_71_0
ARG boost_version_dot=1.71.0
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://dl.bintray.com/boostorg/release/$boost_version_dot/source/boost_$boost_version.tar.bz2 \
	&& tar xjf boost_$boost_version.tar.bz2 && cd boost_$boost_version \
	&& ./bootstrap.sh \
	&& ./b2 --with-atomic --with-chrono --with-date_time --with-filesystem --with-locale --with-regex --with-thread --with-system link=static runtime-link=static --no-samples --no-tests cxxflags=-fPIC \
	&& rm -Rf bin.v2 \
	&& rm -Rf doc \
	&& rm -Rf libs \
	&& rm -Rf tools \
	&& cd .. && rm $YADOMS_DEPS_PATH/boost_$boost_version.tar.bz2

# OpenSSL
ARG openssl_version=1.1.1d
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://www.openssl.org/source/old/$openssl_version/openssl-$openssl_version.tar.gz \
	&& tar xzf openssl-$openssl_version.tar.gz && cd openssl-$openssl_version \
	&& ./Configure --prefix=$HOME/depsBuild/openssl -fPIC linux-x86_64\
	&& make \
	&& make install \
	&& cd .. && rm -Rf openssl-$openssl_version && rm $YADOMS_DEPS_PATH/openssl-$openssl_version.tar.gz

# Poco
ARG poco_version=1.9.4
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose http://pocoproject.org/releases/poco-$poco_version/poco-$poco_version-all.tar.gz \
	&& tar xzf poco-$poco_version-all.tar.gz && cd poco-$poco_version-all \
	&& echo 'STATICOPT_CC = -fPIC' >> build/config/Linux \
	&& echo 'STATICOPT_CXX = -fPIC' >> build/config/Linux \
	&& ./configure --static --config=Linux --no-samples --no-tests --omit=CppUnit,CppUnit/WinTestRunner,Data,Data/SQLite,Data/ODBCData/MySQL,MongoDB,PageCompiler,PageCompiler/File2Page --include-path=$HOME/depsBuild/openssl/include --library-path=$HOME/depsBuild/openssl/lib \
	&& make \
	&& cd .. \
	&& find . -name obj -type d -print0 | xargs -0 rm -rf \
	&& rm $YADOMS_DEPS_PATH/poco-$poco_version-all.tar.gz

# Protobuf
ARG protobuf_version=3.11.1
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://github.com/google/protobuf/releases/download/v$protobuf_version/protobuf-cpp-$protobuf_version.tar.gz \
	&& tar xzf protobuf-cpp-$protobuf_version.tar.gz && cd protobuf-$protobuf_version \
	&& ./autogen.sh \
	&& ./configure --enable-shared=no --prefix=$HOME/depsBuild/protobuf --with-pic \
	&& make \
	&& make install \
	&& ldconfig \
	&& cd .. && rm -Rf protobuf-$protobuf_version && rm $YADOMS_DEPS_PATH/protobuf-cpp-$protobuf_version.tar.gz

# Swig
ARG swig_version=4.0.1
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose http://prdownloads.sourceforge.net/swig/swig-$swig_version.tar.gz \
	&& tar xzf swig-$swig_version.tar.gz \
	&& cd swig-$swig_version \
	&& ./configure \
	&& make \
	&& make install \
	&& cd .. \
	&& rm -f swig-$swig_version\Source\Modules\*.o \
	&& rm -Rf swig-$swig_version\Examples \
	&& rm -Rf swig-$swig_version\Docs \
	&& rm $YADOMS_DEPS_PATH/swig-$swig_version.tar.gz

# Python 2.7 
ARG python2_version=2.7.16
RUN wget --no-verbose https://www.python.org/ftp/python/$python2_version/Python-$python2_version.tgz  > /dev/null\
	&& tar xzf Python-$python2_version.tgz && rm Python-$python2_version.tgz  > /dev/null\
	&& cd Python-$python2_version \
	&& ./configure --enable-shared --prefix=$YADOMS_DEPS_PATH/python27 > /dev/null\
	&& make > /dev/null\
	&& make install  > /dev/null\
	&& cd ..

# Python $python3_version
ARG python3_version=3.7.3
RUN apt-get install -y libffi-dev
RUN wget --no-verbose https://www.python.org/ftp/python/$python3_version/Python-$python3_version.tgz  > /dev/null\
	&& tar xzf Python-$python3_version.tgz && rm Python-$python3_version.tgz  > /dev/null\
	&& cd Python-$python3_version \
	&& ./configure --enable-shared --without-pymalloc --prefix=$YADOMS_DEPS_PATH/python37 > /dev/null\
	&& make > /dev/null\
	&& make install  > /dev/null\
	&& cd ..

# PostgreSQL
ARG postgresql_version=9.6.2
RUN apt-get install -y libreadline-dev
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://ftp.postgresql.org/pub/source/v$postgresql_version/postgresql-$postgresql_version.tar.bz2 \
	&& tar xjf postgresql-$postgresql_version.tar.bz2 \
	&& cd postgresql-$postgresql_version \
	&& ./configure \
	&& cd src/interfaces/libpq \
	&& make \
	&& cd .. && rm -Rf postgresql-$postgresql_version/doc && rm $YADOMS_DEPS_PATH/postgresql-$postgresql_version.tar.bz2

# Gammu
ARG gammu_version=1.40.0
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://dl.cihar.com/gammu/releases/gammu-$gammu_version.tar.bz2  > /dev/null\
	&& tar xjf gammu-$gammu_version.tar.bz2  > /dev/null\
	&& cd gammu-$gammu_version \
	&& mkdir rpicc \
	&& cd rpicc \
	&& cmake -DBUILD_SHARED_LIBS=OFF -DCMAKE_STAGING_PREFIX=$YADOMS_DEPS_PATH/gammu ..  > /dev/null\
	&& make  > /dev/null\
	&& make install  > /dev/null\
	&& cd ../.. && rm -Rf gammu-$gammu_version*


# Yadoms configuration file
RUN echo 'Configuring Yadoms CMakeListsUserConfig.txt' \
	&& echo 'set(BOOST_ROOT "'$YADOMS_DEPS_PATH'/boost_'$boost_version'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(POCO_ROOT "'$YADOMS_DEPS_PATH'/poco-'$poco_version-all'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_ROOT "'$HOME'/depsBuild/protobuf")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_PROTOC_EXECUTABLE "'$HOME'/depsBuild/protobuf/bin/protoc")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_INSTALLED_TO_CUSTOM_DIRECTORY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(OPENSSL_ROOT "'$HOME'/depsBuild/openssl")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(DEBUG_WITH_GCC OFF)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_USE_PKGCONFIG OFF)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_USE_SOURCES ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_ROOT "'$YADOMS_DEPS_PATH'/Python-'$python2_version'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_LIBRARIES "'$YADOMS_DEPS_PATH'/Python-'$python2_version'/libpython2.7.so")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python2_ROOT "'$YADOMS_DEPS_PATH'/Python-'$python2_version'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON27_LIBRARIES "'$YADOMS_DEPS_PATH'/Python-'$python2_version'/libpython2.7.so")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_ROOT "'$YADOMS_DEPS_PATH'/Python-'$python3_version'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_ROOT_DIR "'$YADOMS_DEPS_PATH'/Python-'$python2_version'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON3_LIBRARIES "'$YADOMS_DEPS_PATH'/Python-'$python3_version'/libpython3.7.so")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PostgreSQL_ROOT ' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "'$YADOMS_DEPS_PATH'/postgresql-'$postgresql_version'/src/interfaces/libpq"' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "'$YADOMS_DEPS_PATH'/postgresql-'$postgresql_version'/src/include")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(GAMMU_ROOT "'$YADOMS_DEPS_PATH'/gammu")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(SWIG_ROOT "'$YADOMS_DEPS_PATH'/swig-'$swig_version'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'SET(COTIRE_USE ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'SET(COTIRE_USE_UNITY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt

COPY entrypoint.sh /

#ensure entrypoint is executable (force flags update, because file flags may change if a commit is made under Windows)
RUN chmod +x /entrypoint.sh



