#!/bin/bash

# This script clones & builds all packages using .spec files.

SPECTOOL=$(curl https://pagure.io/spectool/raw/master/f/spectool)

for i in `ls ../specs/*.spec`
do
	# Using spectool to download source tarball
	python3 -c "$SPECTOOL" -g $i
done
mv *.tar.gz `rpm --eval "%{_sourcedir}"`
for i in `ls ../specs/*.spec`
do
	# Building
	rpmbuild -ba $i
done
