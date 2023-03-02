#!/bin/bash

set -euxo pipefail

test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

echo "Configure image: [$kiwi_iname]-[$kiwi_profiles]..."

#======================================
# Clear machine specific configuration
#--------------------------------------
## Clear machine-id on pre generated images
rm -f /etc/machine-id
touch /etc/machine-id
## remove random seed, the newly installed instance should make its own
rm -f /var/lib/systemd/random-seed

#======================================
# Delete & lock the root user password
#--------------------------------------
passwd -d root
passwd -l root

#======================================
# Setup default services
#--------------------------------------

## Enable wicked
systemctl enable wicked.service
## Enable chrony
systemctl enable chronyd.service
## Enable persistent journal
mkdir -p /var/log/journal

if [[ "$kiwi_profiles" == *"GNOME"* ]] || [[ "$kiwi_profiles" == *"KDE"* ]] || [[ "$kiwi_profiles" == *"XFCE"* ]]; then
	systemctl set-default graphical.target
else
	systemctl set-default multi-user.target
fi

#======================================
# Enable yast2-firstboot
#--------------------------------------
touch /var/lib/YaST2/reconfig_system

#======================================
# Generate boot.bin
#--------------------------------------
mkdir -p /boot/efi/m1n1
update-m1n1 /boot/efi/m1n1/boot.bin
rm -rf /boot/.builder
#======================================
# Regenerate initrds
#--------------------------------------
mkinitrd
grub2-mkconfig -o /boot/grub2/grub.cfg

exit 0
