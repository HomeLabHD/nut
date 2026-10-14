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
<!-- sf:project:end -->
<!-- sf:badges:start -->
<!-- sf:badges:end -->
<!-- sf:image:start -->
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
  hlhd/nut:latest
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
docker build -t nut .
```

---

## Image Contents

<!-- sf:contents-base:start -->
<!-- sf:contents-base:end -->

<!-- sf:contents-apk:start -->
<!-- sf:contents-apk:end -->

## Upstream Documentation

NUT's own documentation is [README.adoc](README.adoc), [INSTALL.nut.adoc](INSTALL.nut.adoc) and [networkupstools.org](https://networkupstools.org/documentation.html).
