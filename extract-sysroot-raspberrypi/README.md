
# Extract RaspberryPi sysroot for Yadoms build

This docker image helps to extract RaspberryPi minimal sysroot to build Yadoms from an Raspberry Pi OS image.

# Usage

Get docker image

```console
docker pull yadoms/rpi-sysroot-extract:latest
```

Create expected folders

```console
mkdir -p output sysroot
```

Call contener

```console
docker run --rm -it --privileged \
  -e IMAGE_URL="https://downloads.raspberrypi.com/raspios_armhf/images/raspios_armhf-2025-05-13/2025-05-13-raspios-bookworm-armhf.img.xz" \
  -e OUT=/sysroot \
  -e MAKE_TARBALL=1 \
  -v "$PWD/output":/output \
  -v "$PWD/sysroot":/sysroot \
  rpi-sysroot-extract
```

Parameters are :

- `IMAGE_URL` : Image url from ie Raspberry Pi OS official website (.img or .img.xz)
- `IMAGE` : Path to a locale image (to not re-download image)
- `IMAGE_SHA256` : (optional) expected downloaded archive checksum (file or value)
- `OUT` : sysroot target folder in the contener
- `MAKE_TARBALL` : 1 to produce tar.gz in /output, else 0

# Contener image update

If docker image need to be rebuilt (ie in case of extract_sysroot.sh was changed)

```console
docker build -t rpi-sysroot-extract .
```

When all is OK, push the image

```console
docker push yadoms/rpi-sysroot-extract:latest
```
