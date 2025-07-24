#!/usr/bin/env bash
# Bootstrap script for macOS Dev Setup
# This script clones the seed repository and runs the setup

set -euo pipefail

# Color output functions
print_info() {
    echo -e "\033[34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[31m[ERROR]\033[0m $1"
}

# Configuration
REPO_URL="https://github.com/jra3/seed.git"
INSTALL_DIR="$HOME/.seed"

# Main installation
main() {
    print_info "Starting macOS Dev Setup bootstrap..."
    
    # Check if running on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script is designed for macOS only"
        exit 1
    fi
    
    # Check if seed directory already exists
    if [[ -d "$INSTALL_DIR" ]]; then
        print_error "Directory $INSTALL_DIR already exists"
        print_info "To reinstall, please remove it first: rm -rf $INSTALL_DIR"
        exit 1
    fi
    
    # Clone the repository
    print_info "Cloning seed repository to $INSTALL_DIR..."
    if git clone "$REPO_URL" "$INSTALL_DIR"; then
        print_success "Repository cloned successfully"
    else
        print_error "Failed to clone repository"
        exit 1
    fi
    
    # Change to the installation directory
    cd "$INSTALL_DIR"
    
    # Make scripts executable
    print_info "Making scripts executable..."
    chmod +x *.sh
    
    # Run the setup script
    print_info "Starting setup process..."
    echo ""
    echo "========================================"
    echo "Running setup.sh - this may take a while"
    echo "========================================"
    echo ""
    
    # Execute the main setup script
    ./setup.sh
    
    print_success "Bootstrap complete!"
    echo ""
    echo "The seed repository has been cloned to: $INSTALL_DIR"
    echo "You can run individual scripts from there if needed."
}

# Run main function
main "$@"