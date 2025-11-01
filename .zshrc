# ===================================================================
#   .zshrc for macOS
#   GitHub | Forgejo | iTerm2 | Kitty | Alacritty | Terminal.app
#   Oh My Zsh | Atuin | Starship | Syntax Highlighting
#   Last Updated: 2025-11-01
# ===================================================================

# --- Path to Oh My Zsh Installation ---
export ZSH="$HOME/.oh-my-zsh"

# --- XDG Base Directory Specification ---
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# --- Editor Configuration ---
if command -v nvim &>/dev/null; then
    export EDITOR=nvim
    export VISUAL=nvim
elif command -v vim &>/dev/null; then
    export EDITOR=vim
    export VISUAL=vim
else
    export EDITOR=nano
    export VISUAL=nano
fi

# --- Shell Options ---
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt AUTO_CD
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# --- History Configuration ---
HISTSIZE=50000
SAVEHIST=50000
HISTFILE="$HOME/.zsh_history"

# --- Homebrew Configuration (Apple Silicon & Intel) ---
if [ -d "/opt/homebrew" ]; then
    export PATH="/opt/homebrew/bin:$PATH"
    export PATH="/opt/homebrew/sbin:$PATH"
elif [ -d "/usr/local/bin" ]; then
    export PATH="/usr/local/bin:$PATH"
    export PATH="/usr/local/sbin:$PATH"
fi

# --- Terminal Detection & Compatibility ---
case "$TERM" in
    xterm-kitty)
        # Kitty terminal with image support
        if ! infocmp xterm-kitty &>/dev/null; then
            export TERM=xterm-256color
        fi
        alias icat='kitty +kitten icat'
        alias kssh='kitty +kitten ssh'
        ;;
    alacritty|wezterm)
        # Alacritty and WezTerm
        if ! infocmp "$TERM" &>/dev/null; then
            export TERM=xterm-256color
        fi
        ;;
    screen-256color|tmux-256color)
        # Tmux/screen compatibility
        export TERM=screen-256color
        ;;
    *)
        # Default to 256 color support for all other terminals
        [ "$TERM" != "xterm-256color" ] && export TERM=xterm-256color
        ;;
esac

# --- Oh My Zsh Plugins ---
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    macos
    history
    command-not-found
)

# --- Oh My Zsh Settings ---
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 30

# --- Initialize Oh My Zsh ---
source $ZSH/oh-my-zsh.sh

# --- Autocompletion Setup ---
autoload -Uz compinit
compinit -C 2>/dev/null

# --- Enable Git Completion with Aliases ---
compdef g=git 2>/dev/null
compdef gco=_git_checkout 2>/dev/null
compdef gb=_git_branch 2>/dev/null
compdef gm=_git_merge 2>/dev/null
compdef gp=_git_push 2>/dev/null
compdef gpl=_git_pull 2>/dev/null
compdef gf=_git_fetch 2>/dev/null
compdef gcl=_git_clone 2>/dev/null

# ==================== FUNCTIONS ====================

# Create a directory and change into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract archives
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
            *.tar.zst)   tar --zstd -xf "$1" ;;
            *)
                echo "Cannot extract: $1" >&2
                return 1
                ;;
        esac
    else
        echo "File not found: $1" >&2
        return 1
    fi
}

# Create timestamped backup
backup() {
    if [ -f "$1" ]; then
        cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
        echo "Backup created: $1.backup-$(date +%Y%m%d-%H%M%S)"
    elif [ -d "$1" ]; then
        tar czf "$1.backup-$(date +%Y%m%d-%H%M%S).tar.gz" "$1"
        echo "Backup created: $1.backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    else
        echo "File or directory not found: $1" >&2
        return 1
    fi
}

# Navigate up N directories
up() {
    local d=""
    local limit="${1:-1}"
    for ((i=1; i<=limit; i++)); do
        d="../$d"
    done
    cd "$d" || return
}

# Find files by name
ff() {
    find . -type f -iname "*$1*" 2>/dev/null
}

# Find directories by name
fd() {
    find . -type d -iname "*$1*" 2>/dev/null
}

# Search for text in files recursively
ftext() {
    grep -rnw . -e "$1" 2>/dev/null
}

# Search history
hgrep() {
    history | grep -i --color=auto "$@"
}

# Create tarball
targz() {
    if [ -d "$1" ]; then
        tar czf "${1%%/}.tar.gz" "${1%%/}"
        echo "Created ${1%%/}.tar.gz"
    else
        echo "Directory not found: $1" >&2
        return 1
    fi
}

# Disk usage (sorted by size)
duh() {
    du -h --max-depth=1 "${1:-.}" | sort -hr
}

# Get size of file or directory
sizeof() {
    du -sh "$1" 2>/dev/null
}

