# Build zeek
FROM ubuntu:focal as builder
LABEL maintainer="Coding <code@ongoing.today>"

ENV WD /scratch
ENV DEBIAN_FRONTEND noninteractive
ENV VER 4.0.2
ENV PATH /zeek/bin:/opt/spicy/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN mkdir ${WD}

WORKDIR ${WD}

ADD ./common/buildzeek ${WD}/common/buildzeek
ADD ./common/buildspicy ${WD}/common/buildspicy
ADD ./common/buildstrip ${WD}/common/buildstrip

RUN apt-get update && \
    apt-get upgrade -yq && \
    apt-get -y install --no-install-recommends \
        binutils \
        bison \
        build-essential \
        ca-certificates \
        ccache \
        cmake \
        curl \
        file \ 
        flex \
        g++ \
        gawk \
        git \
        gnupg2 \
        libcurl4-openssl-dev \
        libfl-dev \
        libmaxminddb0 \
        libmaxminddb-dev \
        libncurses5-dev \
        libpcap0.8 \
        libpcap-dev \
        libssl-dev \
        locales-all \
        make \
        ninja-build \
        python3-dev \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        swig \
        wget \
        zlib1g-dev
# Run in separate statements. Build environment so no need to optimice space.
RUN ${WD}/common/buildzeek zeek ${VER}
RUN ${WD}/common/buildspicy zeek ${VER}
RUN ${WD}/common/buildstrip zeek ${VER}


# Get geoip data
FROM ubuntu:focal as geogetter
ARG MAXMIND_LICENSE_KEY
ADD ./common/getmmdb.sh /usr/local/bin/getmmdb.sh

RUN apt-get update && \
    apt-get -qy install wget ca-certificates --no-install-recommends && \
    mkdir -p /usr/share/GeoIP && \
    /usr/local/bin/getmmdb.sh ${MAXMIND_LICENSE_KEY} && \
    # This is a workaround for the case where getmmdb.sh does not create any files.
    touch /usr/share/GeoIP/.notempty


# Make final image
FROM ubuntu:focal
ENV VER 4.0.2
ENV DEBIAN_FRONTEND noninteractive
ENV PATH /zeek/bin:/opt/spicy/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ADD ./common/zeek_profile.sh /etc/profile.d/zeek.sh
COPY --from=builder /usr/local/zeek-${VER} /usr/local/zeek-${VER}
COPY --from=builder /opt/spicy /opt/spicy
COPY --from=geogetter /usr/share/GeoIP/* /usr/share/GeoIP/

RUN apt-get update && \
    apt-get -yq install --no-install-recommends \
        libpcap0.8 \
        libssl1.1 \
        libmaxminddb0 \
        python3-minimal && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc && \
    rm -rf /usr/local/share/man /var/cache/debconf/*-old && \
    rm -f /usr/share/GeoIP/.notempty && \
    ln -s /usr/local/zeek-${VER} /bro && \
    ln -s /usr/local/zeek-${VER} /zeek && \
    mkdir /output
    
WORKDIR "/output"

CMD /bin/bash -l
