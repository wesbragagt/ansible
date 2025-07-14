# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Ansible-based development environment automation tool that sets up macOS, Ubuntu, Linux Mint, Arch Linux, and Fedora machines with essential development tools and configurations. The project uses Ansible playbooks to install and configure tools like homebrew/apt/pacman/dnf, zsh, neovim, nodejs, tmux, and various CLI utilities.

## Key Commands

### Running the Full Setup
```bash
# Complete setup (requires sudo password and vault password)
# Works on macOS, Ubuntu, Linux Mint, Arch Linux, and Fedora
make all
# or
ansible-playbook local.yml --ask-become-pass --ask-vault-pass
```

### Running Individual Components
```bash
# Core development tools (fzf, ripgrep, bat, fd, tmux, etc.)
make core

# ZSH configuration
make zsh

# Node.js and npm/yarn
make node

# SSH setup (requires vault password)
make ssh

# Git configuration
make git-setup

# Dotfiles deployment (requires vault password)
make dotfiles

# Neovim setup
make neovim

# Font installation
make fonts
```

### Testing
```bash
# Cross-platform testing (Ubuntu, Arch Linux, and Fedora)
./test-both.sh

# Test specific platforms
./test-macos.sh --validate          # macOS simulation (Ubuntu + Linuxbrew)
./test-ubuntu-native.sh --validate  # Ubuntu environment (native apt)
./test-arch.sh --validate           # Arch Linux environment
./test-fedora.sh --validate         # Fedora environment

# Interactive testing
./test-macos.sh --interactive          # macOS simulation environment
./test-ubuntu-native.sh --interactive  # Ubuntu native environment
./test-arch.sh --interactive           # Arch Linux environment
./test-fedora.sh --interactive         # Fedora environment

# Legacy testing (Ubuntu only)
make test
# or
./test.sh
```

## Architecture

### Main Components

- **local.yml**: Main Ansible playbook that orchestrates the entire setup
- **tasks/**: Directory containing individual task modules:
  - `core.yml`: Core CLI tools (fzf, ripgrep, bat, fd, tmux, jq, git-delta, gh, zoxide, golang)
  - `zsh.yml`: ZSH shell configuration
  - `node.yml`: Node.js ecosystem setup
  - `ssh.yml`: SSH key management
  - `git-setup.yml`: Git configuration
  - `dotfiles.yml`: Dotfiles deployment using GNU stow
  - `neovim.yml`: Neovim editor setup
  - `fonts.yml`: Font installation

### Configuration Files

- **ansible.cfg**: Ansible configuration with timer and profiling callbacks
- **Makefile**: Convenient command shortcuts with consistent flags
- **docker-compose.yml**: Multi-platform testing environment setup (Ubuntu + Arch Linux + Fedora)
- **Dockerfile**: Ubuntu-based testing container with Linuxbrew (macOS simulation)
- **Dockerfile.ubuntu**: Ubuntu testing container with native apt
- **Dockerfile.archlinux**: Arch Linux testing container with pacman
- **Dockerfile.fedora**: Fedora testing container with DNF
- **requirements.yml**: Ansible collections for cross-platform support
- **scripts/**: Utility scripts for initial setup (homebrew, ansible installation, etc.)

### Key Features

- **Cross-platform support**: Works on macOS, Ubuntu, Linux Mint, Arch Linux, and Fedora
- **Automatic OS detection**: Uses `ansible_distribution` for platform-specific tasks
- **Package manager abstraction**: Homebrew (macOS), APT (Ubuntu/Linux Mint), Pacman (Arch Linux), and DNF (Fedora)
- **GNU stow integration**: Dotfiles management across platforms
- **Comprehensive testing**: Multi-platform Docker testing environment
- **Vault encryption**: Secure handling of SSH keys and sensitive dotfiles
- **Development tools**: Consistent tooling across platforms (fzf, ripgrep, bat, etc.)
- **Git enhancement**: git-delta for improved diff viewing

## Development Notes

### Prerequisites

#### macOS
- Homebrew installed or will be installed automatically
- Ansible installed via `pip install ansible`
- Required collections: `ansible-galaxy collection install community.general`

#### Arch Linux
- Pacman package manager (default)
- Ansible installed via `pacman -S ansible`
- Required collections: `ansible-galaxy collection install community.general`

#### Ubuntu/Linux Mint
- APT package manager (default)
- Ansible installed via `apt install ansible`
- Required collections: `ansible-galaxy collection install community.general`

#### Fedora
- DNF package manager (default)
- Ansible installed via `dnf install ansible`
- Required collections: `ansible-galaxy collection install community.general`

### General Notes
- **OS Detection**: Automatically detects platform using `ansible_distribution`
- **Vault passwords**: Required for SSH and dotfiles tasks
- **Dotfiles**: Repository cloned with `--recurse-submodules`
- **Package management**: Homebrew (macOS), APT (Ubuntu/Linux Mint), Pacman (Arch Linux), or DNF (Fedora)
- **Privilege escalation**: Uses `become: True` with proper user handling
- **Testing**: Multi-platform Docker environment for validation

### Testing Infrastructure

The project includes comprehensive testing infrastructure:

- **test-both.sh**: Cross-platform testing on Ubuntu, Arch Linux, and Fedora
- **test-macos.sh**: macOS simulation testing (Ubuntu + Linuxbrew)
- **test-ubuntu-native.sh**: Ubuntu native testing (true apt environment)
- **test-arch.sh**: Arch Linux testing (true pacman environment)
- **test-fedora.sh**: Fedora testing (true DNF environment)
- **Docker environments**: Separate containers for each platform
- **Automated validation**: Syntax checking and environment verification
- Cross-platform package management with OS detection via `ansible_distribution`

### Vault Password Management
- When running playbooks that require vault encryption, use the `--ask-vault-pass` flag
- Store vault password in a secure password manager or vault file
- Recommended to use a vault password file for convenience in local development
  - Create a vault password file (e.g., `.vault-pass`) and add it to `.gitignore`
  - Use the file with: `ansible-playbook local.yml --vault-password-file .vault-pass`
- Never commit vault password files to version control
- Rotate vault passwords periodically for enhanced security

## Static Checks

### Recommended Static Analysis Commands
- Run Ansible linter: `ansible-lint local.yml`
- Validate YAML syntax: `yamllint .`
- Check Ansible playbook syntax: `ansible-playbook --syntax-check local.yml`
- Perform dry-run for validation: `ansible-playbook local.yml --check`

## Validation Steps for Supporting a New OS

When adding support for a new operating system to this Ansible automation project, follow these validation steps:

- **Dependency Mapping**:
  - Identify package manager for the new OS (e.g., apt, yum, zypper)
  - Map equivalent packages across different package managers
  - Create conditional tasks using `ansible_distribution` variable

- **Package Installation Validation**:
  - Test package installation using the native package manager
  - Verify package dependencies and conflicts
  - Create fallback mechanisms for packages not available in default repositories

- **Environment Configuration**:
  - Test shell configuration (zsh, bash) compatibility
  - Validate path and environment variable settings
  - Ensure cross-shell script compatibility

- **Toolchain Compatibility**:
  - Test core development tools (git, nodejs, python, etc.)
  - Verify version management and installation methods
  - Check for platform-specific compilation requirements

- **Docker Testing**:
  - Create a Dockerfile for the new OS
  - Set up a testing container with necessary build tools
  - Integrate the new OS into the `test-both.sh` script

- **Continuous Integration**:
  - Update GitHub Actions or CI/CD pipeline to include the new OS
  - Create matrix builds that include the new platform
  - Set up automated testing for the new environment

- **Documentation**:
  - Update README with new OS-specific installation instructions
  - Document any unique configuration or setup requirements
  - Add troubleshooting notes for the new platform

## Memory

- Update documentation