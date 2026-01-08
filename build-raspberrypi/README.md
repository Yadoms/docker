
Yadoms build docker image
=========================

This is the image docker for cross-compiling [Yadoms](http://www.yadoms.com/) for raspberryPi

# How to use

[ ] TODO revoir la ligne de commande (et le dockerfile et le cmakelists)
Build Yadoms for specific branch :
```console
docker run -e MAKE_PACKAGE=true -e YADOMS_BUILD_BRANCH=${YADOMS_BRANCH} -e UPLOAD_FTP_CREDENTIALS=${FTP_USER}:${FTP_PASSWORD} yadoms/build_for_raspberrypi


TODO en cours de test (mapping de dossier à revoir)
docker run -it -v .:/tmp build_for_raspberrypi

```

[ ] TODO est utilisé ?
* MAKE_PACKAGE : define to true to build also install and update packages (default to false)
[ ] TODO est utilisé ?
* YADOMS_BUILD_BRANCH : specify a branch to build (default to develop)
[ ] TODO est utilisé ?
* UPLOAD_FTP_CREDENTIALS : if defined, upload build results to www.yadoms.com FTP site (default not defined)

# Building image

## Build from scratch

It will build the image from local cache (or from zero if no cache)

````
docker build --cache-from yadoms/build_for_raspberrypi:latest -t build_for_raspberrypi .
docker tag build_for_raspberrypi yadoms/build_for_raspberrypi
docker push yadoms/build_for_raspberrypi
````

## Build reusing previously built image (in case cache not on local machine)

Example : you want to update a Docker image (ie change the entrypoint.sh script)
If building from a new environment all step will be computed. (changing entrypoint is the last step, and we could reuse an image from docker-hub to build faster)

````
docker pull yadoms/build_for_raspberrypi:latest
docker build --cache-from yadoms/build_for_raspberrypi:latest -t build_for_raspberrypi .
docker tag build_for_raspberrypi yadoms/build_for_raspberrypi
docker push yadoms/build_for_raspberrypi
````

## Debug the build

Some useful commands to debug the build :

````
export BUILDKIT_PROGRESS=plain

# To build
clear && docker build -t build_for_raspberrypi --progress plain .
````


# Setup build options

## Using proxy

Add the following args to the docker build command:
 * http_proxy
 * https_proxy

````
docker build --build-arg http_proxy=http://myproxyadress:8080 --build-arg https_proxy=http://myproxyadress:8080 -t build_for_raspberrypi .
````

 