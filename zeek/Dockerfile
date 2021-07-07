# Build zeek
FROM ubuntu:focal
LABEL maintainer="Coding <code@ongoing.today>"

ENV DEBIAN_FRONTEND noninteractive
ENV ZEEK_LTS=-lts
ENV ZEEK_VERSION=4.0.3-0
ENV SPICY_VERSION=1.1.0

ENV ZEEK_DIR "/opt/zeek"
ENV SPICY_DIR "/opt/spicy"
ENV PATH "${ZEEK_DIR}/bin:${SPICY_DIR}/bin:${ZEEK_DIR}/lib/zeek/plugins/packages/spicy-plugin/bin:${PATH}"

ENV CCACHE_DIR "/var/spool/ccache"

ADD ./common/zeek_install_plugins.sh /usr/local/bin/

RUN apt-get update && \
    apt-get upgrade -yq && \
    apt-get -y install --no-install-recommends \
        binutils \
        bison \
        build-essential \
        ca-certificates \
        ccache \
        clang-11 \
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
        python3-git \
        python3-pip \
        python3-semantic-version \
        python3-setuptools \
        python3-wheel \
        swig \
        wget \
        zlib1g-dev && \
    python3 -m pip install --no-cache-dir pyzmq && \
    mkdir -p /tmp/zeek-packages && \
    cd /tmp/zeek-packages && \
    curl -sSL --remote-name-all \
        "https://download.zeek.org/binary-packages/xUbuntu_20.04/amd64/libbroker${ZEEK_LTS}-dev_${ZEEK_VERSION}_amd64.deb" \
        "https://download.zeek.org/binary-packages/xUbuntu_20.04/amd64/zeek${ZEEK_LTS}-core-dev_${ZEEK_VERSION}_amd64.deb" \
        "https://download.zeek.org/binary-packages/xUbuntu_20.04/amd64/zeek${ZEEK_LTS}-core_${ZEEK_VERSION}_amd64.deb" \
        "https://download.zeek.org/binary-packages/xUbuntu_20.04/amd64/zeek${ZEEK_LTS}-libcaf-dev_${ZEEK_VERSION}_amd64.deb" \
        "https://download.zeek.org/binary-packages/xUbuntu_20.04/amd64/zeek${ZEEK_LTS}_${ZEEK_VERSION}_amd64.deb" \
        "https://download.zeek.org/binary-packages/xUbuntu_20.04/amd64/zeek${ZEEK_LTS}-btest_${ZEEK_VERSION}_amd64.deb" \
        "https://download.zeek.org/binary-packages/xUbuntu_20.04/amd64/zeek${ZEEK_LTS}-zkg_${ZEEK_VERSION}_amd64.deb" \
        "https://download.zeek.org/binary-packages/xUbuntu_20.04/amd64/zeekctl${ZEEK_LTS}_${ZEEK_VERSION}_amd64.deb" && \
    dpkg -i ./*.deb && \
    mkdir -p /tmp/spicy-packages && \
    cd /tmp/spicy-packages && \
    curl -sSL --remote-name-all \
        "https://github.com/zeek/spicy/releases/download/v${SPICY_VERSION}/spicy_linux_debian10.deb" && \
    dpkg -i ./*.deb && \
	cd /tmp && \
    mkdir -p "${CCACHE_DIR}" && \
    zkg autoconfig --force && \
    zkg install --force --skiptests zeek/spicy-plugin && \
    bash /usr/local/bin/zeek_install_plugins.sh && \
    ( find "${ZEEK_DIR}"/lib -type d -name CMakeFiles -exec rm -rf "{}" \; 2>/dev/null || true ) && \
    ( find "${ZEEK_DIR}"/var/lib/zkg -type d -name build -exec rm -rf "{}" \; 2>/dev/null || true ) && \
    ( find "${ZEEK_DIR}"/var/lib/zkg/clones -type d -name .git -execdir bash -c "pwd; du -sh; git pull --depth=1 --ff-only; git reflog expire --expire=all --all; git tag -l | xargs -r git tag -d; git gc --prune=all; du -sh" \; ) && \
    rm -rf "${ZEEK_DIR}"/var/lib/zkg/scratch && \
    ( find "${ZEEK_DIR}/" "${SPICY_DIR}/" -type f -exec file "{}" \; | grep -Pi "ELF 64-bit.*not stripped" | sed 's/:.*//' | xargs -l -r strip --strip-unneeded ) && \
    ( find "${ZEEK_DIR}/" "${SPICY_DIR}/" -type f -exec file "{}" \; | grep -Pi "current ar archive" | sed 's/:.*//' | xargs -l -r strip --strip-unneeded ) && \
    mkdir -p "${ZEEK_DIR}"/var/lib/zkg/clones/package/spicy-plugin/build/plugin/bin/ && \
    ln -s -r "${ZEEK_DIR}"/lib/zeek/plugins/packages/spicy-plugin/bin/spicyz \
        "${ZEEK_DIR}"/var/lib/zkg/clones/package/spicy-plugin/build/plugin/bin/spicyz && \
    mkdir -p "${ZEEK_DIR}"/var/lib/zkg/clones/package/spicy-plugin/plugin/lib/ && \
    ln -s -r "${ZEEK_DIR}"/lib/zeek/plugins/packages/spicy-plugin/lib/bif \
        "${ZEEK_DIR}"/var/lib/zkg/clones/package/spicy-plugin/plugin/lib/bif && \
    cd /usr/lib/locale && \
    ( ls | grep -Piv "^(en|en_US|en_US\.utf-?8|C\.utf-?8)$" | xargs -l -r rm -rf ) && \
    cd /tmp && \
    apt-get clean && \
    apt-get autoremove -y && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/*/*

CMD ["/bin/bash"]
