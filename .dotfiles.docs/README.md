# Krayon dotfiles

A nice, clean, new dotfiles repo :D

# Installation

## Quickstart

First, optionally fork the repository, and substitute your path below. You
may need to consider using `ssh` cloning if that's how you push back to
repositories.

```bash
git clone https://github.com/krayon/dotfiles/ ~/.dotfiles/
~/.dotfiles/.dotfiles.bootstrap.bash
alias dotfiles='git --git-dir="${HOME}/.dotfiles/" --work-tree="${HOME}"'
dotfiles status
```

# Using

## Adding your files

```
dotfiles add .vimrc
dotfiles commit -S -m 'Added my vimrc'
```
