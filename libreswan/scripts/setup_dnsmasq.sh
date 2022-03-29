#!/bin/sh

set -e

echo "Start: Configuration Dnsmasq"

# Configuration Dnsmasq
dhcp_routes=""
for route in $(echo $VPN_ROUTES | tr "," "\n" | tr -s " " "\n")
do
    dhcp_routes="$route,$L2TP_LOCAL,$dhcp_routes"
done
dhcp_routes=$(echo "$dhcp_routes" | sed 's/,$//')
dhcp_range=$(echo $L2TP_POOL | sed 's/-/,/')

NEWLINE=$'\n'
dhcp_address=""
for host in $(echo $VPN_HOSTS | tr "," "\n" | tr -s " " "\n")
do
    HOST_IP=$(echo -n $host | awk -F "/" '{print $1}')
    HOST_NAME=$(echo -n $host | awk -F "/" '{print $2}')
    dhcp_address="address=/$HOST_NAME/$HOST_IP$NEWLINE$dhcp_address"
done



cat > /etc/dnsmasq.conf <<EOF
# Указываем интерфейсы для прослушивания.
listen-address=127.0.0.1,${L2TP_LOCAL}

server=8.8.8.8
server=8.8.4.4

# Запрещаем чтение файла /etc/resolv.conf для получения DNS-серверов.
no-resolv

# Запрещаем добавление хостов из файла /etc/hosts.
no-hosts

dhcp-range=$dhcp_range
dhcp-option=121,$dhcp_routes
dhcp-option=249,$dhcp_routes

# Экспортируем дополнительные хосты при необходимости.
$dhcp_address
EOF

echo "Finish: Configuration Dnsmasq"