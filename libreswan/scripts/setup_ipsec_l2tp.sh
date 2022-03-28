#!/bin/sh

set -e

# Create IPsec config
cat > /etc/ipsec.conf <<EOF
version 2.0

config setup
  virtual-private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12,%v4:!${L2TP_NET},%v4:!${XAUTH_NET}
  uniqueids=no

conn shared
  left=%defaultroute
  leftid=${PUBLIC_IP}
  right=%any
  encapsulation=yes
  authby=secret
  pfs=no
  rekey=no
  keyingtries=5
  dpddelay=30
  dpdtimeout=120
  dpdaction=clear
  ikev2=never
  ike=aes256-sha2,aes128-sha2,aes256-sha1,aes128-sha1,aes256-sha2;modp1024,aes128-sha1;modp1024
  phase2alg=aes_gcm-null,aes128-sha1,aes256-sha1,aes256-sha2_512,aes128-sha2,aes256-sha2
  ikelifetime=24h
  salifetime=24h
  sha2-truncbug=no

conn l2tp-psk
  auto=add
  leftprotoport=17/1701
  rightprotoport=17/%any
  type=transport
  also=shared

conn xauth-psk
  auto=add
  leftsubnet=0.0.0.0/0
  rightaddresspool=${XAUTH_POOL}
  modecfgdns="${DNS_SRV1} ${DNS_SRV2}"
  leftxauthserver=yes
  rightxauthclient=yes
  leftmodecfgserver=yes
  rightmodecfgclient=yes
  modecfgpull=yes
  cisco-unity=yes
  also=shared

include /etc/ipsec.d/*.conf

EOF

# Specify IPsec PSK
cat > /etc/ipsec.secrets <<EOF
%any  %any  : PSK "$IPSEC_PSK"
EOF

# Create xl2tpd config
cat > /etc/xl2tpd/xl2tpd.conf <<EOF
[global]
port = 1701

[lns default]
ip range = ${L2TP_POOL}
local ip = ${L2TP_LOCAL}
require chap = yes
refuse pap = yes
require authentication = yes
name = l2tpd
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF

# Set xl2tpd options
cat > /etc/ppp/options.xl2tpd <<EOF
+mschap-v2
ipcp-accept-local
ipcp-accept-remote
noccp
auth
mtu 1280
mru 1280
proxyarp
nodefaultroute
lcp-echo-failure 4
lcp-echo-interval 30
connect-delay 5000
ms-dns ${DNS_SRV1}
ms-dns ${DNS_SRV2}
EOF

echo -n "" > /etc/ppp/chap-secrets
echo -n "" > /etc/ipsec.d/passwd

echo "Create VPN credentials..."
for vpn_user in $(echo $VPN_USERS | tr "," "\n" | tr -s " " "\n")
do
    USER_NAME=$(echo -n $vpn_user | awk -F ":" '{print $1}')
    USER_PASSWORD=$(echo -n $vpn_user | awk -F ":" '{print $2}')
    USER_PASSWORD_ENC=$(openssl passwd -1 "$USER_PASSWORD")
    USER_IP=$(echo -n $vpn_user | awk -F ":" '{print $3}')

    echo "Add VPN User: $USER_NAME"
    echo "\"$USER_NAME\" l2tpd \"$USER_PASSWORD\" $USER_IP" \
        >> /etc/ppp/chap-secrets

    echo "$USER_NAME:$USER_PASSWORD_ENC:xauth-psk" \
        >> /etc/ipsec.d/passwd
done


# Update file attributes
chmod 600 /etc/ipsec.secrets /etc/ppp/chap-secrets /etc/ipsec.d/passwd