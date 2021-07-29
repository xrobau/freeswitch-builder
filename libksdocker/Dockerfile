FROM clangbuilder:12.0.0

ARG LIBJWT
ARG LIBJWTDEVEL
ADD ${LIBJWT} /usr/local
ADD ${LIBJWTDEVEL} /usr/local

RUN ls -l /usr/local/*rpm
RUN yum -y install /usr/local/${LIBJWT} /usr/local/${LIBJWTDEVEL}

