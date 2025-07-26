{
  description = "Development environment setup for ansible-managed systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    
    darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, darwin, home-manager }:
    let
      # Supported systems
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      
      # Helper function to generate attributes for all systems
      forAllSystems = nixpkgs.lib.genAttrs systems;
      
      # Package configuration for all platforms
      mkPackages = pkgs: with pkgs; [
        # Core CLI tools
        fzf
        ripgrep
        bat
        fd
        wget
        tmux
        jq
        delta
        gh
        zoxide
        go
        git-lfs
        stow
        openssh
        unzip
        
        # Shell environment
        zsh
        starship
        
        # Development tools
        neovim
        nodejs
        fnm
        python3
        uv
        cmake
        ninja
        gettext
        curl
        
        # Secrets management tools (for manual use)
        sops
        age
        
        # Fonts
        nerd-fonts.hack
        nerd-fonts.fira-code
      ];
      
      # Common home-manager configuration
      mkHomeConfiguration = { pkgs, username, homeDirectory, ... }: {
        home.username = username;
        home.homeDirectory = homeDirectory;
        home.stateVersion = "24.05";
        
        home.packages = mkPackages pkgs;
        
        # SSH Agent Service - creates systemd user service automatically
        # This creates the socket at $XDG_RUNTIME_DIR/ssh-agent.socket
        # that your zshrc references with SSH_AUTH_SOCK
        services.ssh-agent.enable = true;
        
        # SSH client configuration
        programs.ssh = {
          enable = true;
          # Automatically add SSH keys to agent when used
          addKeysToAgent = "yes";
        };
        
        # Git configuration
        programs.git = {
          enable = true;
          userName = "wesbragagt";
          userEmail = "wesbragagt@gmail.com";
          extraConfig = {
            core.pager = "delta";
            interactive.diffFilter = "delta --color-only";
            delta = {
              navigate = true;
              line-numbers = true;
              side-by-side = true;
            };
            merge.conflictstyle = "diff3";
            diff.colorMoved = "default";
          };
        };
        
        programs.home-manager.enable = true;
      };
    in
    {
      # Development shells for different systems
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = mkPackages pkgs;
            
            shellHook = ''
              echo "Development environment loaded!"
              echo "Run 'home-manager switch --flake .' to activate home configuration"
            '';
          };
        }
      );
      
      # Home configurations
      homeConfigurations = {
        # Linux x86_64 configuration
        "wesbragagt@linux-x86_64" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [
            (mkHomeConfiguration {
              pkgs = nixpkgs.legacyPackages."x86_64-linux";
              username = "wesbragagt";
              homeDirectory = "/home/wesbragagt";
            })
          ];
        };
        
        # Linux aarch64 configuration
        "wesbragagt@linux-aarch64" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."aarch64-linux";
          modules = [
            (mkHomeConfiguration {
              pkgs = nixpkgs.legacyPackages."aarch64-linux";
              username = "wesbragagt";
              homeDirectory = "/home/wesbragagt";
            })
          ];
        };
        
        # macOS x86_64 configuration
        "wesbragagt@darwin-x86_64" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-darwin";
          modules = [
            (mkHomeConfiguration {
              pkgs = nixpkgs.legacyPackages."x86_64-darwin";
              username = "wesbragagt";
              homeDirectory = "/Users/wesbragagt";
            })
          ];
        };
        
        # macOS aarch64 configuration
        "wesbragagt@darwin-aarch64" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."aarch64-darwin";
          modules = [
            (mkHomeConfiguration {
              pkgs = nixpkgs.legacyPackages."aarch64-darwin";
              username = "wesbragagt";
              homeDirectory = "/Users/wesbragagt";
            })
          ];
        };
      };
      
      # Darwin system configurations (for macOS)
      darwinConfigurations."example-darwin" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          {
            system.stateVersion = 5;
            
            environment.systemPackages = mkPackages nixpkgs.legacyPackages."aarch64-darwin";
            
            # Enable Touch ID for sudo
            security.pam.services.sudo_local.touchIdAuth = true;
            
            # Homebrew management (for GUI apps)
            homebrew = {
              enable = true;
              casks = [
                "1password"
                "firefox"
                "slack"
                "discord"
              ];
            };
            
            users.users.wesbragagt = {
              name = "wesbragagt";
              home = "/Users/wesbragagt";
            };
          }
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.wesbragagt = mkHomeConfiguration {
              pkgs = nixpkgs.legacyPackages."aarch64-darwin";
              username = "wesbragagt";
              homeDirectory = "/Users/wesbragagt";
            };
          }
        ];
      };
    };
}