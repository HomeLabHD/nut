# Network UPS Tools

A rootless container image of [Network UPS Tools](https://networkupstools.org/): USB, serial, SNMP and NetXML drivers, `upsd`, and optional `upsmon`, built from this tree.

> The purpose of this fork is to close an issue; `shutdown.return` on `eaton_pw_nm2` / `eaton_pxg_ups`
> (Eaton Network-M2 / PXG cards) writes `xupsLoadShedSecsWithRestart` without its `.0` instance, so the
> card answers `noSuchName` and the UPS never cuts and restores its output
> ([nut#1571](https://github.com/networkupstools/nut/issues/1571)). Without that command a host shut
> down on battery stays off if utility returns before the UPS powers down. The fork tracks upstream
> and is rebased onto each release; apart from this fix it is identical to the upstream version it is
> built from, so a given fork tag is equivalent to the same upstream version.

<!-- sf:project:start -->
[![GitHub](https://img.shields.io/badge/GitHub-mirror-181717?logo=github)](https://github.com/HomeLabHD/nut) [![GitLab](https://img.shields.io/badge/GitLab-source-FC6D26?logo=gitlab)](https://gitlab.prplanit.com/HomeLabHD/nut) [![license](https://raw.githubusercontent.com/HomeLabHD/nut/main/.stagefreight/scribe/license.svg)](https://github.com/HomeLabHD/nut/blob/main/LICENSE) [![Open Issues](https://img.shields.io/github/issues/HomeLabHD/nut)](https://github.com/HomeLabHD/nut/issues) [![Open PRs](https://img.shields.io/github/issues-pr/HomeLabHD/nut)](https://github.com/HomeLabHD/nut/pulls) [![Contributors](https://img.shields.io/github/contributors/HomeLabHD/nut)](https://github.com/HomeLabHD/nut/graphs/contributors) [![donate](https://img.shields.io/badge/donate-FF5E5B?logo=ko-fi&logoColor=white)](https://ko-fi.com/T6T41IT163) [![sponsor](https://img.shields.io/badge/sponsor-EA4AAA?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/HomeLabHD)
<!-- sf:project:end -->
<!-- sf:badges:start -->
[![release](https://raw.githubusercontent.com/HomeLabHD/nut/main/.stagefreight/scribe/release.svg)](https://github.com/HomeLabHD/nut/releases) [![build](https://raw.githubusercontent.com/HomeLabHD/nut/main/.stagefreight/scribe/build.svg)](https://gitlab.prplanit.com/HomeLabHD/nut/-/pipelines) [![Last Commit](https://img.shields.io/github/last-commit/HomeLabHD/nut)](https://github.com/HomeLabHD/nut/commits) [![StageFreight](https://img.shields.io/badge/StageFreight-0.14.0--dev+30807d4-310937?logo=readthedocs&logoColor=white)](https://stagefreight.prplanit.com)
<!-- sf:badges:end -->
<!-- sf:image:start -->
[![GHCR](https://img.shields.io/badge/GHCR-homelabhd%2Fnut-181717?logo=github&logoColor=white)](https://github.com/HomeLabHD/nut/pkgs/container/nut) [![Docker](https://img.shields.io/badge/Docker-hlhd%2Fnut-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/r/hlhd/nut) [![pulls](https://img.shields.io/docker/pulls/hlhd/nut?color=1d63ed&logo=docker&logoColor=white)](https://hub.docker.com/r/hlhd/nut) [![Harbor](https://img.shields.io/badge/Harbor-hlhd%2Fnut-60b932)](https://cr.pcfae.com/harbor/projects)

[![latest](https://raw.githubusercontent.com/HomeLabHD/nut/main/.stagefreight/scribe/release-latest.svg)](https://github.com/HomeLabHD/nut/pkgs/container/nut) ![updated](https://raw.githubusercontent.com/HomeLabHD/nut/main/.stagefreight/scribe/release-updated.svg) [![size](https://raw.githubusercontent.com/HomeLabHD/nut/main/.stagefreight/scribe/release-size.svg)](https://github.com/HomeLabHD/nut/pkgs/container/nut) [![latest-dev](https://raw.githubusercontent.com/HomeLabHD/nut/main/.stagefreight/scribe/dev-latest.svg)](https://github.com/HomeLabHD/nut/pkgs/container/nut) ![updated](https://raw.githubusercontent.com/HomeLabHD/nut/main/.stagefreight/scribe/dev-updated.svg) [![size](https://raw.githubusercontent.com/HomeLabHD/nut/main/.stagefreight/scribe/dev-size.svg)](https://github.com/HomeLabHD/nut/pkgs/container/nut)
<!-- sf:image:end -->

### What it runs:

|                    |                                                                                              |
| ------------------ | -------------------------------------------------------------------------------------------- |
| **Drivers + upsd** | `upsdrvctl -F start` and `upsd -F` in the foreground; any process exiting ends the container |
| **upsmon, opt-in** | Runs only when `/etc/nut/upsmon.conf` is mounted; without it the container shuts nothing down |
| **Drivers**        | USB (`usbhid-ups`, `blazer_usb`, `nutdrv_qx`, …), serial, SNMP, NetXML; TLS via OpenSSL     |
| **Rootless**       | uid/gid 65532, no setuid binaries, no package manager; runs with a read-only root filesystem and no capabilities |

`nut-scanner` is not built.

### Fork fixes:

| Fix | Upstream |
| --- | -------- |
| `shutdown.return` on `eaton_pw_nm2` / `eaton_pxg_ups` targets `xupsLoadShedSecsWithRestart.0` | [nut#1571](https://github.com/networkupstools/nut/issues/1571) |

## Quick Start

```bash
docker run -d --read-only \
  --cap-drop ALL --security-opt no-new-privileges \
  --tmpfs /run/nut:uid=65532,gid=65532,mode=0750 \
  -v ./nut:/etc/nut:ro \
  -p 3493:3493 \
  hlhd/nut
```

USB: pass the device and a group that can open it, e.g.
`--device /dev/bus/usb/001/004 --group-add $(stat -c %g /dev/bus/usb/001/004)`.

### Configuration

| Path                   |                                          |
| ---------------------- | ---------------------------------------- |
| `/etc/nut/ups.conf`    | Driver and device                        |
| `/etc/nut/upsd.conf`   | `LISTEN 0.0.0.0 3493`                    |
| `/etc/nut/upsd.users`  | Client accounts and their `instcmds`     |
| `/etc/nut/upsmon.conf` | Optional; enables `upsmon`               |
| `/run/nut`             | Writable, owned by 65532 (state sockets) |

### Build

From the repository root:

```bash
docker build -t hlhd/nut .
```

---

## Image Contents

<!-- sf:contents-base:start -->
[![alpine 3.24.2](https://img.shields.io/badge/alpine-3.24.2-0078D4?style=flat)](https://hub.docker.com/_/alpine)
<!-- sf:contents-base:end -->

<!-- sf:contents-apk:start -->
[![autoconf](https://img.shields.io/badge/autoconf-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=autoconf) [![automake](https://img.shields.io/badge/automake-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=automake) [![g++](https://img.shields.io/badge/g++-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=g%2B%2B) [![gcc](https://img.shields.io/badge/gcc-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=gcc) [![git](https://img.shields.io/badge/git-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=git) [![libcrypto3](https://img.shields.io/badge/libcrypto3-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=libcrypto3) [![libssl3](https://img.shields.io/badge/libssl3-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=libssl3) [![libtool](https://img.shields.io/badge/libtool-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=libtool) [![libusb](https://img.shields.io/badge/libusb-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=libusb) [![libusb-dev](https://img.shields.io/badge/libusb--dev-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=libusb-dev) [![make](https://img.shields.io/badge/make-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=make) [![musl-dev](https://img.shields.io/badge/musl--dev-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=musl-dev) [![neon](https://img.shields.io/badge/neon-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=neon) [![neon-dev](https://img.shields.io/badge/neon--dev-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=neon-dev) [![net-snmp-dev](https://img.shields.io/badge/net--snmp--dev-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=net-snmp-dev) [![net-snmp-libs](https://img.shields.io/badge/net--snmp--libs-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=net-snmp-libs) [![openssl-dev](https://img.shields.io/badge/openssl--dev-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=openssl-dev) [![perl](https://img.shields.io/badge/perl-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=perl) [![pkgconf](https://img.shields.io/badge/pkgconf-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=pkgconf)
<!-- sf:contents-apk:end -->

## Upstream Documentation

NUT's own documentation is [README.adoc](README.adoc), [INSTALL.nut.adoc](INSTALL.nut.adoc) and [networkupstools.org](https://networkupstools.org/documentation.html).
