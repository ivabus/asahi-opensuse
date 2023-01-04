Name:           m1n1
Version:        1.2.4
Release:        1
Summary:        Bootloader and experimentation playground for Apple Silicon

# m1n1 proper is MIT licensed, but it relies on a number of vendored projects
# See the "License" section in README.md for the breakdown
License:        MIT and CC0 and BSD and OFL and zlib
URL:            https://github.com/AsahiLinux/m1n1
Source0:         %{url}/archive/v%{version}/%{name}-%{version}.tar.gz

%ifarch aarch64
# On aarch64 do a native build
BuildRequires:  gcc
%global buildflags RELEASE=1 ARCH=
%else
# By default m1n1 does a cross build
BuildRequires:  gcc-aarch64-linux-gnu
%global buildflags RELEASE=1
%endif
BuildRequires:  make

BuildRequires:  ImageMagick
BuildRequires:  zopfli

# For the udev rule
BuildRequires:  systemd-rpm-macros

# These are bundled, modified and statically linked into m1n1
Provides:       bundled(arm-trusted-firmware)
Provides:       bundled(dwc3)
Provides:       bundled(dlmalloc)
Provides:       bundled(PDCLib)
Provides:       bundled(libfdt)
Provides:       bundled(minilzlib)
Provides:       bundled(tinf)

%description
m1n1 is the bootloader developed by the Asahi Linux project to bridge the Apple
(XNU) boot ecosystem to the Linux boot ecosystem.

%prep
tar xpvf %{_sourcedir}/%{name}-%{version}.tar.gz

%build
cd %{name}-%{version}
%make_build %{buildflags}

%install
install -Dpm0644 -t %{buildroot}/usr/lib/asahi-boot %{name}-%{version}/build/%{name}.bin

%files
%license %{name}-%{version}/LICENSE %{name}-%{version}/3rdparty_licenses/LICENSE.*
%doc %{name}-%{version}/README.md
/usr/lib/asahi-boot/m1n1.bin

%posttrans
update-m1n1

%changelog
* Tue Jan 24 2023 Ivan Bushchik <ivabus@ivabus.dev> 1.2.4-1
- Update to 1.2.4; Fix installation

* Sun Jan 22 2023 Ivan Bushchik <ivabus@ivabus.dev> 1.2.3-1
- Initial version