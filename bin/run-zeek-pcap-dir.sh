#!/bin/bash

COUNT=$(find pcap -type f | wc -l | awk '{print $1}')

[[ ! -d input ]] && mkdir input
[[ -e input/input.pcap ]] && rm -f input/input.pcap

function run_container() {
    docker run --rm -v "${PWD}"/input:/input -v "${PWD}"/pcap:/pcap:ro reuteras/container-alpine-network mergecap -w input/input.pcap pcap/*
}

if [[ ${COUNT} -gt 1 ]]; then
    if docker images -a | grep -E ^reuteras/container-alpine-network > /dev/null 2>&1 ; then
        run_container
    else
        echo "No reuteras/container-alpine-network container. Pull."
        docker pull reuteras/container-alpine-network
        run_container
    fi
else
    cp pcap/* input/input.pcap
fi

if [[ "${1}" == "json" ]]; then
    docker run -it --rm -v "${PWD}"/input:/pcap:ro -v "${PWD}/output-json":/output -v "${PWD}/config/local.zeek:/opt/zeek/share/zeek/site/local.zeek" -w /output reuteras/container-zeek zeek -C -r "/pcap/input.pcap" local
else
    docker run -it --rm -v "${PWD}"/input:/pcap:ro -v "${PWD}/output":/output -w /output reuteras/container-zeek zeek -C -r "/pcap/input.pcap"
fi

rm -rf input
