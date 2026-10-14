# Drivers and upsd always; upsmon only when the deployment supplies upsmon.conf.
FROM alpine:3.24.2 AS build

RUN apk add --no-cache \
        autoconf automake libtool make gcc g++ musl-dev pkgconf git perl \
        libusb-dev net-snmp-dev neon-dev openssl-dev

WORKDIR /src
COPY . .

# Augeas lens generation is the only python step in autogen; the lens is unused here.
# nut-scanner needs python to generate its SNMP table, so it is not built.
RUN set -eux; \
    WITHOUT_NUT_AUGEAS=true ./autogen.sh; \
    ./configure \
        --prefix=/usr \
        --sysconfdir=/etc/nut \
        --datadir=/usr/share/nut \
        --with-drvpath=/usr/lib/nut \
        --with-statepath=/run/nut \
        --with-altpidpath=/run/nut \
        --with-user=nut \
        --with-group=nut \
        --with-all=no \
        --with-usb \
        --with-serial \
        --with-snmp \
        --with-neon \
        --with-openssl \
        --with-nut-scanner=no \
        --with-dev=no \
        --with-doc=no \
        --disable-static \
        --enable-strip; \
    make -j"$(nproc)"; \
    make install DESTDIR=/out; \
    find /out/usr/share -mindepth 1 -maxdepth 1 ! -name nut -exec rm -rf {} +; \
    rm -rf /out/usr/include /out/usr/lib/pkgconfig /out/etc/nut/*.sample

FROM alpine:3.24.2

ARG VERSION
ARG COMMIT

LABEL org.opencontainers.image.title="nut" \
      org.opencontainers.image.description="Network UPS Tools drivers, upsd and optional upsmon, rootless" \
      org.opencontainers.image.source="https://gitlab.prplanit.com/HomeLabHD/nut" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${COMMIT}" \
      org.opencontainers.image.licenses="GPL-2.0-or-later"

COPY --from=build /out/ /
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN set -eux; \
    apk upgrade --no-cache; \
    apk add --no-cache libusb net-snmp-libs neon libssl3 libcrypto3; \
    addgroup -S -g 65532 nut; \
    adduser -S -D -H -u 65532 -G nut -h /run/nut nut; \
    install -d -m 0750 -o nut -g nut /run/nut; \
    # Nothing installs packages at runtime. /lib/apk/db stays for SBOM and CVE scanning.
    apk --no-cache --purge del apk-tools; \
    rm -rf /var/cache/apk /etc/apk; \
    find / -xdev -perm /6000 -type f -exec chmod a-s {} + 2>/dev/null || true

USER 65532:65532
EXPOSE 3493/tcp
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
