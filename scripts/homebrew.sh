#!/bin/bash

echo "Configuring Homebrew"

# Check for Homebrew, install if we don't have it
if test ! $(which brew); then
    echo "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else 
	echo "Brew installed"
fi

# Update homebrew recipes
brew update

echo "Installing cask..."
brew install cask
