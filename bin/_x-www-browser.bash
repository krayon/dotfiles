#!/bin/bash
# vim:set ts=4 sw=4 tw=80 et ai si cindent cino=L0,b1,(1s,U1,m1,j1,J1,)50,*90 cinkeys=0{,0},0),0],\:,!^F,o,O,e,0=break:

# Usage:
#     ln -s ~/bin/_x-www-browser.bash ~/bin/x-www-breowser.bash
#     x-www-browser 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'
#
# When x-www-browser is called, instead of some browser you likely didn't want
# to use for the given operation, you will receive the URL in your clipboard as
# well as a nice little popup telling you what's happened! :D

showhelp() {
    echo
    sed -n '/^# Usage/,/^[^#]/{/^[^#]/!{s/^#[ ]\?//p}}' "${1}"
}

if [ "${1}"       == '--help'             ] \
|| [ "${1}"       == '-h'                 ] \
; then #{
    showhelp "${0}"

    exit 0
fi #}


allparams="${*}"
[ ${#allparams} -gt 20 ] && allparams="${allparams:0:20}..."
[ ${#allparams} -lt  1 ] && allparams="&lt;stdin&gt;"

doit() {
    # Put into clipboard
    xclip -i || {
        notify-send -u critical "Unable to copy to clipboard: ${allparams}"
        return 1
    }
    notify-send -u normal "Copied to clipboard: ${allparams}"
}



# No params, read from stdin
[ $# -eq 0 ] && {
    doit
    exit $?
}

doit <<<"${@}"
exit $?

