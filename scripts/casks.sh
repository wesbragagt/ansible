#!/bin/bash 

set -e

# Use this script to install --casks for homebrew
brew install cask

apps=(
    slack
    alacritty
    visual-studio-code  
    brave-browser
    raycast
    obsidian
    karabiner-elements
)

#install casks
echo "Installing cask apps..."
brew install --cask ${apps[@]} --appdir=/Applications

# Wezterm Nightly
brew tap homebrew/cask-versions
brew install --cask wezterm-nightly


