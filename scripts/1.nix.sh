#!/bin/sh

# This will perform a single-user installation of Nix, meaning that /nix is owned by the invoking user. You should run this under your usual user account, not as root. The script will invoke sudo to create /nix if it doesn’t already exist. If you don’t have sudo, you should manually create /nix first as root, e.g.:
export NIX_INSTALLER_NO_MODIFY_PROFILE=true
sh <(curl -L https://nixos.org/nix/install) --no-daemon
export PATH=$HOME/.nix-profile/bin:$PATH
