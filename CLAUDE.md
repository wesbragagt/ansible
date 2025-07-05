# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Ansible-based development environment automation tool that sets up macOS and Arch Linux machines with essential development tools and configurations. The project uses Ansible playbooks to install and configure tools like homebrew/pacman, zsh, neovim, nodejs, tmux, and various CLI utilities.

## Key Commands

### Running the Full Setup
```bash
# Complete setup (requires sudo password and vault password)
# Works on both macOS and Arch Linux
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
# Cross-platform testing (both Ubuntu and Arch Linux)
./test-both.sh

# Test specific platforms
./test-ubuntu.sh --validate    # Ubuntu environment (macOS simulation)
./test-arch.sh --validate      # Arch Linux environment

# Interactive testing
./test-ubuntu.sh --interactive
./test-arch.sh --interactive

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
- **docker-compose.yml**: Multi-platform testing environment setup (Ubuntu + Arch Linux)
- **Dockerfile**: Ubuntu-based testing container with Linuxbrew
- **Dockerfile.archlinux**: Arch Linux testing container with pacman
- **requirements.yml**: Ansible collections for cross-platform support
- **scripts/**: Utility scripts for initial setup (homebrew, ansible installation, etc.)

### Key Features

- **Cross-platform support**: Works on both macOS and Arch Linux
- **Automatic OS detection**: Uses `ansible_distribution` for platform-specific tasks
- **Package manager abstraction**: Homebrew (macOS) and Pacman (Arch Linux)
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

### General Notes
- **OS Detection**: Automatically detects platform using `ansible_distribution`
- **Vault passwords**: Required for SSH and dotfiles tasks
- **Dotfiles**: Repository cloned with `--recurse-submodules`
- **Package management**: Homebrew (macOS) or Pacman (Arch Linux)
- **Privilege escalation**: Uses `become: True` with proper user handling
- **Testing**: Multi-platform Docker environment for validation

### Testing Infrastructure

The project includes comprehensive testing infrastructure:

- **test-both.sh**: Cross-platform testing on both Ubuntu and Arch Linux
- **test-ubuntu.sh**: Ubuntu-based testing (simulates macOS with Linuxbrew)
- **test-arch.sh**: Arch Linux testing (true pacman environment)
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