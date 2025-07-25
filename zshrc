#!/usr/bin/env zsh

# History
HISTFILE=~/.zsh-history
HISTSIZE=130000
SAVEHIST=130000
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS

# Shell options
set -o physical
setopt SH_WORD_SPLIT
unsetopt EXTENDED_GLOB

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
setopt COMPLETE_ALIASES

# Key bindings
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Prompt
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt PROMPT_SUBST
zstyle ':vcs_info:git:*' formats ' %F{green}(%b)%f'

if [[ -n "$ADD_ERRORCODE_TO_PROMPT" ]]; then
    PROMPT='%(?.%F{blue}%~%f${vcs_info_msg_0_}.%F{red}%~%f${vcs_info_msg_0_} [%?]) %# '
else
    PROMPT='%F{blue}%~%f${vcs_info_msg_0_} %# '
fi

# Aliases
alias ls='ls -G'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias g='git'
alias ag='rg'
alias pcl='pkill tsc; pnpm run -w precommit-checklist'
alias bwssh='~/bin/bw_add_sshkeys.py'

# Functions
ut() {
    if [ $# -eq 0 ]; then
        date +%s
    else
        date -u -r "$1" -Iseconds
    fi
}

# Environment
export EDITOR='emacs -nw -q'
export VISUAL='emacs -nw -q'
export PAGER='less'
export LESS='-F -g -i -M -R -S -w -X -z-4'

# PATH additions
path=(
    $HOME/bin
    $HOME/.local/bin
    /usr/local/bin
    $path
)

# History substring search
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '^[[A' history-beginning-search-backward-end
bindkey '^[[B' history-beginning-search-forward-end

# SSH agent and keys
if [[ -z "$SSH_AUTH_SOCK" ]]; then
    eval "$(ssh-agent -s)" > /dev/null
fi

ssh-add -l &>/dev/null || {
    ssh-add ~/.ssh/id_rsa 2>/dev/null
    ssh-add ~/.ssh/id_github_rsa 2>/dev/null
}

# AWS CLI completion (bash compatibility)
if command -v aws &>/dev/null; then
    autoload -Uz bashcompinit && bashcompinit
    complete -C "$(command -v aws_completer)" aws 2>/dev/null
fi

# kubectl completion
if command -v kubectl &>/dev/null; then
    source <(kubectl completion zsh 2>/dev/null)
fi

# Cargo/Rust
[[ -f ~/.cargo/env ]] && source ~/.cargo/env

# Load local config if exists
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local