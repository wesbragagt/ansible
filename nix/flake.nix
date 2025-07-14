{
  description = "Development environment flake - replicates Ansible setup for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      
      # Generate package sets for each system
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      
      # Package definitions
      mkPackages = system: 
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./modules/packages.nix { inherit pkgs; };
        
      # Generate NixOS configurations for each supported system
      mkNixosConfiguration = system: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules/development.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.wes = import ./modules/home.nix;
            home-manager.extraSpecialArgs = { 
              devPackages = mkPackages system; 
            };
          }
        ];
      };
    in
    {
      # NixOS configurations for different architectures
      nixosConfigurations = {
        default = mkNixosConfiguration "x86_64-linux";
        x86_64-linux = mkNixosConfiguration "x86_64-linux";
        aarch64-linux = mkNixosConfiguration "aarch64-linux";
      };

      # Home Manager configurations (standalone)
      homeConfigurations = forAllSystems (system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [ 
            ./modules/home.nix 
            {
              home.username = "wes";
              home.homeDirectory = "/home/wes";
            }
          ];
          extraSpecialArgs = { 
            devPackages = mkPackages system; 
          };
        }
      );

    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        devPackages = mkPackages system;
      in {
        # Development shells
        devShells = {
          default = import ./devShell.nix { 
            inherit pkgs; 
            packages = devPackages; 
          };
          
          # Alternative shell with fewer packages for lighter usage
          minimal = pkgs.mkShell {
            packages = with devPackages; [
              core-cli-tools
              git-tools  
              shell-tools
            ];
          };
        };

        # Packages for standalone installation
        packages = {
          default = pkgs.buildEnv {
            name = "dev-environment";
            paths = builtins.attrValues devPackages;
          };
          
          # Individual package groups
          inherit (devPackages) 
            core-cli-tools
            development-tools
            node-tools
            shell-tools
            git-tools;
        };

        # Apps for easy CLI access via 'nix run'
        apps = {
          default = flake-utils.lib.mkApp {
            drv = self.packages.${system}.default;
          };
          
          # Run Neovim with full development environment
          nvim = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "dev-nvim" ''
              export EDITOR=nvim
              export PATH=${pkgs.lib.makeBinPath devPackages.all-packages}:$PATH
              exec ${pkgs.neovim}/bin/nvim "$@"
            '';
          };
          
          # Run development shell with all tools
          dev = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "dev-shell" ''
              export PATH=${pkgs.lib.makeBinPath devPackages.all-packages}:$PATH
              export EDITOR=nvim
              export PAGER="bat --style=plain"
              export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
              export FZF_DEFAULT_OPTS='--preview "bat --color=always --style=header,grid --line-range :300 {}"'
              
              echo "🚀 Development Environment Active"
              echo "💻 Available: nvim, git, node, go, fzf, ripgrep, bat, tmux, and more"
              
              exec ${pkgs.zsh}/bin/zsh
            '';
          };
          
          # Quick git with delta
          git = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "dev-git" ''
              export PATH=${pkgs.lib.makeBinPath devPackages.git-tools}:$PATH
              export GIT_PAGER="delta"
              exec ${pkgs.git}/bin/git "$@"
            '';
          };
          
          # Node.js development environment
          node = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "dev-node" ''
              export PATH=${pkgs.lib.makeBinPath devPackages.node-tools}:$PATH
              export NPM_CONFIG_PREFIX="$HOME/.npm-global"
              mkdir -p "$NPM_CONFIG_PREFIX"
              
              echo "📦 Node.js Development Environment"
              echo "🟢 Node: $(${pkgs.nodejs_22}/bin/node --version)"
              echo "📋 npm: $(${pkgs.npm}/bin/npm --version)"
              echo "⚡ Available: fnm, bun"
              
              exec ${pkgs.zsh}/bin/zsh
            '';
          };
          
          # Tmux with development environment
          tmux = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "dev-tmux" ''
              export PATH=${pkgs.lib.makeBinPath devPackages.all-packages}:$PATH
              export EDITOR=nvim
              exec ${pkgs.tmux}/bin/tmux "$@"
            '';
          };
        };
      }
    );
}