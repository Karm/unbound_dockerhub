FROM fedora:20
MAINTAINER Michal Karm Babacek <karm@email.cz>

# TODO: We install stuff that's superfluous at runtime.
#       Let's move build time dependencies to the build layer
RUN yum -y update && yum -y install wget expat-devel expatpp-devel file unzip python-devel swig make autoconf gcc sed binutils gawk openssl-devel openssl-libs byacc bash && yum clean all

# TODO: How about ONBUILD?
#ONBUILD 

WORKDIR /opt
RUN mkdir /opt/unbound-build -p
ENV PYTHON_SITE_PKG /opt/unbound-build/etc/unbound/
ENV DEF_CFG ${PYTHON_SITE_PKG}/unbound.conf
ENV UNBOUND_BRANCH docker_dev

# TODO: OMG, is there another way how to keep stuff on a single fs layer?
RUN  wget https://github.com/Karm/unbound/archive/${UNBOUND_BRANCH}.zip && unzip ${UNBOUND_BRANCH}.zip && cd unbound-${UNBOUND_BRANCH} && \
     ./configure --prefix=/opt/unbound-build --with-pythonmodule=${PYTHON_SITE_PKG} && make && make install && make clean && \
     cp ./pythonmod/doc/examples/example0-1.py /opt/python_script.py && \
     rm -rf /opt/unbound-${UNBOUND_BRANCH} /opt/docker_dev.zip

RUN useradd unbound
WORKDIR /opt/unbound-build/sbin

# TODO: Default conf, TBD.
# TODO: python-script is not a part of this image
RUN echo '' > ${DEF_CFG} && \
    echo 'server:' >> ${DEF_CFG} && \
    echo '  verbosity: 2' >> ${DEF_CFG} && \
    echo '  interface: 0.0.0.0@53' >> ${DEF_CFG} && \
    echo '  interface: ::0@53 ' >> ${DEF_CFG} && \
    echo '  access-control: 172.0.0.0/8 allow' >> ${DEF_CFG} && \
    echo '  access-control: fe80::/16 allow' >> ${DEF_CFG} && \
    echo '  chroot: ""' >> ${DEF_CFG} && \
    echo '  logfile: ""' >> ${DEF_CFG} && \
    echo '  username: "unbound"' >> ${DEF_CFG} && \
    echo '  module-config: "validator iterator python"' >> ${DEF_CFG} && \
    echo 'python:' >> ${DEF_CFG} && \
    echo '  python-script: "/opt/python_script.py"' >> ${DEF_CFG} && \
    echo 'remote-control:' >> ${DEF_CFG} && \
    echo '  control-enable: no' >> ${DEF_CFG}

EXPOSE 53
EXPOSE 53/udp

CMD ["./unbound","-dvvv"]