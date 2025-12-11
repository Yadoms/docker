
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
  -e IMAGE_URL="https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-2025-05-13/2025-05-13-raspios-bookworm-armhf-lite.img.xz" \
  -e IMAGE_SHA256=a73d68b618c3ca40190c1aa04005a4dafcf32bc861c36c0d1fc6ddc48a370b6e \
  -e OUT=/sysroot \
  -e MODE=minimal \
  -e STRIP=1 
  -e MAKE_TARBALL=1 \
  -v "$PWD/input":/input \
  -v "$PWD/output":/output \
  -v "$PWD/sysroot":/sysroot \
  rpi-sysroot-extract
```

or from a locale image :

```console
docker run --rm -it --privileged \
  -e IMAGE="/input/2025-05-13-raspios-bookworm-armhf-lite.img" \
  -e IMAGE_SHA256=a73d68b618c3ca40190c1aa04005a4dafcf32bc861c36c0d1fc6ddc48a370b6e \
  -e OUT=/sysroot \
  -e MODE=minimal \
  -e STRIP=1 \
  -e MAKE_TARBALL=1 \
  -v "$PWD/input":/input \
  -v "$PWD/output":/output \
  -v "$PWD/sysroot":/sysroot \
  rpi-sysroot-extract
```

Parameters are :

- `IMAGE_URL` : Image url from ie Raspberry Pi OS official website (.img or .img.xz)
- `IMAGE` : Path to a locale image (to not re-download image)
- `IMAGE_SHA256` : (optional) expected downloaded archive checksum (file or value)
- `OUT` : sysroot target folder in the contener
- `MODE` (full | minimal) : full (no sysroot reduction), minimal (minimal sysroot by whitelist)
- `PRUNE` : cleanup ssyroot after copy (full mode only)
- `STRIP` : 1 to strip .so/.bin files (remove debug symbols)
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
