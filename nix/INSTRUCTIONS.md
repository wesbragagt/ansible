# NixOS Development Environment Setup Instructions

This directory contains a complete Nix flake that replicates the Ansible development environment for NixOS systems. Follow these instructions to bootstrap your development environment.

## Prerequisites

- NixOS system or Nix package manager installed
- Flakes enabled: `nix.settings.experimental-features = [ "nix-command" "flakes" ]`

## Quick Setup Commands

### 1. Test the Development Environment

```bash
# Test the development shell (temporary)
cd /path/to/this/ansible/repo
nix develop ./nix

# Test specific tools with nix run
nix run ./nix#nvim --help
nix run ./nix#dev
```

### 2. Install with Home Manager (Recommended)

```bash
# If you don't have Home Manager, install it first:
nix run home-manager/master -- init

# Apply this configuration
home-manager switch --flake ./nix

# Or for specific architecture
home-manager switch --flake ./nix#x86_64-linux
home-manager switch --flake ./nix#aarch64-linux
```

### 3. Full NixOS System Integration

Add to your `/etc/nixos/configuration.nix`:

```nix
{
  imports = [
    /path/to/this/ansible/repo/nix/modules/development.nix
  ];
  
  # Your existing configuration...
}
```

Then rebuild:
```bash
sudo nixos-rebuild switch
```

## Step-by-Step NixOS Bootstrap

### Fresh NixOS Installation

1. **Clone your dotfiles repository** (containing this nix flake):
   ```bash
   git clone https://github.com/yourusername/ansible-setup.git ~/setup
   cd ~/setup
   ```

2. **Test the environment**:
   ```bash
   nix develop ./nix
   ```

3. **Apply Home Manager configuration**:
   ```bash
   # Install Home Manager if not present
   nix run home-manager/master -- init
   
   # Apply the development configuration
   home-manager switch --flake ./nix
   ```

4. **Configure your dotfiles** (using stow, which is now available):
   ```bash
   # Clone your actual dotfiles repository
   git clone --recurse-submodules https://github.com/yourusername/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   
   # Use stow to symlink configurations
   stow nvim
   stow zsh  
   stow tmux
   stow starship
   # etc.
   ```

5. **Optional: Add to system configuration**:
   ```bash
   # Edit your system configuration
   sudo nvim /etc/nixos/configuration.nix
   
   # Add the import:
   # imports = [ /home/wes/setup/nix/modules/development.nix ];
   
   # Rebuild system
   sudo nixos-rebuild switch
   ```

6. **Configure git** (customize in the home.nix first):
   ```bash
   # Edit modules/home.nix to set your name and email
   nvim ~/setup/nix/modules/home.nix
   
   # Then reapply
   home-manager switch --flake ~/setup/nix
   ```

## Using `nix run` for Portable Tools

Perfect for using your development tools on any NixOS system:

```bash
# Use your configured Neovim anywhere
nix run github:yourusername/ansible-setup#nvim myfile.js

# Or locally
nix run ./nix#nvim

# Full development environment
nix run ./nix#dev

# Git with delta configuration
nix run ./nix#git status

# Node.js environment
nix run ./nix#node

# Tmux with all tools
nix run ./nix#tmux
```

## Directory Structure

```
nix/
├── flake.nix              # Main flake configuration
├── devShell.nix           # Development shell setup
├── modules/
│   ├── packages.nix       # Package definitions by category
│   ├── home.nix           # Home Manager user configuration
│   └── development.nix    # NixOS system module
├── README.md              # Detailed documentation
└── INSTRUCTIONS.md        # This file
```

## Customization

### 1. Modify Packages
Edit `modules/packages.nix` to add or remove tools:

```nix
# Add new tools to the appropriate category
development-tools = with pkgs; [
  # existing tools...
  your-new-tool
];
```

### 2. Customize Shell Configuration
Edit `modules/home.nix` to modify ZSH, git, or other settings:

```nix
programs.zsh = {
  # your custom zsh configuration
};
```

### 3. System-Level Changes
Edit `modules/development.nix` for system configuration:

```nix
# Add system packages, services, etc.
environment.systemPackages = with pkgs; [
  # your system packages
];
```

## Common Workflows

### Development Session
```bash
# Start development environment
nix develop ./nix

# Or use nix run for specific tools
nix run ./nix#nvim
nix run ./nix#tmux
```

### Update Environment
```bash
# Update flake inputs
nix flake update ./nix

# Reapply configuration
home-manager switch --flake ./nix
```

### Share Configuration
```bash
# Others can use your exact environment
nix run github:yourusername/repo#nvim

# Or clone and use locally
git clone https://github.com/yourusername/repo.git
nix develop ./repo/nix
```

## Troubleshooting

### Flakes Not Enabled
Add to `/etc/nixos/configuration.nix`:
```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

### Home Manager Issues
```bash
# Reset Home Manager
rm -rf ~/.local/state/home-manager
home-manager switch --flake ./nix
```

### Package Not Found
```bash
# Search for packages
nix search nixpkgs package-name

# Check flake
nix flake check ./nix
```

### Permission Issues
```bash
# Fix ownership
sudo chown -R $USER:$USER ~/.nix-profile
sudo chown -R $USER:$USER ~/.local/state/nix
```

## Benefits Over Ansible

- ✅ **Instant access**: `nix run` provides immediate tool access
- ✅ **Reproducible**: Exact same environment every time
- ✅ **Rollback**: Easy to undo changes
- ✅ **Portable**: Use your tools on any NixOS system
- ✅ **Declarative**: Everything in version control
- ✅ **Composable**: Mix and match configurations

## Next Steps

1. Test the development environment
2. Apply Home Manager configuration
3. Set up your dotfiles with stow
4. Customize packages and configurations as needed
5. Use `nix run` to access your tools anywhere

Your development environment is now fully declarative and reproducible!