# .bashrc
# mv .bashrc .bashrc.bak && curl -Lo .bashrc https://raw.githubusercontent.com/buildplan/dotfiles/refs/heads/main/bashrc/fedora-ws.bashrc

# shellcheck shell=bash
# ===================================================================
#   Last Updated: 2025-10-30
# ===================================================================

# If not running interactively, don't do anything.
case $- in
    *i*) ;;
      *) return;;
esac

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# --- History Control ---
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
HISTSIZE=50000
HISTFILESIZE=100000
shopt -s histverify
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "
HISTIGNORE="ls:ll:la:l:cd:pwd:exit:clear:c:history:h"

# --- General Shell Behavior & Options ---
shopt -s checkwinsize
shopt -s globstar 2>/dev/null
shopt -s autocd 2>/dev/null
shopt -s cdspell 2>/dev/null
shopt -s dirspell 2>/dev/null
shopt -s cmdhist 2>/dev/null

# Set command-line editing mode
set -o emacs

# Make `less` more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# --- Better Less Configuration ---
export LESS='-R -F -X -i -M -w'
export LESS_TERMCAP_mb=$'\e[1;31m'      # begin blink
export LESS_TERMCAP_md=$'\e[1;36m'      # begin bold
export LESS_TERMCAP_me=$'\e[0m'         # reset bold/blink
export LESS_TERMCAP_so=$'\e[01;44;33m'  # begin reverse video
export LESS_TERMCAP_se=$'\e[0m'         # reset reverse video
export LESS_TERMCAP_us=$'\e[1;32m'      # begin underline
export LESS_TERMCAP_ue=$'\e[0m'         # reset underline

# --- XDG Base Directory Specification ---
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# --- Terminal & SSH Compatibility Fixes ---
if [[ "$TERM" == "xterm-kitty" ]]; then
    if ! infocmp xterm-kitty &>/dev/null; then
        export TERM=xterm-256color
    fi
    [[ -d "$HOME/.terminfo" ]] && export TERMINFO="$HOME/.terminfo"
fi

case "$TERM" in
    alacritty|wezterm)
        if ! infocmp "$TERM" &>/dev/null; then
            export TERM=xterm-256color
        fi
        ;;
esac

# Kitty terminal enhancements
if command -v kitty &>/dev/null; then
    alias icat='kitty +kitten icat'
    alias kssh='kitty +kitten ssh'
fi

# --- Editor Configuration ---
if command -v vim &>/dev/null; then
    export EDITOR=vim
    export VISUAL=vim
elif command -v nano &>/dev/null; then
    export EDITOR=nano
    export VISUAL=nano
else
    export EDITOR=vi
    export VISUAL=vi
fi

# --- Additional Environment Variables ---
export PAGER=less
stty -ixon 2>/dev/null

# --- PATH Configuration ---
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"

# ==================== USEFUL FUNCTIONS ====================

# Create a directory and change into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Create a backup of a file with timestamp
backup() {
    if [ -f "$1" ]; then
        local backup_file="$1.backup-$(date +%Y%m%d-%H%M%S)"
        cp "$1" "$backup_file"
        echo "Backup created: $backup_file"
    elif [ -d "$1" ]; then
        tar czf "$1.backup-$(date +%Y%m%d-%H%M%S).tar.gz" "$1"
        echo "Backup created: $1.backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    else
        echo "'$1' is not a valid file or directory" >&2
        return 1
    fi
}

# Extract any archive file with a single command
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
            *.tar.zst)
                if command -v zstd &>/dev/null; then
                    zstd -dc "$1" | tar xf -
                else
                    tar --zstd -xf "$1"
                fi
                ;;
            *)
                echo "'$1' cannot be extracted via extract()" >&2
                return 1
                ;;
        esac
    else
        echo "'$1' is not a valid file" >&2
        return 1
    fi
}

# Quick directory navigation up multiple levels
up() {
    local d=""
    local limit="${1:-1}"
    for ((i=1; i<=limit; i++)); do
        d="../$d"
    done
    cd "$d" || return
}

# Find files by name in current directory tree
ff() {
    find . -type f -iname "*$1*" 2>/dev/null
}

# Find directories by name in current directory tree
fd() {
    find . -type d -iname "*$1*" 2>/dev/null
}

# Search for text in files recursively
ftext() {
    grep -rnw . -e "$1" 2>/dev/null
}

# Search history easily
hgrep() { history | grep -i --color=auto "$@"; }

# Create a tarball of a directory
targz() {
    if [ -d "$1" ]; then
        tar czf "${1%%/}.tar.gz" "${1%%/}"
        echo "Created ${1%%/}.tar.gz"
    else
        echo "'$1' is not a valid directory" >&2
        return 1
    fi
}