# GitHub clone helper
ghclone() {
    if [ -z "$1" ]; then
        echo "Usage: ghclone <user/repo>"
        return 1
    fi
    git clone "https://github.com/$1.git"
}

# Forgejo clone helper
fgclone() {
    if [ -z "$2" ]; then
        echo "Usage: fgclone <instance> <user/repo>"
        echo "Example: fgclone codeberg.org username/repo"
        return 1
    fi
    git clone "https://$1/$2.git"
}

# Quick commit, push - renamed to avoid conflict with Oh My Zsh alias
gitpush() {
    if [ -z "$1" ]; then
        echo "Usage: gitpush \"commit message\""
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
            echo ""
            echo "=== $dir ==="
            git -C "$dir" status -sb
        fi
    done
}

# Script testing helper
testscript() {
    if [ -f "$1" ]; then
        echo "Running shellcheck..."
        shellcheck "$1"
        echo ""
        echo "Syntax check..."
        bash -n "$1"
        echo "Dry run complete."
    else
        echo "Script not found: $1" >&2
        return 1
    fi
}

# macOS system info
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
        local GREEN='\e[1;32m'
        local DIM='\e[2m'
        local RESET='\e[0m'
    else
        local CYAN='' YELLOW='' GREEN='' DIM='' RESET=''
    fi

    printf "\n${CYAN}=== System Information ===${RESET}\n"
    printf "${CYAN}%-15s${RESET} %s\n" "Hostname:" "$(hostname -s)"
    printf "${CYAN}%-15s${RESET} %s\n" "OS:" "$(sw_vers -productName) $(sw_vers -productVersion)"
    printf "${CYAN}%-15s${RESET} %s\n" "Kernel:" "$(uname -r)"
    printf "${CYAN}%-15s${RESET} %s\n" "Uptime:" "$(uptime | sed 's/^.*up //' | sed 's/,.*//')"
    printf "${CYAN}%-15s${RESET} %s\n" "Time:" "$(date '+%Y-%m-%d %H:%M:%S %Z')"
    printf "${CYAN}%-15s${RESET} %s\n" "CPU:" "$(sysctl -n machdep.cpu.brand_string)"

    # Memory display using vm_stat - WORKING VERSION
    printf "${CYAN}%-15s${RESET} " "Memory:"

    # Get total memory in GB
    local total_mem
    total_mem=$(sysctl -n hw.memsize 2>/dev/null | awk '{printf "%.0f", $1 / 1024 / 1024 / 1024}')

    # Get used memory from vm_stat
    # Used = (Pages active + Pages inactive + Pages wired down) * 4096 bytes
    local used_mem
    used_mem=$(vm_stat 2>/dev/null | awk '
        /^Pages active:/ { active = $3 }
        /^Pages inactive:/ { inactive = $3 }
        /^Pages wired down:/ { wired = $4 }
        END {
            if (active && inactive && wired) {
                used_bytes = (active + inactive + wired) * 4096
                used_gb = used_bytes / (1024 * 1024 * 1024)
                printf "%.0f", used_gb
            }
        }
    ')

    if [ -n "$total_mem" ] && [ -n "$used_mem" ] && [ "$used_mem" != "0" ]; then
        printf "%sGB / %sGB\n" "$used_mem" "$total_mem"
    elif [ -n "$total_mem" ]; then
        printf "%sGB (total)\n" "$total_mem"
    else
        printf "N/A\n"
    fi

    # Disk usage
    printf "${CYAN}%-15s${RESET} %s\n" "Disk (/):" "$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 " used)"}')"

    # Git repos count
    if [ -d ~/Documents/github ] || [ -d ~/github ]; then
        local gh_count
        gh_count=$(find ~/Documents/github ~/github -maxdepth 2 -name ".git" -type d 2>/dev/null | wc -l | xargs)
        if [ "$gh_count" -gt 0 ]; then
            printf "${CYAN}%-15s${RESET} ${GREEN}%s${RESET}\n" "GitHub Repos:" "$gh_count"
        fi
    fi

    if [ -d ~/Documents/forgejo ] || [ -d ~/forgejo ]; then
        local fg_count
        fg_count=$(find ~/Documents/forgejo ~/forgejo -maxdepth 2 -name ".git" -type d 2>/dev/null | wc -l | xargs)
        if [ "$fg_count" -gt 0 ]; then
            printf "${CYAN}%-15s${RESET} ${GREEN}%s${RESET}\n" "Forgejo Repos:" "$fg_count"
        fi
    fi

    printf "\n"
}

# Most used commands
histop() {
    history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " a;}' | \
        sort -rn | head -20 | awk '{printf "%3d  %s\n", $1, $2}'
}

