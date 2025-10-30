# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Editor preferences
export EDITOR="vim"
export VISUAL="vim"

# History configuration - Important for development work
export HISTSIZE=50000
export HISTFILESIZE=100000
export HISTCONTROL=ignoredups:erasedups
export HISTTIMEFORMAT='%F %T '
shopt -s histappend
shopt -s cmdhist

# Better directory navigation
shopt -s autocd
shopt -s cdspell
shopt -s dirspell
shopt -s globstar

# Terminal-specific configurations
case "$TERM" in
    xterm-kitty)
        # Kitty-specific settings
        alias icat='kitty +kitten icat'
        alias kssh='kitty +kitten ssh'
        ;;
    alacritty)
        # Alacritty-specific settings
        export TERM=alacritty
        ;;
esac

# ==================== GIT CONFIGURATION ====================

# Git completion for Fedora
if [ -f /usr/share/bash-completion/completions/git ]; then
    . /usr/share/bash-completion/completions/git
fi

# Git aliases with autocomplete support
alias g='git'
alias gs='git status'
alias gst='git status -sb'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpl='git pull'
alias gf='git fetch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gl='git log --oneline --graph --decorate --all'
alias gls='git log --oneline --graph --decorate'
alias gd='git diff'
alias gds='git diff --staged'
alias gsh='git stash'
alias gshp='git stash pop'
alias gcl='git clone'
alias gm='git merge'
alias gr='git remote -v'

# Enable git completion for aliases
__git_complete g __git_main
__git_complete gco _git_checkout
__git_complete gb _git_branch
__git_complete gm _git_merge
__git_complete gp _git_push
__git_complete gpl _git_pull
__git_complete gf _git_fetch

# ==================== HOME-LAB ALIASES ====================

# System Management
alias update='sudo dnf update -y && flatpak update -y'
alias cleanup='sudo dnf autoremove -y && sudo dnf clean all'
alias sysinfo='fastfetch'

# File Operations
alias ls='ls --color=auto'
alias ll='ls -lAh --group-directories-first'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -lAht'  # List by time

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# Navigation shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias home='cd ~'
alias lab='cd ~/homelab'  # Adjust to your home-lab directory

# Grep with color
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# System monitoring for home-lab
alias ports='sudo ss -tulpn'
alias listening='sudo lsof -i -P -n | grep LISTEN'
alias meminfo='free -h'
alias diskusage='df -h | grep -E "(Filesystem|/dev/)"'
alias cpu='top -o %CPU'
alias topcpu='ps aux | sort -rk 3,3 | head -n 11'
alias topmem='ps aux | sort -rk 4,4 | head -n 11'
alias temp='sensors'

# Systemd shortcuts
alias sctl='systemctl'
alias sctls='systemctl status'
alias sctlr='sudo systemctl restart'
alias sctlu='systemctl --user'
alias jctl='journalctl'
alias jctlf='journalctl -f'
alias jctlu='journalctl --user'

# Network utilities
alias myip='curl -s ifconfig.me'
alias localip='ip -4 addr show | grep -oP "(?<=inet\s)\d+(\.\d+){3}"'
alias pingg='ping -c 5 8.8.8.8'
alias pingcf='ping -c 5 1.1.1.1'
alias flushdns='sudo resolvectl flush-caches'

# Docker shortcuts for home-lab
alias d='docker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dexec='docker exec -it'
alias dlogs='docker logs -f'
alias dprune='docker system prune -af --volumes'
alias dstop='docker stop $(docker ps -q)'
alias dc='docker compose'
alias dcup='docker compose up -d'
alias dcdown='docker compose down'
alias dclogs='docker compose logs -f'
alias dcrestart='docker compose restart'

# Quick edits
alias bashrc='$EDITOR ~/.bashrc && source ~/.bashrc'
alias vimrc='$EDITOR ~/.vimrc'
alias sshconfig='$EDITOR ~/.ssh/config'
alias hosts='sudo $EDITOR /etc/hosts'

