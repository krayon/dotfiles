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
alias dotfiles='git --git-dir="${HOME}/.dotfiles.git/" --work-tree="${HOME}"'
dotfiles status
```

# Using

## Adding your files

```
dotfiles add .vimrc
dotfiles commit -S -m 'Added my vimrc'
```

# Host level files

**NOTE:** In the following sections, `<HOSTNAME>` refers to the hostname of the
host in question.

Each host can have a custom `bin` directory and bash extensions to the base.

When `.dotfiles.bootstrap.bash` is run, symlinks are created on the local
system, pointing to it's `<HOSTNAME>` versions. You can also trigger the
(re)creation of these at any time by running `.dotfiles.bootstrap.bash` with the
`-s`/`--symlinks` option.

## bin

- Make a local `bin.<HOSTNAME>` directory in your `${HOME}` on `<HOSTNAME>`;
- Add files to `bin.<HOSTNAME>`; and
- (OPTIONALLY) Commit files to your dotfiles.

## bashrc

- Add a `.bashrc.<HOSTNAME>` file to your `${HOME}`; and
- (OPTIONALLY) Commit `.bashrc.<HOSTNAME>` to your dotfiles repository.

## .bashrc

- Add a `.bashrc.<HOSTNAME>` file to your `${HOME}`; and
- (OPTIONALLY) Commit `.bashrc.<HOSTNAME>` to your dotfiles repository.

## .bash_aliases

- Add a `.bash_aliases.<HOSTNAME>` file to your `${HOME}`; and
- (OPTIONALLY) Commit `.bash_aliases.<HOSTNAME>` to your dotfiles repository.

----
[//]: # ( vim: set ts=4 sw=4 et cindent tw=80 ai si syn=markdown ft=markdown: )
