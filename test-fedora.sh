#!/bin/bash

# Fedora testing script for cross-platform Ansible playbooks
# This script tests the Ansible playbooks in a true Fedora environment
# using dnf as the package manager to validate Fedora scenarios

echo "=== Starting Fedora Testing Environment ==="

# Build and start the Fedora container
echo "Building Fedora test container..."
docker compose down fedora_test 2>/dev/null || true
docker compose up --build -d fedora_test

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build Fedora test container"
    exit 1
fi

echo "Fedora test container is ready!"
echo "Container: fedora_dev_test"
echo "Access with: docker compose exec fedora_test bash"
echo ""
echo "To run Ansible playbooks inside the container:"
echo "  # Core components (no vault required):"
echo "  ansible-playbook local.yml --tags=core,zsh,node,neovim,fonts,git-setup --ask-become-pass -vv"
echo ""
echo "  # Full setup (requires vault password):"
echo "  ansible-playbook local.yml --ask-become-pass --ask-vault-pass -vv"
echo ""
echo "To validate the environment:"
echo "  ./validate-fedora.sh"
echo ""
echo "VAULT-AWARE TESTING:"
echo "  - Components that work WITHOUT vault: core, zsh, node, neovim, fonts, git-setup"
echo "  - Components that REQUIRE vault: ssh, dotfiles"
echo ""

# Check if we should run interactively or just validate
if [ "$1" = "--interactive" ] || [ "$1" = "-i" ]; then
    echo "Starting interactive session..."
    docker compose exec fedora_test bash
elif [ "$1" = "--validate" ] || [ "$1" = "-v" ]; then
    echo "Running validation tests..."
    docker compose exec fedora_test /bin/bash -c "
        echo '=== Fedora Environment Validation ==='
        echo 'OS: \$(uname -a)'
        echo 'Distribution: \$(cat /etc/os-release | grep PRETTY_NAME)'
        echo 'DNF version: \$(dnf --version | head -1)'
        echo 'Ansible version: \$(ansible --version | head -1)'
        echo 'Available collections:'
        ansible-galaxy collection list
        echo 'Testing dnf access:'
        sudo dnf list installed | head -5
        echo '=== Testing Ansible Syntax ==='
        ansible-playbook --syntax-check local.yml
        echo '=== Testing Fedora Detection ==='
        ansible localhost -m setup -a 'filter=ansible_distribution' | grep -i fedora
        echo '=== Testing Core Components (No Vault) ==='
        echo 'Checking if core components can be validated without vault...'
        ansible-playbook local.yml --tags=core,zsh,node,neovim,fonts,git-setup --check --ask-become-pass -vv || echo 'Note: Some tasks may require sudo password in interactive mode'
    "
elif [ "$1" = "--core-only" ] || [ "$1" = "-c" ]; then
    echo "Running core components test (no vault required)..."
    docker compose exec fedora_test /bin/bash -c "
        echo '=== Testing Core Components Only ==='
        echo 'Running core, zsh, node, neovim, fonts, git-setup without vault...'
        ansible-playbook local.yml --tags=core,zsh,node,neovim,fonts,git-setup --ask-become-pass -vv
    "
elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Fedora testing script for cross-platform Ansible playbooks"
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
    echo "Without options, container runs in background. Use 'docker compose exec fedora_test bash' to access."
else
    echo "Use --interactive/-i for interactive mode, --validate/-v for validation, or --core-only/-c for vault-free testing"
    echo "Use --help/-h for more information about vault-aware testing"
    echo "Container is running in the background. Use 'docker compose exec fedora_test bash' to access it."
fi