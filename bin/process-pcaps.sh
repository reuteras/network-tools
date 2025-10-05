#!/bin/bash
# Generate zeek logs for more then one pcap files in specified directory.

if [[ "${#}" != "1" ]]; then
    echo "Usage: $0 <directory with pcaps>"
    exit
fi

PCAP_DIR="${1}"
LOG_DIR=logs

if [[ ! -d "${PCAP_DIR}" ]]; then
    echo "Error: Not a directory: ${1}"
    exit
fi

[[ -d output ]] || mkdir output

# Only run if output directory is empty
if ! find output -type f | wc -l | grep -E "^0" > /dev/null ; then
    echo "Directory output not empty"
    exit
fi

# Temporary dir for logs
if [[ -d "$LOG_DIR" ]] ; then
    echo "Error: Log dir exists: ${LOG_DIR}"
    exit
else
    mkdir "${LOG_DIR}"
fi

# Requieres capinfos
if ! which capinfos > /dev/null ; then
    echo "Error: capinfos not installed."
    exit
fi

# Process pcaps in directory.
for pcap in "${PCAP_DIR}"/* ; do
    pcap_basename=$(basename "$pcap")
    docker run -it --rm -v "${PCAP_DIR}":/pcap:ro -v "${PWD}/output":/output -w /output reuteras/container-zeek zeek -C -r /pcap/"${pcap_basename}"
    time=$(capinfos "${pcap}" | grep "First packet time" | awk '{print $4"-"$5}' | cut -f1 -d,)
    for log in output/*; do
        logname=$(basename "${log}" | cut -f1 -d.)
        if [[ -e "${LOG_DIR}"/"${logname}.${time}.log" ]]; then
            echo "Log exists! ${LOG_DIR}/${logname}.${time}.log"
            exit
        fi
        mv "${log}" "${LOG_DIR}"/"${logname}.${time}.log" 
    done
done

# Move files to output directory for use in other scripts
cp "${LOG_DIR}"/* output || exit
rm -rf "${LOG_DIR}"
