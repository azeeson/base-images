FROM alpine:3.14

LABEL maintainer="Azeeson <azeeson@gmail.com>"

ARG SWAN_VER=4.4

ENV \
    LANG=C.UTF-8 \
    # ...
    L2TP_LOCAL=192.168.42.1 \
    L2TP_NET=192.168.42.0/24 \
    L2TP_POOL=192.168.42.10-192.168.42.250 \
    # ...
    XAUTH_NET=192.168.43.0/24 \
    XAUTH_POOL=192.168.43.10-192.168.43.250 \
    # ...
    DNS_SRV1=8.8.8.8 \
    DNS_SRV2=8.8.4.4

RUN set -x \
    && mkdir -p /opt/src && cd /opt/src \
    && export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    && apk add --no-cache \
         bash bind-tools coreutils openssl uuidgen wget xl2tpd iproute2 \
         libcap-ng libcurl libevent linux-pam musl nspr nss nss-tools \
         bison flex gcc make libc-dev bsd-compat-headers linux-pam-dev \
         nss-dev libcap-ng-dev libevent-dev curl-dev nspr-dev dnsmasq \
    && wget -t 3 -T 30 -nv -O libreswan.tar.gz "https://github.com/libreswan/libreswan/archive/v${SWAN_VER}.tar.gz" \
    || wget -t 3 -T 30 -nv -O libreswan.tar.gz "https://download.libreswan.org/libreswan-${SWAN_VER}.tar.gz" \
    && tar xzf libreswan.tar.gz \
    && rm -f libreswan.tar.gz \
    && cd "libreswan-${SWAN_VER}" \
    && sed -i '28s/stdlib\.h/sys\/types.h/' include/fd.h \
    && printf 'WERROR_CFLAGS=-w -s\nUSE_DNSSEC=false\nUSE_DH2=true\n' > Makefile.inc.local \
    && printf 'FINALNSSDIR=/etc/ipsec.d\nUSE_GLIBC_KERN_FLIP_HEADERS=true\n' >> Makefile.inc.local \
    && make -s base \
    && make -s install-base \
    && cd /opt/src \
    && rm -rf "/opt/src/libreswan-${SWAN_VER}" \
    && apk del --no-cache \
         bison flex gcc make libc-dev bsd-compat-headers linux-pam-dev \
         nss-dev libcap-ng-dev libevent-dev curl-dev nspr-dev \
    && rm -rf /var/cache/apk/*

COPY ./scripts/setup_vpn.sh /usr/bin/setup_vpn.sh
COPY ./scripts/setup_ipsec_l2tp.sh /usr/bin/setup_ipsec_l2tp.sh
COPY ./scripts/setup_iptables.sh /usr/bin/setup_iptables.sh
COPY ./scripts/setup_dnsmasq.sh /usr/bin/setup_dnsmasq.sh

COPY ./scripts/entrypoint.sh /entrypoint.sh

RUN chmod +x /usr/bin/setup_dnsmasq.sh /usr/bin/setup_ipsec_l2tp.sh \
    /usr/bin/setup_iptables.sh /usr/bin/setup_vpn.sh /entrypoint.sh

EXPOSE 67/udp 68/udp 500/udp 4500/udp

ENTRYPOINT [ "/entrypoint.sh" ]