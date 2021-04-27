all: run report

interactive: run-zeek

run-zeek:
	docker run -it --rm -v "$$PWD"/pcap:/pcap:ro -v "$$PWD"/output:/output -w /output container-zeek /bin/bash

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
	open reports/$(shell ls -rt reports/ | tail -1)/pcaps/index.html

reports:
	mkdir -p reports

build: build-zeek build-tools

build-zeek:
	docker build --tag=container-zeek zeek

no-cache-build-zeek:
	docker build --tag=container-zeek --no-cache zeek

build-tools:
	docker build --tag=container-network-tools tools

no-cache-build-tools:
	docker build --tag=container-network-tools --no-cache tools

image-rm:
	docker rmi container-zeek || true
	docker rmi container-network-tools || true

clean:
	docker rm pcaps || true
	docker stop container-zeek_db_1 || true
	docker rm container-zeek_db_1 || true
	docker volume rm container-zeek_db || true

dist-clean: image-rm clean
	rm -rf output reports
