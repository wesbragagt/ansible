#!/bin/bash

# Make sure to have this export PATH='$HOME/.nix-profile/bin:$PATH'

# Install nix
curl -L https://nixos.org/nix/install | sh &&

# Install ansible
nix-env -iA 'nixpkgs.ansible'
