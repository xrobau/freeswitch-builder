ARG VERSION
FROM libksbuilder:${VERSION}

ARG LIBKS
ADD ${LIBKS} /usr/local
RUN ls -al /usr/local
RUN yum -y install /usr/local/${LIBKS}

RUN yum -y install glib2-devel lksctp-tools-devel


