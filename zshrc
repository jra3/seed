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
setopt AUTO_CD              # Auto changes to a directory without typing cd
setopt CDABLE_VARS          # Change directory to a path stored in a variable
setopt MULTIOS              # Write to multiple descriptors
setopt EXTENDED_GLOB        # Use extended globbing syntax
unsetopt CLOBBER            # Do not overwrite existing files with > and >>.
                            # Use >! and >>! to bypass

# Shell options
set -o physical
setopt SH_WORD_SPLIT
setopt CORRECT              # Command auto-correction
setopt INTERACTIVE_COMMENTS # Allow comments in interactive shell
setopt RC_QUOTES            # Allow 'Henry''s Garage' instead of 'Henry'\''s Garage'

# Completion
# Add Homebrew completions to fpath before compinit
if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
    fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
fi

autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
setopt COMPLETE_ALIASES

# Shell Integrations and Completions
# ===================================

# Git completions are loaded from fpath automatically

# fzf - Fuzzy finder
if command -v fzf &>/dev/null; then
    # Auto-completion
    source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2>/dev/null
    # Key bindings (CTRL-T, CTRL-R, ALT-C)
    source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh" 2>/dev/null
    
    # fzf configuration
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    
    # Enhanced fzf options with preview window
    export FZF_DEFAULT_OPTS='
        --height 40% 
        --layout=reverse 
        --border 
        --inline-info
        --color=dark
        --color=fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f
        --color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
        --bind="ctrl-/:toggle-preview"
        --bind="ctrl-u:preview-page-up"
        --bind="ctrl-d:preview-page-down"
    '
    
    # Preview configuration for files (CTRL-T)
    export FZF_CTRL_T_OPTS="
        --preview 'bat -n --color=always --line-range :500 {} 2>/dev/null || cat {} 2>/dev/null || echo \"No preview available\"'
        --preview-window=right:50%:hidden
        --bind='ctrl-/:toggle-preview'
    "
    
    # Preview configuration for directories (ALT-C)
    export FZF_ALT_C_OPTS="
        --preview 'eza --tree --level=2 --color=always {} 2>/dev/null || tree -C {} 2>/dev/null || ls -la {} 2>/dev/null'
        --preview-window=right:50%:hidden
        --bind='ctrl-/:toggle-preview'
    "
    
    # Better history search (CTRL-R)
    export FZF_CTRL_R_OPTS="
        --preview 'echo {}'
        --preview-window=down:3:wrap
        --bind='ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
        --header='Press CTRL-Y to copy command to clipboard'
    "
fi

# zoxide - Smarter cd command
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
    # fzf integration for zoxide
    export _ZO_FZF_OPTS="$FZF_DEFAULT_OPTS --preview 'eza --tree --level=2 --color=always {2} 2>/dev/null || ls -la {2} 2>/dev/null'"
fi

# GitHub CLI completion
if command -v gh &>/dev/null; then
    eval "$(gh completion -s zsh)"
fi

# Docker completion
if command -v docker &>/dev/null; then
    # Docker completion is provided by docker itself
    autoload -Uz bashcompinit && bashcompinit
    complete -F _docker docker 2>/dev/null
fi

# Node/npm completion (if using pnpm)
if command -v pnpm &>/dev/null; then
    eval "$(pnpm completion zsh 2>/dev/null)"
elif command -v npm &>/dev/null; then
    # npm completion through bash compatibility
    autoload -Uz bashcompinit && bashcompinit
    eval "$(npm completion 2>/dev/null)"
fi

# Rust/Cargo completions are already in fpath via Homebrew
# The following tools have zsh completions automatically loaded from
# /opt/homebrew/share/zsh/site-functions/:
# - bat, cargo, eza, fd, gh, git, ripgrep, tldr, zoxide

# Key bindings
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Prompt setup (Sorin theme style)
autoload -Uz vcs_info
setopt PROMPT_SUBST

# Define colors
typeset -gA colors
colors=(
  'blue'     '%F{4}'
  'cyan'     '%F{6}'
  'green'    '%F{2}'
  'magenta'  '%F{5}'
  'red'      '%F{1}'
  'white'    '%F{7}'
  'yellow'   '%F{3}'
  'black'    '%F{0}'
  'reset'    '%f'
)

# Git status symbols
typeset -gA git_symbols
git_symbols=(
  'added'      '✚'
  'ahead'      '⬆'
  'behind'     '⬇'
  'deleted'    '✖'
  'modified'   '✱'
  'renamed'    '➜'
  'unmerged'   '═'
  'untracked'  '✭'
)

# VCS info configuration
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr "${colors[green]}${git_symbols[added]}${colors[reset]}"
zstyle ':vcs_info:*' unstagedstr "${colors[red]}${git_symbols[modified]}${colors[reset]}"
zstyle ':vcs_info:git:*' formats " ${colors[cyan]}%b%c%u${colors[reset]}"
zstyle ':vcs_info:git:*' actionformats " ${colors[cyan]}%b${colors[reset]} ${colors[yellow]}(%a)${colors[reset]}%c%u"

# Prompt functions
function prompt_sorin_pwd {
  local pwd="${PWD/#$HOME/~}"
  print -n "${colors[blue]}${pwd}${colors[reset]}"
}

function prompt_sorin_git_status {
  [[ -n "$vcs_info_msg_0_" ]] && print -n "$vcs_info_msg_0_"
}

function prompt_sorin_precmd {
  vcs_info
}

# Add precmd function
precmd_functions+=(prompt_sorin_precmd)
precmd_functions+=(set_terminal_title)

