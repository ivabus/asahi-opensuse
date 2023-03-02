#!/bin/bash
set -e
# This script clones & builds all linux-asahi related packages.

../specs/kernel.sh
rpmbuild -ba kernel.spec
rm -f kernel.spec
