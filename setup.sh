#!/usr/bin/env bash

# macOS Setup Script
# This script automates the setup of a new macOS machine

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Helper functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    error "This script is only for macOS"
    exit 1
fi

log "Starting macOS setup..."

# 1. Install Xcode Command Line Tools
if ! xcode-select -p &> /dev/null; then
    log "Installing Xcode Command Line Tools..."
    xcode-select --install
    # Wait for installation
    until xcode-select -p &> /dev/null; do
        sleep 5
    done
else
    log "Xcode Command Line Tools already installed"
fi

# 2. Install Homebrew
if ! command -v brew &> /dev/null; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    log "Homebrew already installed"
fi

# 3. Update Homebrew
log "Updating Homebrew..."
brew update

# 4. Install packages from Brewfile
if [[ -f "Brewfile" ]]; then
    log "Installing packages from Brewfile..."
    brew bundle
else
    warning "Brewfile not found. Skipping brew bundle."
fi

# 5. Setup dotfiles directory
DOTFILES_DIR="$HOME/.dotfiles"

# Check if we have a dotfiles repo URL or use local files
DOTFILES_REPO="${DOTFILES_REPO:-}"  # Can be set as environment variable

if [[ -n "$DOTFILES_REPO" ]]; then
    # Clone from repository if URL provided
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        log "Cloning dotfiles repository..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    else
        log "Dotfiles already cloned. Pulling latest changes..."
        cd "$DOTFILES_DIR" && git pull
    fi
else
    # Use local dotfiles from this repository
    log "Using local dotfiles..."
    mkdir -p "$DOTFILES_DIR"
    
    # Copy local config files to dotfiles directory
    [[ -f ".tmux.conf" ]] && cp ".tmux.conf" "$DOTFILES_DIR/" && log "Copied .tmux.conf"
    # Add other config files here as they are created
fi

# 6. Setup Zprezto
if [[ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]]; then
    log "Installing Zprezto..."
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    
    # Create Zsh configuration files
    # Use zsh to handle the glob pattern
    zsh -c '
        setopt EXTENDED_GLOB
        for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
            ln -sf "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
        done
    '
else
    log "Zprezto already installed"
fi

# 7. Symlink dotfiles
log "Creating dotfile symlinks..."
if [[ -f "$DOTFILES_DIR/dotfiles-setup.sh" ]]; then
    bash "$DOTFILES_DIR/dotfiles-setup.sh"
elif [[ -f "dotfiles-setup.sh" ]]; then
    bash dotfiles-setup.sh
fi

# 8. Configure macOS defaults
log "Configuring macOS defaults..."
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [[ -f "$SCRIPT_DIR/macos-defaults.sh" ]]; then
    bash "$SCRIPT_DIR/macos-defaults.sh"
else
    warning "macos-defaults.sh not found. Skipping macOS configuration."
fi

# 9. Setup SSH key
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
    log "Generating SSH key..."
    ssh-keygen -t ed25519 -C "nop@porcnick.com" -f "$HOME/.ssh/id_ed25519" -N ""
    
    # Start ssh-agent and add key
    eval "$(ssh-agent -s)"
    ssh-add "$HOME/.ssh/id_ed25519"
    
    # Copy public key to clipboard
    pbcopy < "$HOME/.ssh/id_ed25519.pub"
    log "SSH public key copied to clipboard. Add it to GitHub/GitLab."
else
    log "SSH key already exists"
fi

# 10. Configure Git
log "Configuring Git..."
git config --global user.name "John Allen"
git config --global user.email "nop@porcnick.com"
git config --global init.defaultBranch main
git config --global pull.rebase false

# 11. Final steps reminder
echo ""
log "Setup mostly complete! Manual steps remaining:"
echo "  1. Sign in to iCloud"
echo "  2. Configure System Preferences that require authentication"
echo "  3. Sign in to apps (Claude, etc.)"
echo "  4. Add SSH key to GitHub/GitLab (already in clipboard)"
echo "  5. Restore application preferences from backups"
echo ""
log "You may need to restart your shell or computer for all changes to take effect."
