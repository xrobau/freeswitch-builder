ARG VERSION
FROM libssbuilder:${VERSION}

## Switch to devtoolset-9 from clang
RUN mv /opt.disabled /opt
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

## These are the new RPMS we're installing, before we build freeswitch.
ARG LIBSS
ARG LIBSSDEVEL
ARG LIBSOFIA
ADD ${LIBSS} /usr/local
ADD ${LIBSSDEVEL} /usr/local
COPY sofia*${LIBSOFIA}.el7.x86_64.rpm /usr/local/

RUN yum -y install /usr/local/${LIBSS} /usr/local/${LIBSSDEVEL} /usr/local/sofia*

## And now you're ready to build!

