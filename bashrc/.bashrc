# ===================================================================
#   Universal Portable .bashrc for Modern Terminals
#   Optimized for Debian/Ubuntu servers with multi-terminal support
# ===================================================================

# If not running interactively, don't do anything.
case $- in
    *i*) ;;
      *) return;;
esac

# --- History Control ---
# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth:erasedups
# Append to the history file, don't overwrite it.
shopt -s histappend
# Set history length with reasonable values for server use.
HISTSIZE=10000
HISTFILESIZE=20000
# Save history immediately and reload from other sessions.
# Safely appends to PROMPT_COMMAND to avoid overwriting other scripts' settings.
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }history -a; history -n"
# Allow editing of commands recalled from history.
shopt -s histverify
# Add timestamp to history entries for audit trail.
HISTTIMEFORMAT="%F %T "
# Ignore common commands from history to reduce clutter.
HISTIGNORE="ls:ll:la:l:cd:pwd:exit:clear:c:history:h"

# --- General Shell Behavior & Options ---
# Check the window size after each command and update LINES and COLUMNS.
shopt -s checkwinsize
# Allow using '**' for recursive globbing (Bash 4.0+, suppress errors on older versions).
shopt -s globstar 2>/dev/null
# Allow changing to a directory by just typing its name (Bash 4.0+).
shopt -s autocd 2>/dev/null
# Autocorrect minor spelling errors in directory names (Bash 4.0+).
shopt -s cdspell 2>/dev/null
shopt -s dirspell 2>/dev/null
# Correct multi-line command editing.
shopt -s cmdhist 2>/dev/null
# Case-insensitive globbing for pathname expansion.
# shopt -s nocaseglob 2>/dev/null

# Set command-line editing mode. Emacs (default) or Vi.
set -o emacs
# For vi keybindings, uncomment the following line and comment the one above:
# set -o vi

# Make `less` more friendly for non-text input files.
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# --- Better Less Configuration ---
# Make less more friendly - R shows colors, F quits if one screen, X prevents screen clear.
export LESS='-R -F -X -i -M -w'
# Colored man pages using less.
export LESS_TERMCAP_mb=$'\e[1;31m'      # begin bold
export LESS_TERMCAP_md=$'\e[1;36m'      # begin blink
export LESS_TERMCAP_me=$'\e[0m'          # reset bold/blink
export LESS_TERMCAP_so=$'\e[01;44;33m'  # begin reverse video
export LESS_TERMCAP_se=$'\e[0m'          # reset reverse video
export LESS_TERMCAP_us=$'\e[1;32m'      # begin underline
export LESS_TERMCAP_ue=$'\e[0m'          # reset underline

# --- Terminal & SSH Compatibility Fixes ---
# Handle Kitty terminal over SSH - fallback to xterm-256color if terminfo unavailable.
if [[ "$TERM" == "xterm-kitty" ]]; then
    # Check if kitty terminfo is available, otherwise fallback.
    if ! infocmp xterm-kitty &>/dev/null; then
        export TERM=xterm-256color
    fi
    # Ensure the shell looks for user-specific terminfo files.
    [[ -d "$HOME/.terminfo" ]] && export TERMINFO="$HOME/.terminfo"
fi

# Fix for other modern terminals that might not be recognized on older servers.
case "$TERM" in
    alacritty|wezterm)
        if ! infocmp "$TERM" &>/dev/null; then
            export TERM=xterm-256color
        fi
        ;;
esac

# --- Prompt Configuration ---
# Set variable identifying the chroot you work in (used in the prompt below).
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Set a colored prompt only if the terminal has color capability.
case "$TERM" in
    xterm-color|*-256color|xterm-kitty|alacritty|wezterm) color_prompt=yes;;
esac

# Force color prompt support check using tput.
if [ -z "${color_prompt}" ] && [ -x /usr/bin/tput ] && tput setaf 1 &>/dev/null; then
    color_prompt=yes
fi

# Function to get git branch for prompt (defined here before PS1 is set).
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

