
# Yadoms build docker image for Windows

Image docker for building [Yadoms](http://www.yadoms.com/) for continuous integration on windows platform

Build Yadoms for specific branch :
```console
docker run -e MAKE_PACKAGE=true -e YADOMS_BUILD_BRANCH=${YADOMS_BRANCH} -e UPLOAD_FTP_CREDENTIALS=${FTP_USER}:${FTP_PASSWORD} yadoms/build_for_windows
```

* MAKE_PACKAGE : define to true to build also install and update packages (default to false)
* YADOMS_BUILD_BRANCH : specify a branch to build (default to develop)

# Building image

## Build from scratch

It will build the image from local cache (or from zero if no cache)


````
docker build --cache-from yadoms/build_for_windows:latest -t build_for_windows .
docker tag build_for_windows yadoms/build_for_windows
docker push yadoms/build_for_windows
````

# Setup build options

## Using proxy

Add the following args to the docker build command:
 * http_proxy
 * https_proxy

````
docker build --build-arg http_proxy=http://myproxyadress:8080 --build-arg https_proxy=http://myproxyadress:8080 -t build_for_windows .
````

 