# Show disk usage of current directory, sorted by size
duh() {
    du -h --max-depth=1 "${1:-.}" | sort -hr
}

# Get the size of a file or directory
sizeof() {
    du -sh "$1" 2>/dev/null
}

# Show most used commands from history
histop() {
    history | awk -v ig="$HISTIGNORE" 'BEGIN{OFS="\t";gsub(/:/,"|",ig);ir="^("ig")($| )";sr="(^|\\s)\\./"}
    {cmd=$4;for(i=5;i<=NF;i++)cmd=cmd" "$i}
    (cmd==""||cmd~ir||cmd~sr){next}
    {C[cmd]++;t++}
    END{if(t>0)for(a in C)printf"%d\t%.2f%%\t%s\n",C[a],(C[a]/t*100),a}' |
    sort -nr | head -n20 |
    awk 'BEGIN{
        FS="\t";
        maxc=length("COUNT");
        maxp=length("PERCENT");
    }
    {
        data[NR]=$0;
        len1=length($1);
        len2=length($2);
        if(len1>maxc)maxc=len1;
        if(len2>maxp)maxp=len2;
    }
    END{
        fmt="  %-4s %-*s  %-*s  %s\n";
        printf fmt,"RANK",maxc,"COUNT",maxp,"PERCENT","COMMAND";
        sep_c=sep_p="";
        for(i=1;i<=maxc;i++)sep_c=sep_c"-";
        for(i=1;i<=maxp;i++)sep_p=sep_p"-";
        printf fmt,"----",maxc,sep_c,maxp,sep_p,"-------";
        for(i=1;i<=NR;i++){
            split(data[i],f,"\t");
            printf fmt,i".",maxc,f[1],maxp,f[2],f[3]
        }
    }'
}

