{
  description = "Darwin configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:nix-darwin/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, home-manager, darwin, nixpkgs }:
    let
      configuration = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [];

	      homebrew = {
	        enable = true;

	        taps = [];

	        brews = [
            "direnv"
	          "pkg-config"
	        ];

	        casks = [
            "1password"
      	    "brainfm"
            "claude"
            "discord"
	          "firefox"
            "font-fira-code-nerd-font"
	          "ghostty"
            "git-credential-manager"
            "localsend"
 	          "notion"
	          "obsidian"
	          "signal"
            "slack"
	          "syncthing-app"
            "tailscale-app"
	          "ticktick"
            "vlc"
	         "vscodium"
	         "zoom"
	        ];
	      };

	      security.pam.services.sudo_local.touchIdAuth = true;

	      system.configurationRevision = self.rev or self.dirtyRev or null;

	      system.stateVersion = 6;

	      nixpkgs.hostPlatform = "aarch64-darwin";
	      nixpkgs.config.allowUnfree = true;

      	system.primaryUser = "seth";
	
      	nix.settings.experimental-features = "nix-command flakes";

      	users.users.seth = {
	        name = "seth";
	        home = "/Users/seth";
	      };

	      home-manager.users.seth = { pkgs, ... }: {
	        home.username = "seth";
	        home.homeDirectory = "/Users/seth";
	
	        home.packages = with pkgs; [
 	          ast-grep
	          fd
	          fira-code
	          fzf
	          lazygit
	          luajitPackages.luarocks
	          neofetch
	          ripgrep
	          wget
	        ];

  	      programs = {
	          neovim = {
	            defaultEditor = true;
              enable = true;
              viAlias = true;
              vimAlias = true;
	          };
      	  };

	        home.file.".vimrc".source = ./vim_configuration;

          home.stateVersion = "25.05";

    	    programs.home-manager.enable = true;
        };
      };
    in {
      darwinConfigurations."SA-MacBook-Pro" = darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
    };
}
