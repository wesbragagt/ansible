# Nix Flake Development Environment

This Nix flake provides all the development dependencies previously managed by Ansible, with added SOPS support for secrets management.

## Features

- Cross-platform support (macOS Darwin and Linux)
- Multi-architecture support (x86_64 and aarch64)
- All development tools from the Ansible setup
- SOPS integration for secure SSH key management
- Home-manager for user-specific configurations

## Quick Start

### 1. Install Nix

If you don't have Nix installed:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. Set up SOPS (for secrets management)

Run the setup script to generate age keys and encrypt the test secret:

```bash
./setup-sops.sh
```

This will:
- Generate an age key at `~/.config/sops/age/keys.txt`
- Update `.sops.yaml` with your public key
- Encrypt the test secret file

### 3. Use the development environment

#### Option A: Development Shell (temporary)

```bash
nix develop
```

This gives you a shell with all tools available.

#### Option B: Home Manager (persistent)

For Linux x86_64:
```bash
home-manager switch --flake .#wesbragagt@linux-x86_64
```

For Linux aarch64:
```bash
home-manager switch --flake .#wesbragagt@linux-aarch64
```

For macOS x86_64 (Intel):
```bash
home-manager switch --flake .#wesbragagt@darwin-x86_64
```

For macOS aarch64 (Apple Silicon):
```bash
home-manager switch --flake .#wesbragagt@darwin-aarch64
# Or for full system configuration:
darwin-rebuild switch --flake .#example-darwin
```

## Installed Packages

### Core CLI Tools
- fzf, ripgrep, bat, fd, wget, tmux, jq
- git-delta, gh, zoxide, golang, git-lfs
- stow (for dotfiles management)
- sops, age (for secrets management)

### Development Tools
- neovim, nodejs, npm, fnm
- python3, uv
- cmake, ninja, gettext, curl

### Shell Environment
- zsh, starship prompt
- Hack and Fira Code Nerd Fonts

## Testing

Run the Docker-based test suite:

```bash
# Run all tests
./test/test-nix.sh

# Build container only
./test/test-nix.sh build

# Interactive shell in test container
./test/test-nix.sh interactive
```

## SOPS Usage

### Encrypting a new secret

1. Add your secret to a YAML file:
```yaml
my_secret: "secret value"
```

2. Encrypt it:
```bash
sops -e -i secrets/my-secret.yaml
```

### Adding SSH keys

1. Create your SSH key YAML:
```yaml
ssh_private_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  [your key here]
  -----END OPENSSH PRIVATE KEY-----
```

2. Encrypt and configure in flake.nix:
```nix
sops.secrets.ssh_private_key = {
  path = "${homeDirectory}/.ssh/id_rsa";
  mode = "0600";
};
```

## Customization

Edit `flake.nix` to:
- Add/remove packages
- Change user configuration
- Add more SOPS secrets
- Modify git settings

## Troubleshooting

### Nix command not found
Make sure to restart your shell or source the Nix profile:
```bash
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

### SOPS decryption fails
Ensure your age key exists at `~/.config/sops/age/keys.txt`

### Package not available
Check that the package name in nixpkgs matches what you expect:
```bash
nix search nixpkgs <package-name>
```