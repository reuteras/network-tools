virtualenv = .env
$(virtualenv):
	test -d $(virtualenv) || python3 -m venv $(virtualenv)
	. $(virtualenv)/bin/activate && python -m pip install -U pip

requires: $(virtualenv)
	. $(virtualenv)/bin/activate && python -m pip install requests

all: run report

interactive: run-zeek

run-zeek:
	docker run -it --rm -v "$$PWD"/pcap:/pcap:ro -v "$$PWD"/output:/output -w /output reuteras/container-zeek /bin/bash

run: output pcap reports clean
	rm -rf output/*
	./bin/run-zeek-pcap-dir.sh
	./bin/tshark.sh
	docker-compose run --rm rita import /logs pcaps
	docker-compose run --name pcaps rita html-report
	rm -rf pcaps
	docker cp "pcaps:/pcaps" reports/$(shell date +"%s")

output: 
	mkdir -p output

pcap:
	mkdir -p pcap

report:
	open reports/$(shell ls -rt reports/ | tail -1)/pcaps/index.html 2> /dev/null || true
	xdg-open reports/$(shell ls -rt reports/ | tail -1)/pcaps/index.html 2> /dev/null || true

reports:
	mkdir -p reports

image-pull:
	docker pull reuteras/container-zeek || true
	docker pull reuteras/container-alpine-network:latest || true
	docker pull docker.elastic.co/elasticsearch/elasticsearch:7.17.0 || true
	docker pull docker.elastic.co/kibana/kibana:7.17.0 || true

update-zeek2es:
	curl -o zeek2es.py -s https://raw.githubusercontent.com/corelight/zeek2es/master/zeek2es.py && chmod +x zeek2es.py

es-up:
	docker-compose -f docker-compose-elastic.yml up -d

es-down:
	docker-compose -f docker-compose-elastic.yml down

es-create-index:
	./create_index.sh

zeek-import: .env requires
	. $(virtualenv)/bin/activate && find output -name "*.log" -exec python zeek2es.py {} \;

zeek-es: es-up es-create-index zeek-import

image-rm:
	docker rmi reuteras/container-zeek || true
	docker rmi reuteras/container-alpine-network:latest || true

clean:
	rm -rf .env || true
	docker rm pcaps 2> /dev/null || true
	docker stop network-tools_db_1 2> /dev/null || true
	docker rm network-tools_db_1 2> /dev/null || true
	docker volume rm network-tools_db 2> /dev/null || true

dist-clean: image-rm clean
	rm -rf output reports
