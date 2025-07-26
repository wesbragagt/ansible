#!/bin/bash
# Test script for Nix flake setup

set -e

echo "=== Nix Flake Test Script ==="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Build and run Docker container
build_container() {
    echo ""
    echo "Building Docker container..."
    echo ""
    
    docker build -f test/Dockerfile.archlinux-nix -t nix-flake-test .
    print_status $? "Docker container built"
}

# Run tests inside container
run_container_tests() {
    echo ""
    echo "Running tests inside container..."
    echo ""
    
    docker run --rm -it nix-flake-test bash -c '
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        
        echo "=== Testing Nix Installation ==="
        nix --version
        
        echo ""
        echo "=== Testing Flake ==="
        cd /home/wesbragagt/ansible
        
        # Enter nix develop shell and test commands
        nix develop --command bash -c "
            echo \"\"
            echo \"=== Testing installed packages ===\"
            echo \"\"
            
            # Test core tools
            for cmd in fzf rg bat fd wget tmux jq delta gh zoxide go git-lfs stow sops age; do
                if command -v \$cmd &> /dev/null; then
                    echo \"✅ \$cmd is available\"
                else
                    echo \"❌ \$cmd is not available\"
                fi
            done
            
            echo \"\"
            echo \"=== Testing development tools ===\"
            echo \"\"
            
            # Test dev tools
            for cmd in zsh starship nvim node npm fnm python3 cmake ninja; do
                if command -v \$cmd &> /dev/null; then
                    echo \"✅ \$cmd is available\"
                else
                    echo \"❌ \$cmd is not available\"
                fi
            done
            
            echo \"\"
            echo \"=== Package versions ===\"
            echo \"\"
            
            echo \"Node: \$(node --version 2>/dev/null || echo \"not found\")\"
            echo \"Python: \$(python3 --version 2>/dev/null || echo \"not found\")\"
            echo \"Neovim: \$(nvim --version | head -n1 2>/dev/null || echo \"not found\")\"
            echo \"Git: \$(git --version 2>/dev/null || echo \"not found\")\"
        "
        
        echo ""
        echo "=== Testing SOPS functionality ===\"
        echo ""
        
        # Generate age key for testing
        mkdir -p ~/.config/sops/age
        age-keygen -o ~/.config/sops/age/keys.txt
        
        # Get public key and update .sops.yaml
        PUBLIC_KEY=$(grep -o "public key: age.*" ~/.config/sops/age/keys.txt | cut -d" " -f3)
        sed -i "s/age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/\$PUBLIC_KEY/g" .sops.yaml
        
        # Encrypt the test secret
        if sops -e -i secrets/test-secret.yaml; then
            echo "✅ Successfully encrypted test secret"
            
            # Try to decrypt it
            if sops -d secrets/test-secret.yaml | grep -q "This is a test secret string!"; then
                echo "✅ Successfully decrypted test secret"
            else
                echo "❌ Failed to decrypt test secret correctly"
            fi
        else
            echo "❌ Failed to encrypt test secret"
        fi
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
            docker run --rm -it nix-flake-test bash -l
            ;;
        *)
            echo "Usage: $0 [build|test|interactive]"
            echo "  build       - Build the Docker container"
            echo "  test        - Build and run tests (default)"
            echo "  interactive - Start an interactive shell in the container"
            exit 1
            ;;
    esac
}

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    exit 1
fi

main "$@"