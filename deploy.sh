#!/bin/sh -e

if [[ -z "$SERVER_FINGERPRINT" ]]; then
  echo "Missing environment variable SERVER_FINGERPRINT"
  exit 1
fi
if [[ -z "$SSH_PRIVATE_KEY" ]]; then
  echo "Missing environment variable SSH_PRIVATE_KEY"
  exit 1
fi

eval $(ssh-agent -s) > /dev/null
echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add - 2> /dev/null
echo "$SERVER_FINGERPRINT" >> ~/.ssh/known_hosts

ansible-playbook playbooks/deploy.yml
