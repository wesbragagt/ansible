#!/bin/bash

# Dotfiles setup script for Nix environment
# This script helps set up dotfiles integration with stow

set -e

DOTFILES_DIR="$HOME/.dotfiles"
DOTFILES_REPO_URL="${DOTFILES_REPO_URL:-}" # Can be set via environment variable

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
    log "Checking dependencies..."
    
    if ! command -v stow &> /dev/null; then
        error "stow is not installed. Please install it via nix or your package manager."
        exit 1
    fi
    
    if ! command -v git &> /dev/null; then
        error "git is not installed. Please install it via nix or your package manager."
        exit 1
    fi
    
    log "Dependencies check passed"
}

setup_dotfiles_directory() {
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        log "Dotfiles directory does not exist at $DOTFILES_DIR"
        
        if [[ -n "$DOTFILES_REPO_URL" ]]; then
            log "Cloning dotfiles repository from $DOTFILES_REPO_URL"
            git clone --recurse-submodules "$DOTFILES_REPO_URL" "$DOTFILES_DIR"
        else
            log "Creating empty dotfiles directory at $DOTFILES_DIR"
            mkdir -p "$DOTFILES_DIR"
            warn "No DOTFILES_REPO_URL provided. Please clone your dotfiles repository manually:"
            warn "  git clone --recurse-submodules https://github.com/yourusername/dotfiles.git $DOTFILES_DIR"
            return 1
        fi
    else
        log "Dotfiles directory already exists at $DOTFILES_DIR"
        
        # Update if it's a git repository
        if [[ -d "$DOTFILES_DIR/.git" ]]; then
            log "Updating dotfiles repository..."
            cd "$DOTFILES_DIR"
            git pull --recurse-submodules
            cd -
        fi
    fi
}

run_stow_setup() {
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        error "Dotfiles directory does not exist at $DOTFILES_DIR"
        exit 1
    fi
    
    cd "$DOTFILES_DIR"
    
    # Check if setup.sh exists and run it
    if [[ -f "setup.sh" ]]; then
        log "Running existing setup.sh script..."
        bash setup.sh
    else
        # Default stow setup for common configurations
        log "No setup.sh found, running default stow setup..."
        
        # List of common dotfiles to stow
        dotfiles_to_stow=(
            "nvim"
            "tmux"
            "zsh"
            "starship"
            "alacritty"
            "wezterm"
            "karabiner"
            "raycast"
            "sesh"
            "nix"
            "ghostty"
        )
        
        for dotfile in "${dotfiles_to_stow[@]}"; do
            if [[ -d "$dotfile" ]]; then
                log "Stowing $dotfile..."
                stow "$dotfile" --adopt || warn "Failed to stow $dotfile (may already be linked)"
            else
                warn "Directory $dotfile does not exist, skipping..."
            fi
        done
    fi
    
    cd - > /dev/null
}

verify_setup() {
    log "Verifying dotfiles setup..."
    
    # Check common symlinks
    checks=(
        "$HOME/.config/nvim"
        "$HOME/.config/tmux"
        "$HOME/.config/starship"
        "$HOME/.zshrc"
        "$HOME/.aliases"
    )
    
    for check in "${checks[@]}"; do
        if [[ -L "$check" ]]; then
            log "✓ $check is properly linked"
        elif [[ -f "$check" || -d "$check" ]]; then
            warn "! $check exists but is not a symlink"
        else
            warn "! $check does not exist"
        fi
    done
}

main() {
    log "Starting dotfiles setup..."
    
    check_dependencies
    setup_dotfiles_directory
    run_stow_setup
    verify_setup
    
    log "Dotfiles setup complete!"
    log "You may need to restart your shell or source your configurations"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi