#!/usr/bin/env python
import os
import sys
if sys.version_info.major < 3:
  os.execvp("python3", ["python3"] + sys.argv)
os.chdir(os.path.dirname(__file__))

import subprocess
import json

with open('launched-ec2.json') as f:
  launched_ec2 = json.load(f)

previous_ec2 = bool(launched_ec2)

if launched_ec2:
  instance_id = launched_ec2[0]
else:
  image_id = "ami-0350928fdb53ae439"
  instance_type = "c5.large"
  security_group_id = "sg-44c9992f"
  subnet_id = "subnet-983cd1f1"
  launch_output = subprocess.check_output(['aws', 'ec2', 'run-instances', '--image-id', image_id, '--instance-type', instance_type, '--key-name', 'AWS1', '--security-group-ids', security_group_id, '--subnet-id', subnet_id])
  launch_output = json.loads(launch_output)
  instance_id = launch_output["Instances"][0]["InstanceId"]
  launched_ec2.append(instance_id)

with open('launched-ec2.json', 'w') as f:
  json.dump(launched_ec2, f)

instance_output = subprocess.check_output(['aws', 'ec2', 'describe-instances', '--instance-ids', instance_id])
instance_output = json.loads(instance_output)
public_dns = instance_output['Reservations'][0]['Instances'][0]['PublicDnsName']
p = subprocess.run(['ssh-keygen', '-F', public_dns])
if p.returncode:
  while True:
    try:
      ssh_fingerprint = subprocess.check_output(['ssh-keyscan', '-H', public_dns])
      break
    except subprocess.CalledProcessError:
      print("EC2 not up, retying...")
  with open(os.path.expanduser('~/.ssh/known_hosts'), 'a') as f:
    f.write(ssh_fingerprint.decode('utf-8'))
if not previous_ec2:
  with open('setup-aws.sh') as f:
    subprocess.run(['ssh', '-v', '-i', '~/AWS1.pem', f'ubuntu@{public_dns}', 'sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/DE0CH/dotfiles/master/setup-aws.sh)"'])

os.execvp('ssh', ['ssh', f'deyaochen@{public_dns}'])