# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# SUPPORT FILES:
#   .sh_set_path
#   .colours

# All paths should be relative to the rc file, which may NOT be ~
bashrc_loc="$(dirname "${BASH_SOURCE[0]}")"

# Include PATH
. "${bashrc_loc}"/.sh_set_path 2>/dev/null

# For each PATH, man adds PATH/../man/ to the MANPATH so this is unnecessary :D
#     UPDATE 20201001: Not any more? Now we set it in .sh_set_path though so yeah...
#     UPDATE 20201002: OK so it's now PATH/man/ ... so: bin.ARCH/man/man1/a.1
#export MANPATH=${MANPATH}:~/man

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Add colours
. "${bashrc_loc}"/.colours || {
    export _col_no=1
}

# Input (key binds)
[ -r "${HOME}/.inputrc" ] && {
    # Parse inputrc ourselves as bash doesn't always honour inputrc contents?

    # Skip:
    #   - empty lines
    #   - comments
    #   - includes (TODO)
    #   - set commands
    while read -r line; do #{
        [ -z "${line}" ]\
        || [ "${line:0:1}" == '#'        ]\
        || [ "${line:0:8}" == '$include' ]\
        || [ "${line:0:4}" == 'set '     ]\
        && continue
        # TODO: $include

        # At this point, we _assume_ the rest of the lines are binds
        bind "${line}"
    done < <(sed 's#^[ \t]*##;s#[ \t]*$##' <"${HOME}/.inputrc") #}
}



##############################################################################{
# BASH HISTORY
#-----------------------------------------------------------------------------

# HISTCONTROL: See bash(1) for more options
#   - Don't store sequential duplicate commands (ignoredups, ignoreboth)
#   - Don't store commands if they start with space (ignorespace, ignoreboth)
#   - Erase (non-)sequential duplicate commands (erasedups)
#export HISTIGNORE=\& # ALTERNATIVE: Ignore dups
export HISTCONTROL=ignorespace:ignoredups:erasedups

# DISABLED - doesn't even exist in <UP>/previous command history, no good
## Ignore common commands
#export HISTIGNORE='pwd:ls:ls -la:ls -lah:ls -latr'

# 1000000 entries please
export HISTSIZE=1000000
export HISTFILESIZE=1000000

# timestamp bash history entries
export HISTTIMEFORMAT='%F %T '

# Append to the history file, don't overwrite it
shopt -s histappend

#=============================================================================}

##############################################################################{
# EDITOR
#-----------------------------------------------------------------------------

type -P vim &>/dev/null && {
    # Set VISUAL and EDITOR variables to control default editor used
    # Set FCEDIT variables to control fc's (bash's builtin fix-command) editor
    export VISUAL=vim
    export EDITOR=vim
    export FCEDIT=vim
}

#=============================================================================}

##############################################################################{
# PAGER
#-----------------------------------------------------------------------------

# less
#   * Quit if less than a page (-F)
#   * Set less to be more prompty than more (-M)
#   * Disable termcap initialization and deinitialization (-X, causes screen to
#     clear etc)
export LESS=-FMX

# Disable less history
export LESSHISTFILE=-

type -P less &>/dev/null && {
    # Set PAGER to control default pager
    export PAGER=less
}

# Make `less` more friendly for non-text input files, see lesspipe(1)/lessfile(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

#=============================================================================}

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Turn on bash's check that a command in cache (hash) still exists where bash
# thinks it does, otherwise it forgets it. This saves you from having to run
# "hash -d" manually.
shopt -s checkhash

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# If set, glob patterns (such as "test*") will expand to null if no matching
# files are found. Without it, it will be treated as a literal when no files
# match.
#shopt -s nullglob

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
    test -r "${bashrc_loc}"/.dircolors && eval "$(dircolors -b "${bashrc_loc}"/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# INCLUDED LATER # # Alias definitions.
# INCLUDED LATER # # You may want to put all your additions into a separate file like
# INCLUDED LATER # # ~/.bash_aliases, instead of adding them here directly.
# INCLUDED LATER # # See /usr/share/doc/bash-doc/examples in the bash-doc package.
# INCLUDED LATER #
# INCLUDED LATER # if [ -f ~/.bash_aliases ]; then
# INCLUDED LATER #     . ~/.bash_aliases
# INCLUDED LATER # fi

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

# Include architecture specific .bashrc
[ -r "${bashrc_loc}"/.bashrc.ARCH ] && . "${bashrc_loc}"/.bashrc.ARCH

# Include OS specific .bashrc
[ -r "${bashrc_loc}"/.bashrc.OS ] && . "${bashrc_loc}"/.bashrc.OS

# Include local host .bashrc
[ -r "${bashrc_loc}"/.bashrc.HOST ] && . "${bashrc_loc}"/.bashrc.HOST

# Include general .bash_aliases
[ -r "${bashrc_loc}"/.bash_aliases ] && . "${bashrc_loc}"/.bash_aliases

# Include architecture specific .bash_aliases
[ -r "${bashrc_loc}"/.bash_aliases.ARCH ] && . "${bashrc_loc}"/.bash_aliases.ARCH

# Include OS specific .bash_aliases
[ -r "${bashrc_loc}"/.bash_aliases.OS ] && . "${bashrc_loc}"/.bash_aliases.OS

# Include local host .bash_aliases
[ -r "${bashrc_loc}"/.bash_aliases.HOST ] && . "${bashrc_loc}"/.bash_aliases.HOST
