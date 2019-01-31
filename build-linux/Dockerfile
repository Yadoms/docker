FROM debian:stable
MAINTAINER sgallou "https://github.com/sgallou"
LABEL authors=sgallou

ENV YADOMS_BUILD_BRANCH feature/yadoms-conan
ENV MAKE_PACKAGE false
ENV YADOMS_DEPS_PATH /yadoms-deps

RUN apt-get update \
	&& apt-get install -y g++ libbz2-dev python-dev wget build-essential libssl-dev \
	libopencv-gpu-dev autoconf automake libtool curl make g++ unzip \
	libudev-dev libpcre3 libpcre3-dev libpq5 \
	postgresql-server-dev-all git rpm zip

RUN mkdir $YADOMS_DEPS_PATH

# CMake
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://github.com/Kitware/CMake/releases/download/v3.13.1/cmake-3.13.1.tar.gz \
	&& tar xzf cmake-3.13.1.tar.gz && cd cmake-3.13.1 \
	&& ./bootstrap && make && make install \
	&& cd .. && rm -Rf cmake-3.13.1 && rm $YADOMS_DEPS_PATH/cmake-3.13.1.tar.gz

# Swig
RUN cd $YADOMS_DEPS_PATH \
	&& wget --no-verbose https://freefr.dl.sourceforge.net/project/swig/swig/swig-3.0.12/swig-3.0.12.tar.gz \
	&& tar xzf swig-3.0.12.tar.gz \
	&& cd swig-3.0.12 \
	&& ./configure \
	&& make \
	&& make install \
	&& cd .. \
	&& rm -f swig-3.0.12\Source\Modules\*.o \
	&& rm -Rf swig-3.0.12\Examples \
	&& rm -Rf swig-3.0.12\Docs \
	&& rm $YADOMS_DEPS_PATH/swig-3.0.12.tar.gz

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

# Conan
RUN apt-get install -y python-pip
RUN pip install --upgrade pip
RUN pip install conan --upgrade
RUN conan remote add other-conan-repo https://api.bintray.com/conan/bincrafters/public-conan

# Yadoms sources
RUN git clone -b feature/yadoms-conan git://github.com/Yadoms/yadoms.git
	
RUN cd yadoms/projects \
	&& conan install --build missing -s build_type=Debug -o Poco:fPIC=True -o boost:fPIC=True ../sources \
	&& cd ../..
RUN cd yadoms/projects \
	&& conan install --build missing -s build_type=Release -o Poco:fPIC=True -o boost:fPIC=True ../sources \
	&& cd ../..

# Yadoms configuration file
RUN echo 'Configuring Yadoms CMakeListsUserConfig.txt' \
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
	
COPY entrypoint.sh /

#ensure entrypoint is executable (force flags update, because file flags may change if a commit is made under Windows)
RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh

