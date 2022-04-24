#!/usr/bin/env python3 

import subprocess 
import os 
import sys
import argparse
import pathlib

from sympy import public

parser = argparse.ArgumentParser("Add Wireguard Peer")
parser.add_argument("-t", "--interface", default="wg1")
parser.add_argument('--pk', required=True, help="The public key of the interface")
parser.add_argument('--ip', required=True, help="The ip address of peer")
parser.add_argument('--ep', required=True, help="The endpoint of the peer")
args = parser.parse_args()
print(args.public_key)

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def r(*args, **kwargs) -> subprocess.CompletedProcess:
    return subprocess.run(*args, **kwargs, shell=True)

if (os.getuid() != 0):
    eprint("Please run this script as root")
    exit(1)

if pathlib.Path('/etc/wireguard/private.key').is_file:
    with open('/etc/wireguard/private.key', 'r') as f:
        private_key = f.read().strip()
else:
    with open('/etc/wireguard/private.key', 'w') as f:
        p = r('wg genkey', capture_output=True)
        private_key = p.stdout.decode('utf-8').strip()
        f.write(private_key+'\n')

with open('/etc/wireguard/public.key', 'w') as f:
    p = r('wg pubkey', input=private_key.encode('utf-8'), capture_output=True)
    public_key = p.stdout.decode('utf-8').strip()

p = r('ip route list table main default', capture_output=True)
default_route = p.stdout.decode('utf-8').strip().split()
gateway_ip = default_route[default_route.index('dev')-1].strip()
gateway_device = default_route[default_route.index('dev')+1].strip()
p = r(f'ip -brief address show {gateway_device}', capture_ouput=True)
default_device_addresses = p.stdout.decode('utf-8').strip().split()
default_device_ip = default_device_addresses[2][:default_device_addresses[2].index('/')].strip()


with open(f'/etc/wireguard/{args.interface}.conf', 'w') as f:
    f.write(f"""[Interface]
PrivateKey = {private_key}
Address = {args.ip}/24
DNS = 8.8.8.8

PostUp = ip rule add table 200 from {default_device_ip}
PostUp = ip route add table 200 default via {gateway_ip}
PreDown = ip rule delete table 200 from {default_device_ip}
PreDown = ip route delete table 200 default via {gateway_ip}

[Peer]
PublicKey = {args.pk}
AllowedIPs = 0.0.0.0/0
Endpoint = {args.ep}
""")
