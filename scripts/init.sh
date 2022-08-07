#!/bin/sh

export PATH="$HOME/.nix-profile/bin:/usr/bin:$PATH"
# Install nix
curl -L https://nixos.org/nix/install | sh &&
# Install ansible
nix-env -iA 'nixpkgs.ansible' &&
# Run playbook
ansible-playbook local.yml &&
export PATH="$HOME/.nix-profile/bin:/usr/bin:$PATH"
