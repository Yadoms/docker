FROM ghcr.io/yadoms/vstools:latest
MAINTAINER jano42 "https://github.com/jano42"
LABEL authors=jano42

ENV YADOMS_BUILD_BRANCH develop
ENV MAKE_PACKAGE false
ENV YADOMS_DEPS_PATH  C:/yadoms-deps

#shell commad for powershell
#SHELL ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]

#classic sheel start script
SHELL ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&"]

# Create working folders
RUN powershell.exe -Command New-Item -ItemType Directory -Path %YADOMS_DEPS_PATH%

###################################################################
# Install chocolatey
###################################################################

# install chocolatey
RUN powershell.exe -Command iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

###################################################################
# Install yadoms dependencies
###################################################################

# CMake
ARG cmake_version=3.30.2
RUN choco install cmake --installargs 'ADD_CMAKE_TO_PATH=System' -y --no-progress --version %cmake_version%

#NSIS and 7zip
RUN choco install nsis 7zip git -y --no-progress

# Boost
ARG boost_version_major=1
ARG boost_version_minor=86
ARG boost_version_patch=0
ARG boost_underscore=_
ARG boost_version=$boost_version_major$boost_underscore$boost_version_minor$boost_underscore$boost_version_patch
ARG boost_version_dot=$boost_version_major.$boost_version_minor.$boost_version_patch
RUN cd %YADOMS_DEPS_PATH% \
   && powershell.exe -Command (New-Object System.Net.WebClient).DownloadFile('https://boostorg.jfrog.io/artifactory/main/release/%boost_version_dot%/source/boost_%boost_version%.zip', '%YADOMS_DEPS_PATH%\\boost_%boost_version%.zip') \
   && powershell.exe -Command Expand-Archive -Path boost_%boost_version%.zip '%YADOMS_DEPS_PATH%'\
   && cd boost_%boost_version% \
   &&.\bootstrap.bat \
   && b2.exe --with-atomic --with-chrono --with-date_time --with-filesystem --with-regex --with-test --with-thread --with-system --with-test --with-json link=static runtime-link=static \
   && powershell.exe -Command Remove-Item -Path bin.v2 -Recurse \
   && powershell.exe -Command Remove-Item -Path doc -Recurse \
   && powershell.exe -Command Remove-Item -Path libs -Recurse \
   && powershell.exe -Command Remove-Item -Path tools -Recurse \
   && cd .. && powershell.exe -Command Remove-Item -Path boost_%boost_version%.zip

# OpenSSL (for chocolatey, 1.1.1.700 match 1.1.1g (g is the 7th...)
ARG openssl_version=1.1.1.1200
RUN choco install openssl --x86 -y --no-progress --version %openssl_version%
 

## 	# Poco
ARG poco_version=1.13.3
RUN cd %YADOMS_DEPS_PATH% \
   && powershell.exe -Command (New-Object System.Net.WebClient).DownloadFile('https://pocoproject.org/releases/poco-%poco_version%/poco-%poco_version%-all.zip', '%YADOMS_DEPS_PATH%\\poco.zip') \
   && powershell.exe -Command Expand-Archive -Path poco.zip '%YADOMS_DEPS_PATH%'\
   && cd poco-%poco_version%-all \
   && cmake . -DOPENSSL_ROOT_DIR="C:\\Program Files (x86)\\OpenSSL-Win32" -DENABLE_SEVENZIP=OFF -DENABLE_MONGODB=OFF -DENABLE_REDIS=OFF -DENABLE_DATA=OFF -DENABLE_DATA_SQLITE=OFF -DENABLE_DATA_MYSQL=OFF -DENABLE_DATA_ODBC=OFF -DENABLE_PAGECOMPILER=OFF -DENABLE_PAGECOMPILER_FILE2PAGE=OFF -DENABLE_JWT=OFF  -DBUILD_SHARED_LIBS=OFF -DPOCO_MT=ON -DFORCE_OPENSSL=ON -A Win32 \
   && cmake --build . \
   && cmake --build . --config Release \
   && cd .. && powershell.exe -Command Remove-Item -Path poco.zip 


# Protobuf
ARG protobuf_version=3.15.8
RUN cd %YADOMS_DEPS_PATH% \
   && powershell.exe -Command (New-Object System.Net.WebClient).DownloadFile('https://github.com/google/protobuf/releases/download/v%protobuf_version%/protobuf-cpp-%protobuf_version%.zip', '%YADOMS_DEPS_PATH%\\protobuf.zip') \
   && powershell.exe -Command Expand-Archive -Path protobuf.zip '%YADOMS_DEPS_PATH%'\
   && cd protobuf-%protobuf_version% \
   && md vsprojects \
   && cd vsprojects \
   && cmake ..\cmake -Dprotobuf_BUILD_TESTS=OFF  -A Win32 \
   && cmake --build . \
   && cmake --build . --config Release \
   && cd .. && cd .. && powershell.exe -Command Remove-Item -Path protobuf.zip 

