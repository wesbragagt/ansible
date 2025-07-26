# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Documentation

**All comprehensive project documentation is consolidated in [README.md](./README.md)**. Please read the README for complete information about:

- Project overview and design philosophy
- Architecture and components  
- Installation and setup instructions
- Available commands and testing
- Development notes and troubleshooting

## Quick Reference for Claude Code

### Project Type
Hybrid Nix + Ansible development environment automation tool

### Key Architecture Points
- **Nix flakes**: Cross-platform package management (immutable, reproducible)
- **GNU Stow**: Dotfiles management (mutable, hot-reload friendly)
- **Ansible**: System orchestration, secrets management (vault), configuration

### Main Commands
```bash
make all      # Complete setup
make nix      # Install Nix and packages  
make zsh      # ZSH configuration
make ssh      # SSH setup (vault required)
make dotfiles # Deploy dotfiles (vault required)
```

### File Structure
- `flake.nix` - All package definitions and SSH agent config
- `local.yml` - Main Ansible playbook
- `tasks/` - Streamlined Ansible tasks (nix, zsh, ssh, git-setup, dotfiles)
- `test/test-nix.sh` - Nix testing infrastructure

### Testing
```bash
./test/test-nix.sh           # Test Nix packages
./test/test-nix.sh interactive  # Interactive testing
```

### Important Notes
- **No platform-specific package logic** - Nix handles all platforms uniformly
- **Secrets via Ansible vault** - NOT Nix/SOPS
- **Dotfiles via Stow** - NOT Nix home-manager (for hot-reload capability)
- **SSH agent automated** - via Nix home-manager systemd service

Refer to [README.md](./README.md) for complete details on design decisions, setup procedures, and development workflows.