# Quick server/workstation info display
sysinfo() {
    local color_support=""
    case "$TERM" in
        xterm-color|*-256color|xterm-kitty|alacritty|wezterm) color_support="yes";;
    esac
    if [ -z "$color_support" ] && [ -x /usr/bin/tput ] && tput setaf 1 &>/dev/null; then
        color_support="yes"
    fi

    if [ "$color_support" = "yes" ]; then
        local CYAN='\e[1;36m'
        local YELLOW='\e[1;33m'
        local BOLD_RED='\e[1;31m'
        local BOLD_WHITE='\e[1;37m'
        local GREEN='\e[1;32m'
        local DIM='\e[2m'
        local RESET='\e[0m'
    else
        local CYAN='' YELLOW='' BOLD_RED='' BOLD_WHITE='' GREEN='' DIM='' RESET=''
    fi

    printf "\n${BOLD_WHITE}=== System Information ===${RESET}\n"

    # CPU info
    local cpu_info
    cpu_info=$(lscpu 2>/dev/null | awk -F: '/Model name/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')
    [ -z "$cpu_info" ] && cpu_info=$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d ':' -f2 | xargs)
    [ -z "$cpu_info" ] && cpu_info="Unknown"

    # IP address detection with timeout and Tailscale handling
    local ip_addr public_ipv4

    # Get public IP with short timeout to avoid hanging
    public_ipv4=$(timeout 2 curl -4 -s --max-time 1 --connect-timeout 1 https://ifconfig.me 2>/dev/null || \
                  timeout 2 curl -4 -s --max-time 1 --connect-timeout 1 https://icanhazip.com 2>/dev/null)

    # Get local IP, excluding Tailscale and Docker interfaces
    for iface in eth0 ens3 enp0s3 enp1s0 eno1 wlan0 wlp2s0 wlp3s0 wlo1; do
        if ip link show "$iface" &>/dev/null; then
            ip_addr=$(ip -4 addr show "$iface" 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)
            [ -n "$ip_addr" ] && break
        fi
    done

    # Fallback: get first non-loopback, non-tailscale, non-docker IP
    if [ -z "$ip_addr" ]; then
        ip_addr=$(ip -4 addr show scope global 2>/dev/null | \
                  grep -v 'tailscale\|docker\|veth' | \
                  awk '/inet/ {print $2}' | cut -d/ -f1 | \
                  grep -v '^100\.' | head -n1)
    fi

    # Display hostname with IPs
    if [ -n "$public_ipv4" ]; then
        printf "${CYAN}%-15s${RESET} %s  ${YELLOW}[%s]${RESET}" "Hostname:" "$(hostname -s)" "$public_ipv4"
        if [ -n "$ip_addr" ] && [ "$ip_addr" != "$public_ipv4" ]; then
            printf " ${DIM}(local: %s)${RESET}\n" "$ip_addr"
        else
            printf "\n"
        fi
    elif [ -n "$ip_addr" ]; then
        printf "${CYAN}%-15s${RESET} %s  ${YELLOW}[%s]${RESET}\n" "Hostname:" "$(hostname -s)" "$ip_addr"
    else
        printf "${CYAN}%-15s${RESET} %s\n" "Hostname:" "$(hostname -s)"
    fi

    # OS info
    printf "${CYAN}%-15s${RESET} %s\n" "OS:" "$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo 'Unknown')"

    # Kernel
    printf "${CYAN}%-15s${RESET} %s\n" "Kernel:" "$(uname -r)"

    # Uptime
    printf "${CYAN}%-15s${RESET} %s\n" "Uptime:" "$(uptime -p 2>/dev/null || uptime | sed 's/.*up //' | sed 's/,.*//')"

    # Time
    printf "${CYAN}%-15s${RESET} %s\n" "Time:" "$(date '+%Y-%m-%d %H:%M:%S %Z')"

    # CPU
    printf "${CYAN}%-15s${RESET} %s\n" "CPU:" "$cpu_info"

    # Memory - Simple approach that works with Fedora's free output
    printf "${CYAN}%-15s${RESET} " "Memory:"
    local mem_info
    mem_info=$(free -h | awk 'NR==2 {print $3 " / " $2}')
    local mem_percent
    mem_percent=$(free | awk 'NR==2 {printf "%.0f", $3/$2 * 100}')
    printf "%s (%s%% used)\n" "$mem_info" "$mem_percent"

    # Disk usage
    printf "${CYAN}%-15s${RESET} %s\n" "Disk (/):" "$(df -h / 2>/dev/null | awk 'NR==2 {print $3 " / " $2 " (" $5 " used)"}')"

    # Tailscale status - Simplified to use tailscale ip command
    if command -v tailscale &>/dev/null; then
        local ts_ip
        ts_ip=$(timeout 1 tailscale ip -4 2>/dev/null | head -n1)
        if [ -n "$ts_ip" ]; then
            # Check if tailscale status shows we're connected
            if timeout 1 tailscale status &>/dev/null; then
                printf "${CYAN}%-15s${RESET} ${GREEN}Connected${RESET} ${DIM}(%s)${RESET}\n" "Tailscale:" "$ts_ip"
            fi
        fi
    fi

    # Fedora-specific: Check for dnf updates
    if command -v dnf &>/dev/null; then
        local updates
        updates=$(timeout 3 dnf check-update -q 2>/dev/null | grep -v "^$" | grep -v "Last metadata" | wc -l)
        if [ -n "$updates" ] && [ "$updates" -gt 0 ]; then
            printf "${CYAN}%-15s${RESET} ${YELLOW}%s packages${RESET}\n" "DNF Updates:" "$updates"
        fi
    fi

    # Docker info
    if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
        local running total
        running=$(docker ps -q 2>/dev/null | wc -l)
        total=$(docker ps -aq 2>/dev/null | wc -l)
        if [ "$total" -gt 0 ]; then
            printf "${CYAN}%-15s${RESET} ${GREEN}%s running${RESET} / %s total containers\n" "Docker:" "$running" "$total"
        fi
    fi

    printf "\n"
}

# Disk space alert (warns if any partition > 80%)
diskcheck() {
    df -h | awk '
        NR > 1 {
            usage = $5
            gsub(/%/, "", usage)
            if (usage > 80) {
                printf "⚠️  %s\n", $0
                found = 1
            }
        }
        END {
            if (!found) print "✓ All disks below 80%"
        }
    '
}

# Directory bookmarks
export MARKPATH=$HOME/.marks
[ -d "$MARKPATH" ] || mkdir -p "$MARKPATH"
mark() { ln -sfn "$(pwd)" "$MARKPATH/${1:-$(basename "$PWD")}"; }
jump() { cd -P "$MARKPATH/$1" 2>/dev/null || ls -l "$MARKPATH"; }

# Service status shortcut
svc() { sudo systemctl status "$1" --no-pager -l | head -20; }

# Show top 10 processes by CPU
topcpu() { ps aux --sort=-%cpu | head -11; }

# Show top 10 processes by memory
topmem() { ps aux --sort=-%mem | head -11; }

# Network connections summary
netsum() {
    echo "=== Active Connections ==="
    ss -s
    echo -e "\n=== Listening Ports ==="
    sudo ss -tulnp | grep LISTEN | awk '{print $5, $7}' | sort -u
}

# GitHub clone helper
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

# Script testing helper
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

# ==================== ALIASES ====================

