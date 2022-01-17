#!/bin/bash 

set -e

# Use this script to install --casks for homebrew
brew install cask

apps=(
    slack
    visual-studio-code  
    brave 
    google-chrome
    postman
    iterm2
    runjs
    raycast
    drawio
)

#install casks
echo "Installing cask apps..."
brew install --cask ${apps[@]} --appdir=/Applications
