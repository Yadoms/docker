FROM mcr.microsoft.com/windows/servercore:ltsc2019
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42

ENV YADOMS_BUILD_BRANCH develop
ENV MAKE_PACKAGE false
ENV YADOMS_DEPS_PATH  C:\\yadoms-deps

#Setup default shell
SHELL ["cmd", "/S", "/C"]

#ok for Powershell (shell)
#RUN echo $env:YADOMS_DEPS_PATH
#ok for Cmd (shell)
#RUN echo %YADOMS_DEPS_PATH%

# Create working folders
RUN powershell.exe -Command New-Item -ItemType Directory -Path %YADOMS_DEPS_PATH%



###################################################################
# Install VisualStudio Tools
###################################################################

# Download the Build Tools bootstrapper.
RUN powershell.exe -Command (New-Object System.Net.WebClient).DownloadFile('https://aka.ms/vs/16/release/vs_buildtools.exe', '%YADOMS_DEPS_PATH%\\vs_buildtools.exe')

# Install Build Tools with the Microsoft.VisualStudio.Workload.AzureBuildTools workload, excluding workloads and components with known issues.
RUN %YADOMS_DEPS_PATH%\\vs_buildtools.exe --quiet --wait --norestart --nocache \
    --installPath C:\BuildTools \
    --add Microsoft.VisualStudio.Workload.MSBuildTools \
    --add Microsoft.VisualStudio.Workload.VCTools \
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 \
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 \
    --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 \
    --remove Microsoft.VisualStudio.Component.Windows81SDK \
 || IF "%ERRORLEVEL%"=="3010" EXIT 0
 

# Start developer command prompt with any other commands specified.
#ENTRYPOINT C:\BuildTools\Common7\Tools\VsDevCmd.bat -arch=amd64 &&

###################################################################
# Install chocolatey
###################################################################

# install chocolatey
RUN powershell.exe -Command iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

###################################################################
# Install yadoms dependencies
###################################################################

# CMake
ARG cmake_version=3.18.1
RUN choco install cmake --installargs 'ADD_CMAKE_TO_PATH=System' -y --no-progress --version %cmake_version%

# Boost
ARG boost_version_major=1
ARG boost_version_minor=74
ARG boost_version_patch=0
ARG boost_underscore=_
ARG boost_version=$boost_version_major$boost_underscore$boost_version_minor$boost_underscore$boost_version_patch
ARG boost_version_dot=$boost_version_major.$boost_version_minor.$boost_version_patch
RUN cd %YADOMS_DEPS_PATH% \
   && powershell.exe -Command (New-Object System.Net.WebClient).DownloadFile('https://dl.bintray.com/boostorg/release/%boost_version_dot%/source/boost_%boost_version%.zip", '%YADOMS_DEPS_PATH%\\boost_%boost_version%.zip') \
   && powershell.exe -Command Expand-Archive -Path boost_%boost_version%.zip '%YADOMS_DEPS_PATH%'\
   && cd boost_%boost_version% \
   &&.\bootstrap.bat \
   && b2.exe --with-atomic --with-chrono --with-date_time --with-filesystem --with-regex --with-thread --with-system --with-test link=static runtime-link=static \
   && powershell.exe -Command Remove-Item -Path bin.v2 -Recurse \
   && powershell.exe -Command Remove-Item -Path doc -Recurse \
   && powershell.exe -Command Remove-Item -Path libs -Recurse \
   && powershell.exe -Command Remove-Item -Path tools -Recurse \
   && cd .. && powershell.exe -Command Remove-Item -Path boost_%boost_versionn%.zip

# OpenSSL (for chocolatey, 1.1.1.700 match 1.1.1g (g is the 7th...)
ARG openssl_version=1.1.1.700
RUN choco install openssl --x86 -y --no-progress --version %openssl_version%
 

## 	RUN cd $YADOMS_DEPS_PATH \
## 		&& wget --no-verbose https://dl.bintray.com/boostorg/release/$boost_version_dot/source/boost_$boost_version.tar.bz2 \
## 		&& tar xjf boost_$boost_version.tar.bz2 && cd boost_$boost_version \
## 		&& ./bootstrap.sh \
## 		&& ./b2 --with-atomic --with-chrono --with-date_time --with-filesystem --with-locale --with-regex --with-thread --with-system link=static runtime-link=static --no-samples --no-tests cxxflags=-fPIC \
## 		&& rm -Rf bin.v2 \
## 		&& rm -Rf doc \
## 		&& rm -Rf libs \
## 		&& rm -Rf tools \
## 		&& cd .. && rm $YADOMS_DEPS_PATH/boost_$boost_version.tar.bz2
## 	
## 	# OpenSSL
## 	ARG openssl_version=1.1.1g
## 	RUN cd $YADOMS_DEPS_PATH \
## 		&& wget --no-verbose https://www.openssl.org/source/openssl-$openssl_version.tar.gz \
## 		&& tar xzf openssl-$openssl_version.tar.gz && cd openssl-$openssl_version \
## 		&& ./Configure --prefix=$YADOMS_DEPS_PATH/openssl -fPIC linux-x86_64\
## 		&& make \
## 		&& make install \
## 		&& cd .. && rm -Rf openssl-$openssl_version && rm $YADOMS_DEPS_PATH/openssl-$openssl_version.tar.gz \
## 		&& rm -Rf $YADOMS_DEPS_PATH/openssl/share
## 	
## 	# Poco
## 	ARG poco_version=1.9.4
## 	RUN cd $YADOMS_DEPS_PATH \
## 		&& wget --no-verbose https://pocoproject.org/releases/poco-$poco_version/poco-$poco_version-all.tar.gz \
## 		&& tar xzf poco-$poco_version-all.tar.gz && cd poco-$poco_version-all \
## 		&& echo 'STATICOPT_CC = -fPIC' >> build/config/Linux \
## 		&& echo 'STATICOPT_CXX = -fPIC' >> build/config/Linux \
## 		&& ./configure --static --config=Linux --no-samples --no-tests --omit=CppUnit,CppUnit/WinTestRunner,Data,Data/SQLite,Data/ODBCData/MySQL,MongoDB,PageCompiler,PageCompiler/File2Page --include-path=$HOME/depsBuild/openssl/include --library-path=$HOME/depsBuild/openssl/lib \
## 		&& make \
## 		&& cd .. \
## 		&& find . -name obj -type d -print0 | xargs -0 rm -rf \
## 		&& rm $YADOMS_DEPS_PATH/poco-$poco_version-all.tar.gz
## 	
## 	# Protobuf
## 	ARG protobuf_version=3.13.0
## 	RUN cd $YADOMS_DEPS_PATH \
## 		&& wget --no-verbose https://github.com/google/protobuf/releases/download/v$protobuf_version/protobuf-cpp-$protobuf_version.tar.gz \
## 		&& tar xzf protobuf-cpp-$protobuf_version.tar.gz && cd protobuf-$protobuf_version \
## 		&& ./autogen.sh \
## 		&& ./configure --enable-shared=no --prefix=$YADOMS_DEPS_PATH/protobuf --with-pic \
## 		&& make \
## 		&& make install \
## 		&& ldconfig \
## 		&& cd .. && rm -Rf protobuf-$protobuf_version && rm $YADOMS_DEPS_PATH/protobuf-cpp-$protobuf_version.tar.gz \
## 		&& rm -f $YADOMS_DEPS_PATH/protobuf/lib/libprotoc.* && rm -f $YADOMS_DEPS_PATH/protobuf/lib/libprotobuf-lite.*
## 	
## 	
## 	# Swig
## 	ARG swig_version=4.0.2
## 	RUN cd $YADOMS_DEPS_PATH \
## 		&& wget --no-verbose http://prdownloads.sourceforge.net/swig/swig-$swig_version.tar.gz \
## 		&& tar xzf swig-$swig_version.tar.gz \
## 		&& cd swig-$swig_version \
## 		&& ./configure \
## 		&& make \
## 		&& make install \
## 		&& cd .. \
## 		&& rm -f swig-$swig_version/Source/Modules/*.o \
## 		&& rm -Rf swig-$swig_version/Examples \
## 		&& rm -Rf swig-$swig_version/Docs \
## 		&& rm $YADOMS_DEPS_PATH/swig-$swig_version.tar.gz
## 	
## 	# Python 2.7 
## 	ARG python2_version_maj=2
## 	ARG python2_version_min=7
## 	ARG python2_version_patch=18
## 	ARG python2_version=$python2_version_maj.$python2_version_min.$python2_version_patch
## 	RUN wget --no-verbose https://www.python.org/ftp/python/$python2_version/Python-$python2_version.tgz  > /dev/null\
## 		&& tar xzf Python-$python2_version.tgz && rm Python-$python2_version.tgz  > /dev/null\
## 		&& cd Python-$python2_version \
## 		&& ./configure --enable-shared --prefix=$YADOMS_DEPS_PATH/python$python2_version_maj$python2_version_min > /dev/null\
## 		&& make > /dev/null\
## 		&& make install  > /dev/null\
## 		&& cd .. \
## 		&& rm -Rf Python-$python2_version && rm -Rf $YADOMS_DEPS_PATH/python$python2_version_maj$python2_version_min/lib/python$python2_version_maj$.python2_version_min
## 	
## 	# Python $python3_version
## 	ARG python3_version_maj=3
## 	ARG python3_version_min=8
## 	ARG python3_version_patch=5
## 	ARG python3_version=$python3_version_maj.$python3_version_min.$python3_version_patch
## 	RUN wget --no-verbose https://www.python.org/ftp/python/$python3_version/Python-$python3_version.tgz  > /dev/null\
## 		&& tar xzf Python-$python3_version.tgz && rm Python-$python3_version.tgz  > /dev/null\
## 		&& cd Python-$python3_version \
## 		&& ./configure --enable-shared --without-pymalloc --prefix=$YADOMS_DEPS_PATH/python$python3_version_maj$python3_version_min > /dev/null\
## 		&& make > /dev/null\
## 		&& make install  > /dev/null\
## 		&& cd ..\
## 		&& rm -Rf Python-$python3_version && rm -Rf $YADOMS_DEPS_PATH/python$python3_version_maj$python3_version_min/lib/python$python3_version_maj.$python3_version_min
## 	
## 	# PostgreSQL
## 	ARG postgresql_version=9.6.2
## 	RUN cd $YADOMS_DEPS_PATH \
## 		&& wget --no-verbose https://ftp.postgresql.org/pub/source/v$postgresql_version/postgresql-$postgresql_version.tar.bz2 \
## 		&& tar xjf postgresql-$postgresql_version.tar.bz2 \
## 		&& cd postgresql-$postgresql_version \
## 		&& ./configure \
## 		&& cd src/interfaces/libpq \
## 		&& make \
## 		&& cd ../../../.. && rm -Rf postgresql-$postgresql_version/doc && rm $YADOMS_DEPS_PATH/postgresql-$postgresql_version.tar.bz2
## 	
## 	# Gammu
## 	ARG gammu_version=1.41.0
## 	RUN cd $YADOMS_DEPS_PATH \
## 		&& wget --no-verbose https://dl.cihar.com/gammu/releases/gammu-$gammu_version.tar.bz2  > /dev/null\
## 		&& tar xjf gammu-$gammu_version.tar.bz2  > /dev/null\
## 		&& cd gammu-$gammu_version \
## 		&& mkdir rpicc \
## 		&& cd rpicc \
## 		&& cmake -DBUILD_SHARED_LIBS=OFF -DWITH_Glib=OFF -DCMAKE_STAGING_PREFIX=$YADOMS_DEPS_PATH/gammu ..  > /dev/null\
## 		&& make  > /dev/null\
## 		&& make install  > /dev/null\
## 		&& cd ../.. && rm -Rf gammu-$gammu_version*
## 	
## 	# Opencv
## 	ARG opencv_version=4.3.0
## 	RUN cd $YADOMS_DEPS_PATH \
## 		&& wget --no-verbose https://github.com/opencv/opencv/archive/$opencv_version.zip  > /dev/null\
## 		&& unzip $opencv_version.zip  > /dev/null\
## 		&& cd opencv-$opencv_version \
## 		&& mkdir build \
## 		&& cd build \
## 		&& cmake -DWITH_EIGEN:BOOL="0" -DWITH_IMGCODEC_HDR:BOOL="0" -DBUILD_opencv_ts:BOOL="0" -DBUILD_opencv_video:BOOL="0" -DWITH_TIFF:BOOL="0" -DBUILD_PACKAGE:BOOL="0" -DBUILD_opencv_features2d:BOOL="0" -DBUILD_ITT:BOOL="0" -Dthunder:BOOL="0" -Dlzw:BOOL="0" -DCV_TRACE:BOOL="0" -DWITH_MSMF:BOOL="0" -DWITH_FFMPEG:BOOL="0" -DWITH_IMGCODEC_PXM:BOOL="0" -DWITH_MSMF_DXVA:BOOL="0" -DCPACK_SOURCE_ZIP:BOOL="0" -Dpackbits:BOOL="0" -DBUILD_opencv_apps:BOOL="0" -DBUILD_PROTOBUF:BOOL="0" -DBUILD_opencv_objdetect:BOOL="0" -DBUILD_IPP_IW:BOOL="0" -DBUILD_opencv_videoio:BOOL="0" -DBUILD_PERF_TESTS:BOOL="0" -Dmdi:BOOL="0" -DWITH_1394:BOOL="0" -DINSTALL_PDB:BOOL="0" -DWITH_OPENCL:BOOL="0" -DM_LIBRARY:FILEPATH="M_LIBRARY-NOTFOUND" -DUSE_WIN32_FILEIO:BOOL="1" -DCPACK_SOURCE_7Z:BOOL="0" -DBUILD_opencv_stitching:BOOL="0" -Dccitt:BOOL="0" -DVIDEOIO_ENABLE_STRICT_PLUGIN_CHECK:BOOL="0" -DWITH_IPP:BOOL="0" -DBUILD_opencv_dnn:BOOL="0" -DWITH_ITT:BOOL="0" -DCPACK_BINARY_NSIS:BOOL="0" -DBUILD_opencv_photo:BOOL="0" -DBUILD_opencv_calib3d:BOOL="0" -DWITH_QUIRC:BOOL="0" -DWITH_WEBP:BOOL="0" -DBUILD_opencv_python_bindings_generator:BOOL="0" -DWITH_PROTOBUF:BOOL="0" -DBUILD_JASPER:BOOL="1" -DWITH_OPENCLAMDBLAS:BOOL="0" -DBUILD_JAVA:BOOL="0" -DWITH_VTK:BOOL="0" -DBUILD_opencv_java_bindings_generator:BOOL="0" -DBUILD_opencv_highgui:BOOL="0" -DWITH_ARITH_DEC:BOOL="0" -DWITH_IMGCODEC_SUNRASTER:BOOL="0" -DWITH_ADE:BOOL="0" -DBUILD_OPENEXR:BOOL="0" -DWITH_OPENEXR:BOOL="0" -DWITH_OPENCLAMDFFT:BOOL="0" -DVIDEOIO_ENABLE_PLUGINS:BOOL="0" -DWITH_DSHOW:BOOL="0" -DOPENCV_DNN_OPENCL:BOOL="0" -DWITH_LAPACK:BOOL="0" -DWITH_IMGCODEC_PFM:BOOL="0" -Dlogluv:BOOL="0" -DINSTALL_PDB_COMPONENT_EXCLUDE_FROM_ALL:BOOL="0" -DBUILD_opencv_ml:BOOL="0" -DOPENCV_ENABLE_MEMALIGN:BOOL="0" -DBUILD_opencv_python_tests:BOOL="0" -DCV_ENABLE_INTRINSICS:BOOL="0" -DOPENCL_FOUND:BOOL="0" -DWITH_OPENCL_D3D11_NV:BOOL="0" -Dnext:BOOL="0" -DBUILD_opencv_gapi:BOOL="0" -DBUILD_opencv_flann:BOOL="0" -DBUILD_TESTS:BOOL="0" -DWITH_DIRECTX:BOOL="0" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$YADOMS_DEPS_PATH/opencv .. >/dev/null \
## 		&& make  > /dev/null\
## 		&& make install  > /dev/null\
## 		&& cmake -DWITH_EIGEN:BOOL="0" -DWITH_IMGCODEC_HDR:BOOL="0" -DBUILD_opencv_ts:BOOL="0" -DBUILD_opencv_video:BOOL="0" -DWITH_TIFF:BOOL="0" -DBUILD_PACKAGE:BOOL="0" -DBUILD_opencv_features2d:BOOL="0" -DBUILD_ITT:BOOL="0" -Dthunder:BOOL="0" -Dlzw:BOOL="0" -DCV_TRACE:BOOL="0" -DWITH_MSMF:BOOL="0" -DWITH_FFMPEG:BOOL="0" -DWITH_IMGCODEC_PXM:BOOL="0" -DWITH_MSMF_DXVA:BOOL="0" -DCPACK_SOURCE_ZIP:BOOL="0" -Dpackbits:BOOL="0" -DBUILD_opencv_apps:BOOL="0" -DBUILD_PROTOBUF:BOOL="0" -DBUILD_opencv_objdetect:BOOL="0" -DBUILD_IPP_IW:BOOL="0" -DBUILD_opencv_videoio:BOOL="0" -DBUILD_PERF_TESTS:BOOL="0" -Dmdi:BOOL="0" -DWITH_1394:BOOL="0" -DINSTALL_PDB:BOOL="0" -DWITH_OPENCL:BOOL="0" -DM_LIBRARY:FILEPATH="M_LIBRARY-NOTFOUND" -DUSE_WIN32_FILEIO:BOOL="1" -DCPACK_SOURCE_7Z:BOOL="0" -DBUILD_opencv_stitching:BOOL="0" -Dccitt:BOOL="0" -DVIDEOIO_ENABLE_STRICT_PLUGIN_CHECK:BOOL="0" -DWITH_IPP:BOOL="0" -DBUILD_opencv_dnn:BOOL="0" -DWITH_ITT:BOOL="0" -DCPACK_BINARY_NSIS:BOOL="0" -DBUILD_opencv_photo:BOOL="0" -DBUILD_opencv_calib3d:BOOL="0" -DWITH_QUIRC:BOOL="0" -DWITH_WEBP:BOOL="0" -DBUILD_opencv_python_bindings_generator:BOOL="0" -DWITH_PROTOBUF:BOOL="0" -DBUILD_JASPER:BOOL="1" -DWITH_OPENCLAMDBLAS:BOOL="0" -DBUILD_JAVA:BOOL="0" -DWITH_VTK:BOOL="0" -DBUILD_opencv_java_bindings_generator:BOOL="0" -DBUILD_opencv_highgui:BOOL="0" -DWITH_ARITH_DEC:BOOL="0" -DWITH_IMGCODEC_SUNRASTER:BOOL="0" -DWITH_ADE:BOOL="0" -DBUILD_OPENEXR:BOOL="0" -DWITH_OPENEXR:BOOL="0" -DWITH_OPENCLAMDFFT:BOOL="0" -DVIDEOIO_ENABLE_PLUGINS:BOOL="0" -DWITH_DSHOW:BOOL="0" -DOPENCV_DNN_OPENCL:BOOL="0" -DWITH_LAPACK:BOOL="0" -DWITH_IMGCODEC_PFM:BOOL="0" -Dlogluv:BOOL="0" -DINSTALL_PDB_COMPONENT_EXCLUDE_FROM_ALL:BOOL="0" -DBUILD_opencv_ml:BOOL="0" -DOPENCV_ENABLE_MEMALIGN:BOOL="0" -DBUILD_opencv_python_tests:BOOL="0" -DCV_ENABLE_INTRINSICS:BOOL="0" -DOPENCL_FOUND:BOOL="0" -DWITH_OPENCL_D3D11_NV:BOOL="0" -Dnext:BOOL="0" -DBUILD_opencv_gapi:BOOL="0" -DBUILD_opencv_flann:BOOL="0" -DBUILD_TESTS:BOOL="0" -DWITH_DIRECTX:BOOL="0" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$YADOMS_DEPS_PATH/opencv .. >/dev/null \
## 		&& make  > /dev/null\
## 		&& make install  > /dev/null\	
## 		&& cd ../.. && rm -Rf opencv-$opencv_version* && rm -f $opencv_version.zip
## 	
## 	# Yadoms configuration file
## 	RUN echo 'Configuring Yadoms CMakeListsUserConfig.txt' \
## 		&& echo 'set(BOOST_ROOT "'$YADOMS_DEPS_PATH'/boost_'$boost_version'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'set(POCO_ROOT "'$YADOMS_DEPS_PATH'/poco-'$poco_version-all'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'set(PROTOBUF_ROOT "'$YADOMS_DEPS_PATH'/protobuf")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'set(PROTOBUF_PROTOC_EXECUTABLE "'$YADOMS_DEPS_PATH'/protobuf/bin/protoc")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'set(PROTOBUF_INSTALLED_TO_CUSTOM_DIRECTORY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'set(OPENSSL_ROOT "'$YADOMS_DEPS_PATH'/openssl")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'set(DEBUG_WITH_GCC OFF)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'set(PYTHON_USE_PKGCONFIG OFF)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'set(PYTHON_USE_SOURCES ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'set(Python2_ManualSetup ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'set(Python2_EXECUTABLE "'$YADOMS_DEPS_PATH'/python'$python2_version_maj$python2_version_min'/bin/python'$python2_version_maj'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'set(Python2_LIBRARIES "'$YADOMS_DEPS_PATH'/python'$python2_version_maj$python2_version_min'/lib/libpython'$python2_version_maj'.'$python2_version_min'.so")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'set(Python2_INCLUDE_DIRS "'$YADOMS_DEPS_PATH'/python'$python2_version_maj$python2_version_min'/include/python'$python2_version_maj'.'$python2_version_min'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'set(Python3_ManualSetup ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'set(Python3_EXECUTABLE "'$YADOMS_DEPS_PATH'/python'$python3_version_maj$python3_version_min'/bin/python'$python3_version_maj'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'set(Python3_LIBRARIES "'$YADOMS_DEPS_PATH'/python'$python3_version_maj$python3_version_min'/lib/libpython'$python3_version_maj'.'$python3_version_min'.so")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'set(Python3_INCLUDE_DIRS "'$YADOMS_DEPS_PATH'/python'$python3_version_maj$python3_version_min'/include/python'$python3_version_maj'.'$python3_version_min'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'set(PostgreSQL_ROOT ' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo '       "'$YADOMS_DEPS_PATH'/postgresql-'$postgresql_version'/src/interfaces/libpq"' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo '       "'$YADOMS_DEPS_PATH'/postgresql-'$postgresql_version'/src/include")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'set(GAMMU_ROOT "'$YADOMS_DEPS_PATH'/gammu")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'set(SWIG_ROOT "'$YADOMS_DEPS_PATH'/swig-'$swig_version'")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'set(OPENCV_ROOT "'$YADOMS_DEPS_PATH'/opencv")' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'SET(COTIRE_USE ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt \
## 		&& echo 'SET(COTIRE_USE_UNITY ON)' >> $YADOMS_DEPS_PATH/CMakeListsUserConfig.txt
## 	
## 	COPY entrypoint.sh /
## 	COPY entrypoint_docker.sh /
## 	#ensure entrypoint is executable (force flags update, because file flags may change if a commit is made under Windows)
## 	RUN chmod +x /entrypoint.sh
## 	RUN chmod +x /entrypoint_docker.sh


