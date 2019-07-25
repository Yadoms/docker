FROM debian:stretch
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42,sgallou

ENV YADOMS_BUILD_BRANCH develop
ENV MAKE_PACKAGE false
ENV YADOMS_DEPS_PATH /yadoms-deps

RUN apt-get update \
	&& apt-get install -y g++ libbz2-dev python-dev python3-dev wget build-essential libssl-dev \
	libopencv-gpu-dev autoconf automake libtool curl make g++ unzip \
	libudev-dev libpcre3 libpcre3-dev libpq5 \
	postgresql-server-dev-all git rpm zip

RUN mkdir $YADOMS_DEPS_PATH

RUN echo "check_certificate = off" >> ~/.wgetrc

# CMake
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://github.com/Kitware/CMake/releases/download/v3.14.5/cmake-3.14.5.tar.gz \
	&& tar xzf cmake-3.14.5.tar.gz && cd cmake-3.14.5 \
	&& ./bootstrap && make && make install \
	&& cd .. && rm -Rf cmake-3.14.5 && rm $YADOMS_DEPS_PATH/cmake-3.14.5.tar.gz

# Boost
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_70_0.tar.bz2 \
	&& tar xjf boost_1_70_0.tar.bz2 && cd boost_1_70_0 \
	&& ./bootstrap.sh \
	&& ./b2 --with-atomic --with-chrono --with-date_time --with-filesystem --with-locale --with-regex --with-thread --with-system link=static runtime-link=static --no-samples --no-tests cxxflags=-fPIC \
	&& rm -Rf bin.v2 \
	&& rm -Rf doc \
	&& rm -Rf libs \
	&& rm -Rf tools \
	&& cd .. && rm $YADOMS_DEPS_PATH/boost_1_70_0.tar.bz2

# OpenSSL
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://www.openssl.org/source/openssl-1.1.0k.tar.gz \
	&& tar xzf openssl-1.1.0k.tar.gz && cd openssl-1.1.0k \
	&& ./Configure --prefix=$HOME/depsBuild/openssl -fPIC linux-x86_64\
	&& make \
	&& make install \
	&& cd .. && rm -Rf openssl-1.1.0k && rm $YADOMS_DEPS_PATH/openssl-1.1.0k.tar.gz

# Poco
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose http://pocoproject.org/releases/poco-1.9.2/poco-1.9.2-all.tar.gz \
	&& tar xzf poco-1.9.2-all.tar.gz && cd poco-1.9.2-all \
	&& echo 'STATICOPT_CC = -fPIC' >> build/config/Linux \
	&& echo 'STATICOPT_CXX = -fPIC' >> build/config/Linux \
	&& ./configure --static --config=Linux --no-samples --no-tests --omit=CppUnit,CppUnit/WinTestRunner,Data,Data/SQLite,Data/ODBCData/MySQL,MongoDB,PageCompiler,PageCompiler/File2Page --include-path=$HOME/depsBuild/openssl/include --library-path=$HOME/depsBuild/openssl/lib \
	&& make \
	&& cd .. \
	&& find . -name obj -type d -print0 | xargs -0 rm -rf \
	&& rm $YADOMS_DEPS_PATH/poco-1.9.2-all.tar.gz

# Protobuf
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://github.com/google/protobuf/releases/download/v3.8.0/protobuf-cpp-3.8.0.tar.gz \
	&& tar xzf protobuf-cpp-3.8.0.tar.gz && cd protobuf-3.8.0 \
	&& ./autogen.sh \
	&& ./configure --enable-shared=no --prefix=$HOME/depsBuild/protobuf --with-pic \
	&& make \
	&& make install \
	&& ldconfig \
	&& cd .. && rm -Rf protobuf-3.8.0 && rm $YADOMS_DEPS_PATH/protobuf-cpp-3.8.0.tar.gz

# Swig
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose http://prdownloads.sourceforge.net/swig/swig-4.0.0.tar.gz \
	&& tar xzf swig-4.0.0.tar.gz \
	&& cd swig-4.0.0 \
	&& ./configure \
	&& make \
	&& make install \
	&& cd .. \
	&& rm -f swig-4.0.0\Source\Modules\*.o \
	&& rm -Rf swig-4.0.0\Examples \
	&& rm -Rf swig-4.0.0\Docs \
	&& rm $YADOMS_DEPS_PATH/swig-4.0.0.tar.gz

# Python 2.7 
RUN wget --no-verbose https://www.python.org/ftp/python/2.7.16/Python-2.7.16.tgz  > /dev/null\
	&& tar xzf Python-2.7.16.tgz && rm Python-2.7.16.tgz  > /dev/null\
	&& cd Python-2.7.16 \
	&& ./configure --enable-shared --prefix=$YADOMS_DEPS_PATH/python27 > /dev/null\
	&& make > /dev/null\
	&& make install  > /dev/null\
	&& cd ..

# Python 3.7.3
RUN apt-get install -y libffi-dev
RUN wget --no-verbose https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tgz  > /dev/null\
	&& tar xzf Python-3.7.3.tgz && rm Python-3.7.3.tgz  > /dev/null\
	&& cd Python-3.7.3 \
	&& ./configure --enable-shared --without-pymalloc --prefix=$YADOMS_DEPS_PATH/python37 > /dev/null\
	&& make > /dev/null\
	&& make install  > /dev/null\
	&& cd ..

# PostgreSQL
# TODO ne fonctionne pas, à voir...
RUN apt-get install -y libreadline-dev
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://ftp.postgresql.org/pub/source/v9.6.2/postgresql-9.6.2.tar.bz2 \
	&& tar xjf postgresql-9.6.2.tar.bz2 \
	&& cd postgresql-9.6.2 \
	&& ./configure \
	&& cd src/interfaces/libpq \
	&& make \
	&& cd .. && rm -Rf postgresql-9.6.2/doc && rm $YADOMS_DEPS_PATH/postgresql-9.6.2.tar.bz2

# Gammu
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://dl.cihar.com/gammu/releases/gammu-1.40.0.tar.bz2  > /dev/null\
	&& tar xjf gammu-1.40.0.tar.bz2  > /dev/null\
	&& cd gammu-1.40.0 \
	&& mkdir rpicc \
	&& cd rpicc \
	&& cmake -DBUILD_SHARED_LIBS=OFF -DCMAKE_STAGING_PREFIX=$YADOMS_DEPS_PATH/gammu ..  > /dev/null\
	&& make  > /dev/null\
	&& make install  > /dev/null\
	&& cd ../.. && rm -Rf gammu-1.40.*


# Yadoms configuration file
RUN echo 'Configuring Yadoms CMakeListsUserConfig.txt' \
	&& echo 'set(BOOST_ROOT "'$YADOMS_DEPS_PATH'/boost_1_70_0")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(POCO_ROOT "'$YADOMS_DEPS_PATH'/poco-1.9.2-all")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_ROOT "'$HOME'/depsBuild/protobuf")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_PROTOC_EXECUTABLE "'$HOME'/depsBuild/protobuf/bin/protoc")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PROTOBUF_INSTALLED_TO_CUSTOM_DIRECTORY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(OPENSSL_ROOT "'$HOME'/depsBuild/openssl")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(DEBUG_WITH_GCC OFF)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_USE_PKGCONFIG OFF)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_USE_SOURCES ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_ROOT "'$YADOMS_DEPS_PATH'/Python-2.7.16")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON_LIBRARIES "'$YADOMS_DEPS_PATH'/Python-2.7.16/libpython2.7.so")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python2_ROOT "'$YADOMS_DEPS_PATH'/Python-2.7.16")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON27_LIBRARIES "'$YADOMS_DEPS_PATH'/Python-2.7.16/libpython2.7.so")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_ROOT "'$YADOMS_DEPS_PATH'/Python-3.7.3")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(Python3_ROOT_DIR "'$YADOMS_DEPS_PATH'/Python-2.7.16")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PYTHON3_LIBRARIES "'$YADOMS_DEPS_PATH'/Python-3.7.3/libpython3.7.so")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(PostgreSQL_ROOT ' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "'$YADOMS_DEPS_PATH'/postgresql-9.6.2/src/interfaces/libpq"' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo '       "'$YADOMS_DEPS_PATH'/postgresql-9.6.2/src/include")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(GAMMU_ROOT "'$YADOMS_DEPS_PATH'/gammu")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'set(SWIG_ROOT "'$YADOMS_DEPS_PATH'/swig-4.0.0")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'SET(COTIRE_USE ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
	&& echo 'SET(COTIRE_USE_UNITY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt

COPY entrypoint.sh /

#ensure entrypoint is executable (force flags update, because file flags may change if a commit is made under Windows)
RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh

