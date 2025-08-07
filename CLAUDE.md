# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a macOS setup automation repository consisting of shell scripts that automate the configuration of a new Mac development environment. The scripts work together in a specific sequence to install software, configure system preferences, and set up development tools.

## Key Scripts and Their Functions

### setup.sh - Main Orchestrator
The entry point that coordinates the entire setup process. Runs all other scripts in sequence:
1. Installs Xcode Command Line Tools
2. Installs Homebrew
3. Runs `brew bundle` to install packages from Brewfile
4. Clones user's dotfiles repository
5. Runs dotfiles-setup.sh (sets up minimal zsh configuration)
6. Runs macos-defaults.sh
7. Generates SSH keys
8. Configures Git

### Brewfile - Package Declaration
Declarative list of packages to install via Homebrew. Organized into:
- Taps (additional repositories)
- Core utilities (git, curl, ripgrep, etc.)
- Development tools (node, python, go, rust)
- CLI productivity tools (fzf, gh, lazygit)
- GUI applications (casks)
- Fonts
- Mac App Store apps (via mas)

### macos-defaults.sh - System Preferences
Configures macOS system preferences programmatically using `defaults write` commands. Modifies:
- General UI/UX settings
- Trackpad and keyboard behavior
- Finder preferences
- Dock configuration
- Safari settings
- Security preferences

### dotfiles-setup.sh - Configuration Management
Manages dotfile symlinks and shell configuration:
- Creates symlinks from dotfiles repository to home directory
- Sets up minimal zsh configuration (zshenv, zprofile, zshrc)
- Configures ripgrep with custom settings
- Configures SQLite with enhanced display settings
- Configures Git aliases
- Sets up Ghostty terminal configuration
- Installs bin scripts (including tmux-new-session) to ~/bin

## Common Commands

```bash
# Run the complete setup (main entry point)
./setup.sh

# Install/update packages only
brew bundle

# Apply macOS system preferences
./macos-defaults.sh

# Set up dotfile symlinks
./dotfiles-setup.sh

# Update Homebrew packages
brew update && brew upgrade

# Check what would be installed
brew bundle check --verbose

# Clean up old Homebrew versions
brew cleanup

# Create new tmux session with Claude and Emacs server
tn                    # Auto-generates session name (e.g., swift-falcon)
tn project-name       # Uses specified session name

# In tmux session, use Emacs
ec file.txt           # Edit in terminal
ecw file.txt          # Edit in GUI window
eck                   # Kill session's Emacs server

# Initialize Emacs in existing tmux session
tmux-init-emacs
```

## Architecture Decisions

1. **Modular Script Design**: Each script has a single responsibility, making it easy to run individual parts of the setup independently.

2. **Error Handling**: All scripts use `set -euo pipefail` to fail fast on errors and undefined variables.

3. **Idempotency**: Scripts check for existing installations/configurations before making changes, allowing safe re-runs.

4. **User Configuration Required**: The scripts expect users to modify hardcoded values:
   - Git user name/email in setup.sh lines 173-174
   - Email for SSH key in setup.sh line 68
   - Computer name in macos-defaults.sh line 20

5. **Manual Steps Documentation**: The README clearly documents steps that cannot be automated (iCloud sign-in, app authentication, etc.).

## Important Notes

- The scripts assume a fresh macOS installation but include checks to avoid breaking existing configurations
- Dotfiles are expected to be in a separate GitHub repository that the user must specify
- The setup creates backups of existing files before creating symlinks
- Some macOS defaults require logout/restart to take effect
- The Brewfile can be customized without modifying the setup scripts