# Enable color support for common commands
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias egrep='grep -E --color=auto'
    alias fgrep='grep -F --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'
fi

# Standard ls aliases
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -alFht'
alias ltr='ls -alFhtr'
alias lS='ls -alFhS'
alias lsd='ls -d */ 2>/dev/null'
alias lsf='find . -maxdepth 1 -type f -printf "%f\n"'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'

# Navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'
alias ~='cd ~'
alias h='history'
alias c='clear'
alias cls='clear'
alias reload='source ~/.bashrc && echo "Bashrc reloaded!"'

# PATH printer
unalias path 2>/dev/null
path() {
    printf '%s\n' "${PATH//:/$'\n'}"
}

# System resource helpers
alias df='df -h'
alias du='du -h'
alias free='free -h'
unalias psgrep 2>/dev/null
psgrep() {
    if [ $# -eq 0 ]; then
        echo "Usage: psgrep <pattern>" >&2
        return 1
    fi
    local pattern
    local term="$1"
    pattern="[${term:0:1}]${term:1}"
    ps aux | grep -i "$pattern"
}

alias ports='ss -tuln'
alias listening='ss -tlnp'
alias meminfo='free -h -l -t'
alias psmem='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3 | head -10'
alias top10='ps aux --sort=-%mem | head -n 11'

# Network aliases
alias myip='curl -s ifconfig.me || curl -s icanhazip.com'
localip() {
    ip -4 addr | awk '/inet/ {print $2}' | cut -d/ -f1 | grep -v '127.0.0.1'
}
alias netstat='ss'
alias ping='ping -c 5'
alias fastping='ping -c 100 -i 0.2'

# Date and time helpers
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias nowdate='date +"%Y-%m-%d"'
alias timestamp='date +%s'

# File operations
alias count='find . -type f | wc -l'
alias cpv='rsync -ah --info=progress2'
alias wget='wget -c'

# Git completion for Fedora
if [ -f /usr/share/bash-completion/completions/git ]; then
    . /usr/share/bash-completion/completions/git
fi

# Git shortcuts
if command -v git &>/dev/null; then
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
    __git_complete g __git_main 2>/dev/null
    __git_complete gco _git_checkout 2>/dev/null
    __git_complete gb _git_branch 2>/dev/null
    __git_complete gm _git_merge 2>/dev/null
    __git_complete gp _git_push 2>/dev/null
    __git_complete gpl _git_pull 2>/dev/null
    __git_complete gf _git_fetch 2>/dev/null
fi

# ==================== DOCKER SHORTCUTS ====================

if command -v docker &>/dev/null; then
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
    alias dprune='docker system prune -f'
    alias dprunea='docker system prune -af'
    alias ddf='docker system df'
    alias dvprune='docker volume prune -f'
    alias diprune='docker image prune -af'
    alias dstats='docker stats --no-stream'
    alias dstatsa='docker stats'

    dtop() {
        docker stats --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}'
    }

    alias dstopa='echo "To stop all containers, run: docker stop \$(docker ps -q)"'
    alias dstarta='docker start $(docker ps -aq)'

    # Docker Compose
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

    # Docker functions
    dsh() {
        if [ -z "$1" ]; then
            echo "Usage: dsh <container-name-or-id>" >&2
            return 1
        fi
        docker exec -it "$1" bash 2>/dev/null || docker exec -it "$1" sh
    }

    dcsh() {
        if [ -z "$1" ]; then
            echo "Usage: dcsh <service-name>" >&2
            return 1
        fi
        docker compose exec "$1" bash 2>/dev/null || docker compose exec "$1" sh
    }

    dfollow() {
        if [ -z "$1" ]; then
            echo "Usage: dfollow <container-name-or-id> [lines]" >&2
            return 1
        fi
        local lines="${2:-100}"
        docker logs -f --tail "$lines" "$1"
    }

    dip() {
        if [ -z "$1" ]; then
            docker ps -q | xargs -I {} docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' {} 2>/dev/null
        else
            docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$1" 2>/dev/null
        fi
    }

    denv() {
        if [ -z "$1" ]; then
            echo "Usage: denv <container-name-or-id>" >&2
            return 1
        fi
        docker inspect "$1" --format '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null | sort
    }

    dclean() {
        printf 'Stopping all containers...\n'
        docker stop "$(docker ps -q)" 2>/dev/null
        printf 'Removing containers, images, volumes...\n'
        docker system prune -af --volumes
        printf 'Docker cleanup complete.\n'
    }

    dcstatus() {
        printf "\n=== Docker Compose Services ===\n\n"
        docker compose ps --format 'table {{.Name}}\t{{.Status}}\t{{.Ports}}'
        printf "\n=== Resource Usage ===\n\n"
        docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}'
        printf "\n"
    }

    dcreload() {
        if [ -z "$1" ]; then
            echo "Usage: dcreload <service-name>" >&2
            return 1
        fi
        docker compose restart "$1" && docker compose logs -f "$1"
    }

    dcupdate() {
        if [ -z "$1" ]; then
            echo "Usage: dcupdate <service-name>" >&2
            return 1
        fi
        docker compose pull "$1" && docker compose up -d "$1" && docker compose logs -f "$1"
    }
