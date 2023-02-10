#!/bin/bash

set -euxo pipefail

FRP_VERSION=0.47.0
FRP_ARCH=amd64
FRP_SYSTEM=linux

TEMP_DIR=$(pwd)/frp-${FRP_VERSION}
TEMP_FILE="${TEMP_DIR}/frp.tar.gz"
EXTRACTED_DIR="${TEMP_DIR}/frp_${FRP_VERSION}_${FRP_SYSTEM}_${FRP_ARCH}"

##
## Remove old files
##
rm -rf "${TEMP_DIR}" &> /dev/null || true
mkdir -p "${TEMP_DIR}"

##
## Download new
##
curl -L -o "${TEMP_FILE}" "https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_${FRP_SYSTEM}_${FRP_ARCH}.tar.gz"
tar -xzf "${TEMP_FILE}" -C "${TEMP_DIR}"

##
## Create package
##
fpm \
    --input-type dir \
    --output-type deb \
    --force \
    --name "frp" \
    --category "Utilities" \
    --architecture ${FRP_ARCH} \
    --maintainer "fatedier" \
    --deb-priority "optional" \
    --description "A fast reverse proxy to help you expose a local server behind a NAT or firewall to the internet." \
    --version "0.47.0" \
    --url "https://github.com/fatedier/frp" \
    --after-install postinst \
    --package frp_${FRP_VERSION}_${FRP_ARCH}.deb \
    --verbose \
    --license "Apache License 2.0" \
    "${EXTRACTED_DIR}/frpc"=/usr/bin/frpc \
    "${EXTRACTED_DIR}/frps"=/usr/bin/frps \
    "${EXTRACTED_DIR}/frpc.ini"=/etc/frp/frpc.ini \
    "${EXTRACTED_DIR}/frpc_full.ini"=/etc/frp/frpc_full.ini \
    "${EXTRACTED_DIR}/frps.ini"=/etc/frp/frps.ini \
    "${EXTRACTED_DIR}/frps_full.ini"=/etc/frp/frps_full.ini \
    ./frpc.service=/usr/lib/systemd/system/frpc.service \
    ./frps.service=/usr/lib/systemd/system/frps.service \
    ;

##
## Cleanup
##
rm -rf "${TEMP_DIR}"