if [ "$color_prompt" = yes ]; then
    # Green: user@host, Blue: directory, Yellow: git branch, Red: error indicator, White: prompt symbol.
    export PS1='\[\e[32m\]\u@\h\[\e[00m\]:\[\e[34m\]\w\[\e[00m\]\[\e[33m\]$(parse_git_branch)\[\e[00m\]$([ $? != 0 ] && echo "\[\e[31m\] ✗\[\e[00m\]")\$ '
else
    export PS1='\u@\h:\w\$ '
fi
unset color_prompt

# Set the terminal window title to user@host:dir for supported terminals.
case "$TERM" in
xterm*|rxvt*|kitty|alacritty|wezterm)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# --- Editor Configuration ---
# Set default editor with fallback chain.
if command -v vim &>/dev/null; then
    export EDITOR=vim
    export VISUAL=vim
elif command -v vi &>/dev/null; then
    export EDITOR=vi
    export VISUAL=vi
else
    export EDITOR=nano
    export VISUAL=nano
fi

# --- Additional Environment Variables ---
# Set default pager.
export PAGER=less
# Prevent Ctrl+S from freezing the terminal.
stty -ixon 2>/dev/null

# --- Useful Functions ---
# Create a directory and change into it.
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Create a backup of a file with timestamp.
backup() {
    if [ -f "$1" ]; then
        local backup_file="$1.backup-$(date +%Y%m%d-%H%M%S)"
        cp "$1" "$backup_file"
        echo "Backup created: $backup_file"
    else
        echo "'$1' is not a valid file" >&2
        return 1
    fi
}

# Extract any archive file with a single command.
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"      ;;
            *.tar.gz)    tar xzf "$1"      ;;
            *.tar.xz)    tar xJf "$1"      ;;
            *.bz2)       bunzip2 "$1"      ;;
            *.rar)       unrar x "$1"      ;;
            *.gz)        gunzip "$1"       ;;
            *.tar)       tar xf "$1"       ;;
            *.tbz2)      tar xjf "$1"      ;;
            *.tgz)       tar xzf "$1"      ;;
            *.zip)       unzip "$1"        ;;
            *.Z)         uncompress "$1"   ;;
            *.7z)        7z x "$1"         ;;
            *.deb)       ar x "$1"         ;;
            *.tar.zst)   tar --zstd -xf "$1" ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick directory navigation up multiple levels.
up() {
    local d=""
    local limit="${1:-1}"
    for ((i=1; i<=limit; i++)); do
        d="../$d"
    done
    cd "$d" || return
}

# Find files by name in current directory tree.
ff() {
    find . -type f -iname "*$1*" 2>/dev/null
}

# Find directories by name in current directory tree.
fd() {
    find . -type d -iname "*$1*" 2>/dev/null
}

# Search for text in files recursively.
ftext() {
    grep -rnw . -e "$1" 2>/dev/null
}

# Create a tarball of a directory.
targz() {
    if [ -d "$1" ]; then
        tar czf "${1%%/}.tar.gz" "${1%%/}"
        echo "Created ${1%%/}.tar.gz"
    else
        echo "'$1' is not a valid directory"
    fi
}

# Show disk usage of current directory, sorted by size.
duh() {
    du -h --max-depth=1 "${1:-.}" | sort -hr
}

# Get the size of a file or directory.
sizeof() {
    du -sh "$1" 2>/dev/null
}

# Show most used commands from history.
histop() {
    history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl | head -n20
}