fi

# Systemd shortcuts
if command -v systemctl &>/dev/null; then
    alias sysstart='sudo systemctl start'
    alias sysstop='sudo systemctl stop'
    alias sysrestart='sudo systemctl restart'
    alias sysstatus='sudo systemctl status'
    alias sysenable='sudo systemctl enable'
    alias sysdisable='sudo systemctl disable'
    alias sysreload='sudo systemctl daemon-reload'
    alias failed='systemctl --failed --no-pager'
fi

# Fedora-specific package management
if command -v dnf &>/dev/null; then
    alias update='sudo dnf update -y && flatpak update -y'
    alias cleanup='sudo dnf autoremove -y && sudo dnf clean all'
    alias dnfin='sudo dnf install'
    alias dnfrm='sudo dnf remove'
    alias dnfsearch='dnf search'
    alias dnfinfo='dnf info'
fi

# Quick edits
alias bashrc='$EDITOR ~/.bashrc && source ~/.bashrc'
alias vimrc='$EDITOR ~/.vimrc'
alias sshconfig='$EDITOR ~/.ssh/config'
alias hosts='sudo $EDITOR /etc/hosts'

# Last command with sudo
alias please='sudo $(history -p !!)'

# ==================== HELP SYSTEM ====================

helpme() {
    cat << 'HELPTEXT'

╔════════════════════════════════════════════════════════╗
║        Fedora Workstation - Quick Reference            ║
╚════════════════════════════════════════════════════════╝

📁 NAVIGATION
  .., ..., ...., home      Navigate directories
  mkcd <dir>               Create and enter directory
  up <n>                   Go up N directories
  mark/jump                Bookmark/jump to directories

📄 FILES
  ll, la, lt, lS           List files (various sorts)
  ff/fd <name>             Find files/directories
  extract <file>           Extract archives
  backup <file>            Create timestamped backup
  targz <dir>              Create tar.gz archive
  duh                      Disk usage sorted

💻 SYSTEM
  sysinfo                  System overview
  topcpu/topmem            Top processes
  psgrep <name>            Find process
  ports/listening          Network ports
  diskcheck                Check disk usage
  failed                   Failed systemd services

🔀 GIT (with tab completion)
  gs, ga, gc, gp, gl       Git shortcuts
  gcp "msg"                Quick commit+push
  gstatus                  Status of all repos
  ghclone user/repo        Clone from GitHub
  testscript <file>        Shellcheck + syntax check

🐳 DOCKER
  dps, di, dv, dn          List containers/images/volumes
  dsh <id>                 Enter container shell
  dip, denv, dfollow       Inspect containers
  dcup, dcdown, dclogs     Docker Compose
  dcstatus                 Compose services status
  dcupdate <srv>           Pull & update service

⚙️  FEDORA
  update                   Update dnf + flatpak
  cleanup                  Clean package cache
  dnfin/dnfrm              Install/remove packages
  sysstart/sysstop         Manage services

📚 HELP
  helpme                   This help
  histop                   Most used commands
  commands                 List all aliases/functions

HELPTEXT
}

alias bh='helpme'
alias commands='compgen -A function -A alias | grep -v "^_" | sort | column'

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

# Load hostname-specific configurations
if [ -f ~/.bashrc."$(hostname -s)" ]; then
    # shellcheck disable=SC1090
    source ~/.bashrc."$(hostname -s)"
fi

# Source personal aliases
if [ -f ~/.bash_aliases ]; then
    # shellcheck disable=SC1090
    . ~/.bash_aliases
fi

# Source local machine-specific settings
if [ -f ~/.bashrc.local ]; then
    # shellcheck disable=SC1090
    . ~/.bashrc.local
fi

# Enable programmable completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
      # shellcheck disable=SC1091
      . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
      # shellcheck disable=SC1091
      . /etc/bash_completion
  fi
fi

# ==================== INITIALIZATION ====================

# Initialize ble.sh before Starship
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

# Attach ble.sh after Starship
if [[ ${BLE_VERSION-} ]]; then
    ble-attach
fi