#!/bin/bash

COUNT=$(find pcap -type f | wc -l | awk '{print $1}')

function run_container() {
    for file in pcap/* ; do
        outfile=$(echo "${file}" | sed -E "s#.*/##")
        docker run --rm -v "${PWD}"/pcap:/pcap -v "${PWD}"/output:/output network-tools capinfos "${file}" > output/"${outfile}".capinfo
        docker run --rm -v "${PWD}"/pcap:/pcap -v "${PWD}"/output:/output network-tools tshark -r "${file}" -q -z io,phs > output/"${outfile}".tshark-phs
    done
}


if [[ ${COUNT} -gt 1 ]]; then
    if docker images -a | grep -E ^network-tools > /dev/null 2>&1 ; then
        run_container
    else
        echo "No network-tools container. Build."
        docker build --tag=network-tools tools
        run_container
    fi
fi

