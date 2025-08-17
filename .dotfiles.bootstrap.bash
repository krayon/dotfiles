#!/bin/bash
# vim:set ts=4 sw=4 tw=80 et ai si cindent cino=L0,b1,(1s,U1,m1,j1,J1,)50,*90,#0 cinkeys=0{,0},0),0],\:,0#,!^F,o,O,e,0=break:
#
#/**********************************************************************
#    dotfiles bootstrapper
#    Copyright (C)2017 Krayon (Todd Harbour)
#
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of the GNU General Public License
#    version 2 ONLY, as published by the Free Software Foundation.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program, in the file COPYING or COPYING.txt; if
#    not, see http://www.gnu.org/licenses/ , or write to:
#      The Free Software Foundation, Inc.,
#      51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
# **********************************************************************/

work_tree="${HOME}"

unset tempdir
unset keep
unset host

cleanup() {
    [ -n "${tempdir}" ] && rm -Rf "${tempdir}"
}
trap cleanup EXIT

# Create host symlinks
create_symlinks() {
    local ARCH OS HOST

    # Get architecture
    ARCH="$(uname -m)" || {
        echo "[1;31mWARNING:[0;0m Failed to identify architecture"
    }

    # Get OS
    OS="$(sed -n 's/^[ \t]*ID[ \t]*=[ \t]*["]\?\([^" \t]*\)["]\?[ \t]*$/\1/p' </etc/os-release)" || {

        echo "[1;31mWARNING:[0;0m Failed to identify Operating System"
    }

    # Host
    [ -n "${host}" ] && {
        HOST="${host}"
    } || {
        echo "[1;31mWARNING:[0;0m Skipping creation of host symlinks - no hostname identified"
    }

    for f in bin/ .bashrc .bash_aliases; do #{
        for a in ARCH OS HOST; do #{
            # Skip unknowns/empty
            [ -z "${!a}" ] && continue

            # Strip extra slashes from directories
            while [ "${f: -2:2}" == '//' ]; do f="${f:0: -1}"; done

            # Directory
            if [ "${f: -1:1}" == '/' ]; then #{
                src="${f%/*}.${!a}/"
                dst="${f%/*}.${a}"
            else #}{
                src="${f}.${!a}"
                dst="${f}.${a}"
            fi #}

            # Check for existance of file or directory (trailing '/' will ensure
            # accurate directory match)
            [ ! -e "${work_tree%/*}/${src}" ] && continue

            ln -s "${src}" "${work_tree%/*}/${dst}" || {
                echo "[1;31mWARNING:[0;0m Failed to symlink ${dst} to ${src} in ${work_tree}"
            }
        done #}
    done #}
}

# Ensure only single trailing '/' for work_tree
while [ "${work_tree: -1:1}" == '/' ]; do work_tree="${work_tree:0: -1}"; done
work_tree+='/'

repo_path="$(realpath "${0%/*}")" || {
    # No realpath, try dirname
    repo_path="$(dirname "${0}")"
    # Make absolute
    [ "${repo_path:0:1}" != '/' ] && repo_path="$(pwd)/${repo_path}"
    repo_path="${repo_path//\/.\//\/}"
}

# Ensure only single trailing '/' for repo_path
while [ "${repo_path: -1:1}" == '/' ]; do repo_path="${repo_path:0: -1}"; done
repo_path+='/'

[ "${1}" == '-h' ] || [ "${1}" == '--help' ] && {
cat <<EOF

Bootstraps the dotfiles repo and your home directory.

Usage: ${0##*/} [-h|--help]
       ${0##*/} [-k|--keep]
       ${0##*/} [-s|--symlinks]

-h|--help      - Shows this help
-k|--keep      - Keeps the original repository directory (default is to replace 
                 it with the bare repository files)
-s|--symlinks  - JUST (re)create symlinks
EOF

    exit 0
}

host="$(hostname)" || {
    echo "[1;31mWARNING:[0;0m Failed to determine hostname"
}

[ "${1}" == '-s' ] || [ "${1}" == '--symlinks' ] && {
    create_symlinks
    exit $?
}

[ "${repo_path}" == "${work_tree}" ] && {
    echo "[1;33mINFO:[0;0m Repository seems to already be \$work_tree ( ${work_tree} )"
    echo
    echo "Aborting..."
    exit 1
}

[ "${1}" == '-k' ] || [ "${1}" == '--keep' ] && {
    keep=1
    shift 1

    true
} || {

    [ ! -z "$(git --git-dir="${repo_path%/*}/.git" --work-tree="${repo_path}" status --porcelain=v1)" ] && {
        echo "[1;31mERROR:[0;0m Repository isn't clean, refusing to delete (use -k|--keep ?)"
        exit 1
    }

cat <<EOF
[1;31mWARNING:[0;0m This repository directory:

    ${repo_path}

will be REPLACED with the bare '.git' directory on completion of bootstrapping.
If you would instead like to keep it, please specify the '-k|--keep' option.

You have 5 seconds to CTRL-C before we continue...

EOF

    sleep 5

    echo 'Proceeding...'
}

[ -n "${keep}" ] && {
    repo_path="${repo_path%/*}/.git"
} || {
    tempdir="$(mktemp --directory --tmpdir)" || {
        echo "[1;31mERROR:[0;0m Failed to create temporary directory"
        exit 1
    }

    mv "${repo_path}" "${tempdir}/DIR" || {
        echo "[1;31mERROR:[0;0m Failed to move files to temporary directory"
        exit 1
    }

    mv "${tempdir}/DIR/.git" "${repo_path}" || {
        echo "[1;31mERROR:[0;0m Failed to replace repository directory"
        exit 1
    }
}

# Ensure we ignore untracked files
git --git-dir="${repo_path}" config status.showUntrackedFiles no

cat <<EOF

If you have not already done so, you should define an alias as follows:

    alias dotfiles='git --git-dir="${repo_path}" --work-tree="${work_tree}"'

EOF

[ ! -z "${host}" ] && {

cat <<EOF
You can likely put this in your host .bashrc or .bash_aliases file:

    - ${work_tree%/*}/.bashrc.${host}
    - ${work_tree%/*}/.bash_aliases.${host}

EOF

}

sleep 1

# Now, pull the files
git --git-dir="${repo_path}" --work-tree="${work_tree}" pull --ff-only

# And restore DELETED files
# (this is totally dangerous probably - we should be not crap here)
while read -r line; do #{
    git --git-dir="${repo_path}" --work-tree="${work_tree}" restore "${line}"
done < <(\
    git --git-dir="${repo_path}" --work-tree="${work_tree}" status --porcelain=v1\
    |sed -n 's/^ D //p'\
) #}

create_symlinks
