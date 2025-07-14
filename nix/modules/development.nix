{ config, pkgs, ... }:

{
  # Enable Nix flakes system-wide
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set ZSH as default shell system-wide (replicates Ansible zsh.yml shell change)
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  # Enable common development services
  services = {
    # Enable SSH daemon for remote development
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  # System packages that should be available globally
  environment.systemPackages = with pkgs; [
    # Essential system tools
    vim
    wget  
    curl
    git
    
    # Development essentials
    gcc
    gnumake
    
    # Nix tools
    nix-index
    nix-tree
    
    # File management
    stow
    rsync
  ];

  # Environment variables for all users
  environment.variables = {
    EDITOR = "nvim";
    PAGER = "bat --style=plain";
  };

  # Configure git system-wide
  programs.git = {
    enable = true;
  };

  # Enable completion for system packages
  environment.pathsToLink = [ 
    "/share/zsh" 
    "/share/bash-completion"
  ];

  # Security settings
  security = {
    sudo.wheelNeedsPassword = true;
  };

  # User account setup (customize as needed)
  users.users.wes = {
    isNormalUser = true;
    description = "Wes";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.zsh;
  };

  # Optional: Docker for containerized development
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Networking
  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # Time zone and locale
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  # System state version
  system.stateVersion = "24.05";

  # Boot configuration for UEFI systems
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # Use latest kernel for best hardware support
    kernelPackages = pkgs.linuxPackages_latest;
  };
}