# Swig
ARG swig_version=4.0.2
RUN cd %YADOMS_DEPS_PATH% \
   && powershell.exe -Command (New-Object System.Net.WebClient).DownloadFile('https://freefr.dl.sourceforge.net/project/swig/swigwin/swigwin-%swig_version%/swigwin-%swig_version%.zip', '%YADOMS_DEPS_PATH%\\swig.zip') \
   && powershell.exe -Command Expand-Archive -Path swig.zip '%YADOMS_DEPS_PATH%'\
   && powershell.exe -Command Remove-Item -Path swig.zip 

# Python2
ARG python2_version_maj=2
ARG python2_version_min=7
ARG python2_version_patch=18
ARG python2_version=$python2_version_maj.$python2_version_min.$python2_version_patch
RUN choco install python2 --x86 -y --no-progress --version %python2_version%

# Python3
ARG python3_version_maj=3
ARG python3_version_min=9
ARG python3_version_patch=4
ARG python3_version=$python3_version_maj.$python3_version_min.$python3_version_patch
RUN choco install python3 --x86 -y --no-progress --version %python3_version%

# PostgreSQL
ARG postgresql_version=9.6.19-1
RUN cd %YADOMS_DEPS_PATH% \
   && powershell.exe -Command (New-Object System.Net.WebClient).DownloadFile('https://get.enterprisedb.com/postgresql/postgresql-%postgresql_version%-windows-binaries.zip', '%YADOMS_DEPS_PATH%\\pg.zip') \
   && powershell.exe -Command Expand-Archive -Path pg.zip '%YADOMS_DEPS_PATH%'\
   && powershell.exe -Command Remove-Item -Path pg.zip 


# OpenCV
ARG opencv_version=4.5.2
RUN cd %YADOMS_DEPS_PATH% \
   && powershell.exe -Command (New-Object System.Net.WebClient).DownloadFile('https://github.com/opencv/opencv/archive/%opencv_version%.zip ', '%YADOMS_DEPS_PATH%\\opencv.zip') \
   && powershell.exe -Command Expand-Archive -Path opencv.zip '%YADOMS_DEPS_PATH%'\
   && cd opencv-%opencv_version% \
   && md build \
   && cd build \
   && cmake.exe -DWITH_EIGEN:BOOL="0" -DWITH_IMGCODEC_HDR:BOOL="0" -DBUILD_opencv_ts:BOOL="0" -DBUILD_opencv_video:BOOL="0" -DWITH_TIFF:BOOL="0" -DBUILD_PACKAGE:BOOL="0" -DBUILD_opencv_features2d:BOOL="0" -DBUILD_ITT:BOOL="0" -Dthunder:BOOL="0" -Dlzw:BOOL="0" -DCV_TRACE:BOOL="0" -DWITH_MSMF:BOOL="0" -DWITH_FFMPEG:BOOL="0" -DWITH_IMGCODEC_PXM:BOOL="0" -DWITH_MSMF_DXVA:BOOL="0" -DCPACK_SOURCE_ZIP:BOOL="0" -Dpackbits:BOOL="0" -DBUILD_opencv_apps:BOOL="0" -DBUILD_PROTOBUF:BOOL="0" -DBUILD_opencv_objdetect:BOOL="0" -DBUILD_IPP_IW:BOOL="0" -DBUILD_opencv_videoio:BOOL="0" -DBUILD_PERF_TESTS:BOOL="0" -Dmdi:BOOL="0" -DWITH_1394:BOOL="0" -DINSTALL_PDB:BOOL="0" -DWITH_OPENCL:BOOL="0" -DM_LIBRARY:FILEPATH="M_LIBRARY-NOTFOUND" -DUSE_WIN32_FILEIO:BOOL="1" -DCPACK_SOURCE_7Z:BOOL="0" -DBUILD_opencv_stitching:BOOL="0" -Dccitt:BOOL="0" -DVIDEOIO_ENABLE_STRICT_PLUGIN_CHECK:BOOL="0" -DWITH_IPP:BOOL="0" -DBUILD_opencv_dnn:BOOL="0" -DWITH_ITT:BOOL="0" -DCPACK_BINARY_NSIS:BOOL="0" -DBUILD_opencv_photo:BOOL="0" -DBUILD_opencv_calib3d:BOOL="0" -DWITH_QUIRC:BOOL="0" -DWITH_WEBP:BOOL="0" -DBUILD_opencv_python_bindings_generator:BOOL="0" -DWITH_PROTOBUF:BOOL="0" -DBUILD_JASPER:BOOL="1" -DWITH_OPENCLAMDBLAS:BOOL="0" -DBUILD_JAVA:BOOL="0" -DWITH_VTK:BOOL="0" -DBUILD_opencv_java_bindings_generator:BOOL="0" -DBUILD_opencv_highgui:BOOL="0" -DWITH_ARITH_DEC:BOOL="0" -DWITH_IMGCODEC_SUNRASTER:BOOL="0" -DWITH_ADE:BOOL="0" -DBUILD_OPENEXR:BOOL="0" -DWITH_OPENEXR:BOOL="0" -DWITH_OPENCLAMDFFT:BOOL="0" -DVIDEOIO_ENABLE_PLUGINS:BOOL="0" -DWITH_DSHOW:BOOL="0" -DOPENCV_DNN_OPENCL:BOOL="0" -DWITH_LAPACK:BOOL="0" -DWITH_IMGCODEC_PFM:BOOL="0" -Dlogluv:BOOL="0" -DINSTALL_PDB_COMPONENT_EXCLUDE_FROM_ALL:BOOL="0" -DBUILD_opencv_ml:BOOL="0" -DOPENCV_ENABLE_MEMALIGN:BOOL="0" -DBUILD_opencv_python_tests:BOOL="0" -DCV_ENABLE_INTRINSICS:BOOL="0" -DOPENCL_FOUND:BOOL="0" -DWITH_OPENCL_D3D11_NV:BOOL="0" -Dnext:BOOL="0" -DBUILD_opencv_gapi:BOOL="0" -DBUILD_opencv_flann:BOOL="0" -DBUILD_TESTS:BOOL="0" -DWITH_DIRECTX:BOOL="0" -DCMAKE_BUILD_TYPE=RELEASE -A Win32 .. \
   && cmake --build . \
   && cmake --build . --config Release \
   && cd .. && cd .. && powershell.exe -Command Remove-Item -Path opencv.zip 


