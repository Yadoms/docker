
# Yadoms build docker image

Image docker for building the RaspberryPI image builtin with [Yadoms](http://www.yadoms.com/) 


Build the image :
```console
docker run --privileged -e CURBRANCH=${TRAVIS_BRANCH} -e YADOMS_VERSION=${YADOMS_VERSION} -e UPLOAD_FTP_CREDENTIALS=${FTP_USER}:${FTP_PASSWORD} yadoms/build_for_raspberrypi_image
```
**The docker run must have the *--privileged* commutator to work**

* YADOMS_VERSION : specify the yadoms version to build image for
* UPLOAD_FTP_CREDENTIALS : if defined, upload build results to www.yadoms.com FTP site (default not defined)
