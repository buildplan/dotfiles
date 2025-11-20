# ==========================================
# ZSH CORE SETTINGS & COMPLETION
# ==========================================
autoload -Uz compinit
zmodload zsh/complist
compinit

# COMPLETION SETTINGS
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'       # Case insensitive
zstyle ':completion:*' menu select                           # Arrow key menu
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS} # Colors
_comp_options+=(globdots)                                    # Match hidden files
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

# ==========================================
# HISTORY & OPTIONS
# ==========================================
unsetopt BEEP
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY          # Write history in ":start:elapsed;command" format
setopt INC_APPEND_HISTORY        # Write immediately
setopt SHARE_HISTORY             # Share between sessions
setopt HIST_IGNORE_DUPS          # Ignore duplicates
setopt HIST_IGNORE_SPACE         # Ignore space-started commands
setopt AUTO_CD                   # cd just by typing directory name

# ==========================================
# EXPORTS
# ==========================================
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export LINUXTOOLBOXDIR="$HOME/linuxtoolbox"

export EDITOR=nvim
export VISUAL=nvim
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'

export PATH=$PATH:"$HOME/.local/bin:$HOME/.cargo/bin:/var/lib/flatpak/exports/bin:/.local/share/flatpak/exports/bin"

# ==========================================
# ALIASES
# ==========================================
# General
alias spico='sudo pico'
alias snano='sudo nano'
alias vim='nvim'
alias vi='nvim'
alias svi='sudo vi'
alias vis='nvim "+set si"'
alias web='cd /var/www/html'
alias ebrc='edit ~/.zshrc'
alias da='date "+%Y-%m-%d %A %T %Z"'

# Operations
alias cp='cp -i'
alias mv='mv -i'
alias rm='trash -v'
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ping='ping -c 10'
alias less='less -R'
alias cls='clear'
alias c='clear'
alias apt-get='sudo apt-get'
alias multitail='multitail --no-repeat -c'
alias freshclam='sudo freshclam'
alias yayf="yay -Slq | fzf --multi --preview 'yay -Sii {1}' --preview-window=down:75% | xargs -ro yay -S"

# Listing
alias la='ls -Alh'
alias ls='ls -aFh --color=always'
alias lx='ls -lXBh'
alias lk='ls -lSrh'
alias lc='ls -ltcrh'
alias lu='ls -lturh'
alias lr='ls -lRh'
alias lt='ls -ltrh'
alias lm='ls -alh |more'
alias lw='ls -xAh'
alias ll='ls -Fls'
alias labc='ls -lap'
alias lf="ls -l | egrep -v '^d'"
alias ldir="ls -l | egrep '^d'"
alias lla='ls -Al'
alias las='ls -A'
alias lls='ls -l'

# Permissions
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Search & System
alias h="history | grep "
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
alias f="find . | grep "
alias checkcommand="whence -v" 
alias openports='netstat -nape --inet'

# Utils
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias mountedinfo='df -hT'
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"
alias sha1='openssl sha1'
alias clickpaste='sleep 3; xdotool type "$(xclip -o -selection clipboard)"'
alias kssh="kitty +kitten ssh"
alias docker-clean='docker container prune -f ; docker image prune -f ; docker network prune -f ; docker volume prune -f '

# System Control
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'
alias hug="systemctl --user restart hugo"
alias lanm="systemctl --user restart lan-mouse"

# Conditional Grep (Ripgrep vs Grep)
if command -v rg &> /dev/null; then
    alias grep='rg'
else
    alias grep="/usr/bin/grep ${GREP_OPTIONS:-}"
fi

# ==========================================
# CAT vs CATLESS (Universal Detection)
# ==========================================
# 1. 'cat' is NOT aliased. It stays standard for easy copying.
# 2. 'catless' uses Bat (fancy viewer) with distro detection.

if command -v bat &> /dev/null; then
    # Arch / Fedora / Mac
    alias catless='bat'
elif command -v batcat &> /dev/null; then
    # Debian / Ubuntu
    alias catless='batcat'
else
    # Fallback if bat isn't installed
    alias catless='less'
fi

# ==========================================
# FUNCTIONS
# ==========================================

# Built-in Help Section
zhelp() {
    echo "================================================="
    echo "  ZSH CUSTOM COMMANDS HELP"
    echo "================================================="
    echo "  Navigation:"
    echo "    .. / ...       : Go up 1 or 2 directories"
    echo "    up <n>         : Go up n directories"
    echo "    mkdirg <dir>   : Create dir and cd into it"
    echo ""
    echo "  File Viewing:"
    echo "    cat <file>     : Standard view (Select & Copy friendly)"
    echo "    catless <file> : Fancy view (Colors & Line numbers)"
    echo "    extract <file> : Universal extractor (tar, zip, etc.)"
    echo ""
    echo "  System:"
    echo "    whatismyip     : Show Internal and External IP"
    echo "    checkcommand   : See where a command is defined"
    echo "    docker-clean   : Remove unused docker resources"
    echo "    topcpu         : Show top 10 CPU consuming processes"
    echo ""
    echo "  Git:"
    echo "    gcom <msg>     : Add . and commit"
    echo "    lazyg <msg>    : Add ., commit, and push"
    echo "================================================="
}

