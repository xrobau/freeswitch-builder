ARG VERSION
FROM libssbuilder:${VERSION}

COPY fsbuild.repo /etc/yum.repos.d/

RUN yum -y install centos-release-scl
RUN yum -y install devtoolset-9

## Switch to devtoolset-9 from clang
ENV PATH=/usr/lib64/ccache:/opt/rh/devtoolset-9/root/usr/bin:/usr/local/clang12.0.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV CCACHE_DIR=/usr/local/ccache
ENV CCACHE_PATH=
ENV MANPATH=/opt/rh/devtoolset-9/root/usr/share/man
ENV INFOPATH=/opt/rh/devtoolset-9/root/usr/share/info
ENV PCP_DIR=/opt/rh/devtoolset-9/root
ENV LD_LIBRARY_PATH=/opt/rh/devtoolset-9/root/usr/lib64:/opt/rh/devtoolset-9/root/usr/lib:/opt/rh/devtoolset-9/root/usr/lib64/dyninst:/opt/rh/devtoolset-9/root/usr/lib/dyninst:/opt/rh/devtoolset-9/root/usr/lib64:/opt/rh/devtoolset-9/root/usr/lib
ENV PKG_CONFIG_PATH=/opt/rh/devtoolset-9/root/usr/lib64/pkgconfig
ENV CXX=g++
ENV CC=gcc

## I spread the installs out over a bunch of lines so it was easier
## to debug. These containers aren't getting moved anywhere, so it's
## better to have them easy to use, insead of as small as possible.
RUN yum -y install curl-devel gnutls-devel ncurses-devel pcre-devel speex-devel sqlite-devel libtiff-devel ldns-devel libedit-devel yasm
RUN yum -y install perl-ExtUtils-Embed unixODBC-devel gdbm-devel libogg-devel libvorbis-devel libjpeg-devel alsa-lib-devel zlib-devel
RUN yum -y install e2fsprogs-devel libtheora-devel libxml2-devel bison autoconf-archive MariaDB-devel opusfile-devel net-snmp-devel
RUN yum -y install libmemcached-devel portaudio-devel libsndfile-devel broadvoice-devel flite-devel ilbc2-devel g722_1-devel
RUN yum -y install codec2-devel libsilk-devel libyuv-devel lua-devel mongo-c-driver-devel opus-devel soundtouch-devel postgresql-devel
RUN yum -y install erlang libshout-devel libmpg123-devel lame-devel MariaDB-shared
RUN yum -y install spandsp3 spandsp3-devel python-devel

## These are the new RPMS we're installing, before we build freeswitch.
ARG LIBSS
ARG LIBSSDEVEL
ARG LIBSOFIA
ADD ${LIBSS} /usr/local
ADD ${LIBSSDEVEL} /usr/local
COPY sofia*${LIBSOFIA}.el7.x86_64.rpm /usr/local/

RUN yum -y install /usr/local/${LIBSS} /usr/local/${LIBSSDEVEL} /usr/local/sofia*

## And now you're ready to build!

