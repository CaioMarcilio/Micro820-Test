FROM ubuntu:20.04

# Install necessary modules
RUN apt-get -y update && apt-get -y upgrade; \
apt-get -y install build-essential wget nano git;

# --- EPICS BASE ---
ENV EPICS_VERSION R3.15.9
ENV EPICS_HOST_ARCH linux-x86_64
ENV EPICS_BASE /opt/epics-${EPICS_VERSION}/base
ENV EPICS_MODULES /opt/epics-${EPICS_VERSION}/modules
ENV PATH ${EPICS_BASE}/bin/${EPICS_HOST_ARCH}:${PATH}

ENV EPICS_CA_AUTO_ADDR_LIST YES
ENV EPICS_CA_ADDR_LIST=10.0.38.59

ARG EPICS_BASE_URL=https://github.com/epics-base/epics-base/archive/${EPICS_VERSION}.tar.gz
LABEL br.cnpem.epics-base=${EPICS_BASE_URL}
RUN set -ex; \
    mkdir -p ${EPICS_MODULES}; \
    wget -O /opt/epics-R3.15.9/base-3.15.9.tar.gz ${EPICS_BASE_URL}; \
    cd /opt/epics-${EPICS_VERSION}; \
    tar -xzf base-3.15.9.tar.gz; \
    rm base-3.15.9.tar.gz; \
    mv epics-base-R3.15.9 base; \
    cd base; \
    make -j$(nproc)

# --- ETHERIP MODULE ---
ARG ETHERIP_URL=https://github.com/EPICSTools/ether_ip/archive/ether_ip-3-3.tar.gz
ENV ETHER_IP ${EPICS_MODULES}/ether_ip-ether_ip-3-3
RUN cd ${EPICS_MODULES} && \
    wget ${ETHERIP_URL} && \
    tar -zxvf ether_ip-3-3.tar.gz && \
    rm -f ether_ip-3-3.tar.gz && \
    cd ether_ip-ether_ip-3-3 && \
    sed -i -e '1iEPICS_BASE='${EPICS_BASE} configure/RELEASE && \
    make -j$(nproc)

COPY ./ioc /opt/ioc
RUN sed -i 's/\r$//' /opt/ioc/iocBoot/st.cmd

WORKDIR /opt

ENTRYPOINT [ "/bin/bash", "-c", "sleep infinity"]
