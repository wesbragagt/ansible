#!/bin/bash 

set -e

# Use this script to install --casks for homebrew
brew install cask

apps=(
    slack
    visual-studio-code  
    google-chrome
    postman
    iterm2
    alacritty
    runjs
    raycast
    drawio
    obsidian
)

#install casks
echo "Installing cask apps..."
brew install --cask ${apps[@]} --appdir=/Applications
