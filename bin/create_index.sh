#!/bin/bash

while ! curl -s "http://127.0.0.1:9200/.kibana/dashboard/_search?pretty" | grep '"successful" : 1,' > /dev/null; do
    sleep 1
done

sleep 1

if [[ "${1}" == "json" ]]; then
curl -XPOST "http://localhost:9200/.kibana/_doc/index-pattern:my-index-pattern-name" -H 'Content-Type: application/json' -d'
{
    "type" : "index-pattern",
    "index-pattern" : {
        "title": "filebeat*",
        "timeFieldName": "@timestamp"
    }
}'
else
curl -XPOST "http://localhost:9200/.kibana/_doc/index-pattern:my-index-pattern-name" -H 'Content-Type: application/json' -d'
{
    "type" : "index-pattern",
    "index-pattern" : {
        "title": "zeek*",
        "timeFieldName": "@timestamp"
    }
}'
fi
echo ""
