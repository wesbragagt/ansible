#!/bin/sh

source scripts/1.nix.sh
source scripts/2.ansible.sh
echo "ansible-playbook local.yml --ask-become-pass"
