#!/bin/bash

# This script clones & builds all linux-asahi related packages.

_rcver=6.2
_rcrel=3
_asahirel=6
_commit_id=asahi-${_rcver}${_rcrel+-rc}${_rcrel}-${_asahirel}
makethreads=`nproc`
CC=gcc
CXX=g++

if [ ! -d build ]; then
	mkdir build
fi
cd build

if [ ! -f ${_commit_id}.tar.gz ]; then
	echo "Downloading linux-asahi sources"
	curl -fSLO https://github.com/AsahiLinux/linux/archive/refs/tags/${_commit_id}.tar.gz
fi
if [ ! -d linux-${_commit_id} ]; then
	echo "Unpacking linux-asahi"
	tar xpf ${_commit_id}.tar.gz
fi
curl -o config -fsSL https://raw.githubusercontent.com/AsahiLinux/PKGBUILDs/main/linux-asahi/config
sed -i -e s/-ARCH/-suse/ config

cd linux-${_commit_id}
echo "Building main kernel"
cp ../config .config
make olddefconfig prepare
diff -u ../config .config || :
make -j$makethreads CC=$CC CXX=$CXX rpm-pkg

# Making source package for asahi-dtbs

make dtbs
make INSTALL_PATH=. dtbs_install
tar cf dtbs-${_rcver}${_rcrel+_rc}${_rcrel}_${_asahirel}.tar dtbs/
cp dtbs-${_rcver}${_rcrel+_rc}${_rcrel}_${_asahirel}.tar ~/rpmbuild/SOURCES/
