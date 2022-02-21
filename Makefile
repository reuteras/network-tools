all: run report

virtualenv = .env
elastic_version = 7.17.0
python = python3.8

$(virtualenv):
	test -d $(virtualenv) || $(python) -m venv $(virtualenv)
	. $(virtualenv)/bin/activate && python -m pip install -U pip

python-requires: $(virtualenv)
	. $(virtualenv)/bin/activate && python -m pip install requests

zeek-interactive-shell:
	docker run -it --rm -v "$$PWD"/pcap:/pcap:ro -v "$$PWD"/output:/output -w /output reuteras/container-zeek /bin/bash

zeek-zeek2es-import: .env python-requires es-up
	. $(virtualenv)/bin/activate && find output -name "*.log" -exec python zeek2es.py {} \;

zeek-output: output pcap clean
	rm -rf output/*
	./bin/run-zeek-pcap-dir.sh

zeek-json-import: output-json
	rm -rf output-json/*
	docker-compose -f docker-compose-elastic.yml --profile filebeat up -d
	./bin/create_index.sh json
	sleep 30
	./bin/run-zeek-pcap-dir.sh json

create-capinfos:
	./bin/tshark.sh

output: 
	mkdir -p output

output-json:
	mkdir -p output-json

pcap:
	mkdir -p pcap

reports:
	mkdir -p reports

dirs: output output-json pcap reports

rita.yaml:
	./bin/c2.sh

rita-generate-report: rita.yaml reports
	docker-compose -f docker-compose-rita.yml run --rm rita import /logs pcaps
	docker-compose -f docker-compose-rita.yml run --name pcaps rita html-report
	docker cp "pcaps:/pcaps" reports/$(shell date +"%s")
	docker rm pcaps 2> /dev/null
	docker stop network-tools_db_1 2> /dev/null
	docker rm network-tools_db_1 2> /dev/null

rita-open-report:
	open reports/$(shell ls -rt reports/ | tail -1)/pcaps/index.html 2> /dev/null || true
	xdg-open reports/$(shell ls -rt reports/ | tail -1)/pcaps/index.html 2> /dev/null || true

image-pull:
	docker pull reuteras/container-zeek || true
	docker pull reuteras/container-alpine-network:latest || true
	docker pull docker.elastic.co/elasticsearch/elasticsearch:$(elastic_version) || true
	docker pull docker.elastic.co/kibana/kibana:$(elastic_version) || true
	docker pull docker.elastic.co/beats/filebeat:$(elastic_version) || true

image-rm: es-down
	docker rmi reuteras/container-zeek || true
	docker rmi reuteras/container-alpine-network:latest || true
	docker rmi docker.elastic.co/elasticsearch/elasticsearch:$(elastic_version) || true
	docker rmi docker.elastic.co/kibana/kibana:$(elastic_version) || true
	docker rmi docker.elastic.co/beats/filebeat:$(elastic_version) || true

update-zeek2es:
	curl -o zeek2es.py -s https://raw.githubusercontent.com/corelight/zeek2es/master/zeek2es.py && chmod +x zeek2es.py

es-up:
	docker-compose -f docker-compose-elastic.yml up -d
	./bin/create_index.sh

es-down:
	docker-compose -f docker-compose-elastic.yml down

clean-db:
	docker stop network-tools_db_1 2> /dev/null || true
	docker rm network-tools_db_1 2> /dev/null || true
	docker volume rm network-tools_db 2> /dev/null || true

clean-pcaps:
	docker stop  pcaps 2> /dev/null || true
	docker rm pcaps 2> /dev/null || true

clean: clean-db clean-pcaps
	rm -rf .env rita.yaml || true

dist-clean: image-rm clean
	rm -rf output output-json reports
