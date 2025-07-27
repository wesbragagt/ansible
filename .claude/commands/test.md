# Test Command for Ansible Development Environment

This command provides comprehensive regression testing for the Ansible-based development environment automation tool. It ensures all core functionality works correctly after changes to the codebase.

## Overview

The project is a hybrid Nix + Ansible development environment automation tool with:
- **Nix flakes**: Cross-platform package management (immutable, reproducible)
- **GNU Stow**: Dotfiles management (mutable, hot-reload friendly)  
- **Ansible**: System orchestration, secrets management (vault), configuration

## Test Strategy

Execute tests in the following order to catch regressions early and efficiently:

### 1. File Structure Integrity Checks

First, verify the project structure is intact:

```bash
# Check core files exist
test -f flake.nix && echo "✅ flake.nix exists" || echo "❌ flake.nix missing"
test -f local.yml && echo "✅ local.yml exists" || echo "❌ local.yml missing"
test -f Makefile && echo "✅ Makefile exists" || echo "❌ Makefile missing"
test -f ansible.cfg && echo "✅ ansible.cfg exists" || echo "❌ ansible.cfg missing"

# Check task files
for task in nix zsh ssh git-setup dotfiles; do
    test -f "tasks/${task}.yml" && echo "✅ tasks/${task}.yml exists" || echo "❌ tasks/${task}.yml missing"
done

# Check test infrastructure
test -f test/test-nix.sh && echo "✅ test script exists" || echo "❌ test script missing"
test -x test/test-nix.sh && echo "✅ test script executable" || echo "❌ test script not executable"
test -f test/Dockerfile.archlinux-nix && echo "✅ Dockerfile exists" || echo "❌ Dockerfile missing"
```

### 2. Configuration Validation

Validate Ansible and Nix configurations:

```bash
# Ansible syntax validation
echo "=== Ansible Syntax Check ==="
ansible-playbook local.yml --syntax-check
if [ $? -eq 0 ]; then
    echo "✅ Ansible syntax valid"
else
    echo "❌ Ansible syntax errors found"
    exit 1
fi

# Check all task files individually
echo "=== Task File Syntax Check ==="
for task_file in tasks/*.yml; do
    ansible-playbook "$task_file" --syntax-check
    if [ $? -eq 0 ]; then
        echo "✅ $task_file syntax valid"
    else
        echo "❌ $task_file syntax errors"
    fi
done

# Nix flake validation
echo "=== Nix Flake Validation ==="
nix flake check --no-warn-dirty 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ Nix flake valid"
else
    echo "❌ Nix flake validation failed"
fi
```

### 3. Template Replacement System Testing

Test the multi-user template system comprehensively:

```bash
# Run the multiuser test mode
echo "=== Template Replacement System Test ==="
./test/test-nix.sh multiuser

# Additional template validation
echo "=== Template Variable Coverage Check ==="
# Ensure all required template variables are present in flake.nix
required_vars=("git_user_name" "git_user_email" "nix_user_name" "nix_home_directory")
for var in "${required_vars[@]}"; do
    if grep -q "{{ $var }}" flake.nix; then
        echo "✅ Template variable $var found in flake.nix"
    else
        echo "❌ Template variable $var missing from flake.nix"
    fi
done
```

### 4. Container-Based Nix Functionality Testing

Test Nix package installation and functionality in isolated environment:

```bash
# Build container and run comprehensive tests
echo "=== Container-Based Nix Testing ==="
./test/test-nix.sh test

# Test specific container modes
echo "=== Testing Container Build Only ==="
./test/test-nix.sh build
```

### 5. Ansible Playbook Validation (Dry Run)

Test Ansible playbooks without making changes:

```bash
echo "=== Ansible Playbook Dry Run Tests ==="

# Test individual tasks with check mode
tasks=("nix" "zsh" "git-setup")
for task in "${tasks[@]}"; do
    echo "Testing task: $task"
    ansible-playbook local.yml --tags "$task" --check --diff --limit localhost
    if [ $? -eq 0 ]; then
        echo "✅ Task $task dry run successful"
    else
        echo "❌ Task $task dry run failed"
    fi
done

# Test vault-required tasks (will prompt for vault password)
echo "=== Vault-Dependent Task Validation ==="
echo "Note: The following tasks require vault password:"
vault_tasks=("ssh" "dotfiles")
for task in "${vault_tasks[@]}"; do
    echo "Validating task: $task (requires vault password)"
    # Use --check to avoid making actual changes
    ansible-playbook local.yml --tags "$task" --check --ask-vault-pass --limit localhost
done
```

### 6. Makefile Command Testing

Verify all Makefile targets work correctly:

```bash
echo "=== Makefile Command Validation ==="

# Test make targets (dry run where possible)
echo "Testing make test..."
make test

# Validate other targets exist and are callable (syntax check only)
targets=("all" "nix" "zsh" "ssh" "git-setup" "dotfiles")
for target in "${targets[@]}"; do
    # Check if target exists in Makefile
    if grep -q "^$target:" Makefile; then
        echo "✅ Make target '$target' exists"
    else
        echo "❌ Make target '$target' missing"
    fi
done
```

### 7. Platform Compatibility Checks

Verify cross-platform compatibility features:

```bash
echo "=== Platform Compatibility Check ==="

# Check OS detection works
echo "Current platform: $(uname -s)"

# Verify no platform-specific package logic in flake.nix
if grep -i "darwin\|linux\|windows" flake.nix | grep -v "# Platform"; then
    echo "⚠️  Warning: Found potential platform-specific logic in flake.nix"
    echo "   This project should use Nix for uniform cross-platform package management"
else
    echo "✅ No platform-specific package logic found in flake.nix"
fi

# Check container runtime detection
echo "=== Container Runtime Detection ==="
./test/test-nix.sh build 2>&1 | head -5
```

### 8. Integration Testing

Test the complete workflow integration:

```bash
echo "=== Integration Testing ==="

# Test flake generation and package availability
echo "Testing complete Nix workflow..."

# Generate a test flake with known user data
test_vars='{
  "nix_user_name": "testuser",
  "git_user_name": "Test User", 
  "git_user_email": "test@example.com",
  "nix_home_directory": "/tmp/testuser",
  "flake_dest": "flake.nix.integration-test"
}'

echo "Generating test flake..."
ansible-playbook local.yml --tags nix --limit localhost --extra-vars "$test_vars" 2>/dev/null

if [ -f "flake.nix.integration-test" ]; then
    echo "✅ Integration test flake generated"
    
    # Validate the generated flake
    echo "Validating generated flake..."
    nix flake check --no-warn-dirty -f ./flake.nix.integration-test 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ Generated flake passes validation"
    else
        echo "❌ Generated flake validation failed"
    fi
    
    # Clean up
    rm -f flake.nix.integration-test
else
    echo "❌ Integration test flake generation failed"
fi
```

### 9. Regression Detection Strategies

Implement automated regression detection:

```bash
echo "=== Regression Detection ==="

# Check for common regression patterns
echo "Checking for common regression patterns..."

# 1. Ensure no hardcoded paths
if grep -r "/Users/\|/home/[^/]" --include="*.yml" --include="*.nix" .; then
    echo "⚠️  Warning: Found potential hardcoded user paths"
else
    echo "✅ No hardcoded user paths found"
fi

# 2. Check for missing template variables
echo "Checking template variable consistency..."
template_vars_in_tasks=$(grep -r "{{ " tasks/ | grep -o "{{ [^}]* }}" | sort -u)
template_vars_in_flake=$(grep -o "{{ [^}]* }}" flake.nix | sort -u)

if [ -n "$template_vars_in_flake" ]; then
    echo "Template variables found in flake.nix:"
    echo "$template_vars_in_flake"
    echo "✅ Template system is active"
else
    echo "⚠️  No template variables found in flake.nix"
fi

# 3. Verify SSH agent configuration exists
if grep -q "services.ssh-agent" flake.nix; then
    echo "✅ SSH agent configuration found in flake.nix"
else
    echo "⚠️  SSH agent configuration missing from flake.nix"
fi

# 4. Check for required packages
echo "Checking for core package definitions..."
required_packages=("fzf" "ripgrep" "bat" "fd" "tmux" "jq" "git" "zsh" "starship" "neovim")
for package in "${required_packages[@]}"; do
    if grep -q "$package" flake.nix; then
        echo "✅ Package $package found in flake.nix"
    else
        echo "⚠️  Package $package not found in flake.nix"
    fi
done
```