# Quick server info.
sysinfo() {
    # --- Self-Contained Color Detection ---
    local color_support=""
    case "$TERM" in
        xterm-color|*-256color|xterm-kitty|alacritty|wezterm) color_support="yes";;
    esac
    if [ -z "$color_support" ] && [ -x /usr/bin/tput ] && tput setaf 1 &>/dev/null; then
        color_support="yes"
    fi

    # --- Color Definitions ---
    if [ "$color_support" = "yes" ]; then
        local CYAN='\e[1;36m'
        local YELLOW='\e[1;33m'
        local BOLD_RED='\e[1;31m'
        local BOLD_WHITE='\e[1;37m'
        local RESET='\e[0m'
    else
        local CYAN=''; local YELLOW=''; local BOLD_RED=''; local BOLD_WHITE=''; local RESET=''
    fi

    # --- Header ---
    printf "\n${BOLD_WHITE}=== System Information ===${RESET}\n"

    # --- Get CPU Info (Multi-architecture support) ---
    local cpu_info
    cpu_info=$(lscpu | grep 'Model name:' | sed 's/Model name:[ \t]*//' 2>/dev/null)
    if [ -z "$cpu_info" ]; then
        cpu_info=$(grep 'model name' /proc/cpuinfo | head -n 1 | cut -d ':' -f 2 | xargs 2>/dev/null)
    fi
    if [ -z "$cpu_info" ]; then
        cpu_info=$(grep '^Model' /proc/cpuinfo | head -n 1 | cut -d ':' -f 2 | xargs 2>/dev/null)
    fi

    # --- System Info ---
    printf "${CYAN}%-12s${RESET} %s\n" "Hostname:" "$(hostname)"
    printf "${CYAN}%-12s${RESET} %s\n" "OS:" "$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2)"
    printf "${CYAN}%-12s${RESET} %s\n" "Kernel:" "$(uname -r)"
    printf "${CYAN}%-12s${RESET} %s\n" "Uptime:" "$(uptime -p 2>/dev/null || uptime)"
    printf "${CYAN}%-12s${RESET} %s\n" "Server time:" "$(date)"
    printf "${CYAN}%-12s${RESET} %s\n" "CPU:" "$cpu_info"
    printf "${CYAN}%-12s${RESET} %s\n" "Memory:" "$(free -h | awk '/^Mem:/ {print $3 " / " $2}')"
    printf "${CYAN}%-12s${RESET} %s\n" "Disk:" "$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 " used)"}')"

    # --- Conditional Info: Updates and Reboot Status ---
    if [ -f /var/run/reboot-required ]; then
        printf "${CYAN}%-12s${RESET} ${BOLD_RED}REBOOT REQUIRED${RESET}\n" "System:"
    elif [ -r /var/lib/update-notifier/updates-available ]; then
        updates=$(grep -c "packages can be updated" /var/lib/update-notifier/updates-available)
        if [ "$updates" -gt 0 ]; then
            total=$(cat /var/lib/update-notifier/updates-available | awk '{print $1; exit}')
            security=$(grep "security updates" /var/lib/update-notifier/updates-available | awk '{print $1}')
            if [ -n "$security" ] && [ "$security" -gt 0 ]; then
                printf "${CYAN}%-12s${RESET} ${YELLOW}%s packages (%s security)${RESET}\n" "Updates:" "$total" "$security"
            else
                printf "${CYAN}%-12s${RESET} %s packages available\n" "Updates:" "$total"
            fi
        fi
    fi

    # Docker Info
    if command -v docker &>/dev/null; then
        if docker_states=$(timeout 2s docker ps -a --format '{{.State}}' 2>/dev/null); then
            local running=$(echo "$docker_states" | grep -c '^running$')
            local total=$(echo "$docker_states" | wc -l)
            if [ "$total" -gt 0 ]; then
                printf "${CYAN}%-12s${RESET} %s running / %s total containers\n" "Docker:" "$running" "$total"
            fi
        fi
    fi
    printf "\n"
}

# --- Aliases ---
# Enable color support for common commands.
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'
fi

# Standard ls aliases with human-readable sizes.
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -alFht'      # Sort by modification time, newest first
alias ltr='ls -alFhtr'    # Sort by modification time, oldest first
alias lS='ls -alFhS'      # Sort by size, largest first

# Safety aliases to prompt before overwriting.
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'

# Convenience & Navigation aliases.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'          # Go to previous directory
alias ~='cd ~'
alias h='history'
alias c='clear'
alias cls='clear'
alias reload='source ~/.bashrc && echo "Bashrc reloaded!"'
alias path='echo -e ${PATH//:/\\n}'  # Print PATH on separate lines

# Enhanced directory listing.
alias lsd='ls -d */'      # List only directories
alias lsf='ls -p | grep -v /'  # List only files

# System resource aliases.
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias psgrep='ps aux | grep -v grep | grep -i -e VSZ -e'
alias ports='ss -tuln'
alias listening='ss -tlnp'
alias meminfo='free -h -l -t'
alias psmem='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3 | head -10'
alias top10='ps aux --sort=-%mem | head -n 11'

