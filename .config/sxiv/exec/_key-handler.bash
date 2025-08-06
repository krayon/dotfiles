#!/bin/bash

# Example for $XDG_CONFIG_HOME/sxiv/exec/key-handler
# Called by sxiv(1) after the external prefix key (C-x by default) is pressed.
# The next key combo is passed as its first argument. Passed via stdin are the
# images to act upon, one path per line: all marked images, if in thumbnail
# mode and at least one image has been marked, otherwise the current image.
# sxiv(1) blocks until this script terminates. It then checks which images
# have been modified and reloads them.

# The key combo argument has the following form: "[C-][M-][S-]KEY",
# where C/M/S indicate Ctrl/Meta(Alt)/Shift modifier states and KEY is the X
# keysym as listed in /usr/include/X11/keysymdef.h without the "XK_" prefix.

# ${@} == key
# stdin == file list
# DEBUGGING:
#echo "${@}:" >>/tmp/sxiv.log

case "${1}" in #{
#    "C-x")      xclip -in -filter | tr '\n' ' ' | xclip -in -selection clipboard ;;
#    "C-c")      while read file; do xclip -selection clipboard -target image/png "$file"; done ;;
#    "C-e")      while read file; do urxvt -bg "#444" -fg "#eee" -sl 0 -title "$file" -e sh -c "exiv2 pr -q -pa '$file' | less" & done ;;
#    "C-g")      tr '\n' '\0' | xargs -0 gimp & ;;
#    "C-r")      while read file; do rawtherapee "$file" & done ;;
#    "C-comma")  rotate 270 ;;
#    "C-period") rotate  90 ;;
#    "C-slash")  rotate 180 ;;

    "d") # Delete file
        prompt="Are you sure you want to delete the following files?"$'\n'
        while read -r f; do #{
            rf="$(readlink -f "${f}")"
            files+=("${rf}")
            prompt+=$'\n'"    ${rf}"
        done #}

        zenity \
            --question \
            --no-markup \
            --default-cancel \
            --icon-name=dialog-warning \
            --ok-label="_Yes" \
            --text="${prompt}"

        [ ${?} -eq 0 ] && {
            mv "${files[@]}" ~/.TRASH/
        }
    ;;

    "C-r") # Rename
        promptpart="Simple replace rename. Files:"$'\n'
        while read -r f; do #{
            rf="$(readlink -f "${f}")"
            files+=("${rf}")
            promptpart+=$'\n'"    ${rf}"
        done #}
        promptpart+=$'\n'

        from=""
        while true; do #{
            prompt="${promptpart}"$'\n'"Enter string to search for?"$'\n'
            from="$( \
                zenity \
                    --entry \
                    --entry-text="${from}" \
                    --no-markup \
                    --default-cancel \
                    --icon-name=dialog-question \
                    --ok-label="_From" \
                    --text="${prompt}"
            )"

            # Allow cancel
            [ ${?} -ne 0 ] && {
                from=""
                break
            }

            # Require from
            [ -z "${from}" ] && continue

            prompt="${promptpart}"$'\n'"Searching for:"$'\n'
            prompt+=$'\n'"    ${from}"$'\n'
            prompt+=$'\n'"Enter string to replace with?"$'\n'

            to="$( \
                zenity \
                    --entry \
                    --no-markup \
                    --default-cancel \
                    --icon-name=dialog-question \
                    --ok-label="_To" \
                    --text="${prompt}"
            )"

            # If cancel, go back to from
            [ ${?} -ne 0 ] && {
                continue
            }

            break
        done #}

        # If we don't have from, it's cancel
        [ -z "${from}" ] && continue

        rename="$(type -P rename.ul)"
        [ ! -x "${rename}" ] && rename="$(type -P rename)"
        [ ! -x "${rename}" ] && {
            zenity \
                --error \
                --no-markup \
                --icon-name=dialog-error \
                --text="Unable to find rename/rename.ul"
            from=""

            true
        } || {
            output="$(
                "${rename}" "${from}" "${to}" "${files[@]}" 2>&1
            )"
            [ -n "${output}" ] && {
                zenity \
                    --warning \
                    --no-markup \
                    --icon-name=dialog-warning \
                    --text="rename/rename.ul returned:"$'\n'$'\n'"${output}"
            }
        }
    ;;

    "C-e") # GIMP
        tr '\n' '\0'|xargs -0 gimp &
    ;;
    "C-c"|"C-y") # Copy image to clipboard (CTRL-c, CTRL-y)
        while read -r f; do #{
            xclip -selection clipboard -target "image/png" "$(readlink -f ${f})"
        done #}
    ;;

    "y") # Copy path(s) to primary selection
        # 'xclip -in -filter' reads all stdin's stuff
        #xclip -in -filter|tr '\n' ' '|xclip -in
        xclip -in -filter|xclip -in
    ;;
esac #}

# vim:ts=4:tw=80:sw=4:et:ai:si
