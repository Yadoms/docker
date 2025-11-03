
# Extract RaspberryPi sysroot for Yadoms build

The docker helps to extract RaspberryPi sysroot from an Raspberry Pi OS image.
The sysroot is needed to build Yadoms and its dependencies.

# Usage

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

