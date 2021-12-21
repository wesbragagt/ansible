#!/bin/bash

set -e

curl https://bootstrap.pypa.io/get-pip.py | python3 &&
pip install ansible &&
ansible --version
