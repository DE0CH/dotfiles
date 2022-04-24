#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root" >&2
  exit
fi

apt-get update
apt-get install wireguard
PRIVATE_KEY=$(wg genkey | tee /etc/wireguard/private.key)
chmod go= /etc/wireguard/private.key
cat /etc/wireguard/private.key | wg pubkey | tee /etc/wireguard/public.key

echo <<EOT >> /etc/wireguard/wg0.conf
[Interface]
PrivateKey = ${PRIVIATE_KEY}
Address = 10.8.0.1/24
ListenPort = 51820
SaveConfig = true
EOT

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p


