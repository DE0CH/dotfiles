#!/usr/bin/env python3
import os
import sys
if sys.version_info.major < 3:
  os.execvp("python3", ["python3"] + sys.argv)
os.chdir(os.path.dirname(__file__))

import subprocess
import json

with open('launched-ec2.json') as f:
  launched_ec2 = json.load(f)

if launched_ec2:
  subprocess.run(['aws', 'ec2', 'terminate-instances', '--instance-ids', *launched_ec2], capture_output=True).check_returncode()

with open('launched-ec2.json', 'w') as f:
  json.dump([], f)