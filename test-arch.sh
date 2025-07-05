#!/bin/bash

# Arch Linux testing script for cross-platform Ansible playbooks
# This script tests the Ansible playbooks in a true Arch Linux environment
# using pacman as the package manager to validate Arch Linux scenarios

echo "=== Starting Arch Linux Testing Environment ==="

# Build and start the Arch Linux container
echo "Building Arch Linux test container..."
docker compose down arch_test 2>/dev/null || true
docker compose up --build -d arch_test

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build Arch Linux test container"
    exit 1
fi

echo "Arch Linux test container is ready!"
echo "Container: arch_dev_test"
echo "Access with: docker compose exec arch_test bash"
echo ""
echo "To run Ansible playbooks inside the container:"
echo "  ansible-playbook local.yml --ask-become-pass --ask-vault-pass -vv"
echo ""
echo "To validate the environment:"
echo "  ./validate-arch.sh"
echo ""

# Check if we should run interactively or just validate
if [ "$1" = "--interactive" ] || [ "$1" = "-i" ]; then
    echo "Starting interactive session..."
    docker compose exec arch_test bash
elif [ "$1" = "--validate" ] || [ "$1" = "-v" ]; then
    echo "Running validation tests..."
    docker compose exec arch_test /bin/bash -c "
        echo '=== Arch Linux Environment Validation ==='
        echo 'OS: \$(uname -a)'
        echo 'Distribution: \$(cat /etc/os-release | grep PRETTY_NAME)'
        echo 'Pacman version: \$(pacman --version | head -1)'
        echo 'Ansible version: \$(ansible --version | head -1)'
        echo 'Available collections:'
        ansible-galaxy collection list
        echo 'Testing pacman access:'
        sudo pacman -Q | head -5
        echo '=== Testing Ansible Syntax ==='
        ansible-playbook --syntax-check local.yml
        echo '=== Testing Arch Linux Detection ==='
        ansible localhost -m setup -a 'filter=ansible_distribution' | grep -i arch
    "
else
    echo "Use --interactive/-i for interactive mode or --validate/-v for validation"
    echo "Container is running in the background. Use 'docker compose exec arch_test bash' to access it."
fi