# Gammu
ARG gammu_version=1.41.0
RUN cd %YADOMS_DEPS_PATH% \
   && powershell.exe -Command (New-Object System.Net.WebClient).DownloadFile('https://dl.cihar.com/gammu/releases/gammu-%gammu_version%.zip', '%YADOMS_DEPS_PATH%\\gammu.zip') \
   && powershell.exe -Command Expand-Archive -Path gammu.zip '%YADOMS_DEPS_PATH%'\
   && cd gammu-%gammu_version% \
   && md build \
   && cd build \
   && cmake -DMSVC_RUNTIME=static -A Win32 .. \
   && cmake --build . \
   && cmake --build . --config Release \
   && cd .. && cd .. && powershell.exe -Command Remove-Item -Path gammu.zip 

# Yadoms configuration file
RUN echo 'Configuring Yadoms CMakeListsUserConfig.txt' \
   && echo set(BOOST_ROOT "%YADOMS_DEPS_PATH%/boost_%boost_version%") >> %YADOMS_DEPS_PATH%/CMakeListsUserConfig.txt \
   && echo set(POCO_ROOT "%YADOMS_DEPS_PATH%/poco-%poco_version%-all") >> %YADOMS_DEPS_PATH%/CMakeListsUserConfig.txt \
   && echo set(PROTOBUF_ROOT "%YADOMS_DEPS_PATH%/protobuf-%protobuf_version%") >> %YADOMS_DEPS_PATH%/CMakeListsUserConfig.txt \
   && echo set(OPENSSL_ROOT "C:/Program Files (x86)/OpenSSL-Win32") >> %YADOMS_DEPS_PATH%/CMakeListsUserConfig.txt \
   && echo set(DEBUG_WITH_GCC OFF) >> %YADOMS_DEPS_PATH%/CMakeListsUserConfig.txt \
   && echo set(Python2_ROOT "C:/Python%python2_version_maj%%python2_version_min%") >> %YADOMS_DEPS_PATH%/CMakeListsUserConfig.txt \
   && echo set(Python3_ROOT "C:/Python%python3_version_maj%%python3_version_min%") >> %YADOMS_DEPS_PATH%/CMakeListsUserConfig.txt \
   && echo set(OPENCV_ROOT "%YADOMS_DEPS_PATH%/opencv-%opencv_version%/build") >> %YADOMS_DEPS_PATH%/CMakeListsUserConfig.txt \
   && echo set(PostgreSQL_ROOT "%YADOMS_DEPS_PATH%/pgsql") >> %YADOMS_DEPS_PATH%/CMakeListsUserConfig.txt \
   && echo set(GAMMU_ROOT "%YADOMS_DEPS_PATH%/gammu-%gammu_version%") >> %YADOMS_DEPS_PATH%/CMakeListsUserConfig.txt \
   && echo set(SWIG_ROOT "%YADOMS_DEPS_PATH%/swigwin-%swig_version%") >> %YADOMS_DEPS_PATH%/CMakeListsUserConfig.txt \
   && echo SET(COTIRE_USE ON) >> %YADOMS_DEPS_PATH%/CMakeListsUserConfig.txt \
   && echo SET(COTIRE_USE_UNITY ON) >> %YADOMS_DEPS_PATH%/CMakeListsUserConfig.txt \
   && echo set(USE_NSIS ON) >> %YADOMS_DEPS_PATH%/CMakeListsUserConfig.txt
   
COPY entrypoint_docker.ps1 C:
