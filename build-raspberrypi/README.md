
# Yadoms build docker image

Image docker for building [Yadoms](http://www.yadoms.com/) for continuous integration

Build Yadoms for default branch (develop) :
```console
docker run yadoms
```

Build Yadoms for specific branch :
```console
docker run --env YADOMS_BUILD_BRANCH=myBranch yadoms
```