# Terminal title
function set_terminal_title {
  local title_format="${PWD/#$HOME/~}"
  case "$TERM" in
    xterm*|rxvt*|screen*|tmux*)
      print -Pn "\e]0;${title_format}\a"
      ;;
  esac
}

# Build the left prompt
function build_prompt {
  local prompt_pwd="$(prompt_sorin_pwd)"
  
  # Multicolored triple chevron prompt
  local prompt_char=""
  if [[ $UID -eq 0 ]]; then
    prompt_char="${colors[red]}#${colors[reset]} "
  else
    prompt_char="${colors[red]}❯${colors[yellow]}❯${colors[green]}❯${colors[reset]} "
  fi
  
  print -n "${prompt_pwd} ${prompt_char}"
}

# Build the right prompt  
function build_rprompt {
  local rprompt=""
  
  # Git status
  local git_status="$(prompt_sorin_git_status)"
  if [[ -n "$git_status" ]]; then
    rprompt="${git_status}"
  fi
  
  # Return code (only show if non-zero)
  if [[ -n "$rprompt" ]]; then
    rprompt+=" "
  fi
  rprompt+='%(?..'${colors[red]}'✘ %?'${colors[reset]}')'
  
  print -n "$rprompt"
}

PROMPT='$(build_prompt)'
RPROMPT='$(build_rprompt)'

# Aliases
alias ls='ls -G'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias g='git'
alias ag='rg'
alias pcl='pkill tsc; pnpm run -w precommit-checklist'
alias bwssh='~/bin/bw_add_sshkeys.py'

# Directory navigation aliases
alias -- -='cd -'

# Safe operations (ask before overwriting)
alias cpi='cp -i'
alias lni='ln -i'
alias mvi='mv -i'
alias rmi='rm -i'

# Suffix aliases (open files with specific programs)
alias -s txt=less
alias -s log=less
alias -s md=less
alias -s json=jq
alias -s {js,ts,jsx,tsx,py,go,rs,c,cpp,h}=$EDITOR

# Global aliases
alias -g G='| grep'
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'
alias -g NE='2> /dev/null'
alias -g NUL='> /dev/null 2>&1'
alias -g F='| fzf'

# fzf-specific aliases
alias vf='fe'  # vim/edit files with fzf
alias cdf='fcd'  # cd with fzf
alias gcb='fbr'  # git checkout branch with fzf
alias glog='fshow'  # git log browser
alias rgf='frg'  # ripgrep with fzf
alias killf='fkill'  # kill process with fzf

# Functions
ut() {
    if [ $# -eq 0 ]; then
        date +%s
    else
        date -u -r "$1" -Iseconds
    fi
}

# Make directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract archives
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# fzf-powered functions
# Kill process
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m --header='[kill process]' | awk '{print $2}')
    
    if [ "x$pid" != "x" ]; then
        echo $pid | xargs kill -${1:-9}
    fi
}

# Git branch selector
fbr() {
    local branches branch
    branches=$(git --no-pager branch -vv --color=always) &&
    branch=$(echo "$branches" | fzf +m --ansi --header='[git branch]') &&
    git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

# Git commit browser
fshow() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
        --header='[git log] Press CTRL-S to toggle sort' \
        --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always' \
        --bind "enter:execute:
            (grep -o '[a-f0-9]\{7,\}' | xargs git show --color=always | less -R) <<< {}"
}

# Search and edit files
fe() {
    local files
    IFS=$'\n' files=($(fzf --query="$1" --multi --select-1 --exit-0 \
        --preview 'bat -n --color=always --line-range :500 {} 2>/dev/null || cat {}' \
        --preview-window=right:50%:hidden \
        --bind='ctrl-/:toggle-preview'))
    [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# Change to selected directory (including hidden)
fcd() {
    local dir
    dir=$(fd --type d --hidden --follow --exclude .git . ${1:-.} 2>/dev/null | fzf +m \
        --preview 'eza --tree --level=2 --color=always {} 2>/dev/null || tree -C {} 2>/dev/null || ls -la {}' \
        --preview-window=right:50%:hidden \
        --bind='ctrl-/:toggle-preview') && cd "$dir"
}

# Search history and execute
fh() {
    eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# Find and open in browser
fopen() {
    local file
    file=$(fzf --query="$1" --select-1 --exit-0 \
        --preview 'bat -n --color=always --line-range :500 {} 2>/dev/null || cat {}' \
        --preview-window=right:50%:hidden \
        --bind='ctrl-/:toggle-preview')
    [[ -n "$file" ]] && open "$file"
}

# Search content in files with ripgrep
frg() {
    local file line
    read -r file line <<<"$(rg --no-heading --line-number --color=always "${*:-}" | fzf -d ':' -n 2.. --ansi --no-sort --preview-window 'down:50%:+{2}' --preview 'bat --color=always {1} --highlight-line {2}')"
    if [[ -n "$file" ]]; then
        ${EDITOR:-vim} "$file" "+$line"
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
    $HOME/go/bin
    /usr/local/bin
    $path
)

# History substring search (with highlighting)
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '^[[A' history-beginning-search-backward-end
bindkey '^[[B' history-beginning-search-forward-end

# Additional useful key bindings
bindkey '^P' history-beginning-search-backward-end
bindkey '^N' history-beginning-search-forward-end
bindkey '^K' kill-whole-line
bindkey '^U' backward-kill-line
bindkey '^?' backward-delete-char
bindkey '^H' backward-delete-char
bindkey '^W' backward-kill-word
bindkey '^R' history-incremental-search-backward

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