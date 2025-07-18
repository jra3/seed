#!/usr/bin/env bash

# Dotfiles Setup Script
# This script manages dotfiles and Zprezto configuration

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Create symlinks for dotfiles
create_symlinks() {
    echo "Creating dotfile symlinks..."
    
    # Define dotfiles to symlink
    # Format: "source:destination"
    local dotfiles=(
        ".gitconfig:$HOME/.gitconfig"
        ".gitignore_global:$HOME/.gitignore_global"
        ".vimrc:$HOME/.vimrc"
        ".tmux.conf:$HOME/.tmux.conf"
        ".editorconfig:$HOME/.editorconfig"
    )
    
    # Create symlinks
    for file in "${dotfiles[@]}"; do
        IFS=':' read -r source dest <<< "$file"
        source_path="$DOTFILES_DIR/$source"
        
        if [[ -f "$source_path" ]]; then
            # Backup existing file if it exists and isn't a symlink
            if [[ -f "$dest" && ! -L "$dest" ]]; then
                echo "Backing up existing $dest to $dest.backup"
                mv "$dest" "$dest.backup"
            fi
            
            # Create symlink
            ln -sf "$source_path" "$dest"
            echo "Linked $source -> $dest"
        else
            echo "Warning: $source_path not found, skipping..."
        fi
    done
}

# Setup Zprezto customizations
setup_zprezto() {
    echo "Setting up Zprezto customizations..."
    
    # Link custom Zprezto configuration if it exists
    if [[ -f "$DOTFILES_DIR/.zpreztorc" ]]; then
        ln -sf "$DOTFILES_DIR/.zpreztorc" "$HOME/.zpreztorc"
        echo "Linked custom .zpreztorc"
    fi
    
    # Link custom zsh configuration
    if [[ -f "$DOTFILES_DIR/.zshrc" ]]; then
        ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
        echo "Linked custom .zshrc"
    fi
    
    # Create custom aliases file if it doesn't exist
    if [[ ! -f "$HOME/.zsh_aliases" ]]; then
        cat > "$HOME/.zsh_aliases" << 'EOF'
# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias g='git'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gco='git checkout'
alias gbr='git branch'
alias glog='git log --oneline --graph --decorate'

# Use modern replacements if available
command -v eza >/dev/null 2>&1 && alias ls='eza'
command -v bat >/dev/null 2>&1 && alias cat='bat'
command -v fd >/dev/null 2>&1 && alias find='fd'
command -v rg >/dev/null 2>&1 && alias grep='rg'
EOF
        echo "Created .zsh_aliases"
    fi
    
    # Ensure aliases are sourced in .zshrc
    if ! grep -q "source.*\.zsh_aliases" "$HOME/.zshrc" 2>/dev/null; then
        echo "" >> "$HOME/.zshrc"
        echo "# Source custom aliases" >> "$HOME/.zshrc"
        echo "[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases" >> "$HOME/.zshrc"
    fi
}

# Setup Git configuration
setup_git() {
    echo "Setting up Git configuration..."
    
    # Set up global gitignore
    git config --global core.excludesfile "$HOME/.gitignore_global"
    
    # Common Git aliases
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.st status
    git config --global alias.unstage 'reset HEAD --'
    git config --global alias.last 'log -1 HEAD'
    git config --global alias.visual '!gitk'
    
    echo "Git configuration complete"
}

# Setup Ghostty terminal configuration
setup_ghostty() {
    echo "Setting up Ghostty configuration..."
    
    local ghostty_config_dir="$HOME/.config/ghostty"
    local ghostty_config_file="$ghostty_config_dir/config"
    local source_config="$DOTFILES_DIR/.config/ghostty/config"
    
    # Create config directory if it doesn't exist
    mkdir -p "$ghostty_config_dir"
    
    # Check if source config exists
    if [[ -f "$source_config" ]]; then
        # Backup existing config if it exists and isn't a symlink
        if [[ -f "$ghostty_config_file" && ! -L "$ghostty_config_file" ]]; then
            echo "Backing up existing Ghostty config to $ghostty_config_file.backup"
            mv "$ghostty_config_file" "$ghostty_config_file.backup"
        fi
        
        # Create symlink
        ln -sf "$source_config" "$ghostty_config_file"
        echo "Linked Ghostty configuration"
    else
        # If no source config exists in dotfiles, check if local config exists in repo
        local local_config=".config/ghostty/config"
        if [[ -f "$local_config" ]]; then
            # Create directory structure in dotfiles
            mkdir -p "$DOTFILES_DIR/.config/ghostty"
            # Copy config to dotfiles
            cp "$local_config" "$source_config"
            # Create symlink
            ln -sf "$source_config" "$ghostty_config_file"
            echo "Copied and linked Ghostty configuration"
        else
            echo "Warning: Ghostty config not found, skipping..."
        fi
    fi
}

# Main execution
main() {
    echo "Starting dotfiles setup..."
    
    # Ensure dotfiles directory exists
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        echo "Error: Dotfiles directory not found at $DOTFILES_DIR"
        echo "Please clone your dotfiles repository first."
        exit 1
    fi
    
    create_symlinks
    setup_zprezto
    setup_git
    setup_ghostty
    
    echo "Dotfiles setup complete!"
}

main "$@"