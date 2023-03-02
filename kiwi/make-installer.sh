#!/bin/sh

set -eu

fail() {
  echo $* >&2
  exit 1
}

requireCommands() {
  for cmd in $*; do
    if ! command -v $cmd &> /dev/null; then
      fail "Cannot find required command: $cmd"
    fi
  done
}

date=$(date +%Y%m%d)
image="${1}"
package="${2}"

if [ ! -r "$image" ]; then
  fail "$image does not exist or cannot be read!"
fi

if [ -e "$package" ]; then
  fail "$package already exists, aborting"
fi

requireCommands 7z awk cat cp dd fdisk file mkdir mv stat wget

workdir="$(mktemp -dp /var/tmp)"

basedir="$PWD"
imagename="$(basename "$image")"
imagedir="$(dirname "$image")"

# extract filesystems from disk image
pushd "$imagedir" > /dev/null
eval "$(fdisk -Lnever -lu -b 4096 "$imagename" | awk "/^${imagename}/ { printf \"dd if=${imagename} of=${workdir}/%s skip=%s count=%s bs=4096\\n\", \$1, \$2, \$4 }")"
popd > /dev/null

# build package
mkdir -p "${workdir}/package/esp"
7z x -o"${workdir}/package/esp" "${workdir}/${imagename}1"
mv "${workdir}/${imagename}2" "${workdir}/package/boot.img"
mv "${workdir}/${imagename}3" "${workdir}/package/root.img"

esp_volume_id="$(file "${workdir}/${imagename}1" | awk -v 'RS=,' '/serial number/ { print $3 }')"
esp_size="$(stat -c %s "${workdir}/${imagename}1")"
boot_size="$(stat -c %s "${workdir}/package/boot.img")"
root_size="$(stat -c %s "${workdir}/package/root.img")"

pushd "${workdir}/package" > /dev/null
7z a -tzip -r "${basedir}/${package}" .
popd > /dev/null

	
cat > installer_data-$package.json <<EOF
{
    "os_list": [
        {
            "name": "openSUSE Tumbleweed",
            "default_os_name": "openSUSE Tumbleweed",
            "boot_object": "m1n1.bin",
            "next_object": "m1n1/boot.bin",
            "package": "${package}.zip",
            "supported_fw": ["12.3", "12.3.1", "12.4"],
            "partitions": [
                {
                    "name": "EFI",
                    "type": "EFI",
                    "size": "${esp_size}B",
                    "format": "fat",
                    "volume_id": "${esp_volume_id}",
                    "copy_firmware": true,
                    "copy_installer_data": true,
                    "source": "esp"
                },
                {
                    "name": "Boot",
                    "type": "Linux",
                    "size": "${boot_size}B",
                    "image": "boot.img"
                },
                {
                    "name": "Root",
                    "type": "Linux",
                    "size": "${root_size}B",
                    "expand": true,
                    "image": "root.img"
                }
            ]
        }
    ]
}
EOF