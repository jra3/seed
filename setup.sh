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

# 4. Setup SSH key early (needed for GitHub access)
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
    log "Generating SSH key..."
    ssh-keygen -t ed25519 -C "nop@porcnick.com" -f "$HOME/.ssh/id_ed25519" -N ""
    
    # Start ssh-agent and add key
    eval "$(ssh-agent -s)"
    ssh-add "$HOME/.ssh/id_ed25519"
    
    # Copy public key to clipboard
    pbcopy < "$HOME/.ssh/id_ed25519.pub"
    
    echo ""
    log "SSH public key has been copied to your clipboard!"
    echo ""
    echo "Please add this key to your GitHub account:"
    echo "1. Go to https://github.com/settings/keys"
    echo "2. Click 'New SSH key'"
    echo "3. Paste the key from your clipboard"
    echo "4. Give it a descriptive title (e.g., 'MacBook Pro - $(date +%Y-%m-%d)')"
    echo ""
    echo "Your public key is:"
    echo "----------------------------------------"
    cat "$HOME/.ssh/id_ed25519.pub"
    echo "----------------------------------------"
    echo ""
    read -p "Press Enter after you've added the key to GitHub..."
    
    # Test GitHub connection
    log "Testing GitHub SSH connection..."
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        log "GitHub SSH connection successful!"
    else
        warning "GitHub SSH connection test failed. You may need to troubleshoot."
    fi
else
    log "SSH key already exists"
fi

# 5. Install packages from Brewfile
if [[ -f "Brewfile" ]]; then
    log "Installing packages from Brewfile..."
    brew bundle
else
    warning "Brewfile not found. Skipping brew bundle."
fi

# 6. Setup dotfiles directory
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

# 9. Configure Git
log "Configuring Git..."
git config --global user.name "John Allen"
git config --global user.email "nop@porcnick.com"
git config --global init.defaultBranch main
git config --global pull.rebase false

# 10. Setup Emacs configuration
log "Setting up Emacs configuration..."
EMACS_CONFIG_DIR="$HOME/.emacs.d"
EMACS_REPO="https://github.com/jra3/dot-emacs.git"

# Clone Emacs configuration
if [[ ! -d "$EMACS_CONFIG_DIR" ]]; then
    log "Cloning Emacs configuration..."
    git clone "$EMACS_REPO" "$EMACS_CONFIG_DIR"
else
    log "Emacs configuration already exists. Pulling latest changes..."
    cd "$EMACS_CONFIG_DIR" && git pull
fi

# 11. Final steps reminder
echo ""
log "Setup mostly complete! Manual steps remaining:"
echo "  1. Sign in to iCloud"
echo "  2. Configure System Preferences that require authentication"
echo "  3. Sign in to apps (Claude, etc.)"
echo "  4. Restore application preferences from backups"
echo ""
log "You may need to restart your shell or computer for all changes to take effect."
