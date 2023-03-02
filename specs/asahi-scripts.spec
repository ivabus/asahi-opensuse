Name:           asahi-scripts
Version:        20221220
Release:        4
Summary:        Miscellaneous scripts for Asahi Linux

License:        MIT
URL:            https://github.com/AsahiLinux/asahi-scripts
Source0:        %{url}/archive/%{version}/%{name}-%{version}.tar.gz

BuildRequires:  systemd-rpm-macros

Requires:       bash
Requires:       growpart
Requires:       coreutils
Requires:       diffutils
Requires:       dosfstools
Requires:       sed
Requires:       tar
Requires:       asahi-dtbs
Requires:       m1n1
Requires:       uboot-asahi

BuildArch:      aarch64

%description
This package contains miscellaneous admin scripts for the Asahi Linux reference
distro.

%prep
%setup -n asahi-scripts-%{version}

%install
make DESTDIR=%{buildroot} PREFIX=/usr install
make DESTDIR=%{buildroot} PREFIX=/usr DRACUT_CONF_DIR=/etc/dracut.conf.d install-dracut

%files
%license LICENSE
/etc/m1n1.conf
/etc/dracut.conf.d/10-asahi.conf
/usr/bin/update-m1n1
/usr/bin/asahi-fwextract
/usr/bin/asahi-diagnose
/usr/share/asahi-scripts/functions.sh
/usr/lib/dracut/modules.d/99asahi-firmware/module-setup.sh
/usr/lib/dracut/modules.d/99asahi-firmware/install-asahi-firmware.sh
/usr/lib/dracut/modules.d/99asahi-firmware/load-asahi-firmware.sh

#%%changelog
#%%autochangelog
