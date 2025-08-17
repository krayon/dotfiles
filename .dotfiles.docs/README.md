# Krayon dotfiles

A nice, clean, new dotfiles repo :D

## TL;DR

### Setup

- Clone the repository, eg. `https://github.com/YOURNICK/dotfiles` where
  `YOURNICK` is your GitHub account name;
- Create `.bashrc`, `.bash_aliases` and `bin/`. Put common stuff in them;
- Create `.bashrc.<ARCH>`, `.bash_aliases.<ARCH>` and `bin.<ARCH>/`. Put stuff
  common to systems running the `<ARCH>` architecture;
- Create `.bashrc.<OS>`, `.bash_aliases.<OS>` and `bin.<OS>/`. Put stuff common
  to systems running the `<OS>` Operating System;
- Create `.bashrc.<HOST>`, `.bash_aliases.<HOST>` and `bin.<HOST>/` for each
  host you have (called `<HOST>`). Put stuff specific to that host in there; and
- Commit all the things.

### Deploy

**NOTE:** Replace `YOURNICK` below with your GitHub account name.

```bash
git clone https://github.com/YOURNICK/dotfiles/ ~/.dotfiles/
~/.dotfiles/.dotfiles.bootstrap.bash
alias dotfiles='git --git-dir="${HOME}/.dotfiles.git/" --work-tree="${HOME}"'
dotfiles status
```



---

# Design

These dotfiles are designed to be modular and cascading. The idea is to have a
common set of files that can be used across multiple systems without having to
worry about compatibility.

- TODO:
  - Add `USER` level files;
  - Allow for symlinking of other configs (eg. `.vimrc.<HOST>`)
  - (maybe) allow merging of configs
    (eg. `cat .vimrc .vimrc.<OS> .vimrc.<HOST> >.vimrc`)

## Common files

The first set of files and directories are common to all platforms. For example:

- `.bashrc`
- `.bash_aliases`
- `bin/*`

## Architecture specific

The next set of files and directories are common to each architecture. The
architecture is that returned by the `uname -m` command. For example:

- `.bashrc.x86_64`
- `.bashrc.i686`
- `bin.x86_64/`

## OS specific

The next set of files and directories are common to each Operating System (OS).
The OS is that returned by the command
`grep '^ID[ ]*=' /etc/os-release|cut -d'=' -f2-|tr -d '"'` . For example:

- `.bashrc.devuan`
- `.bash_aliases.rhel`
- `bin.ubuntu/`

## Host specific

The final set of files and directories are those specific to the host. The
host name is as returned by the `hostname` command. For example:

- `.bashrc.mymachine`
- `.bashrc.myserver`



---

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

## Bootstrap

When the `.dotfiles.bootstrap.bash` script is initially run ( or when re-ran
using `.dotfiles.bootstrap.bash --symlinks` ) it will create a number of
symbolic links to detected versions of files that will be included when
processing the main `.bashrc` file. These symlinks will point to the various
files specific to the Architecture, OS and Host and have the extensions `.ARCH`,
`.OS` and `.HOST` respectively.

## Adding your files

```
dotfiles add .vimrc
dotfiles commit -S -m 'Added my vimrc'
```

### Architecture, OS and Host level files

**NOTE:** In the following sections:

- `<ARCH>` refers to the architecture of the system in question (ie. `uname -m`,
  eg. `x86_64` etc)
- `<OS>` refers to the OS of the system in question (ie.
  `grep '^ID[ ]*=' /etc/os-release|cut -d'=' -f2-|tr -d '"'`, eg. `devuan` etc)
- `<HOST>` refers to the hostname of the system in question (ie. `hostname`, eg.
  `myhost` etc)

Any files you commit under the `bin.<ARCH>` and `bin.<OS>` directories, will be
shared between machines running the `<ARCH>` architecture and the `<OS>`
Operating System respectively.

#### bin/

- Make a       `bin.<ARCH>` directory in your `${HOME}` on `<HOST>`;
- Make a       `bin.<OS>`   directory in your `${HOME}` on `<HOST>`;
- Make a local `bin.<HOST>` directory in your `${HOME}` on `<HOST>`;
- Add files to `bin.<ARCH>`, `bin.<OS>` and/or `bin.<HOST>`;
- Run `./.dotfiles.bootstrap.bash --symlinks` to create missing symlinks; and
- (OPTIONALLY) Commit files to your dotfiles.

## .bashrc

- Make a       `.bashrc.<ARCH>` file in your `${HOME}` on `<HOST>`;
- Make a       `.bashrc.<OS>`   file in your `${HOME}` on `<HOST>`;
- Make a local `.bashrc.<HOST>` file in your `${HOME}` on `<HOST>`; and
- Run `./.dotfiles.bootstrap.bash --symlinks` to create missing symlinks; and
- (OPTIONALLY) Commit these `.bashrc.*` files to your dotfiles repository.

## .bash_aliases

- Make a       `.bash_aliases.<ARCH>` file in your `${HOME}` on `<HOST>`;
- Make a       `.bash_aliases.<OS>`   file in your `${HOME}` on `<HOST>`;
- Make a local `.bash_aliases.<HOST>` file in your `${HOME}` on `<HOST>`; and
- Run `./.dotfiles.bootstrap.bash --symlinks` to create missing symlinks; and
- (OPTIONALLY) Commit these `.bash_aliases.*` files to your dotfiles repository.

----
[//]: # ( vim: set ts=4 sw=4 et cindent tw=80 ai si syn=markdown ft=markdown: )
