# milouk/unbound-exporter

[![Docker Hub](https://img.shields.io/docker/v/milouk/unbound-exporter?sort=semver&label=Docker%20Hub)](https://hub.docker.com/r/milouk/unbound-exporter)
[![Docker Pulls](https://img.shields.io/docker/pulls/milouk/unbound-exporter)](https://hub.docker.com/r/milouk/unbound-exporter)
[![GitHub Actions](https://github.com/milouk/unbound_exporter/actions/workflows/docker-release.yml/badge.svg)](https://github.com/milouk/unbound_exporter/actions/workflows/docker-release.yml)

Fork of [letsencrypt/unbound_exporter](https://github.com/letsencrypt/unbound_exporter) with automated Docker image builds published to [Docker Hub](https://hub.docker.com/r/milouk/unbound-exporter) on every upstream release.

## Docker

```bash
docker run -d \
  --name unbound-exporter \
  -p 9167:9167 \
  -v /path/to/unbound_server.pem:/etc/unbound_server.pem \
  -v /path/to/unbound_control.pem:/etc/unbound_control.pem \
  -v /path/to/unbound_control.key:/etc/unbound_control.key \
  milouk/unbound-exporter:latest \
  -unbound.host tcp://unbound:8953 \
  -unbound.ca /etc/unbound_server.pem \
  -unbound.cert /etc/unbound_control.pem \
  -unbound.key /etc/unbound_control.key
```

### Docker Compose

```yaml
services:
  unbound-exporter:
    image: milouk/unbound-exporter:latest
    container_name: unbound-exporter
    read_only: true
    command: >
      -unbound.host tcp://unbound:8953
      -unbound.ca /etc/unbound_server.pem
      -unbound.cert /etc/unbound_control.pem
      -unbound.key /etc/unbound_control.key
    volumes:
      - /data/unbound/unbound_server.pem:/etc/unbound_server.pem
      - /data/unbound/unbound_control.pem:/etc/unbound_control.pem
      - /data/unbound/unbound_control.key:/etc/unbound_control.key
```

### Tags

| Tag | Description |
|-----|-------------|
| `latest` | Latest stable release |
| `0.6.0` | Specific upstream version |

Automated builds run daily — a new image is pushed whenever [letsencrypt/unbound_exporter](https://github.com/letsencrypt/unbound_exporter) publishes a new release.

- - - -

# Prometheus Unbound exporter

This repository provides code for a simple Prometheus metrics exporter
for [the Unbound DNS resolver](https://unbound.net/). This exporter
connects to Unbounds TLS control socket and sends the `stats_noreset`
command, causing Unbound to return metrics as key-value pairs. The
metrics exporter converts Unbound metric names to Prometheus metric
names and labels by using a set of regular expressions.

- - - -

# Prerequisites

Go 1.24 or above is required.

# Installation

    go install github.com/letsencrypt/unbound_exporter@latest

This will install the binary in `$GOBIN`, or `$HOME/go/bin` if
`$GOBIN` is unset.

# Updating dependencies

```
go get -u
go mod tidy
```

- - - -

# Usage - Unix socket

The simplest way to run unbound_exporter is on the same machine as your Unbound instance, connecting via a Unix socket. First, make sure you have this in your unbound.conf:

    remote-control:
      control-enable: yes
      control-interface: /run/unbound.ctl

Then, arrange to run this on the same machine:

    unbound_exporter -unbound.ca "" -unbound.cert "" -unbound.host "unix:///run/unbound.ctl"

Metrics will be exported under /metrics, on port 9167, on all interfaces.

    $ curl 127.0.0.1:9167/metrics | grep '^unbound_up'
    unbound_up 1

# Usage - TLS

The more complicated way to run unbound_exporter is to configure unbound's control-interface with a TLS certificate from a private CA, and run unbound_exporter on a separate host. This is more of a hassle because you have to keep the certificate up to date and distribute the private CA to the host that unbound_exporter runs on.

See https://unbound.docs.nlnetlabs.nl/en/latest/getting-started/configuration.html#set-up-remote-control for instructions on setting up the certificates and keys for remote-control via TLS. On the unbound_exporter side you will need to set the `-unbound.ca`, `-unbound.cert`, and `-unbound.key` flags to point to valid files that will trust the Unbound server's certificate and be trusted by Unbound in return.

# Extended statistics

From the Unbound [statistics doc](https://www.nlnetlabs.nl/documentation/unbound/howto-statistics/): Unbound has an option to enable extended statistics collection. If enabled, more statistics are collected, for example what types of queries are sent to the resolver. Otherwise, only the total number of queries is collected. Add the following to your `unbound.conf`.

    server:
	    extended-statistics: yes

