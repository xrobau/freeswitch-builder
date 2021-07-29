%undefine _missing_build_ids_terminate_build

Name:			libstirshaken
Summary:		STIR/SHAKEN library.
Version:		__VERSION__
Release:		__RELEASE__%{?dist}
License:		MIT
Group:			System Environment/Libraries
Source0:		__SOURCE__
URL:			http://freeswitch.org/

BuildRequires:		libcurl-devel >= 7.19
BuildRequires:		libjwt-devel >= 1.12
BuildRequires:		libks
BuildRequires:		openssl11-devel
BuildRequires:		git
BuildRequires:		autoconf
BuildRequires:		automake
BuildRequires:		libtool
BuildRequires:		libuuid-devel

%description
%{name}

%package devel
Summary:		Development files for %{name}
Group:			Development/Libraries
Requires:		%{name} = %{version}-%{release}

%description devel
Development libraries and headers for developing software against
%{name}.

%prep
%setup -q -n __LIBSSPREFIX__
autoreconf -fiv

%build
export CXXFLAGS="$CXXFLAGS -Wno-error"
export CFLAGS="$CFLAGS -Wno-error"
export CPPFLAGS="$CPPFLAGS -Wno-error"
export LDFLAGS="-Wl,--allow-multiple-definition"
%configure --enable-shared

%{__make}

%install
DESTDIR=%{buildroot} %{__make} install

%post -p /sbin/ldconfig
%postun -p /sbin/ldconfig

%files
%{_bindir}/stir_shaken*
%{_bindir}/stirshaken
%{_libdir}/libstirshaken.so.*

%files devel
# These are SDK docs, not really useful to an end-user.
%{_libdir}/pkgconfig/stirshaken.pc
%{_libdir}/libstirshaken.so
%{_libdir}/libstirshaken.a
%{_libdir}/libstirshaken.la
%{_includedir}/stir_shaken.h
