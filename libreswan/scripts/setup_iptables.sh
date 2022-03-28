#!/bin/sh

set -e

NET_IFACE=$(route 2>/dev/null | grep -m 1 '^default' | grep -o '[^ ]*$')
[ -z "$NET_IFACE" ] && NET_IFACE=$(ip -4 route list 0/0 2>/dev/null | grep -m 1 -Po '(?<=dev )(\S+)')
[ -z "$NET_IFACE" ] && NET_IFACE=eth0

# Update sysctl settings
syt='/sbin/sysctl -e -q -w'
$syt kernel.msgmnb=65536 2>/dev/null
$syt kernel.msgmax=65536 2>/dev/null
$syt net.ipv4.ip_forward=1 2>/dev/null
$syt net.ipv4.conf.all.accept_redirects=0 2>/dev/null
$syt net.ipv4.conf.all.send_redirects=0 2>/dev/null
$syt net.ipv4.conf.all.rp_filter=0 2>/dev/null
$syt net.ipv4.conf.default.accept_redirects=0 2>/dev/null
$syt net.ipv4.conf.default.send_redirects=0 2>/dev/null
$syt net.ipv4.conf.default.rp_filter=0 2>/dev/null
$syt "net.ipv4.conf.$NET_IFACE.send_redirects=0" 2>/dev/null
$syt "net.ipv4.conf.$NET_IFACE.rp_filter=0" 2>/dev/null

# Create IPTables rules
ipi='iptables -I INPUT'
ipf='iptables -I FORWARD'
ipp='iptables -t nat -I POSTROUTING'
res='RELATED,ESTABLISHED'

if ! iptables -t nat -C POSTROUTING -s "$L2TP_NET" -o "$NET_IFACE" -j MASQUERADE 2>/dev/null; then
  $ipi 1 -p udp --dport 1701 -m policy --dir in --pol none -j DROP
  $ipi 2 -m conntrack --ctstate INVALID -j DROP
  $ipi 3 -m conntrack --ctstate "$res" -j ACCEPT
  $ipi 4 -p udp -m multiport --dports 500,4500 -j ACCEPT
  $ipi 5 -p udp --dport 1701 -m policy --dir in --pol ipsec -j ACCEPT
  $ipi 6 -p udp --dport 1701 -j DROP

  $ipf 1 -m conntrack --ctstate INVALID -j DROP
  $ipf 2 -i "$NET_IFACE" -o ppp+ -m conntrack --ctstate "$res" -j ACCEPT
  $ipf 3 -i ppp+ -o "$NET_IFACE" -j ACCEPT
  $ipf 4 -i ppp+ -o ppp+ -j ACCEPT
  $ipf 5 -i "$NET_IFACE" -d "$XAUTH_NET" -m conntrack --ctstate "$res" -j ACCEPT
  $ipf 6 -s "$XAUTH_NET" -o "$NET_IFACE" -j ACCEPT
  $ipf 7 -s "$XAUTH_NET" -o ppp+ -j ACCEPT

  # Client-to-client traffic is allowed by default. To *disallow* such traffic,
  # uncomment below and restart the Docker container.
#   $ipf 2 -i ppp+ -o ppp+ -s "$L2TP_NET" -d "$L2TP_NET" -j DROP
#   $ipf 3 -s "$XAUTH_NET" -d "$XAUTH_NET" -j DROP
#   $ipf 4 -i ppp+ -d "$XAUTH_NET" -j DROP
#   $ipf 5 -s "$XAUTH_NET" -o ppp+ -j DROP

  iptables -A FORWARD -j DROP
  $ipp -s "$XAUTH_NET" -o "$NET_IFACE" -m policy --dir out --pol none -j MASQUERADE
  $ipp -s "$L2TP_NET" -o "$NET_IFACE" -j MASQUERADE
fi