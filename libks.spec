%undefine _missing_build_ids_terminate_build

Name:		libks
Version:	__VERSION__
Release:	__RELEASE__%{?dist}
Summary:	Signalwire LibKitchenSink

Group:		Standard
License:	MIT
URL:		https://github.com
Source0:	__SOURCE__

BuildRequires:          libcurl-devel >= 7.19
BuildRequires:          libjwt-devel >= 1.12
BuildRequires:          openssl11-devel >= 1.1
BuildRequires:          git
BuildRequires:          autoconf
BuildRequires:          automake
BuildRequires:          libtool
BuildRequires:          libuuid-devel
BuildRequires:		cmake3


Requires:	openssl11
Requires:	libatomic


%description
Desc

%prep
%setup -n __LIBKSPREFIX__


%build
mkdir build
cd build
cmake3 -DOPENSSL_ROOT_DIR=/usr/lib64/openssl11 -DOPENSSL_INCLUDE_DIR=/usr/include/openssl11 ..
make %{?_smp_mflags}


%install
cd build
cp ../copyright .
make install DESTDIR=%{buildroot}


%files
%{_includedir}/libks/*
/usr/lib/libks.so
/usr/lib/libks.so.1
/usr/lib64/pkgconfig/libks.pc
/usr/share/doc/libks/copyright


%doc



%changelog

