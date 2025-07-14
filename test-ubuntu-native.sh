#!/bin/bash

# Native Ubuntu testing script for cross-platform Ansible playbooks
# This script tests the Ansible playbooks in a true Ubuntu environment
# using apt as the package manager to validate Ubuntu scenarios

echo "=== Starting Native Ubuntu Testing Environment ==="

# Build and start the native Ubuntu container
echo "Building native Ubuntu test container..."
docker compose down ubuntu_native_test 2>/dev/null || true
docker compose up --build -d ubuntu_native_test

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build native Ubuntu test container"
    exit 1
fi

echo "Native Ubuntu test container is ready!"
echo "Container: ubuntu_native_dev_test"
echo "Access with: docker compose exec ubuntu_native_test bash"
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
    docker compose exec ubuntu_native_test bash
elif [ "$1" = "--validate" ] || [ "$1" = "-v" ]; then
    echo "Running validation tests..."
    docker compose exec ubuntu_native_test /bin/bash -c "
        echo '=== Native Ubuntu Environment Validation ==='
        echo 'OS: \$(uname -a)'
        echo 'Distribution: \$(cat /etc/os-release | grep PRETTY_NAME)'
        echo 'APT version: \$(apt --version | head -1)'
        echo 'Ansible version: \$(ansible --version | head -1)'
        echo 'Available collections:'
        ansible-galaxy collection list
        echo 'Testing apt access:'
        sudo apt list --installed | head -5
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
    docker compose exec ubuntu_native_test /bin/bash -c "
        echo '=== Testing Core Components Only ==='
        echo 'Running core, zsh, node, neovim, fonts, git-setup without vault...'
        ansible-playbook local.yml --tags=core,zsh,node,neovim,fonts,git-setup --ask-become-pass -vv
    "
elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Native Ubuntu testing script for cross-platform Ansible playbooks"
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
    echo "This test uses native Ubuntu environment with apt package manager."
    echo "Without options, container runs in background. Use 'docker compose exec ubuntu_native_test bash' to access."
else
    echo "Use --interactive/-i for interactive mode, --validate/-v for validation, or --core-only/-c for vault-free testing"
    echo "Use --help/-h for more information about vault-aware testing"
    echo "Container is running in the background. Use 'docker compose exec ubuntu_native_test bash' to access it."
fi