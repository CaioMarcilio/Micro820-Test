FROM debian:stretch-slim

# Install Essential Debian Modules
RUN set -ex; \
    apt-get update &&\
    apt-get install -y make build-essential &&\
    apt-get install -y --fix-missing --no-install-recommends \
        tzdata \
        wget \
        nano \
        && rm -rf /var/lib/apt/lists/*  && \
    dpkg-reconfigure --frontend noninteractive tzdata

# EPICS Environment Variables
ENV EPICS_CA_AUTO_ADDR_LIST YES
ENV EPICS_IOC_CAPUTLOG_INET 0.0.0.0
ENV EPICS_IOC_CAPUTLOG_PORT 7012
ENV EPICS_IOC_LOG_INET 0.0.0.0
ENV EPICS_IOC_LOG_PORT 7011
ENV EPICS_BASE=/opt/epics-R3.15.9/base
ENV EPICS_MODULES=/opt/epics-R3.15.9/modules
ENV ASYN=${EPICS_MODULES}/asyn4-35

# --- EPICS Base ---
WORKDIR /opt
RUN apt-get update && apt-get -y install build-essential libreadline-gplv2-dev && \
    mkdir /opt/epics-R3.15.9 && \
    cd /opt/epics-R3.15.9 && \
    wget --no-check-certificate https://epics-controls.org/download/base/base-3.15.9.tar.gz && \
    tar -xzvf base-3.15.9.tar.gz && \
    rm -rf base-3.15.9.tar.gz && \
    mv base-3.15.9 base && \
    mkdir modules && \
    cd base && \
    make -j$(nproc)

# --- ASYN Driver ---
RUN cd ../modules/ && \
    wget --no-check-certificate https://www.aps.anl.gov/epics/download/modules/asyn4-35.tar.gz && \
    tar -xvzf asyn4-35.tar.gz && \
    rm -rf asyn4-35.tar.gz && \
    sed -i -e '3,4s/^/#/' -e '8,11s/^/#/' -e '14cEPICS_BASE='${EPICS_BASE} asyn4-35/configure/RELEASE && \
    cd asyn4-35 && \
    make -j$(nproc)

# --- Stream Device ---
RUN cd .. && \
    wget --no-check-certificate https://github.com/paulscherrerinstitute/StreamDevice/archive/2.8.16.tar.gz && \
    tar -zxvf 2.8.16.tar.gz && \
    rm -rf 2.8.16.tar.gz && \
    cd StreamDevice-2.8.16 && \
    sed -i -e '11,18s/^/#/' -e '21,22s/^/#/' -e '29,31s/^/#/' -e '20cASYN='${ASYN} -e '25cEPICS_BASE='${EPICS_BASE} configure/RELEASE && cat configure/RELEASE && \
    make -j$(nproc)

COPY ./ioc/ /root/ioc-micro820/
# COPY ./entrypoint.sh /root/ioc-micro820/iocBoot/

WORKDIR /root/ioc-micro820/iocBoot/

ENTRYPOINT ["/bin/bash", "-c", "sleep 5000"]
