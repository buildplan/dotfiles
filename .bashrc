# ===================================================================
#   Universal Portable .bashrc for Modern Terminals
#   Optimized for Debian/Ubuntu servers with multi-terminal support
# ===================================================================

# If not running interactively, don't do anything.
case $- in
    *i*) ;;
      *) return;;
esac

# --- Performance: Only load if interactive ---
# Prevent sourcing in non-interactive scripts
[[ $- != *i* ]] && return

# --- History Control ---
# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth:erasedups
# Append to the history file, don't overwrite it.
shopt -s histappend
# Set history length with larger values for better recall.
HISTSIZE=10000
HISTFILESIZE=20000
# Save history immediately after each command and reload it.
PROMPT_COMMAND="history -a; history -n"
# Allow editing of commands recalled from history.
shopt -s histverify
# Add timestamp to history entries.
HISTTIMEFORMAT="%F %T "

# --- General Shell Behavior & Options ---
# Check the window size after each command and update LINES and COLUMNS.
shopt -s checkwinsize
# Allow using '**' for recursive globbing (e.g., ls **/*.log).
shopt -s globstar 2>/dev/null
# Allow changing to a directory by just typing its name.
shopt -s autocd 2>/dev/null
# Autocorrect minor spelling errors in directory names.
shopt -s cdspell 2>/dev/null
shopt -s dirspell 2>/dev/null
# Make `less` more friendly for non-text input files.
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

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

# --- Locale and Language Settings ---
# Ensure UTF-8 locale for proper character display.
export LC_ALL=en_US.UTF-8 2>/dev/null || export LC_ALL=C.UTF-8 2>/dev/null
export LANG=en_US.UTF-8 2>/dev/null || export LANG=C.UTF-8 2>/dev/null

# --- Prompt Configuration ---
# Set a colored prompt only if the terminal has color capability.
case "$TERM" in
    xterm-color|*-256color|xterm-kitty|alacritty|wezterm) color_prompt=yes;;
esac

# Force color prompt support check.
if [ -z "${color_prompt}" ] && [ -x /usr/bin/tput ] && tput setaf 1 &>/dev/null; then
    color_prompt=yes
fi

if [ "$color_prompt" = yes ]; then
    # Green: user@host, Blue: directory, White: prompt symbol.
    # Show exit status if non-zero in red.
    export PS1='\[\e[32m\]\u@\h\[\e[00m\]:\[\e[34m\]\w\[\e[00m\]$([ $? != 0 ] && echo "\[\e[31m\] ✗\[\e[00m\]")\$ '
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

# --- Useful Functions ---
# Create a directory and change into it.
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract any archive file with a single command.
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.tar.xz)    tar xJf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *.deb)       ar x "$1"        ;;
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
fi

# Standard ls aliases.
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -alFht'  # Sort by time
alias ltr='ls -alFhtr'  # Sort by time, reversed
alias lS='ls -alFhS'  # Sort by size

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
alias -- -='cd -'  # Go to previous directory
alias h='history'
alias c='clear'

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

# Quick system info.
alias myip='curl -s ifconfig.me'
alias sysinfo='uname -a && cat /etc/os-release'

# Apt aliases for Debian/Ubuntu (only if apt is available).
if command -v apt &>/dev/null; then
    alias aptup='sudo apt update && sudo apt upgrade'
    alias aptin='sudo apt install'
    alias aptrm='sudo apt remove'
    alias aptsearch='apt search'
fi

# Reload .bashrc.
alias reload='source ~/.bashrc'

# --- PATH Configuration ---
# Add user's local bin directories to PATH if they exist.
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"

# --- SSH Agent Management (optional, comment out if not needed) ---
# Only start ssh-agent if not already running and we're in an interactive SSH session.
# if [[ -z "$SSH_AUTH_SOCK" ]] && [[ -n "$SSH_CONNECTION" ]]; then
#     eval "$(ssh-agent -s)" &>/dev/null
# fi

# --- Server-Specific Configuration ---
# Load hostname-specific configurations if they exist.
# This allows per-server customization without modifying the main bashrc.
if [[ -f ~/.bashrc.$(hostname -s) ]]; then
    source ~/.bashrc.$(hostname -s)
fi

# Load domain-specific configurations (useful for server groups).
# e.g., ~/.bashrc.eagle for all eagle*.host.us servers
if [[ -f ~/.bashrc.${HOSTNAME%%[0-9]*} ]]; then
    source ~/.bashrc.${HOSTNAME%%[0-9]*}
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

# --- Performance Tip ---
# If you notice slow startup, comment out unused sections or move
# expensive operations to separate files that can be sourced on-demand.
