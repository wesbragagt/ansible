#!/bin/bash

echo -e "Set keyboard press on hold repeat" &&
defaults write -g ApplePressAndHoldEnabled -bool false
