# Container for zeek

This container is based on [zeek-docker](https://github.com/zeek/zeek-docker) from [Zeek](https://zeek.org/) with packages and some other tools included.

This is a work in progress!

## Resources

- [zeek](https://zeek.org/)
- [rita](https://github.com/activecm/rita) - Check for updates in [docker-compose.yml](https://github.com/activecm/rita/blob/master/docker-compose.yml)
- [zeek2es](https://github.com/corelight/zeek2es) under this [License](https://github.com/corelight/zeek2es/blob/master/LICENSE). Introduction video on [Youtube](https://www.youtube.com/watch?v=Ahe4jmdB2uQ)

## TODO

- How should [Sigma](https://github.com/SigmaHQ/sigma) rules be included?
- Look at [How to hunt with Zeek using Sigma rules for your SIEM](https://www.youtube.com/watch?v=B20u53S72zA)
- Compare import with [Filebeat](https://www.ericooi.com/zeekurity-zen-part-viii-how-to-send-zeek-logs-to-elastic/) to zeek2es.
- Sigma rules for Cobalt strike (but no pcap) can be found in [Cobalt Strike, a Defender’s Guide](https://thedfirreport.com/2021/08/29/cobalt-strike-a-defenders-guide/) and in [Cobalt Strike, a Defender’s Guide – Part 2](https://thedfirreport.com/2022/01/24/cobalt-strike-a-defenders-guide-part-2/) by The DFIR Report.

