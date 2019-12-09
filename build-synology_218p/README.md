
# Yadoms build docker image

Image docker for building [Yadoms](http://www.yadoms.com/) for continuous integration

Build Yadoms for specific branch :
```console
docker run -e MAKE_PACKAGE=true -e YADOMS_BUILD_BRANCH=${YADOMS_BRANCH} -e UPLOAD_FTP_CREDENTIALS=${FTP_USER}:${FTP_PASSWORD} yadoms/build_for_synology218p
```

* MAKE_PACKAGE : define to true to build also install and update packages (default to false)
* YADOMS_BUILD_BRANCH : specify a branch to build (default to develop)
* UPLOAD_FTP_CREDENTIALS : if defined, upload build results to www.yadoms.com FTP site (default not defined)
