{ pkgs, packages }:

pkgs.mkShell {
  name = "dev-environment";
  
  packages = packages.all-packages;

  shellHook = ''
    echo "🚀 Development Environment Loaded"
    echo "📦 Available tools:"
    echo "  • CLI: fzf, ripgrep, bat, fd, jq, tmux"  
    echo "  • Dev: go, nodejs, npm, fnm, bun"
    echo "  • Git: git, delta, gh"
    echo "  • Shell: zsh, starship, zoxide"
    echo "  • Editor: neovim"
    echo ""
    echo "💡 Quick start:"
    echo "  • Run 'zsh' to switch to zsh shell"
    echo "  • Run 'starship init zsh' to enable starship prompt"
    echo "  • Use 'z <dir>' for smart directory navigation"
    echo "  • Use 'fzf' for fuzzy file finding"
    echo ""
    
    # Set up environment variables
    export EDITOR=nvim
    export PAGER="bat --style=plain"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    
    # Enhanced ls using bat for previews in fzf
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_DEFAULT_OPTS='--preview "bat --color=always --style=header,grid --line-range :300 {}"'
    
    # Node.js setup
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"
    
    # Create npm global directory if it doesn't exist
    mkdir -p "$NPM_CONFIG_PREFIX"
  '';

  # Shell aliases that replicate Ansible setup behavior
  shellAliases = {
    # Enhanced ls with colors and icons
    ls = "ls --color=auto";
    ll = "ls -la";
    la = "ls -la";
    
    # Use bat instead of cat
    cat = "bat";
    
    # Git shortcuts with delta
    git-log = "git log --oneline --graph --decorate --all";
    
    # Directory navigation
    ".." = "cd ..";
    "..." = "cd ../..";
    
    # Common development commands
    serve = "python3 -m http.server 8000";
    
    # Package manager shortcuts
    ndev = "nix develop";
    nshell = "nix-shell";
    
    # Quick neovim
    v = "nvim";
    vi = "nvim";
    vim = "nvim";
  };
}