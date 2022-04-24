#!/usr/bin/env python3 

import subprocess 
import os 
import sys
import argparse
import pathlib

parser = argparse.ArgumentParser("Add Wireguard Peer")
parser.add_argument("-t", "--interface", default="wg1")
parser.add_argument('--pk', required=True, help="The public key of the interface")
parser.add_argument('--ip', required=True, help="The ip address of peer")
parser.add_argument('--ep', required=True, help="The endpoint of the peer")
parser.add_argument('-c', help="Write the config file to an output file")
args = parser.parse_args()

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def r(*args, **kwargs) -> subprocess.CompletedProcess:
    return subprocess.run(*args, **kwargs, shell=True)

if (not args.c and os.getuid() != 0):
    eprint("Please run this script as root")
    exit(1)

p = r('wg genkey', capture_output=True)
private_key = p.stdout.decode('utf-8').strip()
p = r('wg pubkey', input=private_key.encode('utf-8'), capture_output=True)
public_key = p.stdout.decode('utf-8').strip()

if not args.c:
    if pathlib.Path('/etc/wireguard/private.key').is_file():
        with open('/etc/wireguard/private.key', 'r') as f:
            private_key = f.read().strip()
    else:
        with open('/etc/wireguard/private.key', 'w') as f:
            f.write(private_key+'\n')

    with open('/etc/wireguard/public.key', 'w') as f:
        f.write(public_key+'\n')


config_s = f"""[Interface]
PrivateKey = {private_key}
Address = {args.ip}/24
DNS = 8.8.8.8
"""

if not args.c:
    p = r('ip route list table main default', capture_output=True)
    default_route = p.stdout.decode('utf-8').strip().split()
    gateway_ip = default_route[default_route.index('dev')-1].strip()
    gateway_device = default_route[default_route.index('dev')+1].strip()
    p = r(f'ip -brief address show {gateway_device}', capture_output=True)
    default_device_addresses = p.stdout.decode('utf-8').strip().split()
    default_device_ip = default_device_addresses[2][:default_device_addresses[2].index('/')].strip()
    config_s += f"""
PostUp = ip rule add table 200 from {default_device_ip}
PostUp = ip route add table 200 default via {gateway_ip}
PreDown = ip rule delete table 200 from {default_device_ip}
PreDown = ip route delete table 200 default via {gateway_ip}
"""

config_s += f"""
[Peer]
PublicKey = {args.pk}
AllowedIPs = 0.0.0.0/0
Endpoint = {args.ep}
"""

if not args.c:
    with open(f'/etc/wireguard/{args.interface}.conf', 'w') as f:
        f.write(config_s)
else:
    with open(args.c, 'w') as f:
        f.write(config_s)

if not args.c:
    r(f'systemctl disable wg-quick@{args.interface}')
    r(f'systemctl stop wg-quick@{args.interface}')
    r(f'systemctl enable wg-quick@{args.interface}')
    r(f'systemctl start wg-quick@{args.interface}')


print("Done, please add peer to server")
print(f"sudo wg set wg0 peer {public_key} allowed-ips {args.ip}")