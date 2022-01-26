#!/bin/bash

COUNT=$(find pcap -type f | wc -l | awk '{print $1}')

[[ ! -d input ]] && mkdir input
[[ -e input/input.pcap ]] && rm -f input/input.pcap

function run_container() {
    docker run --rm -v "${PWD}"/input:/input -v "${PWD}"/pcap:/pcap:ro container-network-tools mergecap -w input/input.pcap pcap/*
}

if [[ ${COUNT} -gt 1 ]]; then
    if docker images -a | grep -E ^container-network-tools > /dev/null 2>&1 ; then
        run_container
    else
        echo "No container-network-tools container. Build."
        docker build --tag=container-network-tools tools
        run_container
    fi
fi

docker run -it --rm -v "${PWD}"/input:/pcap:ro -v "${PWD}"/output:/output -w /output container-zeek zeek -C -r "/pcap/input.pcap"

rm -rf input
