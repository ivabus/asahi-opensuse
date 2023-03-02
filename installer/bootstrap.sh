#!/bin/sh
# SPDX-License-Identifier: MIT

set -e

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

export VERSION_FLAG=https://storage.ivabus.dev/asahi-opensuse/installer/latest
export INSTALLER_BASE=https://storage.ivabus.dev/asahi-opensuse/installer
export INSTALLER_DATA=https://storage.ivabus.dev/asahi-opensuse/installer/installer_data.json
export INSTALLER_DATA_ALT=https://raw.githubusercontent.com/ivabus/asahi-opensuse/main/installer/installer_data.json
export REPO_BASE=https://storage.ivabus.dev/asahi-opensuse

TMP="$(mktemp -d)"

echo
echo "Bootstrapping installer:"

if [ -e "$TMP" ]; then
    mv "$TMP" "$TMP-$(date +%Y%m%d-%H%M%S)"
fi

mkdir -p "$TMP"
cd "$TMP"

echo "  Checking version..."

PKG_VER="$(curl --no-progress-meter -L "$VERSION_FLAG")"
echo "  Version: $PKG_VER"

PKG="installer-$PKG_VER.tar.gz"

echo "  Downloading..."

curl --no-progress-meter -L -o "$PKG" "$INSTALLER_BASE/$PKG"
if ! curl --no-progress-meter -L -O "$INSTALLER_DATA"; then
	echo "    Error downloading installer_data.json. GitHub might be blocked in your network."
	echo "    Please consider using a VPN if you experience issues."
	echo "    Trying workaround..."
	curl --no-progress-meter -L -O "$INSTALLER_DATA_ALT"
fi

echo "  Extracting..."
tar xf "$PKG"

echo "  Initializing..."
echo

if [ "$USER" != "root" ]; then
    echo "The installer needs to run as root."
    echo "Please enter your sudo password if prompted."
    exec caffeinate -dis sudo -E ./install.sh "$@"
else
    exec caffeinate -dis ./install.sh "$@"
fi
