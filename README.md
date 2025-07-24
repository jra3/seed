# macOS Dev Setup

Automated setup scripts for a fresh macOS installation, designed to get your development environment up and running quickly.

## Features

- 🚀 **One-command setup** - Run a single script to configure your entire system
- 📦 **Homebrew-based** - Declarative package management with Brewfile
- 🔧 **System preferences** - Automated macOS settings configuration
- 🏠 **Dotfiles integration** - Easy symlink management for your config files
- 🛡️ **Safe & idempotent** - Scripts can be run multiple times without issues
- 📝 **Well-documented** - Clear instructions for both automated and manual steps

## Quick Start

### Option 1: One-Line Installation (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/jra3/seed/main/bootstrap.sh | bash
```

This will:
- Clone the repository to `~/.seed`
- Make all scripts executable
- Run the setup automatically

### Option 2: Manual Installation

```bash
# Clone this repository
git clone https://github.com/jra3/seed.git
cd seed

# Make scripts executable
chmod +x *.sh

# Run the setup
./setup.sh
```

## Prerequisites

- macOS (tested on macOS 13+ Ventura and later)
- Administrator access
- Internet connection
- Apple ID (for manual App Store installations)

## What's Included

### Development Tools
- **Languages**: Node.js, Python, Go, Rust
- **Version Control**: Git with useful aliases
- **Package Managers**: Homebrew, npm, pip
- **Containers**: Docker & Docker Compose

### Modern CLI Tools
- `ripgrep` - Fast text search
- `fd` - User-friendly find
- `bat` - Better cat with syntax highlighting
- `eza` - Modern ls replacement
- `zoxide` - Smarter cd command
- `fzf` - Fuzzy finder
- `tmux` - Terminal multiplexer
- `neovim` - Modern vim
- `emacs` - Extensible text editor

### Emacs Configuration
- Automatically clones configuration from [jra3/dot-emacs](https://github.com/jra3/dot-emacs)
- Installs to `~/.emacs.d` (standard location)
- Supports native compilation if installed with `--with-native-compilation`

### Applications
- **Terminals**: Ghostty
- **Development**: Visual Studio Code, Claude
- **Productivity**: Rectangle, Alfred/Raycast
- **Security**: 1Password
- **Communication**: Slack, Discord

### Shell Environment
- Zsh with Zprezto framework
- Custom aliases and functions
- Optimized shell startup time
- Git-aware prompt

## Customization

### Before Running

1. **Update Git Configuration** - Edit `setup.sh`:
   ```bash
   # Lines 133-134 - Your Git identity
   git config --global user.name "Your Name"
   git config --global user.email "your-email@example.com"
   ```

2. **Dotfiles Setup** - Choose one option:
   - **Option A**: Use included config files (default)
     - The setup will use the `.tmux.conf` and other config files in this repo
   - **Option B**: Use your own dotfiles repository
     ```bash
     export DOTFILES_REPO="https://github.com/YOUR_USERNAME/dotfiles.git"
     ./setup.sh
     ```

3. **Customize Packages** - Edit `Brewfile` to add/remove:
   - CLI tools
   - GUI applications
   - Fonts
   - Mac App Store apps

4. **Adjust System Preferences** - Edit `macos-defaults.sh` to change:
   - Dock behavior
   - Finder settings
   - Keyboard/trackpad preferences
   - Security settings

### Using Your Own Dotfiles

This repository includes a `.tmux.conf` configuration file. If you have your own dotfiles repository, you can use it instead by setting the `DOTFILES_REPO` environment variable before running setup.

The `dotfiles-setup.sh` script expects these files in your dotfiles repository:
- `.gitconfig`
- `.gitignore_global`
- `.vimrc`
- `.tmux.conf`
- `.editorconfig`
- `.config/ghostty/config` - Ghostty terminal configuration

If you're using the included setup without a separate dotfiles repo, only the `.tmux.conf` will be configured.

## Post-Installation

### Automated Steps Complete ✅

After running the scripts, the following will be configured:
- Development tools and applications installed via Homebrew
- Zsh with Zprezto framework installed
- System preferences applied (Finder, Dock, keyboard, etc.)
- SSH key generated (ED25519, copied to clipboard)
- Basic Git configuration with common aliases
- Tmux configured with custom key bindings
- Ghostty terminal configured (if config exists in dotfiles)

### Manual Steps Required 📋

1. **Sign in to iCloud**
   - System Settings → Apple ID
   - Enable desired services

2. **Configure Security**
   - Enable FileVault: System Settings → Privacy & Security → FileVault
   - Configure Firewall settings
   - Review app permissions

3. **Authenticate Applications**
   - Sign in to: Claude, 1Password, Slack, etc.
   - Configure app-specific settings

4. **Add SSH Key to GitHub**
   - The public key is in your clipboard
   - Go to GitHub → Settings → SSH Keys
   - Add new SSH key

5. **Install App Store Apps**
   - Sign in to App Store
   - Install purchased apps or those listed in Brewfile comments

## Scripts Overview

| Script | Purpose |
|--------|---------|
| `setup.sh` | Main orchestrator - runs entire setup process |
| `Brewfile` | Declares all packages to install |
| `macos-defaults.sh` | Configures system preferences |
| `dotfiles-setup.sh` | Creates dotfile symlinks |

## Troubleshooting

### Homebrew Issues
```bash
# If Homebrew fails to install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# If packages fail to install
brew doctor
brew update
```

### Permission Errors
```bash
# Fix Homebrew permissions
sudo chown -R $(whoami) /usr/local/bin /usr/local/lib

# For Apple Silicon Macs
sudo chown -R $(whoami) /opt/homebrew
```

### Dotfiles Not Linking
- Ensure your dotfiles repo is cloned
- Check file paths in `dotfiles-setup.sh`
- Look for `.backup` files if links fail

## Contributing

Feel free to fork and customize! Common modifications:

- Different terminal preferences
- Alternative shells (fish, nushell)
- Additional development tools
- Company-specific configurations

Pull requests for improvements are welcome.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

Inspired by the macOS setup community and various dotfile repositories. Special thanks to:
- [Homebrew](https://brew.sh/) for package management
- [Zprezto](https://github.com/sorin-ionescu/prezto) for Zsh configuration
- The developers of all the excellent tools included
