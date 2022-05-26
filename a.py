import json 
with open('a.json') as f:
  data = json.load(f)

print(data['Reservations'][0]['Instances'][0]['PublicDnsName'])
print("hello world")