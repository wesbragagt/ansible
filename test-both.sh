#!/bin/bash

# Cross-platform testing script for Ansible playbooks
# This script tests the Ansible playbooks on Ubuntu (macOS simulation), Ubuntu (native), Arch Linux, and Fedora
# to validate cross-platform compatibility

echo "=== Cross-Platform Testing for Ansible Playbooks ==="

# Function to run tests on a specific platform
run_platform_test() {
    local platform=$1
    local script=$2
    
    echo ""
    echo "=========================================="
    echo "Testing on $platform"
    echo "=========================================="
    
    if [ ! -f "$script" ]; then
        echo "ERROR: Test script $script not found"
        return 1
    fi
    
    # Make script executable
    chmod +x "$script"
    
    # Run validation
    echo "Running validation for $platform..."
    $script --validate
    
    if [ $? -eq 0 ]; then
        echo "✅ $platform validation passed"
    else
        echo "❌ $platform validation failed"
        return 1
    fi
}

# Function to run syntax check
run_syntax_check() {
    echo ""
    echo "=========================================="
    echo "Running Ansible Syntax Check"
    echo "=========================================="
    
    if command -v ansible-playbook &> /dev/null; then
        echo "Checking syntax of local.yml..."
        ansible-playbook --syntax-check local.yml
        if [ $? -eq 0 ]; then
            echo "✅ Syntax check passed"
        else
            echo "❌ Syntax check failed"
            return 1
        fi
    else
        echo "⚠️  Ansible not available on host, skipping syntax check"
    fi
}

# Function to clean up containers
cleanup() {
    echo ""
    echo "=========================================="
    echo "Cleaning up test containers"
    echo "=========================================="
    docker compose down
    echo "Cleanup completed"
}

# Main execution
main() {
    local ubuntu_failed=0
    local ubuntu_native_failed=0
    local arch_failed=0
    local fedora_failed=0
    
    echo "Starting cross-platform testing..."
    echo "This will test on Ubuntu (simulating macOS), Ubuntu (native), Arch Linux, and Fedora"
    echo ""
    
    # Run syntax check first
    run_syntax_check
    if [ $? -ne 0 ]; then
        echo "❌ Syntax check failed, aborting tests"
        exit 1
    fi
    
    # Test Ubuntu environment (macOS simulation)
    run_platform_test "Ubuntu (macOS simulation)" "./test-ubuntu.sh"
    if [ $? -ne 0 ]; then
        ubuntu_failed=1
    fi
    
    # Test Ubuntu native environment
    run_platform_test "Ubuntu (native)" "./test-ubuntu-native.sh"
    if [ $? -ne 0 ]; then
        ubuntu_native_failed=1
    fi
    
    # Test Arch Linux environment
    run_platform_test "Arch Linux" "./test-arch.sh"
    if [ $? -ne 0 ]; then
        arch_failed=1
    fi
    
    # Test Fedora environment
    run_platform_test "Fedora" "./test-fedora.sh"
    if [ $? -ne 0 ]; then
        fedora_failed=1
    fi
    
    # Summary
    echo ""
    echo "=========================================="
    echo "Test Results Summary"
    echo "=========================================="
    
    if [ $ubuntu_failed -eq 0 ] && [ $ubuntu_native_failed -eq 0 ] && [ $arch_failed -eq 0 ] && [ $fedora_failed -eq 0 ]; then
        echo "✅ All tests passed!"
        echo "✅ Ubuntu environment (macOS simulation): PASSED"
        echo "✅ Ubuntu environment (native): PASSED"
        echo "✅ Arch Linux environment: PASSED"
        echo "✅ Fedora environment: PASSED"
        echo ""
        echo "Your Ansible playbooks are ready for cross-platform deployment!"
    else
        echo "❌ Some tests failed:"
        if [ $ubuntu_failed -eq 1 ]; then
            echo "❌ Ubuntu environment (macOS simulation): FAILED"
        else
            echo "✅ Ubuntu environment (macOS simulation): PASSED"
        fi
        
        if [ $ubuntu_native_failed -eq 1 ]; then
            echo "❌ Ubuntu environment (native): FAILED"
        else
            echo "✅ Ubuntu environment (native): PASSED"
        fi
        
        if [ $arch_failed -eq 1 ]; then
            echo "❌ Arch Linux environment: FAILED"
        else
            echo "✅ Arch Linux environment: PASSED"
        fi
        
        if [ $fedora_failed -eq 1 ]; then
            echo "❌ Fedora environment: FAILED"
        else
            echo "✅ Fedora environment: PASSED"
        fi
        
        echo ""
        echo "Please review the errors above and fix the issues."
        exit 1
    fi
}

# Handle command line arguments
case "$1" in
    --help|-h)
        echo "Cross-platform testing script for Ansible playbooks"
        echo ""
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "OPTIONS:"
        echo "  --help, -h           Show this help message"
        echo "  --cleanup, -c        Clean up test containers and exit"
        echo "  --ubuntu             Test only Ubuntu environment (macOS simulation)"
        echo "  --ubuntu-native      Test only Ubuntu native environment"
        echo "  --arch               Test only Arch Linux environment"
        echo "  --fedora             Test only Fedora environment"
        echo ""
        echo "Without options, tests all four platforms"
        exit 0
        ;;
    --cleanup|-c)
        cleanup
        exit 0
        ;;
    --ubuntu)
        run_syntax_check
        run_platform_test "Ubuntu (macOS simulation)" "./test-ubuntu.sh"
        ;;
    --ubuntu-native)
        run_syntax_check
        run_platform_test "Ubuntu (native)" "./test-ubuntu-native.sh"
        ;;
    --arch)
        run_syntax_check
        run_platform_test "Arch Linux" "./test-arch.sh"
        ;;
    --fedora)
        run_syntax_check
        run_platform_test "Fedora" "./test-fedora.sh"
        ;;
    "")
        main
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac