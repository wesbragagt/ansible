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

# Build and run container
build_container() {
    echo ""
    echo "Building container using $RUNTIME..."
    echo ""
    
    $RUNTIME build -f test/Dockerfile.archlinux-nix -t nix-flake-test .
    print_status $? "Container built with $RUNTIME"
}

# Run tests inside container
run_container_tests() {
    echo ""
    echo "Running tests inside container..."
    echo ""
    
    $RUNTIME run --rm -it nix-flake-test bash -c '
        # Source nix profile  
        source ~/.nix-profile/etc/profile.d/nix.sh
        
        echo "=== Testing Nix Installation ==="
        nix --version
        
        echo ""
        echo "=== Testing Flake ==="
        cd /home/wesbragagt/ansible
        
        # Test flake show first
        echo "Testing flake structure..."
        nix flake show --no-warn-dirty || true
        
        echo ""
        echo "=== Testing installed packages ==="
        echo ""
        
        # Enter nix develop shell and test commands
        nix develop --command bash -c '\''
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
            $RUNTIME run --rm -it nix-flake-test bash -l
            ;;
        *)
            echo "Usage: $0 [build|test|interactive]"
            echo "  build       - Build the container"
            echo "  test        - Build and run tests (default)"
            echo "  interactive - Start an interactive shell in the container"
            echo ""
            echo "Environment variables:"
            echo "  CONTAINER_RUNTIME - Specify container runtime (docker/podman)"
            echo "                      Auto-detects if not set"
            exit 1
            ;;
    esac
}

main "$@"