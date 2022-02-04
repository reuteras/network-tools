all: run report

virtualenv = .env

$(virtualenv):
	test -d $(virtualenv) || python3 -m venv $(virtualenv)
	. $(virtualenv)/bin/activate && python -m pip install -U pip

python-requires: $(virtualenv)
	. $(virtualenv)/bin/activate && python -m pip install requests

zeek-interactive-shell:
	docker run -it --rm -v "$$PWD"/pcap:/pcap:ro -v "$$PWD"/output:/output -w /output reuteras/container-zeek /bin/bash

zeek-import-es: .env python-requires es-up
	. $(virtualenv)/bin/activate && find output -name "*.log" -exec python zeek2es.py {} \;

zeek-output: rita.yaml dir-output dir-pcap dir-reports clean
	rm -rf output/*
	./bin/run-zeek-pcap-dir.sh
	docker-compose -f docker-compose-rita.yml run --rm rita import /logs pcaps
	docker-compose -f docker-compose-rita.yml run --name pcaps rita html-report
	rm -rf pcaps
	docker cp "pcaps:/pcaps" reports/$(shell date +"%s")

create-capinfos:
	./bin/tshark.sh

rita.yaml:
	./bin/c2.sh

dir-output: 
	mkdir -p output

dir-pcap:
	mkdir -p pcap

dir-reports:
	mkdir -p reports

rita-open-report:
	open reports/$(shell ls -rt reports/ | tail -1)/pcaps/index.html 2> /dev/null || true
	xdg-open reports/$(shell ls -rt reports/ | tail -1)/pcaps/index.html 2> /dev/null || true

image-pull:
	docker pull reuteras/container-zeek || true
	docker pull reuteras/container-alpine-network:latest || true
	docker pull docker.elastic.co/elasticsearch/elasticsearch:7.17.0 || true
	docker pull docker.elastic.co/kibana/kibana:7.17.0 || true

image-rm:
	docker rmi reuteras/container-zeek || true
	docker rmi reuteras/container-alpine-network:latest || true

update-zeek2es:
	curl -o zeek2es.py -s https://raw.githubusercontent.com/corelight/zeek2es/master/zeek2es.py && chmod +x zeek2es.py

es-up:
	docker-compose -f docker-compose-elastic.yml up -d
	es-create-index

es-down:
	docker-compose -f docker-compose-elastic.yml down

es-create-index:
	./bin/create_index.sh

clean:
	rm -rf .env rita.yaml || true
	docker rm pcaps 2> /dev/null || true
	docker stop network-tools_db_1 2> /dev/null || true
	docker rm network-tools_db_1 2> /dev/null || true
	docker volume rm network-tools_db 2> /dev/null || true

dist-clean: image-rm clean
	rm -rf output reports
