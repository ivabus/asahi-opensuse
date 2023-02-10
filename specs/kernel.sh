#!/bin/bash
cd=$(pwd)
_rcver=6.2
_rcrel=3
_asahirel=6
_commit_id=asahi-${_rcver}${_rcrel+-rc}${_rcrel}-${_asahirel}

rpmbuildsources=$(rpm --eval %{_sourcedir})

curl -fSLo $rpmbuildsources/${_commit_id}.tar.gz https://github.com/AsahiLinux/linux/archive/refs/tags/${_commit_id}.tar.gz
echo 
curl -fSLo $rpmbuildsources/config-${_commit_id} https://raw.githubusercontent.com/AsahiLinux/PKGBUILDs/main/linux-asahi/config
tmpdir=$(mktemp -dp /var/tmp)
cd $tmpdir
tar xpvf $rpmbuildsources/${_commit_id}.tar.gz
cd linux-${_commit_id}
ver=$(make kernelversion)
cd $cd
rm -rf $tmpdir

cat > kernel.spec << EOF
%define _rcver ${_rcver}
%define _rcrel ${_rcrel}
%define _asahirel ${_asahirel}
%define _commit_id asahi-%{_rcver}%(if [ ! %_rcrel == "0" ]; then echo -rc%{_rcrel}; fi)-%{_asahirel}
%define _rpm_ver %{_rcver}%(if [ ! %_rcrel == "0" ]; then echo _rc%{_rcrel}; fi)_%{_asahirel}_asahi_suse
%define ver ${ver}-asahi-suse
Name: kernel
Summary: The Linux Kernel
Version: %{_rpm_ver}
Release: 1
License: GPL
Group: System Environment/Kernel
Vendor: The Linux Community
URL: https://www.kernel.org
Source0: https://github.com/AsahiLinux/linux/archive/refs/tags/%{_commit_id}.tar.gz
Source1: config-%{_commit_id}
Provides: kernel-drm kernel-%{_rpm_ver} kernel-default kernel kernel-asahi
BuildRequires: bc binutils bison dwarves
BuildRequires: (elfutils-libelf-devel or libelf-devel) flex
BuildRequires: gcc make openssl openssl-devel perl python3 rsync
Provides:       multiversion(kernel)

# aarch64 as a fallback of _arch in case
# /usr/lib/rpm/platform/*/macros was not included.
%define _arch %{?_arch:aarch64}
%define __spec_install_post /usr/lib/rpm/brp-compress || :
%define debug_package %{nil}

%description
The Linux Kernel, the operating system core itself
Requires(post): kmod-zstd

%package headers
Summary: Header files for the Linux kernel for use by glibc
Group: Development/System
Obsoletes: kernel-headers
Provides: kernel-headers = %{version}
Provides: glibc-kernheaders
%description headers
Kernel-headers includes the C header files that specify the interface
between the Linux kernel and userspace libraries and programs.  The
header files define structures and constants that are needed for
building most standard programs and are also needed for rebuilding the
glibc package.

%package devel
Summary: Development package for building kernel modules to match the %{_rpm_ver} kernel
Group: System Environment/Kernel
AutoReqProv: no
%description -n kernel-devel
This package provides kernel headers and makefiles sufficient to build modules
against the %{_rpm_ver} kernel package.

%package dtbs
Summary: Device Tree binaries (dtbs) for Apple Silicon machines
Group: System Environment/Kernel
Provides: asahi-dtbs kernel-asahi-dtbs
%description dtbs
Device Tree binaries (dtbs) for Apple Silicon machines


%prep
%setup -n linux-%{_commit_id} -q
sed -i -e s/-ARCH/-suse/ %{_sourcedir}/config-%{_commit_id}
cp %{_sourcedir}/config-%{_commit_id} .config
make olddefconfig prepare
diff -u %{_sourcedir}/config-%{_commit_id} .config || :
rm -f scripts/basic/fixdep scripts/kconfig/conf
rm -f tools/objtool/{fixdep,objtool}

%build
make %{?_smp_mflags} KBUILD_BUILD_VERSION=%{release} vmlinux modules dtbs Image

%install
mkdir -p %{buildroot}/boot
cp arch/arm64/boot/Image %{buildroot}/boot/Image-%{ver}
make %{?_smp_mflags} INSTALL_MOD_PATH=%{buildroot} modules_install
make %{?_smp_mflags} INSTALL_HDR_PATH=%{buildroot}/usr headers_install
cp System.map %{buildroot}/boot/System.map-%{ver}
cp .config %{buildroot}/boot/config-%{ver}
rm -f %{buildroot}/lib/modules/%{ver}/build
rm -f %{buildroot}/lib/modules/%{ver}/source
mkdir -p %{buildroot}/usr/src/kernels/%{ver}
make INSTALL_PATH=. dtbs_install
install -Dpm 755 -t %{buildroot}/lib/modules/%{ver}-ARCH/dtbs/ \$(find dtbs/ -type f)
tar cf - --exclude SCCS --exclude BitKeeper --exclude .svn --exclude CVS --exclude .pc --exclude .hg --exclude .git --exclude=*vmlinux* --exclude=*.mod --exclude=*.o --exclude=*.ko --exclude=*.cmd --exclude=Documentation --exclude=.config.old --exclude=.missing-syscalls.d --exclude=*.s . | tar xf - -C %{buildroot}/usr/src/kernels/%{ver}
cd %{buildroot}/lib/modules/%{ver}
ln -sf /usr/src/kernels/%{ver} build
ln -sf /usr/src/kernels/%{ver} source

%clean
rm -rf %{buildroot}

%post
if [ -x /sbin/installkernel -a -r /boot/Image-%{ver} -a -r /boot/System.map-%{ver} ]; then
cp /boot/Image-%{ver} /boot/.Image-%{ver}-rpm
cp /boot/System.map-%{ver} /boot/.System.map-%{ver}-rpm
rm -f /boot/Image-%{ver} /boot/System.map-%{ver}
/sbin/installkernel %{ver} /boot/.Image-%{ver}-rpm /boot/.System.map-%{ver}-rpm
rm -f /boot/.Image-%{ver}-rpm /boot/.System.map-%{ver}-rpm
fi

%preun
if [ -x /sbin/new-kernel-pkg ]; then
new-kernel-pkg --remove %{ver} --rminitrd --initrdfile=/boot/initramfs-%{ver}.img
elif [ -x /usr/bin/kernel-install ]; then
kernel-install remove %{ver}
fi

%postun
if [ -x /sbin/update-bootloader ]; then
/sbin/update-bootloader --remove %{ver}
fi

%files
%defattr (-, root, root)
/lib/modules/%{ver}
%exclude /lib/modules/%{ver}/build
%exclude /lib/modules/%{ver}/source
/boot/*

%files headers
%defattr (-, root, root)
/usr/include

%files devel
%defattr (-, root, root)
/usr/src/kernels/%{ver}
/lib/modules/%{ver}/build
/lib/modules/%{ver}/source

%files dtbs
%defattr (-, root, root)
/lib/modules/*-ARCH/dtbs/
EOF
echo "Prepared kernel.spec for $ver"