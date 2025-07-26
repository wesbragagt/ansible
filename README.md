# Hybrid Nix + Ansible Development Environment

A development environment automation tool that combines **Nix flakes for cross-platform package management** with **Ansible for system configuration** and **GNU Stow for dotfiles management**. This hybrid approach provides reproducible environments while maintaining developer-friendly mutable configurations.

## Design Philosophy

### Why Hybrid Architecture: Nix + Stow vs Pure Nix

This project uses a **hybrid approach** rather than pure Nix home-manager for a key reason: **developer experience and hot-reload capabilities**.

**Why Nix for Packages:**
- **Immutable & Reproducible**: Packages benefit from declarative, reproducible management
- **Cross-platform Consistency**: Same tool versions across macOS, Linux distributions, and architectures  
- **Dependency Management**: Automatic handling of complex package dependencies
- **Rollback Safety**: Easy to revert to previous working package sets

**Why Stow for Dotfiles (Not Nix home-manager):**
- **Mutability**: Configuration files remain editable in-place for immediate changes
- **Hot Reload**: Tools like neovim, tmux, zsh, starship can reload configs without rebuilding
- **Development Experience**: Instant feedback when tweaking configurations during development
- **Tool Compatibility**: Many development tools expect mutable config files for features like auto-save, session restoration, and plugin management
- **Flexibility**: Easy experimentation with config changes without Nix rebuild cycles

**The Problem with Immutable Dotfiles:**
Nix home-manager creates immutable symlinks to the Nix store, which breaks hot-reload workflows:
- Neovim plugin changes require full rebuild instead of `:source %`
- Tmux config changes require rebuild instead of `prefix + r`
- Shell aliases/functions require rebuild instead of `source ~/.zshrc`
- This creates a cumbersome development experience for configuration iteration

**Our Solution:**
- **Nix**: Manages packages and system-level tools (immutable, reproducible)
- **Stow**: Manages dotfiles (mutable, developer-friendly)  
- **Ansible**: Orchestrates system setup, secrets (vault), and ties everything together

This gives you the best of both worlds: reproducible environments with a smooth development experience.

## Features

- **Hybrid Architecture**: Nix for packages + Stow for dotfiles = reproducible yet developer-friendly
- **Cross-platform support**: Works identically on macOS and all major Linux distributions
- **Multi-architecture**: Supports both x86_64 and aarch64 (ARM) architectures
- **No Platform-Specific Logic**: Nix eliminates need for different package managers per OS
- **Automated SSH Agent**: Home-manager manages SSH agent as systemd user service
- **Hot-Reload Dotfiles**: Mutable configurations allow instant config changes without rebuilds
- **Vault encryption**: Secure handling of SSH keys and sensitive dotfiles via Ansible vault
- **Comprehensive testing**: Nix-specific and legacy multi-platform testing environments

## Installed Tools

### Core CLI Tools
- **Search & Navigation**: fzf, ripgrep (rg), bat, fd, zoxide
- **Network & Archives**: wget, curl, unzip
- **Development**: tmux, jq, git-delta, gh (GitHub CLI), git-lfs, stow
- **Languages**: go, nodejs, python3, fnm (Node version manager), uv (Python package manager)
- **Build Tools**: cmake, ninja, gettext
- **Security**: openssh, sops, age

### Shell Environment  
- **Shell**: zsh with starship prompt
- **Fonts**: Hack and Fira Code Nerd Fonts

### Editors & Development
- **Editor**: neovim
- **SSH**: Automated SSH agent with key management

## Quick Start

### Prerequisites

#### All Platforms
- **Nix with flakes enabled** - Primary requirement for package management
- **Ansible** - For system orchestration and configuration
- **Git** - Required for flake functionality

#### Installation
**macOS:**
```bash
# Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
# Install Ansible  
pip install ansible
```

**Linux (any distribution):**
```bash
# Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
# Install Ansible (use your distribution's package manager)
# Ubuntu/Debian: apt install ansible
# Arch: pacman -S ansible
# Fedora: dnf install ansible
```

### Setup Commands

#### Complete Setup
```bash
# Install required Ansible collections
ansible-galaxy collection install community.general

# Complete setup (installs Nix, sets up packages, configures system, deploys dotfiles)
# Requires sudo password for system changes and vault password for secrets
make all
```

#### Individual Components
```bash
# Install Nix and activate all packages via home-manager
make nix

# ZSH shell configuration (system-level shell change and cleanup)
make zsh

# SSH setup (requires vault password for key deployment)
make ssh

# Git configuration
make git-setup

# Dotfiles deployment via GNU stow (requires vault password)
make dotfiles
```

## Architecture

### Main Components

- **flake.nix**: Nix flake managing all development packages and SSH agent configuration
- **local.yml**: Main Ansible playbook that orchestrates the entire setup
- **tasks/**: Directory containing streamlined task modules:
  - `nix.yml`: Nix installation and home-manager activation (replaces platform-specific package management)
  - `zsh.yml`: System-level ZSH shell configuration and cleanup
  - `ssh.yml`: SSH key management via Ansible vault
  - `git-setup.yml`: Basic Git configuration and host key setup
  - `dotfiles.yml`: Dotfiles deployment using GNU stow

### Configuration Files

- **ansible.cfg**: Ansible configuration with timer and profiling callbacks
- **Makefile**: Convenient command shortcuts with streamlined targets
- **flake.lock**: Nix flake lock file ensuring reproducible package versions
- **requirements.yml**: Ansible collections for cross-platform support

## Testing

### Nix Testing
```bash
# Test Nix flake package installation and availability
./test/test-nix.sh

# Interactive testing in Arch Linux container with Nix  
./test/test-nix.sh interactive

# Build test container only
./test/test-nix.sh build
```

### Legacy Ansible Testing
```bash
# Cross-platform testing (Ubuntu, Arch Linux, Fedora)
./test-both.sh
./test-macos.sh --validate          # macOS simulation (Ubuntu + Linuxbrew)
./test-ubuntu-native.sh --validate  # Ubuntu environment (native apt)
./test-arch.sh --validate           # Arch Linux environment  
./test-fedora.sh --validate         # Fedora environment
```

## Development Notes

### How It Works

1. **Nix Installation**: Ansible installs Nix using Determinate Systems installer
2. **Package Management**: Nix flake provides all development tools consistently across platforms
3. **SSH Agent**: Home-manager automatically configures SSH agent as systemd user service
4. **System Configuration**: Ansible handles system-level changes (shell, git, SSH keys)
5. **Dotfiles**: GNU Stow deploys mutable configuration files from your dotfiles repository

### Key Benefits

- **No Platform-Specific Logic**: Single configuration works everywhere
- **Instant Config Changes**: Edit dotfiles and see changes immediately
- **Reproducible Environments**: Nix ensures consistent tool versions
- **Secure Secrets**: Ansible vault manages SSH keys and sensitive data
- **Developer-Friendly**: Hot-reload capabilities for rapid iteration

### SSH Agent Integration

The setup includes automated SSH agent configuration:
- Nix home-manager creates systemd user service for SSH agent
- Creates socket at `$XDG_RUNTIME_DIR/ssh-agent.socket`
- Your dotfiles can reference this with: `export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"`
- SSH keys automatically added to agent when first used

### Vault Password Management

- SSH keys and sensitive dotfiles are encrypted with Ansible vault
- Use `--ask-vault-pass` flag for tasks requiring vault access
- Store vault password securely in password manager
- For convenience, create `.vault-pass` file (add to `.gitignore`)

## Home-Manager Usage

This project uses Nix home-manager to manage packages and services. Here are useful commands for working with home-manager:

### Package Management
```bash
# Activate home-manager configuration (install/update packages)
nix run .#homeConfigurations.wesbragagt@linux-x86_64.activationPackage

# Check what packages are currently installed
home-manager packages

# Search for available packages
nix search nixpkgs <package-name>

# See what would be installed/updated (dry run)
nix run .#homeConfigurations.wesbragagt@linux-x86_64.activationPackage --dry-run
```

### Configuration Management
```bash
# Edit the home-manager configuration
# Configuration is defined in flake.nix under home-manager.users.wesbragagt

# View current home-manager generation
home-manager generations

# Rollback to previous generation
home-manager rollback

# Remove old generations (cleanup)
home-manager expire-generations "-30 days"
```

### Service Management
```bash
# List all home-manager services
systemctl --user list-units --type=service | grep -E "(home-manager|nix)"

# Check SSH agent service (managed by home-manager)
systemctl --user status ssh-agent

# Restart all home-manager services
systemctl --user restart home-manager-*.service
```

### Development Workflow
```bash
# Enter development shell with all packages available
nix develop

# Test configuration changes before applying
nix flake check

# Update flake inputs (nixpkgs, home-manager, etc.)
nix flake update

# View flake outputs and configuration structure
nix flake show
```

### Useful Paths
- **Configuration**: Defined in `flake.nix` under `home-manager.users.wesbragagt`
- **State directory**: `~/.local/state/nix/profiles/home-manager`
- **Service logs**: `journalctl --user -u home-manager-*.service`

## Troubleshooting

### Nix Issues
```bash
# If nix command not found, source the profile
source ~/.nix-profile/etc/profile.d/nix.sh
# or for multi-user installs:
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Update flake dependencies
nix flake update

# Check flake structure  
nix flake show
```

### SSH Agent Issues
```bash
# Check SSH agent status
systemctl --user status ssh-agent

# Restart SSH agent service
systemctl --user restart ssh-agent

# Check SSH agent socket
ls -la $XDG_RUNTIME_DIR/ssh-agent.socket
```

### Package Issues
```bash
# Search for packages in nixpkgs
nix search nixpkgs <package-name>

# Enter development shell to test packages
nix develop

# Rebuild home-manager configuration
nix run .#homeConfigurations.wesbragagt@linux-x86_64.activationPackage
```