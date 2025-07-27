#!/bin/bash
# Test script for Nix flake setup and multi-user template system
#
# This script validates:
# - Multi-user flake.nix customization via Ansible replace tasks
# - Nix installation via Determinate Systems installer in containers
# - Package availability and functionality after setup
# - Cross-platform compatibility and architecture support

set -e

echo "=== Nix Flake Test Script ==="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Container runtime detection
CONTAINER_RUNTIME="${CONTAINER_RUNTIME:-}"

# Function to detect container runtime
detect_container_runtime() {
    if [ -n "$CONTAINER_RUNTIME" ]; then
        # User specified runtime
        if command -v "$CONTAINER_RUNTIME" &> /dev/null; then
            echo "$CONTAINER_RUNTIME"
            return 0
        else
            echo -e "${RED}Error: Specified container runtime '$CONTAINER_RUNTIME' not found${NC}" >&2
            exit 1
        fi
    fi
    
    # Auto-detect (prefer docker)
    if command -v docker &> /dev/null; then
        echo "docker"
    elif command -v podman &> /dev/null; then
        echo "podman"
    else
        echo -e "${RED}Error: No container runtime found. Please install docker or podman${NC}" >&2
        exit 1
    fi
}

# Set container runtime
RUNTIME=$(detect_container_runtime)
echo -e "${GREEN}Using container runtime: $RUNTIME${NC}"
echo ""

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        return 1
    fi
}

# Function to check if command exists
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✅ $1 is available${NC}"
        return 0
    else
        echo -e "${RED}❌ $1 is not available${NC}"
        return 1
    fi
}

# Test multi-user functionality
# This tests the Ansible replace-based template system that customizes flake.nix
# for different users without requiring separate Jinja2 template files
test_multiuser() {
    echo ""
    echo "=== Testing Multi-User Template System ==="
    echo ""
    echo "Testing Ansible replace tasks that customize flake.nix for different users..."
    echo ""
    
    # Test different user configurations
    declare -a test_users=(
        "testuser1:Test User One:test1@example.com"
        "testuser2:Test User Two:test2@company.org"
        "developer:Jane Developer:jane@dev.local"
    )
    
    for user_config in "${test_users[@]}"; do
        IFS=':' read -r username fullname email <<< "$user_config"
        
        echo "Testing configuration for: $username ($fullname)"
        
        # Generate flake with specific user  
        echo "  Running: ansible-playbook with user=$username, name='$fullname', email='$email'"
        extra_vars=$(cat <<EOF
{
  "nix_user_name": "$username",
  "git_user_name": "$fullname", 
  "git_user_email": "$email",
  "nix_home_directory": "/home/$username"
}
EOF
)
        ansible_output=$(ansible-playbook local.yml --tags nix --limit localhost \
            --extra-vars "$extra_vars" \
            --extra-vars "flake_dest=flake.nix.test" 2>&1)
        ansible_exit_code=$?
        
        if [ $ansible_exit_code -ne 0 ]; then
            echo "  Ansible failed with exit code: $ansible_exit_code"
            echo "  Output: $ansible_output"
        fi
        
        # Check if template generated correctly
        if grep -F "userName = \"$fullname\"" flake.nix.test >/dev/null && \
           grep -F "userEmail = \"$email\"" flake.nix.test >/dev/null && \
           grep -F "\"$username@" flake.nix.test >/dev/null; then
            echo -e "${GREEN}✅ Template generated correctly for $username${NC}"
        else
            echo -e "${RED}❌ Template generation failed for $username${NC}"
        fi
    done
    
    # Restore original user config
    ansible-playbook local.yml --tags nix --limit localhost &>/dev/null
}

# Build and run container
build_container() {
    echo ""
    echo "Building container using $RUNTIME..."
    echo ""
    echo -e "${YELLOW}Note: Nix will be installed via Ansible inside the container${NC}"
    echo -e "${YELLOW}Container tests require '--security-opt seccomp=unconfined' for Nix to work${NC}"
    echo ""
    
    $RUNTIME build --platform linux/amd64 -f test/Dockerfile.archlinux-nix -t nix-flake-test .
    print_status $? "Container built with $RUNTIME"
}

