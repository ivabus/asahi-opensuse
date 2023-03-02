#!/bin/bash
set -e
# This script clones & builds all RPMs that are used in repository.

# clean up
rm -rf ../repo

sh 01_build_kernel.sh

sh 02_build_rpms.sh

mkdir -p ../repo/{RPMS,SRPMS}

# RpmBuildDir
RBD=$(rpm --eval "%{_topdir}")

cp -rv $RBD/RPMS ../repo/
cp -rv $RBD/SRPMS ../repo/

cd ../repo

createrepo --xz .
