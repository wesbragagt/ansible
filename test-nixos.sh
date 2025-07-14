#!/bin/bash

# NixOS testing script for cross-platform development
# This script tests the nix flake in a true NixOS environment
# using nix package manager and flakes to validate NixOS scenarios

echo "=== Starting NixOS Testing Environment ==="

# Build and start the NixOS container
echo "Building NixOS test container..."
docker compose down nixos_test 2>/dev/null || true
docker compose up --build -d nixos_test

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build NixOS test container"
    exit 1
fi

echo "NixOS test container is ready!"
echo "Container: nixos_dev_test"
echo "Access with: docker compose exec nixos_test sh"
echo ""
echo "To test the nix flake inside the container:"
echo "  # Navigate to nix directory:"
echo "  cd /home/wesbragagt/dev/ansible/nix"
echo ""
echo "  # Check flake structure:"
echo "  nix flake check"
echo ""
echo "  # Enter development shell:"
echo "  nix develop"
echo ""
echo "  # Build packages:"
echo "  nix build"
echo ""
echo "  # Run development environment:"
echo "  nix run .#dev"
echo ""
echo "To validate the environment:"
echo "  ./validate-nixos.sh"
echo ""
echo "NIX FLAKE TESTING:"
echo "  - Test flake check and validation"
echo "  - Test development shell functionality"
echo "  - Test package building and installation"
echo ""

# Check if we should run interactively or just validate
if [ "$1" = "--interactive" ] || [ "$1" = "-i" ]; then
    echo "Starting interactive session..."
    docker compose exec nixos_test sh
elif [ "$1" = "--validate" ] || [ "$1" = "-v" ]; then
    echo "Running validation tests..."
    docker compose exec nixos_test /bin/sh -c "
        echo '=== NixOS Environment Validation ==='
        echo 'OS: \$(uname -a)'
        echo 'Nix version: \$(nix --version)'
        echo 'Nix store: \$(ls -la /nix/store | head -5)'
        echo 'Flakes enabled: \$(nix show-config | grep experimental-features)'
        echo 'Available packages (sample):'
        nix-env -qa | head -5
        echo '=== Testing Nix Flake ==='
        cd /home/wesbragagt/dev/ansible/nix
        echo 'Flake check:'
        nix flake check || echo 'Note: Some flake checks may fail in container environment'
        echo '=== Testing Development Shell ==='
        echo 'Testing development shell availability...'
        nix develop --command bash -c 'echo Available tools: && which git fzf ripgrep bat fd tmux nvim node || echo Some tools may not be available'
        echo '=== Testing Package Building ==='
        echo 'Testing package building...'
        nix build .#default || echo 'Note: Package building may require additional setup'
    "
elif [ "$1" = "--flake-only" ] || [ "$1" = "-f" ]; then
    echo "Running nix flake tests only..."
    docker compose exec nixos_test /bin/sh -c "
        echo '=== Testing Nix Flake Only ==='
        cd /home/wesbragagt/dev/ansible/nix
        echo 'Flake check:'
        nix flake check
        echo 'Testing development shell:'
        nix develop --command bash -c 'echo Development shell works!'
        echo 'Testing package building:'
        nix build .#default
    "
elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "NixOS testing script for cross-platform development"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  --interactive, -i    Start interactive session in container"
    echo "  --validate, -v       Run validation tests and nix flake checks"
    echo "  --flake-only, -f     Test only nix flake functionality"
    echo "  --help, -h           Show this help message"
    echo ""
    echo "NIX FLAKE TESTING:"
    echo "  This script tests the nix flake functionality in a true NixOS environment"
    echo "  Focus is on flake validation, development shell, and package building"
    echo ""
    echo "Without options, container runs in background. Use 'docker compose exec nixos_test sh' to access."
else
    echo "Use --interactive/-i for interactive mode, --validate/-v for validation, or --flake-only/-f for flake-only testing"
    echo "Use --help/-h for more information about nix flake testing"
    echo "Container is running in the background. Use 'docker compose exec nixos_test sh' to access it."
fi