# ==================== HOME-LAB FUNCTIONS ====================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
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
            *.tar.xz)    tar xJf "$1"     ;;
            *)           printf 'Error: Unknown archive format\n' ;;
        esac
    else
        printf 'Error: File does not exist\n'
    fi
}

# Find process by name
psgrep() {
    ps aux | grep -v grep | grep -i -e VSZ -e "$1"
}

# Quick backup function
backup() {
    if [ -f "$1" ]; then
        cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
        printf 'Backup created: %s.backup-%s\n' "$1" "$(date +%Y%m%d-%H%M%S)"
    elif [ -d "$1" ]; then
        tar czf "$1.backup-$(date +%Y%m%d-%H%M%S).tar.gz" "$1"
        printf 'Backup created: %s.backup-%s.tar.gz\n' "$1" "$(date +%Y%m%d-%H%M%S)"
    else
        printf 'Error: File or directory does not exist\n'
    fi
}

# Quick script testing function
testscript() {
    if [ -f "$1" ]; then
        printf 'Running shellcheck...\n'
        shellcheck "$1"
        printf '\nSyntax check...\n'
        bash -n "$1"
        printf '\nDry run complete.\n'
    else
        printf 'Error: Script does not exist\n'
    fi
}

# GitHub CLI helper functions
ghclone() {
    if [ -z "$1" ]; then
        printf 'Usage: ghclone <user/repo>\n'
        return 1
    fi
    git clone "https://github.com/$1.git"
}

# Quick commit and push
gcp() {
    if [ -z "$1" ]; then
        printf 'Usage: gcp "commit message"\n'
        return 1
    fi
    git add --all
    git commit -m "$1"
    git push
}

# Show git repo status for all repos in current directory
gstatus() {
    for dir in */; do
        if [ -d "$dir/.git" ]; then
            printf '\n=== %s ===\n' "$dir"
            git -C "$dir" status -sb
        fi
    done
}

# Docker cleanup function
dclean() {
    printf 'Stopping all containers...\n'
    docker stop "$(docker ps -q)" 2>/dev/null
    printf 'Removing containers, images, volumes...\n'
    docker system prune -af --volumes
    printf 'Docker cleanup complete.\n'
}

# Show listening services on common ports
checkports() {
    printf 'Checking common ports...\n'
    for port in 22 80 443 8080 3000 5000 9000; do
        if sudo ss -tulpn | grep -q ":$port "; then
            printf 'Port %s: ' "$port"
            sudo ss -tulpn | grep ":$port "
        fi
    done
}

# List aliases and functions (help flag)
helpme() {
    printf '\n=== GIT ALIASES ===\n'
    alias | grep "^alias g" | sort
    printf '\n=== DOCKER ALIASES ===\n'
    alias | grep "^alias d" | sort
    printf '\n=== SYSTEM ALIASES ===\n'
    alias | grep -E "^alias (s|ports|mem|disk|cpu)" | sort
    printf '\n=== CUSTOM FUNCTIONS ===\n'
    printf 'mkcd <dir>          - Create directory and cd into it\n'
    printf 'extract <file>      - Extract various archive formats\n'
    printf 'psgrep <name>       - Find process by name\n'
    printf 'backup <file|dir>   - Create timestamped backup\n'
    printf 'testscript <file>   - Run shellcheck and syntax check\n'
    printf 'ghclone <user/repo> - Clone GitHub repo\n'
    printf 'gcp "message"       - Git add, commit, and push\n'
    printf 'gstatus             - Show status of all git repos in current dir\n'
    printf 'dclean              - Stop and clean all Docker resources\n'
    printf 'checkports          - Show services on common ports\n'
    printf 'helpme              - Show this help\n'
}

# ==================== CONDITIONAL LOADING ====================

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# Initialize ble.sh before Starship for proper autocomplete
if [ -f ~/.local/share/blesh/ble.sh ]; then
    source ~/.local/share/blesh/ble.sh --noattach
fi

# Run fastfetch on shell initialization
if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi

# Initialize Starship prompt
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi

# Attach ble.sh after Starship for proper rendering
if [[ ${BLE_VERSION-} ]]; then
    ble-attach
fi
