#!/bin/sh -e

playbook=$1
if [[ -z "$playbook" ]]; then
  echo "Missing playbook argument"
  exit 1
fi
if [[ ! -e playbooks/"$playbook".yml ]]; then
  echo "Playbook $playbook does not exist in /playbooks"
  exit 1
fi
if [[ -z "$SERVER_FINGERPRINT" ]]; then
  echo "Missing environment variable SERVER_FINGERPRINT"
  exit 1
fi
if [[ -n "$SSH_PRIVATE_KEY_BASE64" ]]; then
  export SSH_PRIVATE_KEY=$(echo $SSH_PRIVATE_KEY_BASE64 | base64 -d)
fi
if [[ -z "$SSH_PRIVATE_KEY" ]]; then
  echo "Missing environment variable SSH_PRIVATE_KEY"
  exit 1
fi

mkdir ~/.ssh
chown 700 ~/.ssh
eval $(ssh-agent -s) > /dev/null
echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add - 2> /dev/null
echo "$SERVER_FINGERPRINT" >> ~/.ssh/known_hosts

ansible-playbook playbooks/"$playbook".yml