# Run tests inside container
run_container_tests() {
    echo ""
    echo "Running tests inside container..."
    echo ""
    
    $RUNTIME run --platform linux/amd64 --security-opt seccomp=unconfined --rm -it nix-flake-test bash -c '
        echo "=== Installing Nix via Ansible ==="
        cd /home/testuser/ansible
        
        # Run Ansible to install Nix (this tests the actual Determinate Systems installation process)
        echo "Running Ansible Nix installation task (with --no-confirm for automation)..."
        ansible-playbook local.yml --tags nix --limit localhost \
            -e git_user_name="Test User" \
            -e git_user_email="test@example.com" \
            -e flake_dest="flake.nix.test" \
            -e nix_user_name="testuser" \
            -e nix_home_directory="/home/testuser" || {
            echo "Ansible Nix installation failed"
            exit 1
        }
        
        # Source nix profile after installation
        if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
            source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        elif [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
            source ~/.nix-profile/etc/profile.d/nix.sh
        fi
        
        echo ""
        echo "=== Testing Nix Installation ==="
        nix --version
        
        echo ""
        echo "=== Testing Flake ==="
        
        # Test flake show first
        echo "Testing flake structure..."
        nix flake show --no-warn-dirty -f ./flake.nix.test || true
        
        echo ""
        echo "=== Testing installed packages ==="
        echo ""
        
        # Enter nix develop shell and test commands
        nix develop -f ./flake.nix.test --command bash -c '\''
            # Test core tools
            for cmd in fzf rg bat fd wget tmux jq delta gh zoxide go git-lfs stow sops age; do
                if command -v $cmd &> /dev/null; then
                    echo "✅ $cmd is available"
                else
                    echo "❌ $cmd is not available"
                fi
            done
            
            echo ""
            echo "=== Testing development tools ==="
            echo ""
            
            # Test dev tools
            for cmd in zsh starship nvim node fnm python3 cmake ninja; do
                if command -v $cmd &> /dev/null; then
                    echo "✅ $cmd is available"
                else
                    echo "❌ $cmd is not available"
                fi
            done
            
            echo ""
            echo "=== Package versions ==="
            echo ""
            
            echo "Node: $(node --version 2>/dev/null || echo "not found")"
            echo "Python: $(python3 --version 2>/dev/null || echo "not found")"
            echo "Neovim: $(nvim --version | head -n1 2>/dev/null || echo "not found")"
            echo "Git: $(git --version 2>/dev/null || echo "not found")"
        '\''
        
    '
}

# Main execution
main() {
    case "${1:-test}" in
        build)
            build_container
            ;;
        test)
            if [ ! -f "test/Dockerfile.archlinux-nix" ]; then
                echo -e "${RED}Error: test/Dockerfile.archlinux-nix not found${NC}"
                echo "Please run this script from the ansible directory"
                exit 1
            fi
            
            build_container && run_container_tests
            ;;
        interactive)
            echo "Starting interactive container..."
            $RUNTIME run --platform linux/amd64 --security-opt seccomp=unconfined --rm -it nix-flake-test bash -l
            ;;
        multiuser)
            if [ ! -f "flake.nix" ]; then
                echo -e "${RED}Error: flake.nix not found${NC}"
                echo "Please ensure the flake.nix file exists"
                exit 1
            fi
            test_multiuser
            ;;
        *)
            echo "Usage: $0 [build|test|interactive|multiuser]"
            echo "  build       - Build the container (no Nix preinstalled)"
            echo "  test        - Build and run full Ansible+Nix tests in container (default)"
            echo "  interactive - Start an interactive shell in the container"
            echo "  multiuser   - Test multi-user flake.nix customization system locally"
            echo ""
            echo "Test modes:"
            echo "  multiuser   - Tests Ansible replace-based template system"
            echo "  test        - Tests full Nix installation via Determinate Systems installer"
            echo "  interactive - Manual testing and debugging"
            echo ""
            echo "Environment variables:"
            echo "  CONTAINER_RUNTIME - Specify container runtime (docker/podman)"
            echo "                      Auto-detects if not set"
            exit 1
            ;;
    esac
}

main "$@"