# Sources to build docker containers for Yadoms

 - [Container to build Yadoms for Linux](build-linux/README.md)

 - [Container to build Yadoms for RaspberryPi](build-raspberrypi/README.md)

  - [Container to build Yadoms for RaspberryPi image](build-raspberrypi-image/README.md)

# Note when editing under Windows

Modifying files under Windows introduce common errors. Please always check:
 * entrypoints are still with executable flags (or add a 'chmod +x' in Dockerfile)
 * ensure entrypoints are in Unix format (LF) and **NOT** in Windows CR/LF format
 
Both errors make running docker fail with ```entripoint.sh not found``` (in fact this should be not executable or not in unix format)

