# ===================================================================
#   Universal Portable .bashrc for Modern Terminals
# ===================================================================

# If not running interactively, don't do anything.
case $- in
    *i*) ;;
      *) return;;
esac

# --- History Control ---
# Don't put duplicate lines or lines starting with space in the history.
[cite_start]HISTCONTROL=ignoreboth [cite: 1]
# Append to the history file, don't overwrite it.
[cite_start]shopt -s histappend [cite: 1]
# Set history length.
[cite_start]HISTSIZE=5000 [cite: 1]
[cite_start]HISTFILESIZE=10000 [cite: 1]
# Save history immediately after each command.
PROMPT_COMMAND="history -a"
# Allow editing of commands recalled from history.
shopt -s histverify

# --- General Shell Behavior & Options ---
# Check the window size after each command and update LINES and COLUMNS.
[cite_start]shopt -s checkwinsize [cite: 1]
# Allow using '**' for recursive globbing (e.g., ls **/*.log).
shopt -s globstar
# Allow changing to a directory by just typing its name.
shopt -s autocd
# Make `less` more friendly for non-text input files.
[cite_start][ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)" [cite: 1]

# --- Prompt Configuration ---
# Set a colored prompt only if the terminal has color capability.
case "$TERM" in
    xterm-color|*-256color|xterm-kitty) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    # Green: user@host, Blue: directory, White: prompt symbol.
    [cite_start]export PS1='\[\e[32m\]\u@\h\[\e[00m\]:\[\e[34m\]\w\[\e[00m\]\$ ' [cite: 1]
else
    export PS1='\u@\h:\w\$ '
fi
unset color_prompt

# Set the terminal window title to user@host:dir for supported terminals.
case "$TERM" in
xterm*|rxvt*|kitty)
    [cite_start]PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1" [cite: 1]
    ;;
*)
    ;;
esac

# --- Terminal Specific Fixes ---
# Ensure the shell looks for user-specific terminfo files (for Kitty).
if [[ "$TERM" == "xterm-kitty" ]] && [[ -d "$HOME/.terminfo" ]]; then
    [cite_start]export TERMINFO=~/.terminfo [cite: 1]
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

# --- Aliases ---
# Enable color support for common commands.
if [ -x /usr/bin/dircolors ]; then
    [cite_start]test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)" [cite: 1]
    [cite_start]alias ls='ls --color=auto' [cite: 1]
    [cite_start]alias grep='grep --color=auto' [cite: 1]
    [cite_start]alias fgrep='fgrep --color=auto' [cite: 1]
    [cite_start]alias egrep='egrep --color=auto' [cite: 1]
fi

# Standard ls aliases.
[cite_start]alias ll='ls -alF' [cite: 1]
[cite_start]alias la='ls -A' [cite: 1]
[cite_start]alias l='ls -CF' [cite: 1]

# Safety aliases to prompt before overwriting.
[cite_start]alias rm='rm -i' [cite: 1]
[cite_start]alias cp='cp -i' [cite: 1]
[cite_start]alias mv='mv -i' [cite:1]

# Convenience & Navigation aliases.
[cite_start]alias ..='cd ..' [cite: 1]
[cite_start]alias ...='cd ../..' [cite: 1]
alias ....='cd ../../..'
[cite_start]alias h='history' [cite: 1]

# System resource aliases.
alias df='df -h'
alias free='free -h'
alias psgrep='ps aux | grep -v grep | grep -i -e VSZ -e'
alias ports='ss -tuln'

# --- PATH Configuration ---
# Add user's local bin directory to PATH if it exists.
if [ -d "$HOME/.local/bin" ]; then
    [cite_start]export PATH="$HOME/.local/bin:$PATH" [cite: 1]
fi

# --- Bash Completion & Personal Aliases ---
# Enable programmable completion features.
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . [cite_start]/usr/share/bash-completion/bash_completion [cite: 1]
  elif [ -f /etc/bash_completion ]; then
    . [cite_start]/etc/bash_completion [cite: 1]
  fi
fi

# Source personal aliases if the file exists.
if [ -f ~/.bash_aliases ]; then
    . [cite_start]~/.bash_aliases [cite: 1]
fi
