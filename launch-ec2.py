#!/usr/bin/env python3
import subprocess
import json
import os 
import argparse
import shlex

parser = argparse.ArgumentParser("")
parser.add_argument('arch', choices=["64", "arm"], default="64")
parser.add_argument('region', choices=["london", "hk"])
args = parser.parse_args()

os.chdir(os.path.dirname(__file__))

with open('launched-ec2.json') as f:
  launched_ec2 = json.load(f)

previous_ec2 = bool(launched_ec2)

if launched_ec2:
  instance_id = launched_ec2[0]
else:
  if args.arch == "64":
    if args.region == "hk":
      image_id = "ami-01efa0814106ea343"
      instance_type = "c5.4xlarge"
    elif args.region == "london":
      raise NotImplementedError()
  else:
    if args.region == "hk":
      image_id = "ami-01ed943edc33bc944"
      instance_type = "c6g.4xlarge"
    elif args.region == "london":
      image_id = "ami-0ba4932cffdd282f7"
      instance_type = "c6g.4xlarge"
  if args.region == "hk":
    security_group_id = "sg-44c9992f"
    subnet_id = "subnet-983cd1f1"
  elif args.region == "london": 
    security_group_id = "sg-d2b73eb7"
    subnet_id = "subnet-90b3e4f9"
  storage = 64
  volumes = [{
    "DeviceName": "/dev/xvda",
    "Ebs": {
      "VolumeSize": storage,
    },
  }]
  print(image_id, instance_type, security_group_id,subnet_id)
  print(' '.join(map(shlex.quote, ['aws', 'ec2', 'run-instances', '--image-id', image_id, '--instance-type', instance_type, '--key-name', 'default-ssh', '--security-group-ids', security_group_id, '--subnet-id', subnet_id, "--block-device-mappings", json.dumps(volumes)])))
  launch_output = subprocess.check_output(['aws', 'ec2', 'run-instances', '--image-id', image_id, '--instance-type', instance_type, '--key-name', 'default-ssh', '--security-group-ids', security_group_id, '--subnet-id', subnet_id, "--block-device-mappings", json.dumps(volumes)])
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
      pass
  with open(os.path.expanduser('~/.ssh/known_hosts'), 'a') as f:
    f.write(ssh_fingerprint.decode('utf-8'))
if not previous_ec2:
  subprocess.run(['ssh', '-v', f'admin@{public_dns}', 'sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/DE0CH/dotfiles/master/setup-aws.sh)"'])

print(f"deyaochen@{public_dns}")
