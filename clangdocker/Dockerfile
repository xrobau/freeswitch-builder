FROM centos:7

## These are all the RPMs that freeswitch needs to build.
## They're waaaay back here at the source container so we
## don't need to redownload them over and over again if a
## container in the middle is rebuilt.
##
## These containers aren't getting moved anywhere, so it's
## better to have them easy to use, insead of as small as
## possible. Feel free to email me or whatever if you 
## disagree.  -- xrobau
#

COPY fsbuild.repo /etc/yum.repos.d/

RUN yum -y install epel-release centos-release-scl deltarpm
RUN yum -y update
RUN yum -y groupinstall "Development tools"
RUN yum -y install devtoolset-9
RUN yum -y install libcurl-devel git autoconf automake libtool libuuid-devel openssl11-devel openssl11-libs cmake3 ccache
RUN yum -y install jansson-devel vim libatomic
RUN yum -y install curl-devel gnutls-devel ncurses-devel pcre-devel speex-devel sqlite-devel libtiff-devel ldns-devel libedit-devel yasm
RUN yum -y install perl-ExtUtils-Embed unixODBC-devel gdbm-devel libogg-devel libvorbis-devel libjpeg-devel alsa-lib-devel zlib-devel
RUN yum -y install e2fsprogs-devel libtheora-devel libxml2-devel bison autoconf-archive MariaDB-devel opusfile-devel net-snmp-devel
RUN yum -y install libmemcached-devel portaudio-devel libsndfile-devel broadvoice-devel flite-devel ilbc2-devel g722_1-devel
RUN yum -y install codec2-devel libsilk-devel libyuv-devel lua-devel mongo-c-driver-devel opus-devel soundtouch-devel postgresql-devel
RUN yum -y install erlang libshout-devel libmpg123-devel lame-devel MariaDB-shared
RUN yum -y install spandsp3 spandsp3-devel python-devel

## After here, things will change, but rebuilding is fast from now on.
ARG CLANG
ADD ${CLANG} /usr/local
## Upper AND lowercase.
ENV openssl_CFLAGS=-I/usr/include/openssl11
ENV OPENSSL_CFLAGS=-I/usr/include/openssl11
ENV CFLAGS=-I/usr/include/openssl11
ENV CXXFLAGS=-I/usr/include/openssl11
ENV openssl_LIBS=-L/usr/lib64/openssl11\ -lssl\ -lcrypto
ENV OPENSSL_LIBS=-L/usr/lib64/openssl11\ -lssl\ -lcrypto
ENV LDFLAGS=-L/usr/lib64/openssl11\ -lssl\ -lcrypto
ENV PATH=/usr/lib64/ccache:/usr/local/clang12.0.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV CCACHE_DIR=/usr/local/ccache
ENV CCACHE_PATH=/usr/local/clang12.0.0/bin

ENV CXX=clang++
ENV CC=clang

RUN ln -s ../../bin/ccache /usr/lib64/ccache/clang
RUN ln -s ../../bin/ccache /usr/lib64/ccache/clang++
#
## We explicitly move devtools-9 out of the way to make sure it's not
## accidentally used by anything later.
RUN mv /opt /opt.disabled

WORKDIR /usr/local/build