# Help system
helpme() {
    cat << 'HELPTEXT'

╔════════════════════════════════════════════════════════╗
║               macOS - Quick Reference                  ║
╚════════════════════════════════════════════════════════╝

📁 NAVIGATION
  .., ..., ...., ~            Navigate directories
  mkcd <dir>                  Create and enter directory
  up <n>                      Go up N directories
  github                      Jump to GitHub projects
  forgejo                     Jump to Forgejo projects

📄 FILES
  ll, la, lt, lS              List files (various sorts)
  ff/fd <name>                Find files/directories
  extract <file>              Extract archives
  backup <file>               Create timestamped backup
  targz <dir>                 Create tar.gz archive
  duh                         Disk usage sorted
  sizeof <file>               Show size of file/dir

💻 SYSTEM
  sysinfo                     System overview
  histop                      Most used commands
  top, htop                   System processes
  ports                       Show listening ports
  myip                        Display public IP
  localip                     Display local IP

🔀 GIT (with full tab completion)
  gs, ga, gc, gp, gl          Git shortcuts
  gco, gb, gm, gf             More git commands
  gitpush "msg"               Quick commit+push
  gstatus                     Status of all repos
  ghclone user/repo           Clone GitHub repo
  fgclone instance user/repo  Clone Forgejo repo
  testscript <file>           Check script syntax
  please git <cmd>            Run git with sudo

⚙️  DEVELOPMENT
  brew list                   Show installed packages
  brewup                       Update Homebrew
  brewsearch <pkg>            Search Homebrew packages
  npmup                        Update npm packages
  pipup                        Upgrade pip

🖥️  TERMINAL SUPPORT
  Works seamlessly with:
  • iTerm2 (with shell integration)
  • Kitty (with image support via icat)
  • Alacritty
  • WezTerm
  • Terminal.app

📚 HELP
  helpme / bh                 This help
  histop                      Most used commands
  alias                       List all aliases
  compdef                     Show completion definitions

HELPTEXT
}

alias bh='helpme'

# ==================== ALIASES ====================

# Enable color support (macOS native)
alias ls='ls -G'
alias ll='ls -alFhG'
alias la='ls -AG'
alias l='ls -CFG'
alias lt='ls -alFhtG'
alias ltr='ls -alFhtrG'
alias lS='ls -alFhSG'
alias lsd='ls -d */ 2>/dev/null'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# Navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'
alias ~='cd ~'
alias h='history'
alias c='clear'
alias reload='source ~/.zshrc && echo "✓ Zshrc reloaded!"'

# Development directory shortcuts
alias github='cd ~/github || cd ~/projects'
alias forgejo='cd ~/forgejo'
alias dev='cd ~/Development'

# System aliases
alias df='df -h'
alias du='du -h'
alias top10='ps aux | sort -rn -k 3 | head -11'
alias ports='lsof -i -P -n | grep LISTEN'
alias myip='curl -s ifconfig.me || curl -s icanhazip.com'
alias localip='ipconfig getifaddr en0'
alias ping='ping -c 5'
alias fping='ping -c 100 -i 0.1'
alias netstat='netstat -an'

# Quick edits
alias zshrc='$EDITOR ~/.zshrc && source ~/.zshrc'
alias vimrc='$EDITOR ~/.vimrc'
alias sshconfig='$EDITOR ~/.ssh/config'
alias hosts='sudo $EDITOR /etc/hosts'

# Homebrew shortcuts
alias brewup='brew update && brew upgrade && brew cleanup'
alias brewlist='brew list'
alias brewsearch='brew search'
alias brewinstall='brew install'
alias brewuninstall='brew uninstall'

# Git shortcut (already in Oh My Zsh but explicit here)
alias g='git'
alias ghopen='open https://github.com'
alias fgopen='open https://codeberg.org'

# Development commands
alias npmup='npm update -g'
alias pipup='python3 -m pip install --upgrade pip'
alias gitgc='git gc --aggressive'

# Last command with sudo
alias please='sudo $(history -p !!)'

# ==================== ATUIN CONFIGURATION ====================

export ATUIN_NOBIND="true"
eval "$(atuin init zsh)"

# Bind Ctrl+R to Atuin history search
bindkey '^r' atuin-up-search-viins
bindkey -M viins '^r' atuin-up-search-viins

# ==================== SYNTAX HIGHLIGHTING & AUTOSUGGESTIONS ====================

# Homebrew-installed syntax highlighting
if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Homebrew-installed autosuggestions
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi

# ==================== STARSHIP PROMPT ====================

eval "$(starship init zsh)"

# ==================== iTERM2 SHELL INTEGRATION ====================

# Load iTerm2 shell integration only if running in iTerm2
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# ==================== CONDITIONAL LOADING ====================

# Load custom aliases
if [ -f ~/.zsh_aliases ]; then
    source ~/.zsh_aliases
fi

# Load local machine-specific settings
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi

# Load per-host configuration
if [ -f ~/.zshrc."$(hostname -s)" ]; then
    source ~/.zshrc."$(hostname -s)"
fi
