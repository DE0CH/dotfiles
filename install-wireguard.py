#!/usr/bin/env python3 

import subprocess 
import os 
import sys
import argparse

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
r('wg genkey')
with open('/etc/wireguard/private.key') as f:
    private_key = f.read().strip()

r('chmod go= /etc/wireguard/private.key')
r('wg genkey', input=private_key.encode('utf-8'))

with open('/etc/wireguard/public.key') as f:
    public_key = f.read().stript()

with open('/etc/sysctl.conf', 'a') as f:
    f.write('net.ipv4.ip_forward=1\n')

r('sysctl -p')
p = r('ip route list default')
default_interface_l = p.stdout.decode('utf-8').split()
default_interface = default_interface_l[default_interface_l.index("dev") + 1].strip()

with open('/etc/wireguard/wg0.conf') as f:
    f.write(f"""[Interface]
PrivateKey = {private_key}
Address = {args.ip}
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
r('ufw enable')
r('systemctl enable wg-quick@wg0.service')
r('systemctl start wg-quick@wg0.service')

print("Done, your public key is")
print(public_key)