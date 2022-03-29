#!/bin/sh

ip link delete dummy0 >/dev/null 2>&1

echo $(date +'%Y-%m-%d %H:%M')

setup_ipsec_l2tp.sh
sleep 10
setup_iptables.sh
sleep 10
setup_dnsmasq.sh
sleep 10

echo "Starting IPsec service..."
mkdir -p /run/pluto /var/run/pluto
rm -f /run/pluto/pluto.pid /var/run/pluto/pluto.pid

ipsec initnss >/dev/null
ipsec pluto --config /etc/ipsec.conf

# Start dnsmasq
echo "Starting Dnsmasq service..."
dnsmasq

# Start xl2tpd
echo "Starting xl2tpd..."
mkdir -p /var/run/xl2tpd
rm -f /var/run/xl2tpd.pid
exec /usr/sbin/xl2tpd -D -c /etc/xl2tpd/xl2tpd.conf