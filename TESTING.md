# Testing Infrastructure

This document describes the testing infrastructure for the cross-platform Ansible automation tool.

## Overview

The testing infrastructure supports validation of Ansible playbooks across multiple platforms:
- **Ubuntu with Linuxbrew**: Simulates macOS environment for testing Homebrew-based tasks
- **Arch Linux with Pacman**: Tests native Arch Linux package management and system integration

## Testing Scripts

### `test-both.sh` - Comprehensive Cross-Platform Testing
Runs tests on both Ubuntu and Arch Linux environments to validate cross-platform compatibility.

```bash
# Run all tests
./test-both.sh

# Test specific platforms
./test-both.sh --ubuntu    # Ubuntu only
./test-both.sh --arch      # Arch Linux only

# Cleanup containers
./test-both.sh --cleanup
```

### `test-ubuntu.sh` - Ubuntu Environment Testing
Tests the playbooks in an Ubuntu environment with Linuxbrew to simulate macOS behavior.

```bash
# Interactive mode
./test-ubuntu.sh --interactive

# Validation mode
./test-ubuntu.sh --validate

# Background mode
./test-ubuntu.sh
```

### `test-arch.sh` - Arch Linux Environment Testing
Tests the playbooks in a native Arch Linux environment with pacman package manager.

```bash
# Interactive mode
./test-arch.sh --interactive

# Validation mode
./test-arch.sh --validate

# Background mode
./test-arch.sh
```

### `test.sh` - Legacy Testing Script
Maintained for backward compatibility. Runs Ubuntu environment testing.

## Docker Infrastructure

### Containers

#### Ubuntu Container (`ubuntu_dev_test`)
- **Base**: `linuxbrew/brew` (Ubuntu + Linuxbrew)
- **Purpose**: Simulate macOS environment for testing Homebrew tasks
- **User**: `wesbragagt` with sudo privileges
- **Package Manager**: Linuxbrew (Homebrew for Linux)

#### Arch Linux Container (`arch_dev_test`)
- **Base**: `archlinux:latest`
- **Purpose**: Test native Arch Linux environment with pacman
- **User**: `wesbragagt` with sudo privileges
- **Package Manager**: Pacman + AUR support

### Docker Compose Services

```yaml
# Ubuntu-based testing
docker compose up -d ubuntu_test

# Arch Linux testing
docker compose up -d arch_test

# Both platforms
docker compose up -d
```

## Testing Workflow

### 1. Syntax Validation
```bash
ansible-playbook --syntax-check local.yml
```

### 2. Environment Validation
Each container includes validation scripts:
- OS detection verification
- Package manager availability
- Ansible collection installation
- User permissions testing

### 3. Platform-Specific Testing
- **Ubuntu**: Tests Homebrew-based tasks (simulating macOS)
- **Arch Linux**: Tests pacman-based tasks (native Arch Linux)

### 4. Cross-Platform Validation
- Verifies OS detection logic (`ansible_distribution`)
- Confirms package name mappings
- Tests conditional task execution

## Validation Checks

### Pre-Test Validation
- [ ] Ansible syntax check passes
- [ ] Required collections are installed
- [ ] Docker containers build successfully

### Environment Validation
- [ ] OS detection works correctly
- [ ] Package managers are accessible
- [ ] User permissions are properly configured
- [ ] Ansible collections are available

### Post-Test Validation
- [ ] Tasks execute without errors
- [ ] Package installations succeed
- [ ] Cross-platform compatibility confirmed
- [ ] No platform-specific hardcoded paths

## Troubleshooting

### Common Issues

#### Container Build Failures
```bash
# Clean rebuild
docker compose down
docker system prune -f
docker compose up --build -d
```

#### Permission Issues
```bash
# Check user configuration in container
docker compose exec ubuntu_test whoami
docker compose exec arch_test whoami
```

#### Collection Installation
```bash
# Install collections manually
docker compose exec ubuntu_test ansible-galaxy collection install community.general
docker compose exec arch_test ansible-galaxy collection install community.general
```

### Debugging Commands

```bash
# Container logs
docker compose logs ubuntu_test
docker compose logs arch_test

# Interactive debugging
docker compose exec ubuntu_test bash
docker compose exec arch_test bash

# Environment inspection
docker compose exec ubuntu_test ansible localhost -m setup
docker compose exec arch_test ansible localhost -m setup
```

## Adding New Tests

### 1. Create Platform-Specific Tasks
```yaml
- name: Test task (Ubuntu)
  command: some_command
  when: ansible_distribution == "Ubuntu"

- name: Test task (Arch Linux)
  command: some_command
  when: ansible_distribution == "Archlinux"
```

### 2. Add Validation Steps
Add validation commands to the respective test scripts:
- `test-ubuntu.sh` for Ubuntu-specific tests
- `test-arch.sh` for Arch Linux-specific tests

### 3. Update Documentation
Update this document with new test procedures and validation steps.

## Best Practices

1. **Always test both platforms** before merging changes
2. **Use OS detection** (`ansible_distribution`) for platform-specific logic
3. **Validate package availability** before installation
4. **Test in clean environments** using Docker containers
5. **Document platform differences** in task comments
6. **Use proper error handling** for cross-platform compatibility

## Continuous Integration

The testing infrastructure is designed to work with CI/CD pipelines:

```bash
# Non-interactive CI testing
./test-both.sh

# Exit codes:
# 0 - All tests passed
# 1 - Tests failed
```

For CI environments, ensure Docker is available and the testing scripts have execution permissions.