### 10. Performance and Resource Testing

Monitor resource usage and performance:

```bash
echo "=== Performance Testing ==="

# Time the container build process
echo "Timing container build..."
time ./test/test-nix.sh build

# Check flake evaluation performance
echo "Testing flake evaluation performance..."
time nix flake show --no-warn-dirty 2>/dev/null

# Monitor container resource usage during tests
echo "Container resource monitoring available via: docker stats"
```

## Complete Test Execution

To run all tests in sequence, create and execute this comprehensive test script:

```bash
#!/bin/bash
# comprehensive-test.sh - Run all regression tests

set -e

echo "=== Comprehensive Regression Test Suite ==="
echo "Starting at: $(date)"
echo ""

# 1. File structure
echo "1/10 - File Structure Checks..."
# [Include file structure checks from above]

# 2. Configuration validation  
echo "2/10 - Configuration Validation..."
# [Include configuration validation from above]

# 3. Template system
echo "3/10 - Template System Testing..."
./test/test-nix.sh multiuser

# 4. Container testing
echo "4/10 - Container-Based Testing..."
./test/test-nix.sh test

# 5. Ansible validation
echo "5/10 - Ansible Playbook Validation..."
# [Include dry run tests from above]

# 6. Makefile testing
echo "6/10 - Makefile Command Testing..."
make test

# 7. Platform compatibility
echo "7/10 - Platform Compatibility..."
# [Include platform checks from above]

# 8. Integration testing
echo "8/10 - Integration Testing..."
# [Include integration tests from above]

# 9. Regression detection
echo "9/10 - Regression Detection..."
# [Include regression detection from above]

# 10. Performance testing
echo "10/10 - Performance Testing..."
# [Include performance tests from above]

echo ""
echo "=== Test Suite Complete ==="
echo "Finished at: $(date)"
```

## Quick Regression Test

For rapid regression detection during development:

```bash
# Quick test (< 2 minutes)
ansible-playbook local.yml --syntax-check && \
nix flake check --no-warn-dirty && \
./test/test-nix.sh multiuser && \
echo "✅ Quick regression test passed"
```

## CI/CD Integration

For automated testing in CI/CD pipelines:

```bash
# CI-friendly test script
export CONTAINER_RUNTIME=docker  # or podman
./test/test-nix.sh test
ansible-playbook local.yml --syntax-check
nix flake check --no-warn-dirty
```

## Troubleshooting Test Failures

### Common Issues and Solutions

1. **Container build failures**: Check Docker/Podman installation and permissions
2. **Ansible syntax errors**: Validate YAML formatting and Ansible module usage
3. **Nix flake validation failures**: Check flake.nix syntax and dependencies
4. **Template variable issues**: Ensure all variables are properly defined in task files
5. **Permission errors**: Verify file permissions and user access

### Debug Mode

For detailed debugging, run tests with verbose output:

```bash
# Verbose container testing
CONTAINER_RUNTIME=docker ./test/test-nix.sh test

# Verbose Ansible testing  
ansible-playbook local.yml --syntax-check -vv

# Interactive container debugging
./test/test-nix.sh interactive
```

This comprehensive testing approach ensures the development environment automation tool maintains reliability and functionality across all supported platforms and use cases.