# syntax=docker/dockerfile:1
FROM debian:stable
LABEL org.opencontainers.image.authors="sgallou"
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /work

#############################################################
## Install all needed packages
#############################################################
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl xz-utils \
    util-linux kpartx e2fsprogs dosfstools mount rsync coreutils file \
&& rm -rf /var/lib/apt/lists/*

# I/O folders
RUN mkdir -p /input /output /sysroot /mnt/boot /mnt/root

# Add script
COPY extract_sysroot.sh /usr/local/bin/extract_sysroot.sh
RUN chmod +x /usr/local/bin/extract_sysroot.sh

# Entry point
# All parameters set by env vars
ENTRYPOINT ["/usr/local/bin/extract_sysroot.sh"]