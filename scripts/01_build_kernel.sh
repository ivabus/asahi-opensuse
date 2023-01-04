#!/bin/bash

# This script clones & builds all RPMs that are used in repository.

_rcver=6.2
_rcrel=2
_asahirel=1
pkgrel=1
_commit_id=asahi-${_rcver}${_rcrel+-rc}${_rcrel}-${_asahirel}
makethreads=48
CC=distcc
CXX=distcc
#makethreads=`distcc -j`
mkdir build
cd build

echo "Downloading linux-asahi sources"
curl -fSLO https://github.com/AsahiLinux/linux/archive/refs/tags/${_commit_id}.tar.gz
echo "Unpacking linux-asahi"
tar xpf ${_commit_id}.tar.gz
curl -o config -fsSL https://raw.githubusercontent.com/AsahiLinux/PKGBUILDs/main/linux-asahi/config
sed -i -e s/ARCH/opensuse/ config

cd linux-${_commit_id}
echo "Building main kernel"
cp ../config .config
make olddefconfig prepare
diff -u ../config .config || :
make -j$makethreads CC=$CC CXX=$CXX rpm-pkg
