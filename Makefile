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

image-rm:
	docker rmi reuteras/container-zeek || true
	docker rmi reuteras/container-alpine-network:latest || true

clean:
	docker rm pcaps 2> /dev/null || true
	docker stop network-tools_db_1 2> /dev/null || true
	docker rm network-tools_db_1 2> /dev/null || true
	docker volume rm network-tools_db 2> /dev/null || true

dist-clean: image-rm clean
	rm -rf output reports
