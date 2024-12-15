# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

source ~/common-settings/.git-prompt.sh

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
# HISTCONTROL=ignoreboth
HISTCONTROL=ignoreboth:erasedups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Add some options to less
export LESS="-r --mouse --wheel-lines=3"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# Config PS1 (bash prompt)
RED_PS='\[\e[0;31m\]'
GREEN_PS='\[\e[01;32m\]'
YELLOW_PS='\[\e[0;33m\]'
BLUE_PS='\[\e[0;34m\]'
MAGENTA_PS='\[\e[0;35m\]'
CYAN_PS='\[\e[1;36m\]'
DECOLOR_PS='\[\e[0m\]'
# Set default PS1 to 'user@host:folder> ', edit this to your own liking
PS1="$CYAN_PS"'\t'"$DECOLOR_PS"'|'"$GREEN_PS"'\u'"$DECOLOR_PS"':'"$CYAN_PS"'\w> '"$DECOLOR_PS"
# Add active git branch to PS1, argument to __git_ps1 is formatting (you can change color etc)
# PS1='$(__my_git_ps1 "\[\e[0;33m\]%s\[\e[0m\]|")'"$PS1"
GIT_PS1_SHOWDIRTYSTATE=yes
GIT_PS1_SHOWUNTRACKEDFILES=yes
GIT_PS1_SHOWUPSTREAM=verbose
PS1='$(__git_ps1 "\[\e[0;33m\]%s\[\e[0m\]|")'"$PS1"

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Add tab completion for tig
source ~/common-settings/tig-completion.bash

# Add tab completion for git
source ~/common-settings/git-completion.bash

# Add completion for makefiles
complete -W "\`grep -oE '^[a-zA-Z0-9_.-]+:([^=]|$)' ?akefile | sed 's/[^a-zA-Z0-9_.-]*$//'\`" make

# Git aliases
alias gs='git status'
alias gd='mydeltagitdiff'
alias gds='mydeltagitdiff --staged'
alias gdo='mydeltagitdiff origin/$(git branch --show-current)'

export DELTA_PAGER="less"

mydeltagitdiff() {
    if ! $(git rev-parse 2> /dev/null); then
        echo "Not in git repository"
        return 1
    fi
    if [[ -z $(git diff $*) ]]; then
        echo "No changes"
        return 0
    fi
    if [ $# -gt 0 ]; then
        git diff --color=always $* | delta
    else
        git diff --color=always | delta
    fi
    return 0
}

function hex() {
  python3 -c "print(hex($*))"
}

function bin() {
  python3 -c "print(bin($*))"
}

# Enable fuzzy keybindings with fzf (for eg. better Ctrl+R history)
source ~/common-settings/fzf-key-bindings.bash

# Enable fuzzy completion with fzf
source ~/common-settings/fzf-completion.bash
# Enable fuzzy for vscode
_fzf_setup_completion path code

# Enable fuzzy git helpers commands
source ~/common-settings/git_fuzzy.sh

export PATH=/home/andreas/.cargo/bin:$PATH

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# alias python3='python3.12'

# Enable direnv, needs to be late in the bashrc
# eval "$(direnv hook bash)"

# Add prompt command so that CWD is set. This makes it possible to use "duplicate" and get same directory
# PROMPT_COMMAND=${PROMPT_COMMAND:+"$PROMPT_COMMAND; "}'printf "\e]9;9;%s\e\\" "`cygpath -w "$PWD" -C ANSI`"'
# PROMPT_COMMAND=${PROMPT_COMMAND:+"$PROMPT_COMMAND; "}'echo "`cygpath -w "$PWD" -C ANSI`"'


# my_prompt() {
#   echo -en '\e]9;9;"'
#   cygpath -w "$PWD" | tr -d '\n'
#   echo -en '"\x07'
# }

# export PROMPT_COMMAND=my_prompt


# PROMPT_COMMAND=${PROMPT_COMMAND:+"$PROMPT_COMMAND; "}'printf "\e]9;9;%s\e\\" "$(cygpath -w "$PWD")"'


# After each command, append to the history file and reread it
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
