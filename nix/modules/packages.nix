{ pkgs }:

let
  # Core CLI tools that replace basic system utilities
  core-cli-tools = with pkgs; [
    fzf          # Fuzzy finder - replaces basic find
    ripgrep      # Fast grep alternative 
    bat          # Cat with syntax highlighting
    fd           # Fast find alternative
    wget         # Download utility
    curl         # HTTP client
    unzip        # Archive extraction
    jq           # JSON processor
    tmux         # Terminal multiplexer
  ];

  # Development tools and languages
  development-tools = with pkgs; [
    go           # Golang compiler
    gcc          # C compiler for building tools
    gnused       # GNU sed for text processing
    cmake        # Build system
    ninja        # Build system
    gettext      # Internationalization tools
  ];

  # Node.js ecosystem tools
  node-tools = with pkgs; [
    nodejs_22    # Latest Node.js LTS
    npm          # Node package manager
    fnm          # Fast Node Manager - version switcher
    bun          # Fast JavaScript runtime and package manager
  ];

  # Shell and prompt tools
  shell-tools = with pkgs; [
    zsh                    # Z shell
    zsh-autosuggestions   # ZSH plugin for command suggestions
    starship              # Cross-shell prompt
    zoxide                # Smart directory navigation (z/cd replacement)
  ];

  # Git and version control tools  
  git-tools = with pkgs; [
    git          # Version control
    delta        # Syntax-highlighting pager for git (git-delta)
    gh           # GitHub CLI
  ];

  # Text editors and IDE tools
  editor-tools = with pkgs; [
    neovim       # Modern Vim-based editor
    vim          # Fallback editor
  ];

  # System utilities for dotfiles management
  dotfiles-tools = with pkgs; [
    stow         # Symlink manager for dotfiles
    rsync        # File synchronization
  ];

in {
  # Export individual groups
  inherit 
    core-cli-tools
    development-tools  
    node-tools
    shell-tools
    git-tools
    editor-tools
    dotfiles-tools;

  # Combined package lists for different use cases
  all-packages = 
    core-cli-tools ++ 
    development-tools ++ 
    node-tools ++ 
    shell-tools ++ 
    git-tools ++ 
    editor-tools ++
    dotfiles-tools;

  # Essential packages for minimal setup
  essential-packages = 
    core-cli-tools ++ 
    shell-tools ++ 
    git-tools ++ 
    [ pkgs.neovim ];

  # Development-focused packages (excludes GUI tools)
  dev-packages = 
    core-cli-tools ++ 
    development-tools ++ 
    node-tools ++ 
    git-tools ++ 
    editor-tools;
}