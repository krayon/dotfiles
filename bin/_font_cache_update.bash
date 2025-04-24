#!/bin/bash
# SC2188: This redirection doesn't have a command. Move to its command (or use 'true' as no-op).
# shellcheck disable=SC2188

# $1 == dir
# $2 == 0/1 == overwrite (defaults to NO)
refreshdir() {
    local dir replace fontfiles numfonts
    dir="$1"; shift 1
    replace="$1"; shift 1

    echo -en "Refreshing font directory: ${dir}...\n\n"

    echo -en "Updating font cache (NEW)..."
    fc-cache "${dir}"
    echo -en " [done]\n"

    echo -en "Updating font scale data (OLD)..."
    mkfontscale "${dir}"
    echo -en " [done]\n"

    [ -r "${dir}"/fonts.dir ] && {
        echo -en "Backing up old font dir data (OLD)..."
        mv "${dir}"/fonts.dir "${dir}"/fonts.dir.BU
        echo -en " [done]\n"
    }

    echo -en "Updating font dir data (OLD)..."
    mkfontdir "${dir}"
    echo -en " [done]\n"

    echo "Discovered $(head -1 "${dir}"/fonts.dir) font(s)"

    if [ "${replace}" != "1" ]; then #{
        # Merge
        echo -en "Merging new font dir ($(head -1 "${dir}"/fonts.dir)) data with old ($(head -1 "${dir}"/fonts.dir.BU))..."

        >"${dir}"/fonts.dir.NEW

        # Retrieve font file list
        fontfiles=("$(
            sed '1d;s# -.*$##g' "${dir}"/fonts.dir|sort -u
        )")
        for font in "${fontfiles[@]}"; do #{
            if [ -r "${dir}"/fonts.dir.BU ]; then #{
                line="$(grep '^'"${font}"' -' "${dir}"/fonts.dir.BU)"
                if [ -n "${line}" ]; then
                    echo "${line}" >>"${dir}"/fonts.dir.NEW
                else
                    grep '^'"${font}"' -' "${dir}"/fonts.dir.BU >>"${dir}"/fonts.dir.NEW
                fi

            else #} {
                grep '^'"${font}"' -' "${dir}"/fonts.dir >>"${dir}"/fonts.dir.NEW

            fi #}
        done #}

        read numfonts _ < <(wc -l "${dir}"/fonts.dir.NEW)
        { echo "${numfonts}"; cat "${dir}"/fonts.dir.NEW; } >"${dir}"/fonts.dir.NEW2
        mv "${dir}"/fonts.dir.NEW2 "${dir}"/fonts.dir

        echo -en " [done]\n"
    fi #}

    echo -en "Deleting old font dir data (OLD)..."
    rm "${dir}"/fonts.dir.BU &>/dev/null
    echo -en " [done]\n"

    echo "$(head -1 "${dir}"/fonts.dir) known font(s)"

    echo -en "\n"
}

[ "${1}" == '-r' ] || [ "${1}" == '--replace' ] && replace=1 && shift 1

dir="${HOME}/.fonts"
[ -n "$1" ] && dir="${1}"
refreshdir "${dir}" ${replace:+1}
[ -d "${dir}/bitmap" ] && refreshdir "${dir}/bitmap"

xset fp+ "${dir}"
xset fp rehash

echo "Done."

exit $?
