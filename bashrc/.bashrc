# ===================================================================
#   Universal Portable .bashrc for Modern Terminals
#   Optimized for Debian/Ubuntu servers with multi-terminal support
#   Version: 2.1
#   Last Updated: 2025-10-12
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
# Add timestamp to history entries for audit trail (ISO 8601 format).
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "
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
# Case-insensitive globbing (commented out to avoid unexpected behavior).
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
# Colored man pages using less (TERMCAP sequences).
export LESS_TERMCAP_mb=$'\e[1;31m'      # begin blink
export LESS_TERMCAP_md=$'\e[1;36m'      # begin bold
export LESS_TERMCAP_me=$'\e[0m'         # reset bold/blink
export LESS_TERMCAP_so=$'\e[01;44;33m'  # begin reverse video
export LESS_TERMCAP_se=$'\e[0m'         # reset reverse video
export LESS_TERMCAP_us=$'\e[1;32m'      # begin underline
export LESS_TERMCAP_ue=$'\e[0m'         # reset underline

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

# Optional: if kitty exists locally, provide a convenience alias for SSH.
# (No effect on hosts without kitty installed.)
if command -v kitty &>/dev/null; then
    alias kssh='kitty +kitten ssh'
fi

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

# Function to get git branch for prompt (optimized to only run in git repos).
parse_git_branch() {
    # Only run in git repositories for performance.
    if git rev-parse --git-dir &>/dev/null; then
        git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
    fi
    return 0  # Always return success to not pollute $?
}

# Precompute exit status indicator safely via PROMPT_COMMAND.
__prompt_status() {
    local rc=$?
    if (( rc != 0 )); then
        PS1_STATUS="\[\e[31m\] ✗\[\e[0m\]"
    else
        PS1_STATUS=""
    fi
}

if [ "$color_prompt" = yes ]; then
    # Green: user@host, Blue: directory, Yellow: git branch, Red: error indicator, White: prompt symbol.
    export PS1='${debian_chroot:+($debian_chroot)}\[\e[32m\]\u@\h\[\e[00m\]:\[\e[34m\]\w\[\e[00m\]\[\e[33m\]$(parse_git_branch)\[\e[00m\]${PS1_STATUS}\$ '
else
    export PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w${PS1_STATUS}\$ '
fi

# Ensure __prompt_status runs first in PROMPT_COMMAND without duplication.
case ";$PROMPT_COMMAND;" in
  *";__prompt_status;"*) ;;
  *) PROMPT_COMMAND="__prompt_status; ${PROMPT_COMMAND}";;
esac

# Set the terminal window title to user@host:dir for supported terminals.
case "$TERM" in
  xterm*|rxvt*|xterm-kitty|alacritty|wezterm)
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
        echo "'$1' is not a valid file" >&2
        return 1
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
        echo "'$1' is not a valid directory" >&2
        return 1
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

# Quick server info display.
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
        local GREEN='\e[1;32m'
        local RESET='\e[0m'
    else
        local CYAN=''; local YELLOW=''; local BOLD_RED=''; local BOLD_WHITE=''; local GREEN=''; local RESET=''
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
    [ -z "$cpu_info" ] && cpu_info="Unknown"

    # --- System Info ---
    printf "${CYAN}%-13s${RESET} %s\n" "Hostname:" "$(hostname)"
    printf "${CYAN}%-13s${RESET} %s\n" "OS:" "$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo 'Unknown')"
    printf "${CYAN}%-13s${RESET} %s\n" "Kernel:" "$(uname -r)"
    printf "${CYAN}%-13s${RESET} %s\n" "Uptime:" "$(uptime -p 2>/dev/null || uptime | sed 's/.*up //' | sed 's/,.*//')"
    printf "${CYAN}%-13s${RESET} %s\n" "Server time:" "$(date '+%Y-%m-%d %H:%M:%S %Z')"
    printf "${CYAN}%-13s${RESET} %s\n" "CPU:" "$cpu_info"
    printf "${CYAN}%-13s${RESET} %s\n" "Memory:" "$(free -h | awk '/^Mem:/ {print $3 " / " $2 " (" int($3/$2 * 100) "% used)"}')"
    printf "${CYAN}%-13s${RESET} %s\n" "Disk (/):" "$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 " used)"}')"

    # --- Reboot Status ---
    if [ -f /var/run/reboot-required ]; then
        printf "${CYAN}%-13s${RESET} ${BOLD_RED}⚠ REBOOT REQUIRED${RESET}\n" "System:"
    fi

    # --- Available Updates (Prefer apt-check when present) ---
    if command -v apt-get &>/dev/null; then
        # Method 0: Use apt-check from update-notifier-common if available
        if [ -x /usr/lib/update-notifier/apt-check ]; then
            IFS=';' read -r total security < <(/usr/lib/update-notifier/apt-check 2>&1)
            if [ -n "$total" ] && [ "$total" -gt 0 ] 2>/dev/null; then
                if [ -n "$security" ] && [ "$security" -gt 0 ] 2>/dev/null; then
                    printf "${CYAN}%-13s${RESET} ${YELLOW}%s packages (%s security)${RESET}\n" "Updates:" "$total" "$security"
                else
                    printf "${CYAN}%-13s${RESET} %s packages available\n" "Updates:" "$total"
                fi
            fi
        # Method 1: update-notifier drop file (fast)
        elif [ -r /var/lib/update-notifier/updates-available ]; then
            local total security
            total=$(grep "packages can be updated" /var/lib/update-notifier/updates-available 2>/dev/null | awk '{print $1}')
            security=$(grep "security updates" /var/lib/update-notifier/updates-available 2>/dev/null | awk '{print $1}')
            if [ -n "$total" ] && [ "$total" -gt 0 ] 2>/dev/null; then
                if [ -n "$security" ] && [ "$security" -gt 0 ] 2>/dev/null; then
                    printf "${CYAN}%-13s${RESET} ${YELLOW}%s packages (%s security)${RESET}\n" "Updates:" "$total" "$security"
                else
                    printf "${CYAN}%-13s${RESET} %s packages available\n" "Updates:" "$total"
                fi
            fi
        else
            # Method 2: apt list fallback (only if lists are recent)
            local apt_lists_age=0
            if [ -d /var/lib/apt/lists ]; then
                apt_lists_age=$(find /var/lib/apt/lists -maxdepth 1 -type f -name '*Packages' -mtime -1 2>/dev/null | wc -l)
            fi
            if [ "$apt_lists_age" -gt 0 ]; then
                local upgradable security_count
                upgradable=$(apt list --upgradable 2>/dev/null | grep -c "upgradable")
                if [ "$upgradable" -gt 0 ]; then
                    security_count=$(apt list --upgradable 2>/dev/null | grep -ci "security")
                    if [ "$security_count" -gt 0 ]; then
                        printf "${CYAN}%-13s${RESET} ${YELLOW}%s packages (%s security)${RESET}\n" "Updates:" "$upgradable" "$security_count"
                    else
                        printf "${CYAN}%-13s${RESET} %s packages available\n" "Updates:" "$upgradable"
                    fi
                fi
            fi
        fi
    fi

    # --- Docker Info ---
    if command -v docker &>/dev/null; then
        if docker_states=$(timeout 2s docker ps -a --format '{{.State}}' 2>/dev/null); then
            local running total
            running=$(echo "$docker_states" | grep -c '^running$' || echo "0")
            total=$(echo "$docker_states" | wc -l)
            if [ "$total" -gt 0 ]; then
                printf "${CYAN}%-13s${RESET} ${GREEN}%s running${RESET} / %s total containers\n" "Docker:" "$running" "$total"
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
alias lt='ls -alFht'       # Sort by modification time, newest first
alias ltr='ls -alFhtr'     # Sort by modification time, oldest first
alias lS='ls -alFhS'       # Sort by size, largest first

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
alias -- -='cd -'           # Go to previous directory
alias ~='cd ~'
alias h='history'
alias c='clear'
alias cls='clear'
alias reload='source ~/.bashrc && echo "Bashrc reloaded!"'
alias path='echo -e ${PATH//:/\\n}'  # Print PATH on separate lines

# Enhanced directory listing.
alias lsd='ls -d */ 2>/dev/null'      # List only directories
alias lsf='ls -p | grep -v /'         # List only files

