#!/usr/bin/env python3 

import subprocess 
import os 
import sys
import argparse
import ipaddress

parser = argparse.ArgumentParser("Install Wireguard")
parser.add_argument("--ip", default="10.8.0.1")
parser.add_argument("-p", "--port", help="The port used for wireguard, default to 51820", type=int, default=51820)
args = parser.parse_args()

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def r(*args, **kwargs) -> subprocess.CompletedProcess:
    return subprocess.run(*args, **kwargs, shell=True)


if (os.getuid() != 0):
    eprint("Please run this script as root")
    exit(1)

r('apt-get update')
r('apt-get install -y wireguard')
p = r('wg genkey', capture_output=True)
private_key = p.stdout.decode('utf-8').strip()

with open('/etc/wireguard/private.key', 'w') as f:
    f.write(private_key + '\n')

r('chmod go= /etc/wireguard/private.key')
p = r('wg pubkey', input=private_key.encode('utf-8'), capture_output=True)
public_key = p.stdout.decode('utf-8').strip()

with open('/etc/wireguard/public.key', 'w') as f:
    f.write(public_key + '\n')

with open('/etc/sysctl.conf', 'r') as f:
    ip_forward = ('net.ipv4.ip_forward=1' not in f.read())

if ip_forward:
    with open('/etc/sysctl.conf', 'a') as f:
        f.write('net.ipv4.ip_forward=1\n')    

r('sysctl -p')
p = r('ip route list default', capture_output=True)
default_interface_l = p.stdout.decode('utf-8').split()
default_interface = default_interface_l[default_interface_l.index("dev") + 1].strip()
r('systemctl stop wg-quick@wg0.service')
r('systemctl disable wg-quick@wg0.service')

with open('/etc/wireguard/wg0.conf', 'w') as f:
    f.write(f"""[Interface]
PrivateKey = {private_key}
Address = {args.ip}/24
ListenPort = {args.port}
SaveConfig = true

PostUp = ufw route allow in on wg0 out on {default_interface}
PostUp = iptables -t nat -I POSTROUTING -o {default_interface} -j MASQUERADE
PostUp = ip6tables -t nat -I POSTROUTING -o {default_interface} -j MASQUERADE
PreDown = ufw route delete allow in on wg0 out on {default_interface}
PreDown = iptables -t nat -D POSTROUTING -o {default_interface} -j MASQUERADE
PreDown = ip6tables -t nat -D POSTROUTING -o {default_interface} -j MASQUERADE
""")

r(f'ufw allow {args.port}/udp')
r('ufw allow OpenSSH')
r('ufw disable')
r('yes | ufw enable')

r('systemctl enable wg-quick@wg0.service')
r('systemctl start wg-quick@wg0.service')

ip_network = ipaddress.ip_network((args.ip+"/24"))
print(ip_network.hosts()[1])

