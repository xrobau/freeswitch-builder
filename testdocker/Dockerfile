ARG VERSION
FROM fsbuilder:${VERSION}

RUN yum -y install net-tools

ARG FREESWITCH
COPY freeswitch*${FREESWITCH} /usr/local/

RUN ls -al /usr/local && yum -y install /usr/local/freeswitch*

ADD fs.tar.gz /


