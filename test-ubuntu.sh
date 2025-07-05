#!/bin/bash

# Ubuntu-based testing script for cross-platform Ansible playbooks
# This script tests the Ansible playbooks in an Ubuntu environment with Linuxbrew
# to simulate macOS-like package management

echo "=== Starting Ubuntu-based Testing Environment ==="

# Build and start the Ubuntu container
echo "Building Ubuntu test container..."
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
echo "  ansible-playbook local.yml --ask-become-pass --ask-vault-pass -vv"
echo ""
echo "To validate the environment:"
echo "  ./validate-ubuntu.sh"
echo ""

# Check if we should run interactively or just validate
if [ "$1" = "--interactive" ] || [ "$1" = "-i" ]; then
    echo "Starting interactive session..."
    docker compose exec ubuntu_test bash
elif [ "$1" = "--validate" ] || [ "$1" = "-v" ]; then
    echo "Running validation tests..."
    docker compose exec ubuntu_test /bin/bash -c "
        echo '=== Ubuntu Environment Validation ==='
        echo 'OS: \$(uname -a)'
        echo 'Distribution: \$(cat /etc/os-release | grep PRETTY_NAME)'
        echo 'Homebrew version: \$(brew --version 2>/dev/null || echo \"Not installed\")'
        echo 'Ansible version: \$(ansible --version | head -1)'
        echo 'Available collections:'
        ansible-galaxy collection list
        echo '=== Testing Ansible Syntax ==='
        ansible-playbook --syntax-check local.yml
    "
else
    echo "Use --interactive/-i for interactive mode or --validate/-v for validation"
    echo "Container is running in the background. Use 'docker compose exec ubuntu_test bash' to access it."
fi