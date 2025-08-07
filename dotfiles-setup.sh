#!/usr/bin/env bash

# Dotfiles Setup Script
# This script manages dotfiles and minimal zsh configuration

set -euo pipefail

# Support both external dotfiles repo and local dotfiles in seed
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
LOCAL_DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)/dotfiles"

# Create symlinks for local dotfiles in seed repository
create_local_symlinks() {
    echo "Creating symlinks for local dotfiles..."
    
    # Define local dotfiles to symlink
    # Format: "source:destination"
    local dotfiles=(
        "tmux.conf:$HOME/.tmux.conf"
        "inputrc:$HOME/.inputrc"
    )
    
    # Create symlinks
    for file in "${dotfiles[@]}"; do
        IFS=':' read -r source dest <<< "$file"
        source_path="$LOCAL_DOTFILES_DIR/$source"
        
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
    
    # Create tmux config directory and symlink scripts
    if [[ -d "$LOCAL_DOTFILES_DIR/tmux" ]]; then
        echo "Setting up tmux notification scripts..."
        mkdir -p "$HOME/.config/tmux"
        
        # Symlink all tmux scripts
        for script in "$LOCAL_DOTFILES_DIR/tmux"/*.sh; do
            if [[ -f "$script" ]]; then
                script_name=$(basename "$script")
                dest_path="$HOME/.config/tmux/$script_name"
                
                # Backup existing script if it exists and isn't a symlink
                if [[ -f "$dest_path" && ! -L "$dest_path" ]]; then
                    echo "Backing up existing $dest_path to $dest_path.backup"
                    mv "$dest_path" "$dest_path.backup"
                fi
                
                # Create symlink
                ln -sf "$script" "$dest_path"
                echo "Linked tmux/$script_name -> .config/tmux/$script_name"
            fi
        done
    fi
}

# Create symlinks for dotfiles
create_symlinks() {
    echo "Creating dotfile symlinks from external repository..."
    
    # Define dotfiles to symlink
    # Format: "source:destination"
    local dotfiles=(
        ".gitconfig:$HOME/.gitconfig"
        ".gitignore_global:$HOME/.gitignore_global"
        ".vimrc:$HOME/.vimrc"
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

# Setup minimal zsh configuration
setup_zsh() {
    echo "Setting up minimal zsh configuration..."
    
    local zsh_files=("zshenv" "zprofile" "zshrc")
    local script_dir="$(cd "$(dirname "$0")" && pwd)"
    
    # Link zsh configuration files
    for file in "${zsh_files[@]}"; do
        source_path="$script_dir/$file"
        dest_path="$HOME/.$file"
        
        if [[ -f "$source_path" ]]; then
            # Backup existing file if it exists and isn't a symlink
            if [[ -f "$dest_path" && ! -L "$dest_path" ]]; then
                echo "Backing up existing .$file to .$file.backup"
                mv "$dest_path" "$dest_path.backup"
            fi
            
            # Create symlink
            ln -sf "$source_path" "$dest_path"
            echo "Linked $file -> .$file"
        else
            echo "Warning: $source_path not found, skipping..."
        fi
    done
    
    # Link ripgreprc
    local ripgreprc_source="$script_dir/ripgreprc"
    local ripgreprc_dest="$HOME/.ripgreprc"
    
    if [[ -f "$ripgreprc_source" ]]; then
        if [[ -f "$ripgreprc_dest" && ! -L "$ripgreprc_dest" ]]; then
            echo "Backing up existing .ripgreprc to .ripgreprc.backup"
            mv "$ripgreprc_dest" "$ripgreprc_dest.backup"
        fi
        ln -sf "$ripgreprc_source" "$ripgreprc_dest"
        echo "Linked ripgreprc -> .ripgreprc"
    fi
    
    # Link sqliterc
    local sqliterc_source="$script_dir/sqliterc"
    local sqliterc_dest="$HOME/.sqliterc"
    
    if [[ -f "$sqliterc_source" ]]; then
        if [[ -f "$sqliterc_dest" && ! -L "$sqliterc_dest" ]]; then
            echo "Backing up existing .sqliterc to .sqliterc.backup"
            mv "$sqliterc_dest" "$sqliterc_dest.backup"
        fi
        ln -sf "$sqliterc_source" "$sqliterc_dest"
        echo "Linked sqliterc -> .sqliterc"
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
    local local_source_config="$LOCAL_DOTFILES_DIR/ghostty-config"
    local external_source_config="$DOTFILES_DIR/.config/ghostty/config"
    
    # Create config directory if it doesn't exist
    mkdir -p "$ghostty_config_dir"
    
    # Check local seed repository first
    if [[ -f "$local_source_config" ]]; then
        # Backup existing config if it exists and isn't a symlink
        if [[ -f "$ghostty_config_file" && ! -L "$ghostty_config_file" ]]; then
            echo "Backing up existing Ghostty config to $ghostty_config_file.backup"
            mv "$ghostty_config_file" "$ghostty_config_file.backup"
        fi
        
        # Create symlink
        ln -sf "$local_source_config" "$ghostty_config_file"
        echo "Linked Ghostty configuration from seed repository"
    elif [[ -f "$external_source_config" ]]; then
        # Use external dotfiles repository
        # Backup existing config if it exists and isn't a symlink
        if [[ -f "$ghostty_config_file" && ! -L "$ghostty_config_file" ]]; then
            echo "Backing up existing Ghostty config to $ghostty_config_file.backup"
            mv "$ghostty_config_file" "$ghostty_config_file.backup"
        fi
        
        # Create symlink
        ln -sf "$external_source_config" "$ghostty_config_file"
        echo "Linked Ghostty configuration from external dotfiles"
    else
        echo "Warning: Ghostty config not found, skipping..."
    fi
}

# Setup Inkscape configuration with macOS optimizations
setup_inkscape() {
    echo "Setting up Inkscape configuration..."
    
    local inkscape_config_dir="$HOME/Library/Application Support/org.inkscape.Inkscape/config/inkscape"
    local inkscape_prefs_file="$inkscape_config_dir/preferences.xml"
    local local_source_prefs="$LOCAL_DOTFILES_DIR/inkscape-preferences.xml"
    
    # Create config directory if it doesn't exist
    mkdir -p "$inkscape_config_dir"
    
    # Check local seed repository for preferences
    if [[ -f "$local_source_prefs" ]]; then
        # Backup existing preferences if it exists and isn't a symlink
        if [[ -f "$inkscape_prefs_file" && ! -L "$inkscape_prefs_file" ]]; then
            echo "Backing up existing Inkscape preferences to $inkscape_prefs_file.backup"
            mv "$inkscape_prefs_file" "$inkscape_prefs_file.backup"
        fi
        
        # Create symlink
        ln -sf "$local_source_prefs" "$inkscape_prefs_file"
        echo "Linked Inkscape preferences with macOS optimizations"
    else
        echo "Warning: Inkscape preferences not found, skipping..."
    fi
}

# Main execution
main() {
    echo "Starting dotfiles setup..."
    
    # Create symlinks for local dotfiles in seed repository
    if [[ -d "$LOCAL_DOTFILES_DIR" ]]; then
        create_local_symlinks
    fi
    
    # Setup minimal zsh configuration
    setup_zsh
    
    # Handle external dotfiles if they exist
    if [[ -d "$DOTFILES_DIR" ]]; then
        create_symlinks
    else
        echo "Note: External dotfiles directory not found at $DOTFILES_DIR"
        echo "Skipping external dotfiles setup..."
    fi
    
    setup_git
    setup_ghostty
    setup_inkscape
    
    echo "Dotfiles setup complete!"
}

main "$@"