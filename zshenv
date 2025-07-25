#!/usr/bin/env zsh

# Ensure path arrays do not contain duplicates
typeset -U path PATH

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Language
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Less
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Timezone
export TZ="America/New_York"

# Temp directory
export TMPDIR="$HOME/tmp"

# Node.js
export NODE_NO_WARNINGS=1
export JSII_SILENCE_WARNING_UNTESTED_NODE_VERSION=1

# Prompt settings
export ADD_ERRORCODE_TO_PROMPT=1

# Ripgrep config
export RIPGREP_CONFIG_PATH=~/.ripgreprc

# macOS specific
if [[ "$OSTYPE" == darwin* ]]; then
    export BROWSER='open'
fi

# Go
export GOPATH="$HOME/go"

# Load local environment if exists
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local