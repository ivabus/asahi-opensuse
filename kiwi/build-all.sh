#!/bin/bash
set -e

mkdir -p installers

for distro in "Tumbleweed" "Leap"; do
	for edition in "JeOS" "KDE" "GNOME" "XFCE"; do
		rm -rf ./outdir-$distro-$edition
		echo Building $distro-$edition
		kiwi-ng --type=oem --profile=$distro-$edition --color-output system build --description ./ --target-dir ./outdir-$distro-$edition
		./make-installer.sh outdir-$distro-$edition/asahi-opensuse.aarch64-0.0.1.raw $distro-$edition.zip
	done
done

