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

unset tempdir
unset keep

cleanup() {
    [ -n "${tempdir}" ] && rm -Rf "${tempdir}"
}
trap cleanup EXIT

repo_path="$(realpath "${0%/*}")" || {
    # No realpath, try dirname
    repo_path="$(dirname "${0}")"
    # Make absolute
    [ "${repo_path:0:1}" != '/' ] && repo_path="$(pwd)/${repo_path}"
    repo_path="${repo_path//\/.\//\/}"
}
[ "${repo_path: -1:1}" != '/' ] && repo_path="${repo_path}/"

[ "${1}" == '-h' ] || [ "${1}" == '--help' ] && {
cat <<EOF

Bootstraps the dotfiles repo and your home directory.

Usage: ${0##*/} [-h|--help]
       ${0##*/} [-k|--keep]

-h|--help      - Shows this help
-k|--keep      - Keeps the original repository directory (default is to replace 
                 it with the bare repository files)
EOF

    exit 0
}

[ "${1}" == '-k' ] || [ "${1}" == '--keep' ] && {
    keep=1
    shift 1

    true
} || {

    [ ! -n "$(git --git-dir="${repo_path}" status --porcelain=v1)" ] && {
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
    repo_path="${repo_path}/.git"
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

    alias dotfiles='git --git-dir="${repo_path}" --work-tree="${HOME}"'

EOF
sleep 1

# Finally, pull the files
git --git-dir="${repo_path}" --work-tree="${HOME}" --ff-only pull

