#!/bin/bash

[[ -e rita.yaml ]] && exit

read -r -p "Enter C2 IP: " c2

cp config/rita-default.yaml rita.yaml

# Difference in sed on macOS and Linux?
if [[ $(uname) == "Darwin" ]]; then
    sed -i '' -e "s/CHANGEME/${c2}/" rita.yaml
else
    sed -i'' -e "s/CHANGEME/${c2}/" rita.yaml
fi

