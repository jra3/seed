#!/usr/bin/env zsh

# Set up homebrew if on macOS
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Additional PATH setup
path=(
    $HOME/bin
    $HOME/.local/bin
    $HOME/.cask/bin
    $path
)

# Homebrew GNU tools (if installed)
if [[ -d /opt/homebrew/opt/make/libexec/gnubin ]]; then
    path=(/opt/homebrew/opt/make/libexec/gnubin $path)
fi

# LLVM tools
if [[ -d /opt/homebrew/opt/llvm/bin ]]; then
    path=(/opt/homebrew/opt/llvm/bin $path)
fi

# Go
if [[ -d /usr/local/go/bin ]]; then
    path=(/usr/local/go/bin $path)
fi
if [[ -n "$GOPATH" && -d "$GOPATH/bin" ]]; then
    path=($GOPATH/bin $path)
fi

# Ensure tmp directory exists
[[ ! -d "$HOME/tmp" ]] && mkdir -p "$HOME/tmp"

# Load local profile if exists
[[ -f ~/.zprofile.local ]] && source ~/.zprofile.local