import os
import requests
import json
import tldextract
from dotenv import load_dotenv

# Load environment variables from .env
load_dotenv()

# Find domain ID by name
def find_by_name(records, subdomain):
    for record in records:
        if record['type'] == 'TXT' and record.get('host', None) == subdomain:
            return record['id']
    return None

# Load API credentials and Certbot variables
user = os.environ['USERNAME']
token = os.environ['TOKEN']
domain = os.environ['CERTBOT_DOMAIN']  # Domain provided by Certbot
extracted = tldextract.extract(domain)

subdomain = extracted.subdomain  # This will be 'sub.printing' or 'printing'
main_domain = f"{extracted.domain}.{extracted.suffix}"  # This will be 'deyaochen.com'

domain_token = os.environ['CERTBOT_VALIDATION']  # Token for DNS validation

# API URLs
BASE_URL = 'https://api.name.com/v4/domains'

# Get all DNS records for the domain
response = requests.get(f"{BASE_URL}/{domain}/records", auth=(user, token))

# Check the response code
if response.status_code != 200:
    raise ValueError(f"Failed to fetch records: {response.status_code} {response.text}")

# Parse the records
domain_list = response.json()['records']
challenge_subdomain = f"_acme-challenge.{subdomain}"

# Find if the TXT record already exists
domain_id = find_by_name(domain_list, challenge_subdomain)

# If the record exists, update it
if domain_id is not None:
    update_url = f"{BASE_URL}/{domain}/records/{domain_id}"
    payload = {
        "type": "TXT",
        "host": challenge_subdomain,
        "answer": domain_token,
        "ttl": 300
    }
    update_response = requests.put(update_url, json=payload, auth=(user, token))
    if update_response.status_code != 200:
        raise ValueError(f"Failed to update TXT record: {update_response.status_code} {update_response.text}")
else:
    # If the record doesn't exist, create it
    create_url = f"{BASE_URL}/{domain}/records"
    payload = {
        "type": "TXT",
        "host": challenge_subdomain,
        "answer": domain_token,
        "ttl": 300
    }
    create_response = requests.post(create_url, json=payload, auth=(user, token))
    if create_response.status_code != 200:
        raise ValueError(f"Failed to create TXT record: {create_response.status_code} {create_response.text}")