# Extract archives
extract() {
    for archive in "$@"; do
        if [ -f "$archive" ]; then
            case $archive in
                *.tar.bz2) tar xvjf $archive ;;
                *.tar.gz) tar xvzf $archive ;;
                *.bz2) bunzip2 $archive ;;
                *.rar) rar x $archive ;;
                *.gz) gunzip $archive ;;
                *.tar) tar xvf $archive ;;
                *.tbz2) tar xvjf $archive ;;
                *.tgz) tar xvzf $archive ;;
                *.zip) unzip $archive ;;
                *.Z) uncompress $archive ;;
                *.7z) 7z x $archive ;;
                *) echo "don't know how to extract '$archive'..." ;;
            esac
        else
            echo "'$archive' is not a valid file!"
        fi
    done
}

# Search text
ftext() {
    grep -iIHrn --color=always "$1" . | less -r
}

# Copy with progress bar
cpp() {
    set -e
    strace -q -ewrite cp -- "${1}" "${2}" 2>&1 |
    awk '{
        count += $NF
        if (count % 10 == 0) {
            percent = count / total_size * 100
            printf "%3d%% [", percent
            for (i=0;i<=percent;i++)
                printf "="
            printf ">"
            for (i=percent;i<100;i++)
                printf " "
            printf "]\r"
        }
    }
    END { print "" }' total_size="$(stat -c '%s' "${1}")" count=0
}

# Navigation Helpers
cpg() { if [ -d "$2" ]; then cp "$1" "$2" && cd "$2"; else cp "$1" "$2"; fi }
mvg() { if [ -d "$2" ]; then mv "$1" "$2" && cd "$2"; else mv "$1" "$2"; fi }
mkdirg() { mkdir -p "$1"; cd "$1"; }

# Up (cd ../..)
up() {
    local d=""
    limit=$1
    for ((i = 1; i <= limit; i++)); do
        d=$d/..
    done
    d=$(echo $d | sed 's/^\///')
    if [ -z "$d" ]; then d=..; fi
    cd $d
}

# PWD Tail
pwdtail() {
    pwd | awk -F/ '{nlast = NF -1;print $nlast"/"$NF}'
}

# Distro Detection
distribution() {
    local dtype="unknown"
    if [ -r /etc/os-release ]; then
        source /etc/os-release
        case $ID in
            fedora|rhel|centos) dtype="redhat" ;;
            sles|opensuse*) dtype="suse" ;;
            ubuntu|debian) dtype="debian" ;;
            gentoo) dtype="gentoo" ;;
            arch|manjaro) dtype="arch" ;;
            slackware) dtype="slackware" ;;
            *) if [ -n "$ID_LIKE" ]; then
                   case $ID_LIKE in
                       *fedora*|*rhel*|*centos*) dtype="redhat" ;;
                       *sles*|*opensuse*) dtype="suse" ;;
                       *ubuntu*|*debian*) dtype="debian" ;;
                       *gentoo*) dtype="gentoo" ;;
                       *arch*) dtype="arch" ;;
                       *slackware*) dtype="slackware" ;;
                   esac
               fi ;;
        esac
    fi
    echo $dtype
}

# IP Address Function
alias whatismyip="whatsmyip"
function whatsmyip() {
    local src_ip=$(ip route get 1.1.1.1 2>/dev/null | sed -n 's/.*src \([0-9.]\+\).*/\1/p' | head -n 1)
    if [ -n "$src_ip" ]; then
        local interface=$(ip -o addr show | grep -F "$src_ip" | awk '{print $2}' | head -1)
        echo "Internal IP ($interface): $src_ip"
    else
        echo "Internal IP: (No internet route found)"
        ip -o -4 addr show | awk '!/^[0-9]*: ?lo/ {print "  " $2 ": " $4}' | cut -d/ -f1
    fi
    echo -n "External IPv4: "; curl -4 -s --connect-timeout 2 https://ip.me || echo "Timeout / Offline"; echo ""
    echo -n "External IPv6: "; curl -6 -s --connect-timeout 2 https://ip.me || echo "Not detected"; echo ""
}

# Git Helpers
gcom() {
    git add .
    git commit -m "$1"
}
lazyg() {
    git add .
    git commit -m "$1"
    git push
}

# Hastebin
function hb {
    if [ $# -eq 0 ]; then echo "No file path specified."; return;
    elif [ ! -f "$1" ]; then echo "File path does not exist."; return; fi
    uri="http://bin.christitus.com/documents"
    response=$(curl -s -X POST -d @"$1" "$uri")
    if [ $? -eq 0 ]; then
        hasteKey=$(echo $response | jq -r '.key')
        echo "http://bin.christitus.com/$hasteKey"
    else echo "Failed to upload the document."; fi
}

# ==========================================
# INITIALIZATION
# ==========================================
if [ -f /usr/bin/fastfetch ]; then fastfetch; fi

# Interactive Shell Keybinds
if [[ -o interactive ]]; then
    bindkey -s '^f' 'zi\n'
fi

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    exec startx
fi
