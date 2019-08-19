#!/bin/bash

sudo docker build --build-arg http_proxy=http://xrxproxy.acs-inc.fr:8080 --build-arg https_proxy=http://xrxproxy.acs-inc.fr:8080 -t toolchain_for_macos .

pause
