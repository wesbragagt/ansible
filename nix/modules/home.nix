{ config, pkgs, devPackages ? null, ... }:

let
  # Use provided devPackages or fallback to importing packages.nix
  packages = if devPackages != null 
    then devPackages 
    else import ./packages.nix { inherit pkgs; };
in
{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "wes";
  home.homeDirectory = "/home/wes";
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Install development packages
  home.packages = packages.all-packages;

  # ZSH configuration - replicates Ansible zsh.yml
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    # ZSH configuration that matches Ansible setup
    initExtra = ''
      # Load starship prompt
      eval "$(starship init zsh)"
      
      # Load zoxide for smart directory navigation
      eval "$(zoxide init zsh)"
      
      # FZF configuration
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh
      
      # FZF-tab plugin (similar to Ansible setup)
      if [[ -d ~/.zsh/fzf-tab ]]; then
        source ~/.zsh/fzf-tab/fzf-tab.plugin.zsh
      fi
      
      # ZSH autosuggestions (handled by programs.zsh.autosuggestion.enable above)
      
      # Environment variables
      export EDITOR=nvim
      export PAGER="bat --style=plain"
      export MANPAGER="sh -c 'col -bx | bat -l man -p'"
      
      # FZF settings with bat preview
      export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_DEFAULT_OPTS='--preview "bat --color=always --style=header,grid --line-range :300 {}"'
      
      # Node.js setup (replicates Ansible node.yml)
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"
      mkdir -p "$NPM_CONFIG_PREFIX" 2>/dev/null
      
      # fnm setup for Node.js version management
      eval "$(fnm env --use-on-cd)"
    '';

    # Shell aliases that match development workflow
    shellAliases = {
      # Enhanced ls
      ls = "ls --color=auto";
      ll = "ls -la";
      la = "ls -A";
      l = "ls -CF";
      
      # Use bat instead of cat  
      cat = "bat";
      
      # Git shortcuts
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph --decorate";
      gd = "git diff";
      
      # Directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "cd.." = "cd ..";
      
      # Quick editors
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
      
      # Development servers
      serve = "python3 -m http.server 8000";
      httpserver = "python3 -m http.server";
      
      # Nix shortcuts
      ndev = "nix develop";
      nshell = "nix-shell";
      nupdate = "nix flake update";
      
      # System shortcuts
      h = "history";
      j = "jobs -l";
      
      # File operations with modern tools
      grep = "rg";
      find = "fd";
    };

    # Oh-my-zsh plugins equivalent
    oh-my-zsh = {
      enable = false; # We handle plugins manually to match Ansible approach
    };
  };

  # Git configuration - replicates Ansible git-setup.yml and core.yml delta config
  programs.git = {
    enable = true;
    userName = "Wes Braga";  # Customize this
    userEmail = "wes@example.com";  # Customize this
    
    extraConfig = {
      # Delta configuration (from Ansible core.yml)
      core = {
        pager = "delta";
      };
      
      interactive = {
        diffFilter = "delta --color-only";
      };
      
      delta = {
        navigate = true;
        line-numbers = true;
        side-by-side = true;
      };
      
      merge = {
        conflictstyle = "diff3";
      };
      
      diff = {
        colorMoved = "default";
      };
      
      # Additional git configuration
      init = {
        defaultBranch = "main";
      };
      
      push = {
        default = "simple";
      };
      
      pull = {
        rebase = true;
      };
    };
  };

  # Starship prompt configuration
  programs.starship = {
    enable = true;
    settings = {
      format = "$all$character";
      
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      
      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = "🌱 ";
      };
      
      nodejs = {
        format = "[$symbol($version )]($style)";
        symbol = "⬢ ";
      };
      
      python = {
        format = "[$symbol$pyenv_prefix($version )]($style)";
        symbol = "🐍 ";
      };
      
      rust = {
        format = "[$symbol($version )]($style)";
        symbol = "🦀 ";
      };
      
      golang = {
        format = "[$symbol($version )]($style)";
        symbol = "🐹 ";
      };
    };
  };

  # Neovim configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    
    extraConfig = ''
      # Enable mouse support
      set -g mouse on
      
      # Start windows and panes at 1, not 0
      set -g base-index 1
      setw -g pane-base-index 1
      
      # Renumber windows when one is closed
      set -g renumber-windows on
      
      # Enable activity alerts
      setw -g monitor-activity on
      set -g visual-activity on
      
      # Increase scrollback buffer size
      set -g history-limit 10000
      
      # Enable focus events
      set -g focus-events on
    '';
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "kitty";
    PAGER = "bat --style=plain";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  };

  # XDG directories
  xdg.enable = true;

  # User directories
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
