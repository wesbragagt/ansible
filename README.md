# My Development Environment: The Best of All Worlds

Let me tell you about my development setup that's been a game-changer for my productivity. I've combined **Nix flakes** for rock-solid package management, **Ansible** for system orchestration, and **GNU Stow** for dotfiles that actually let me iterate quickly. 

This isn't just another "here's my dotfiles" repo—it's a hybrid approach that gives me reproducible environments without sacrificing the developer experience I actually want.

## Design Philosophy

### Why I Don't Use Pure Nix (And You Probably Shouldn't Either)

Here's the thing about pure Nix home-manager: it's theoretically perfect and practically frustrating. I tried it, lived with it for months, and finally admitted what every developer knows deep down—sometimes you just want to edit a config file and see the change immediately.

**Nix handles my packages because:**
- I get the exact same `ripgrep` version on my MacBook and my Linux servers
- Dependencies just work (no more "works on my machine" nonsense)
- I can rollback when that new Node version breaks everything
- Zero platform-specific package management headaches

**Stow handles my dotfiles because I actually develop:**
- When I tweak my Neovim config, I want to `:source %` and see it work
- My tmux settings should reload with `prefix + r`, not a full system rebuild
- Shell aliases need to be testable with a quick `source ~/.zshrc`
- I experiment with configs constantly—rebuild cycles kill creativity

**The immutable dotfiles trap:**
Nix home-manager sounds great until you're waiting for a rebuild every time you want to test a one-line config change. That's not development—that's bureaucracy.

**My solution is embarrassingly simple:**
- **Nix**: Handles packages (the stuff that should be immutable)
- **Stow**: Handles dotfiles (the stuff I actually edit)
- **Ansible**: Ties it all together and manages my secrets

Result? I get reproducible environments that don't fight me when I'm trying to work.

## What This Gets You

- **Actually works everywhere**: Same setup on my MacBook, Linux desktop, and every server I touch
- **No more platform hell**: One config file, not separate scripts for apt/brew/pacman/dnf
- **ARM support**: Because M1 Macs exist and Linux ARM servers are getting popular
- **SSH that just works**: Automated agent setup, no more ssh-add dance every reboot
- **Instant config iteration**: Edit, reload, test—the way development should be
- **Secure secrets**: Ansible vault keeps my SSH keys encrypted, not sitting in plain text
- **Real testing**: Docker containers that verify everything actually works

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

## Getting Started (It's Pretty Simple)

### What You Need First

Three things, and you probably already have one of them:
- **Nix with flakes** - The magic that makes this work everywhere
- **Ansible** - Handles the orchestration
- **Git** - Because this is 2024

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

### The Magic Commands

#### Full Setup (The "Just Make It Work" Option)
```bash
# Get the Ansible bits we need
ansible-galaxy collection install community.general

# Do everything at once
# (You'll need your sudo password and vault password)
make all
```

That's it. Seriously. Go grab coffee while it sets up your entire development environment.

#### Or Go Step by Step (If You're Cautious Like That)
```bash
# Just the Nix packages
make nix

# Shell setup (makes zsh your default)
make zsh

# SSH keys and configuration
make ssh

# Basic git setup
make git-setup

# Deploy your actual dotfiles
make dotfiles

# Test that everything works
make test
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

```bash
# Test Nix flake package installation and availability
./test/test-nix.sh

# Interactive testing in Arch Linux container with Nix  
./test/test-nix.sh interactive

# Build test container only
./test/test-nix.sh build

# Or use the Makefile shortcut
make test
```

## Development Notes

### Behind the Scenes

1. **Nix gets installed** via the Determinate Systems installer (it's the good one)
2. **My flake activates** and suddenly you have all my development tools
3. **SSH agent starts working** automatically (no more manual ssh-add)
4. **System gets configured** with sane defaults for git, shell, etc.
5. **Your dotfiles deploy** and everything Just Works™

### Why This Approach Wins

- **Write once, run anywhere**: No more separate configs for every OS
- **Development at the speed of thought**: Edit configs, see results instantly
- **Reproducible but not rigid**: Consistency where it matters, flexibility where you need it
- **Security that doesn't suck**: Encrypted secrets that don't get in your way
- **Built for people who actually code**: Hot-reload everything, rebuild nothing

### SSH Agent Integration

My setup includes automated SSH agent configuration:
- Nix home-manager creates systemd user service for SSH agent
- Creates socket at `$XDG_RUNTIME_DIR/ssh-agent.socket`
- My dotfiles can reference this with: `export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"`
- SSH keys automatically added to agent when first used

### Vault Password Management

- SSH keys and sensitive dotfiles are encrypted with Ansible vault
- Use `--ask-vault-pass` flag for tasks requiring vault access
- Store vault password securely in password manager
- For convenience, create `.vault-pass` file (add to `.gitignore`)

## Working with Home-Manager

Since this setup uses Nix home-manager for package management, here's what you need to know:

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

### When You Want to Hack on the Config
```bash
# Drop into a shell with everything available
nix develop

# Check if your changes are valid before applying
nix flake check

# Update to latest packages
nix flake update

# See what this flake actually provides
nix flake show
```

### Useful Paths
- **My Configuration**: Defined in `flake.nix` under `home-manager.users.wesbragagt`
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
