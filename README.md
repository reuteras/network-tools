# Network tools 

Scripts and configuration to use zeek with [Rita](https://github.com/activecm/rita) and [zeek2es](https://github.com/corelight/zeek2es). 

## Usage

Copy the pcaps to the *pcap* subdirectory. Then run 

    make zeek-output

To generate zeek logs and Rita report. To view the report run

    make rita-open-report

Import to Elastic with (view http://127.0.0.1:5601) with zeek2es:

    make zeek-zeek2es-import

or via Elastic Filebeat:

    make zeek-json-import

## Links

- [zeek](https://zeek.org/)
- [rita](https://github.com/activecm/rita) - Check for updates in [docker-compose.yml](https://github.com/activecm/rita/blob/master/docker-compose.yml)
- [zeek2es](https://github.com/corelight/zeek2es) under this [License](https://github.com/corelight/zeek2es/blob/master/LICENSE). Introduction video on [Youtube](https://www.youtube.com/watch?v=Ahe4jmdB2uQ)

## TODO

- How should [Sigma](https://github.com/SigmaHQ/sigma) rules be included?
- Look at [How to hunt with Zeek using Sigma rules for your SIEM](https://www.youtube.com/watch?v=B20u53S72zA)
- Sigma rules for Cobalt strike (but no pcap) can be found in [Cobalt Strike, a Defender’s Guide](https://thedfirreport.com/2021/08/29/cobalt-strike-a-defenders-guide/) and in [Cobalt Strike, a Defender’s Guide – Part 2](https://thedfirreport.com/2022/01/24/cobalt-strike-a-defenders-guide-part-2/) by The DFIR Report.
- Configure local networks for Zeek and other configuration changes
- Look at [docker-zeek](https://github.com/blacktop/docker-zeek)

