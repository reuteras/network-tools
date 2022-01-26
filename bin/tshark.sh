#!/bin/bash

COUNT=$(find pcap -type f | wc -l | awk '{print $1}')

function run_container() {
    for file in pcap/* ; do
        outfile=$(echo "${file}" | sed -E "s#.*/##")
        docker run --rm -v "${PWD}"/pcap:/pcap -v "${PWD}"/output:/output reuteras/container-alpine-network capinfos "${file}" > output/"${outfile}".capinfo
        docker run --rm -v "${PWD}"/pcap:/pcap -v "${PWD}"/output:/output reuteras/container-alpine-network tshark -r "${file}" -q -z io,phs > output/"${outfile}".tshark-phs
    done
}


if [[ ${COUNT} -gt 1 ]]; then
    if docker images -a | grep -E ^reuteras/container-alpine-network > /dev/null 2>&1 ; then
        run_container
    else
        echo "Download reuteras/container-alpine-network"
        docker pull reuteras/container-alpine-network
        run_container
    fi
fi

