#!/usr/bin/env python
import os
import sys
if sys.version_info.major < 3:
  os.execvp("python3", ["python3"] + sys.argv)

import argparse
import json
import subprocess 

parser = argparse.ArgumentParser("rsync to ec2")
parser.add_argument("path", help="The path of the file or folder to rsync")
args = parser.parse_args()

with open(os.path.join(os.path.dirname(__file__), 'launched-ec2.json')) as f:
  launched_ec2 = json.load(f)
if not launched_ec2:
  raise ValueError("EC2 not launched")
instance_id = launched_ec2[0]
instance_output = subprocess.check_output(['aws', 'ec2', 'describe-instances', '--instance-ids', instance_id])
instance_output = json.loads(instance_output)
public_dns = instance_output['Reservations'][0]['Instances'][0]['PublicDnsName']

os.execvp('rsync', ['rsync', '-azP', f'deyaochen@{public_dns}:/home/deyaochen/{args.path}', os.path.join(os.getcwd(), args.path)])

