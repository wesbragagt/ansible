#!/bin/sh

sh <(curl -L https://nixos.org/nix/install) --daemon &&

export PATH=/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:$PATH
sudo chown -R $(whoami) /nix
