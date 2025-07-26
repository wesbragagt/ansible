#!/bin/bash
# Quick start script for Nix flake setup

echo "=== Nix Flake Quick Start ==="
echo ""

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Map architecture names
case "$ARCH" in
    x86_64)
        NIX_ARCH="x86_64"
        ;;
    arm64|aarch64)
        NIX_ARCH="aarch64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Map OS names
case "$OS" in
    linux)
        NIX_OS="linux"
        HOME_PREFIX="/home"
        ;;
    darwin)
        NIX_OS="darwin"
        HOME_PREFIX="/Users"
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

FLAKE_TARGET="wesbragagt@${NIX_OS}-${NIX_ARCH}"

echo "Detected system: ${OS} ${ARCH}"
echo "Flake target: ${FLAKE_TARGET}"
echo ""

# Check if Nix is installed
if ! command -v nix &> /dev/null; then
    echo "Nix is not installed. Would you like to install it? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Installing Nix..."
        curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
        echo ""
        echo "Nix installed! Please restart your shell and run this script again."
        exit 0
    else
        echo "Please install Nix first: https://nixos.org/download.html"
        exit 1
    fi
fi

echo "Choose an option:"
echo "1) Enter development shell (temporary)"
echo "2) Install with Home Manager (persistent)"
echo "3) Set up SOPS for secrets management"
echo "4) Run tests in Docker"
echo ""
read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo ""
        echo "Entering Nix development shell..."
        nix develop
        ;;
    2)
        echo ""
        echo "Installing with Home Manager..."
        echo "This will install all packages persistently for your user."
        echo ""
        
        echo "Switching to flake configuration..."
        nix run .#homeConfigurations.${FLAKE_TARGET}.activationPackage
        ;;
    3)
        echo ""
        echo "Setting up SOPS..."
        ./setup-sops.sh
        ;;
    4)
        echo ""
        echo "Running tests in Docker..."
        ./test/test-nix.sh
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac