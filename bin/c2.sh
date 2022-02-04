#!/bin/bash

[[ -e rita.yaml ]] && exit

read -r -p "Enter C2 IP: " c2

cp rita-default.yaml rita.yaml

sed -i "" -e "s/CHANGEME/${c2}/" rita.yaml 

