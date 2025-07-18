#!/bin/bash

# Ubuntu testing script for cross-platform Ansible playbooks
# This script tests the Ansible playbooks in an Ubuntu environment with Linuxbrew
# (simulates macOS homebrew scenario) to validate package management compatibility

echo "=== Starting Ubuntu Testing Environment (macOS simulation) ==="

# Build and start the Ubuntu container with Linuxbrew
echo "Building Ubuntu test container with Linuxbrew..."
docker compose down ubuntu_test 2>/dev/null || true
docker compose up --build -d ubuntu_test

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build Ubuntu test container"
    exit 1
fi

echo "Ubuntu test container is ready!"
echo "Container: ubuntu_dev_test"
echo "Access with: docker compose exec ubuntu_test bash"
echo ""
echo "To run Ansible playbooks inside the container:"
echo "  # Core components (no vault required):"
echo "  ansible-playbook local.yml --tags=core,zsh,node,neovim,fonts,git-setup --ask-become-pass -vv"
echo ""
echo "  # Full setup (requires vault password):"
echo "  ansible-playbook local.yml --ask-become-pass --ask-vault-pass -vv"
echo ""
echo "To validate the environment:"
echo "  ./validate-ubuntu.sh"
echo ""
echo "VAULT-AWARE TESTING:"
echo "  - Components that work WITHOUT vault: core, zsh, node, neovim, fonts, git-setup"
echo "  - Components that REQUIRE vault: ssh, dotfiles"
echo ""

# Check if we should run interactively or just validate
if [ "$1" = "--interactive" ] || [ "$1" = "-i" ]; then
    echo "Starting interactive session..."
    docker compose exec ubuntu_test bash
elif [ "$1" = "--validate" ] || [ "$1" = "-v" ]; then
    echo "Running validation tests..."
    docker compose exec ubuntu_test /bin/bash -c "
        echo '=== Ubuntu Environment Validation (macOS simulation) ==='
        echo 'OS: \$(uname -a)'
        echo 'Distribution: \$(cat /etc/os-release | grep PRETTY_NAME)'
        echo 'Homebrew version: \$(brew --version | head -1)'
        echo 'Ansible version: \$(ansible --version | head -1)'
        echo 'Available collections:'
        ansible-galaxy collection list
        echo 'Testing brew access:'
        brew list | head -5
        echo '=== Testing Ansible Syntax ==='
        ansible-playbook --syntax-check local.yml
        echo '=== Testing Ubuntu Detection ==='
        ansible localhost -m setup -a 'filter=ansible_distribution' | grep -i ubuntu
        echo '=== Testing Core Components (No Vault) ==='
        echo 'Checking if core components can be validated without vault...'
        ansible-playbook local.yml --tags=core,zsh,node,neovim,fonts,git-setup --check --ask-become-pass -vv || echo 'Note: Some tasks may require sudo password in interactive mode'
    "
elif [ "$1" = "--core-only" ] || [ "$1" = "-c" ]; then
    echo "Running core components test (no vault required)..."
    docker compose exec ubuntu_test /bin/bash -c "
        echo '=== Testing Core Components Only ==='
        echo 'Running core, zsh, node, neovim, fonts, git-setup without vault...'
        ansible-playbook local.yml --tags=core,zsh,node,neovim,fonts,git-setup --ask-become-pass -vv
    "
elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Ubuntu testing script for cross-platform Ansible playbooks (macOS simulation)"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  --interactive, -i    Start interactive session in container"
    echo "  --validate, -v       Run validation tests and syntax checks"
    echo "  --core-only, -c      Test only core components (no vault required)"
    echo "  --help, -h           Show this help message"
    echo ""
    echo "VAULT-AWARE TESTING:"
    echo "  Components that work WITHOUT vault: core, zsh, node, neovim, fonts, git-setup"
    echo "  Components that REQUIRE vault: ssh, dotfiles"
    echo ""
    echo "This test simulates macOS environment using Ubuntu with Linuxbrew."
    echo "Without options, container runs in background. Use 'docker compose exec ubuntu_test bash' to access."
else
    echo "Use --interactive/-i for interactive mode, --validate/-v for validation, or --core-only/-c for vault-free testing"
    echo "Use --help/-h for more information about vault-aware testing"
    echo "Container is running in the background. Use 'docker compose exec ubuntu_test bash' to access it."
fi