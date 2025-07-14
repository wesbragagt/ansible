# NixOS Development Environment

This flake replicates the Ansible development environment setup for NixOS systems, providing a declarative and reproducible development environment with all your preferred tools and configurations.

## Features

✅ **Cross-architecture support**: Works on both `x86_64-linux` and `aarch64-linux`  
✅ **Complete tool replication**: All tools from the Ansible setup (fzf, ripgrep, bat, fd, tmux, neovim, etc.)  
✅ **Shell configuration**: ZSH with starship prompt, autosuggestions, and fzf integration  
✅ **Git configuration**: Delta syntax highlighting, proper diff settings  
✅ **Node.js ecosystem**: Latest Node.js, npm, fnm, and bun  
✅ **Development tools**: Go, build tools, and everything needed for development  
✅ **Dotfiles integration**: Stow and rsync for dotfiles management  
✅ **Multiple usage patterns**: Development shell, Home Manager, NixOS modules, and `nix run` apps

## Quick Start

### 1. Development Shell (Temporary)
Get an instant development environment without installing anything permanently:

```bash
# Enter development shell with all tools
nix develop github:yourusername/yourrepo#nix

# Or locally
cd /path/to/this/repo
nix develop ./nix
```

### 2. Run Specific Tools with `nix run`

Perfect for using your configured Neovim and tools anywhere:

```bash
# Run Neovim with full development environment
nix run ./nix#nvim

# Run development shell 
nix run ./nix#dev

# Run git with delta configured
nix run ./nix#git status

# Run Node.js development environment
nix run ./nix#node

# Run tmux with development tools
nix run ./nix#tmux
```

### 3. Home Manager Integration (User-level)

Install and configure all tools for your user account:

```bash
# Add to your existing Home Manager configuration
home-manager switch --flake ./nix#x86_64-linux

# Or standalone
nix run home-manager/master -- switch --flake ./nix
```

### 4. Full NixOS Integration (System-level)

Bootstrap a complete NixOS system with this environment:

```bash
# Add to /etc/nixos/configuration.nix:
# imports = [ /path/to/this/nix/modules/development.nix ];

# Then rebuild
sudo nixos-rebuild switch --flake ./nix
```

## Available Tools

### Core CLI Tools
- **fzf** - Fuzzy finder with bat preview
- **ripgrep** - Fast grep alternative  
- **bat** - Cat with syntax highlighting
- **fd** - Fast find alternative
- **tmux** - Terminal multiplexer
- **jq** - JSON processor
- **zoxide** - Smart directory navigation

### Development Tools  
- **go** - Golang compiler
- **nodejs** - Latest Node.js LTS
- **npm** - Node package manager
- **fnm** - Fast Node Manager
- **bun** - Fast JavaScript runtime
- **neovim** - Modern Vim-based editor

### Git & Version Control
- **git** - With delta syntax highlighting
- **delta** - Git diff pager
- **gh** - GitHub CLI

### Shell & Prompt
- **zsh** - Z shell with plugins
- **starship** - Cross-shell prompt
- **autosuggestions** - Command suggestions

## Configuration Details

### Shell Configuration
The setup provides a fully configured ZSH environment with:
- Starship prompt for beautiful shell prompts
- ZSH autosuggestions for command completion
- FZF integration with bat preview
- Zoxide for smart directory navigation
- Custom aliases matching development workflow

### Git Configuration  
Includes the same delta configuration as the Ansible setup:
- Delta as the default pager
- Side-by-side diffs with line numbers
- Enhanced merge conflict style
- Color-moved diff detection

### Environment Variables
Pre-configured environment variables:
- `EDITOR=nvim`
- `PAGER=bat --style=plain` 
- `MANPAGER` using bat for colored man pages
- FZF settings with file preview
- Node.js npm global directory setup

## Usage Examples

### Development Workflow
```bash
# Quick development session
nix develop ./nix

# Use preferred neovim anywhere
nix run ./nix#nvim myfile.js

# Development shell with tools
nix run ./nix#dev

# Git with beautiful diffs
nix run ./nix#git log --oneline --graph
```

### Project Setup
```bash
# In any project directory
echo "use flake /path/to/this/nix" > .envrc
direnv allow  # If using direnv

# Or directly
nix develop /path/to/this/nix
```

### System Bootstrap
For a fresh NixOS installation:

1. **Clone your dotfiles** (with this nix flake)
2. **Apply NixOS configuration**:
   ```bash
   sudo nixos-rebuild switch --flake ./nix#x86_64-linux
   ```
3. **Apply Home Manager**:
   ```bash
   home-manager switch --flake ./nix
   ```
4. **Use stow for dotfiles**:
   ```bash
   cd ~/.dotfiles
   stow nvim zsh tmux  # etc.
   ```

## Architecture Support

The flake supports both:
- **x86_64-linux** (Intel/AMD 64-bit)
- **aarch64-linux** (ARM 64-bit)

All packages are available on both architectures through nixpkgs.

## Customization

### Adding Tools
Edit `modules/packages.nix` to add new tools:

```nix
development-tools = with pkgs; [
  # existing tools...
  your-new-tool
];
```

### Modifying Shell Config
Edit `modules/home.nix` to customize ZSH, git, or other configurations.

### System Settings
Edit `modules/development.nix` for system-level changes.

## Comparison with Ansible Setup

This Nix flake provides the same functionality as the Ansible playbooks:

| Ansible Task | Nix Equivalent | Location |
|--------------|----------------|----------|
| `core.yml` | `core-cli-tools` | `modules/packages.nix` |
| `zsh.yml` | `programs.zsh` | `modules/home.nix` |
| `node.yml` | `node-tools` | `modules/packages.nix` |
| `git-setup.yml` | `programs.git` | `modules/home.nix` |
| `dotfiles.yml` | `stow` + Home Manager | User workflow |
| `neovim.yml` | `programs.neovim` | `modules/home.nix` |

## Benefits over Ansible

- ✅ **Declarative**: Entire environment in version-controlled expressions
- ✅ **Reproducible**: Identical environments across machines  
- ✅ **Atomic**: Rollback capability for environment changes
- ✅ **Composable**: Mix and match components
- ✅ **No external dependencies**: Pure Nix solution
- ✅ **Instant access**: `nix run` for immediate tool access
- ✅ **Multiple patterns**: Shell, Home Manager, NixOS modules

## Troubleshooting

### Missing Tools
If a tool is missing, check if it's available in nixpkgs:
```bash
nix search nixpkgs your-tool-name
```

### Permission Issues
For Home Manager, ensure you have write access to `~/.nix-profile`.

### Cache Issues
Clear the Nix store cache:
```bash
nix-collect-garbage -d
```

## Contributing

To extend this environment:
1. Fork and modify the flake
2. Test with `nix flake check`
3. Submit improvements

## License

This configuration is provided as-is for development use.
