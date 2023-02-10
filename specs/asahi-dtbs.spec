Name:       asahi-dtbs
Version:    6.2_rc3_6
# From _commit_id in 01_build_kernel.sh
Release:    1
Summary:    Device Trees (dtb) for Apple Silicon machines

License:    GPLv2+
URL:        https://github.com/AsahiLinux/linux
BuildArch:  aarch64

Source0:    dtbs-%{version}.tar
# Generated by 01_build_kernel.sh

%description
Device Trees (dtb) for Apple Silicon machines

%prep
%setup -n dtbs

%install
install -Dpm 755 -t %{buildroot}/lib/modules/$(cat release)-ARCH/dtbs/ $(find . -type f)

%files
/lib/modules/*-ARCH/dtbs/

%posttrans
update-m1n1

%changelog