# Quick network info.
alias myip='curl -s ifconfig.me'
alias localip='ip -4 addr show | grep -oP "(?<=inet\s)\d+(\.\d+){3}"'
alias netstat='ss'
alias ping='ping -c 5'
alias fastping='ping -c 100 -i 0.2'

# Date and time helpers.
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias nowdate='date +"%Y-%m-%d"'
alias timestamp='date +%s'

# File operations.
alias count='find . -type f | wc -l'  # Count files in current directory
alias cpv='rsync -ah --info=progress2'  # Copy with progress
alias wget='wget -c'  # Resume wget by default

# Git shortcuts (if git is available).
if command -v git &>/dev/null; then
    alias gs='git status'
    alias ga='git add'
    alias gc='git commit'
    alias gp='git push'
    alias gl='git log --oneline --graph --decorate'
    alias gd='git diff'
fi

# Docker shortcuts (if docker is available).
if command -v docker &>/dev/null; then
    # Core Docker aliases
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias di='docker images'
    alias dex='docker exec -it'
    alias dlog='docker logs -f'
    alias dstop='echo "This will stop all containers. Use: docker stop \$(docker ps -q)"'
    alias dclean='docker system prune -af'

    # Docker Compose aliases (check if the compose plugin exists)
    if docker compose version &>/dev/null; then
        alias dcup='docker compose up -d'
        alias dcdown='docker compose down'
        alias dclogs='docker compose logs -f'
        alias dcps='docker compose ps'
        alias dcex='docker compose exec'
        alias dcbuild='docker compose build'
        alias dcrestart='docker compose restart'
        alias dcrecreate='docker compose up -d --force-recreate'
        alias dcpull='docker compose pull'
    fi
fi

# Systemd shortcuts.
if command -v systemctl &>/dev/null; then
    alias sysstart='sudo systemctl start'
    alias sysstop='sudo systemctl stop'
    alias sysrestart='sudo systemctl restart'
    alias sysstatus='sudo systemctl status'
    alias sysenable='sudo systemctl enable'
    alias sysdisable='sudo systemctl disable'
fi

# Apt aliases for Debian/Ubuntu (only if apt is available).
if command -v apt &>/dev/null; then
    alias aptup='sudo apt update && sudo apt upgrade'
    alias aptin='sudo apt install'
    alias aptrm='sudo apt remove'
    alias aptsearch='apt search'
    alias aptshow='apt show'
    alias aptclean='sudo apt autoremove && sudo apt autoclean'
fi

# --- PATH Configuration ---
# Add user's local bin directories to PATH if they exist.
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"

# --- Server-Specific Configuration ---
# Load hostname-specific configurations if they exist.
# This allows per-server customization without modifying the main bashrc.
if [ -f ~/.bashrc."$(hostname -s)" ]; then
    source ~/.bashrc."$(hostname -s)"
fi

# --- Bash Completion & Personal Aliases ---
# Enable programmable completion features.
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Source personal aliases if the file exists.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Source local machine-specific settings that shouldn't be in version control.
if [ -f ~/.bashrc.local ]; then
    . ~/.bashrc.local
fi

# --- Welcome message for SSH sessions ---
# Show system info and context on login for SSH sessions.
if [ -n "$SSH_CONNECTION" ]; then
    # Use the existing sysinfo function for a full system overview.
    sysinfo

    # Correctly display the *actual* last login by skipping the current session.
    # `last | sed -n '2p'` intelligently grabs the second line of output.
    last_login_info=$(last "$USER" | sed -n '2p')
    if [ -n "$last_login_info" ]; then
        # The output from `last` already includes IP, date, and duration.
        printf "Last login: %s\n" "$(echo "$last_login_info" | sed 's/  */ /g')"
    fi

    # Add other useful at-a-glance information.
    printf "Users online: %s\n" "$(who | wc -l)"
    printf -- "-----------------------------------------------------\n"
fi


# --- Performance Note ---
# This configuration is optimized for performance using built-in bash operations
# and minimizing external command calls. If startup feels slow, check:
# - ~/.bash_aliases and ~/.bashrc.local for expensive operations
# - Consider moving rarely-used functions to separate files
