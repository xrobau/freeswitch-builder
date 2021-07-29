FROM centos:7
ARG CLANG
ADD ${CLANG} /usr/local

RUN yum -y install epel-release
RUN yum -y groupinstall "Development tools"
RUN yum -y update
RUN yum -y install libcurl-devel git autoconf automake libtool libuuid-devel \
	openssl11-devel openssl11-libs cmake3 ccache jansson-devel vim libatomic

# Upper AND lowercase.
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

WORKDIR /usr/local/build