# System resource helpers.
alias df='df -h'
alias du='du -h'
alias free='free -h'
# psgrep as a function to accept patterns reliably
psgrep() {
    if [ $# -eq 0 ]; then
        echo "Usage: psgrep <pattern>" >&2
        return 1
    fi
    ps aux | grep -i "$@" | grep -v grep
}
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
    alias gb='git branch'
    alias gco='git checkout'
fi

# --- Docker Shortcuts and Functions ---
if command -v docker &>/dev/null; then
    # Core Docker aliases
    alias d='docker'
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias dpsq='docker ps -q'
    alias di='docker images'
    alias dv='docker volume ls'
    alias dn='docker network ls'
    alias dex='docker exec -it'
    alias dlog='docker logs -f'
    alias dins='docker inspect'
    alias drm='docker rm'
    alias drmi='docker rmi'
    alias dpull='docker pull'

    # Docker system management
    alias dprune='docker system prune -f'
    alias dprunea='docker system prune -af'
    alias ddf='docker system df'
    alias dvprune='docker volume prune -f'
    alias diprune='docker image prune -af'

    # Docker stats
    alias dstats='docker stats --no-stream'
    alias dstatsa='docker stats'
    alias dtop='docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"'

    # Safe stop all (shows command instead of executing)
    alias dstopall='echo "To stop all containers, run: docker stop \$(docker ps -q)"'

    # Docker Compose v2 aliases (check if the compose plugin exists)
    if docker compose version &>/dev/null; then
        alias dc='docker compose'
        alias dcup='docker compose up -d'
        alias dcdown='docker compose down'
        alias dclogs='docker compose logs -f'
        alias dcps='docker compose ps'
        alias dcex='docker compose exec'
        alias dcbuild='docker compose build'
        alias dcbn='docker compose build --no-cache'
        alias dcrestart='docker compose restart'
        alias dcrecreate='docker compose up -d --force-recreate'
        alias dcpull='docker compose pull'
        alias dcstop='docker compose stop'
        alias dcstart='docker compose start'
        alias dcconfig='docker compose config'
        alias dcvalidate='docker compose config --quiet && echo "✓ docker-compose.yml is valid" || echo "✗ docker-compose.yml has errors"'
    fi

    # --- Docker Functions ---

    # Enter container shell (bash or sh fallback)
    dsh() {
        if [ -z "$1" ]; then
            echo "Usage: dsh <container-name-or-id>" >&2
            return 1
        fi
        docker exec -it "$1" bash 2>/dev/null || docker exec -it "$1" sh
    }

    # Docker Compose enter shell (bash or sh fallback)
    dcsh() {
        if [ -z "$1" ]; then
            echo "Usage: dcsh <service-name>" >&2
            return 1
        fi
        docker compose exec "$1" bash 2>/dev/null || docker compose exec "$1" sh
    }

    # Follow logs for a specific container with tail
    dfollow() {
        if [ -z "$1" ]; then
            echo "Usage: dfollow <container-name-or-id> [lines]" >&2
            return 1
        fi
        local lines="${2:-100}"
        docker logs -f --tail "$lines" "$1"
    }

    # Show container IP addresses
    dip() {
        if [ -z "$1" ]; then
            docker ps -q | xargs -I {} docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' {} 2>/dev/null
        else
            docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$1" 2>/dev/null
        fi
    }

    # Show bind mounts for containers
    dbinds() {
        if [ -z "$1" ]; then
            printf "\n\033[1;32mContainer Bind Mounts:\033[0m\n"
            printf "═══════════════════════════════════════════════════════════════\n"
            docker ps --format '{{.Names}}' | while read container; do
                printf "\n\033[1;32m%s\033[0m:\n" "$container"
                docker inspect "$container" --format '{{range .Mounts}}{{if eq .Type "bind"}}  {{.Source}} → {{.Destination}}{{println}}{{end}}{{end}}' 2>/dev/null
            done
            printf "\n"
        else
            printf "\nBind mounts for %s:\n" "$1"
            docker inspect "$1" --format '{{range .Mounts}}{{if eq .Type "bind"}}  {{.Source}} → {{.Destination}}{{println}}{{end}}{{end}}' 2>/dev/null
        fi
    }

    # Show disk usage by containers (enable size reporting)
    dsize() {
        printf "\n%-40s %s\n" "Container" "Size"
        printf "═══════════════════════════════════════════════════════════════\n"
        docker ps -a --size --format '{{.Names}}\t{{.Size}}' | column -t
        printf "\n"
    }

    # Restart a compose service and follow logs
    dcreload() {
        if [ -z "$1" ]; then
            echo "Usage: dcreload <service-name>" >&2
            return 1
        fi
        docker compose restart "$1" && docker compose logs -f "$1"
    }

    # Update and restart a single compose service
    dcupdate() {
        if [ -z "$1" ]; then
            echo "Usage: dcupdate <service-name>" >&2
            return 1
        fi
        docker compose pull "$1" && docker compose up -d "$1" && docker compose logs -f "$1"
    }

    # Show Docker Compose services status with detailed info
    dcstatus() {
        printf "\n=== Docker Compose Services ===\n\n"
        docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
        printf "\n=== Resource Usage ===\n\n"
        docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
        printf "\n"
    }

    # Watch Docker Compose logs for specific service with grep
    dcgrep() {
        if [ -z "$1" ] || [ -z "$2" ]; then
            echo "Usage: dcgrep <service-name> <search-pattern>" >&2
            return 1
        fi
        docker compose logs -f "$1" | grep --color=auto -i "$2"
    }

    # Show environment variables for a container
    denv() {
        if [ -z "$1" ]; then
            echo "Usage: denv <container-name-or-id>" >&2
            return 1
        fi
        docker inspect "$1" --format '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null | sort
    }

    # Remove all stopped containers
    drmall() {
        local containers
        containers=$(docker ps -aq -f status=exited 2>/dev/null)
        if [ -n "$containers" ]; then
            docker rm $containers
            echo "Removed all stopped containers"
        else
            echo "No stopped containers to remove"
        fi
    }
fi

# Systemd shortcuts.
if command -v systemctl &>/dev/null; then
    alias sysstart='sudo systemctl start'
    alias sysstop='sudo systemctl stop'
    alias sysrestart='sudo systemctl restart'
    alias sysstatus='sudo systemctl status'
    alias sysenable='sudo systemctl enable'
    alias sysdisable='sudo systemctl disable'
    alias sysreload='sudo systemctl daemon-reload'
fi

# Apt aliases for Debian/Ubuntu (only if apt is available).
if command -v apt &>/dev/null; then
    alias aptup='sudo apt update && sudo apt upgrade'
    alias aptin='sudo apt install'
    alias aptrm='sudo apt remove'
    alias aptsearch='apt search'
    alias aptshow='apt show'
    alias aptclean='sudo apt autoremove && sudo apt autoclean'
    alias aptlist='apt list --installed'
fi

# --- PATH Configuration ---
# Add user's local bin directories to PATH if they exist.
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"

# --- Server-Specific Configuration ---
# Load hostname-specific configurations if they exist.
# This allows per-server customization without modifying the main bashrc.
if [ -f ~/.bashrc."$(hostname -s)" ]; then
    # shellcheck disable=SC1090
    source ~/.bashrc."$(hostname -s)"
fi

# --- Bash Completion & Personal Aliases ---
# Enable programmable completion features.
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    # shellcheck disable=SC1091
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    # shellcheck disable=SC1091
    . /etc/bash_completion
  fi
fi

# Source personal aliases if the file exists.
if [ -f ~/.bash_aliases ]; then
    # shellcheck disable=SC1090
    . ~/.bash_aliases
fi

# Source local machine-specific settings that shouldn't be in version control.
if [ -f ~/.bashrc.local ]; then
    # shellcheck disable=SC1090
    . ~/.bashrc.local
fi

# --- Welcome Message for SSH Sessions ---
# Show system info and context on login for SSH sessions.
if [ -n "$SSH_CONNECTION" ]; then
    # Use the existing sysinfo function for a full system overview.
    sysinfo

    # Display previous login information (skip current session)
    last_login=$(last -R "$USER" 2>/dev/null | sed -n '2p' | awk '{$1=""; print}' | xargs)
    [ -n "$last_login" ] && printf "Last login: %s\n" "$last_login"

    # Show active sessions
    printf "Active sessions: %s\n" "$(who | wc -l)"
    printf -- "-----------------------------------------------------\n\n"
fi

# --- Performance Note ---
# This configuration is optimized for performance using built-in bash operations
# and minimizing external command calls. If startup feels slow, check:
# - ~/.bash_aliases and ~/.bashrc.local for expensive operations
# - Consider moving rarely-used functions to separate files
# - Use 'time bash -i -c exit' to measure startup time
