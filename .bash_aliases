############################################################
# ~/.bash_aliases
############################################################
# vim:set ts=4 sw=4 tw=80 et ai si cindent cino=L0,b1,(1s,U1,m1,j1,J1,)50,*90 cinkeys=0{,0},0),0],\:,0#,!^F,o,O,e,0=break:

# Are we being run?
[ "${0}" == "${BASH_SOURCE}" ] && {
    # Oh HELL no
    >&2 echo "ERROR: Non-executable, source file instead"
    exit 1
}



############################################################
# Tpyos
############################################################

# Mistakes are made
alias gerp='grep'

# Oops - slip of the fingers
alias psax='ps ax'



############################################################
# Shell
############################################################

# The greatest thing EVER! Because alias get's expanded out first, the end
# result is sudo/fork supporting YOUR aliases (NOTE: the command could be used
# as the alias name directly to make it do it all the time :D)
alias sudoa='sudo '
alias forka='fork '

# Use !!, it's quicker and easier
## sudo the last command typed
#alias sudothat='echo "sudo $(fc -ln -1)" && sudo $(fc -ln -1)'

# Disable stdin, stderr, stdout
alias closestdin='exec 0>&-'
alias closestdout='exec 1>&-'
alias closestderr='exec 2>&-'

#function==============================================================
# set_return
#======================================================================
# Sets the return value ($?)
#----------------------------------------------------------------------
# set_return [<ret_val>]
#----------------------------------------------------------------------
# Outputs:
#   -
# Returns:
#           0 = if no <ret_val> set
#   <ret_val> = if <ret_val> is set
#----------------------------------------------------------------------
set_return() {
    return ${1:-0}
} # set_return()

#function==============================================================
# isset
#======================================================================
# Returns if a variable is set or not
#----------------------------------------------------------------------
# isset <VAR_NAME>
#----------------------------------------------------------------------
# Outputs:
#   NOTHING
# Returns:
#   0 = Is set
#   1 = Is not set
#       (or no <VAR_NAME> provided)
#----------------------------------------------------------------------
isset() {
    [ $# -ne 1 ] && return 1

    return $(declare -p "${1}" &>/dev/null)
} # isset()

#function==============================================================
# isint
#======================================================================
# Returns if the string(s) provided is an integer or not
#----------------------------------------------------------------------
# isint <STRING> [<STRING> [...]]
# isnum <STRING> [<STRING> [...]]
#----------------------------------------------------------------------
# Outputs:
#   NOTHING
# Returns:
#   0 = SUCCESS: Provided string(s) is an integer
#   1 = (PARTIAL) FAILURE: NOT an integer
#       (or no <STRING> provided)
#----------------------------------------------------------------------
alias isint='isnum'
isint() {
    [ $# -lt 1 ] && return 1

    ret=0
    while [ $# -gt 0 ]; do #{
        # Ensure param is an integer
        #[ "${1}" -eq "${1}" ] 2>/dev/null
        expr "${1}" + 0 &>/dev/null || {
            # Invalid integer
            >&2 echo "WARNING: Invalid integer: ${1}"
            ret=1
            shift 1
            continue
        }

        shift 1
    done #}

    return 0
} # isint()

#function==============================================================
# isfloat
#======================================================================
# Returns if the string(s) provided is a float or not
#----------------------------------------------------------------------
# isfloat <STRING> [<STRING> [...]]
#----------------------------------------------------------------------
# Outputs:
#   NOTHING
# Returns:
#   0 = SUCCESS: Provided string(s) is a float
#   1 = (PARTIAL) FAILURE: NOT a float
#       (or no <STRING> provided)
#----------------------------------------------------------------------
isfloat() {
    [ $# -lt 1 ] && return 1

    ret=0
    while [ $# -gt 0 ]; do #{
        # Ensure param is a float
        local prec="${1#*.}"; [ "${prec}" == "${1}" ] && prec=0 || prec="${#prec}"
        local fl="$(printf "%.${prec}f" "${1}" 2>/dev/null)$([ "${1: -1}" == '.' ] && echo '.')" && [ "${fl}" == "${1}" ] || {
            # Invalid float
            >&2 echo "WARNING: Invalid float: ${1}"
            ret=1
            shift 1
            continue
        }

        shift 1
    done #}

    return 0
} # isfloat()

#function==============================================================
# cdd, cd.., cd... etc
#======================================================================
# Changes up multiple directories, based on number (or period count)
#   - Based on dyscoria's (ArchLinux Forums) script
#   - Optimized by Procyon
#   - Further optimized by Krayon
#----------------------------------------------------------------------
# cdd <NUM>
# cdd .[.[.]] ...
# cd..
# cd...
# cd....
# cd.....
# cd......
#----------------------------------------------------------------------
# Outputs:
#   NOTHING
# Returns:
#   0 = SUCCESS
#   1 = FAILURE
#----------------------------------------------------------------------
alias cd..='cdd 1'
alias cd...='cdd 2'
alias cd....='cdd 3'
alias cd.....='cdd 4'
alias cd......='cdd 5'
cdd() {
    # Blank parameter
    [ -z "${1}" ] && return

    [ ${#} -gt 1 ] && {
        >&2 echo "ERROR: Too many parameter(s): ${@}"
        return 1
    }

    local num=''

    # Periods?
    [ -z "${1//./}" ] && {
        num="$((${#1} - 1))"
    }

    [ -z "${num}" ] && {
        num="$(printf '%d' "${1}" 2>/dev/null)" || {
            >&2 echo "ERROR: NaN: Parameter 'num' not an integer: ${1}"
            return 1
        }
    }

    [ -z "${num}" ] && {
        >&2 echo "ERROR: Invalid parameter(s): ${@}"
        return 1
    }

    # Exponentiate 10 by the number of directories
    # ie. '1' followed by numdirs '0's
    local dirs="$((10 ** ${num:-1}))"

    # Now, lose the '1' at the front
    dirs="${dirs:1}"

    # Finally, cd but change each '0' to '../'
    cd "${dirs//0/..\/}"
} # cdd()

#function==============================================================
# cdf
#======================================================================
# CDs to a file's directory
#----------------------------------------------------------------------
cdf() {
    if [ ${#} -lt 1 ]; then #{
        >&2 echo "Usage: cdf <FILE>"
        return 1
    fi #}

    # Exists and is directory
    [ -d "${1}" ] && {
        cd "${1}"
        return $?
    }

    # File I guess, CD to it's parent
    cd "${1%/*}"
    return $?
} # cdf()

#function==============================================================
# mkcd
#======================================================================
# Makes a directory, then cd's into it
#----------------------------------------------------------------------
mkcd() {
    if [ ${#} -lt 1 ]; then #{
        >&2 echo "Usage: mkcd <DIR> [...]"
        >&2 echo "(if more than one DIR specified, CD to last)"
        return 1
    fi #}

    while [ ${#} -gt 0 ]; do #{
        if [ -d "${1}" ]; then #{
            >&2 echo "WARNING: Directory '${1}' exists..."
        else #} {
            mkdir -p "${1}"
        fi #}

        [ ${#} -eq 1 ] && cd "${1}"

        shift 1
    done #}

    pwd
} # mkcd()

#function==============================================================
# cdclip
#======================================================================
# CDs to a directory in the primary selection (or clipboard)
#----------------------------------------------------------------------
cdclip() {
    [ -z "${DISPLAY}" ] && return 1

    declare -a dirs

    clip_p="$(xclip -o)" && {
        dirs+=("${clip_p}")
    }

    clip_c="$(xclip -o -selection clipboard)" && {
        [ $(wc -l < <(echo -n "${clip_p}")) -gt $(wc -l < <(echo -n "${clip_c}")) ] && {
            dirs=("${clip_c}" "${dirs[@]}")
        } || {
            dirs+=("${clip_c}")
        }
    }

    for d in "${dirs[@]}"; do #{
        # Exists and is directory
        [ -d "${d}" ] && {
            cd "${d}"
            return $?
        }

        # Exists but not a directory? Assume file, CD to it's parent
        [ -e "${d}" ] && {
            cd "${d%/*}"
            return $?
        }

        >&2 echo "WARNING: Unknown directory or file: ${d}"
    done #}

    >&2 echo "ERROR: No valid directory found in selection or clipboard"
    return 2
} # cdclip()

#function==============================================================
# chlike
#======================================================================
# chmod and chown like another file
#----------------------------------------------------------------------
# chlike <SOURCE_FILE> <DEST_FILE> [<DEST_FILE> [...]]
#----------------------------------------------------------------------
chlike() {
    if \
       [ ${#} -lt 2  ]\
    || [ ! -e "${1}" ]\
    || [ ! -e "${2}" ]\
    ; then #{
        >&2 echo "Usage: chlike <SOURCE_FILE> <DEST_FILE> [<DEST_FILE> [...]]"
        return 1
    fi #}

    src="${1}"; shift 1

    chown --reference="${src}" "${@}"
    chmod --reference="${src}" "${@}"
} # chlike()



############################################################
# Time and date
############################################################

# Timestamp  (YYYYMMDDhhmmss)
# Timestampm (YYYYMMDDhhmm)
# Timestamph (YYYYMMDDhh)
# Timestampd (YYYYMMDD)
alias timestamp='date +%Y%m%d%H%M%S'
alias timestampm='date +%Y%m%d%H%M'
alias timestamph='date +%Y%m%d%H'
alias timestampd='date +%Y%m%d'
alias timestampe='date +%s'
alias ts='timestamp'
alias tsm='timestampm'
alias tsh='timestamph'
alias tsd='timestampd'
alias tse='timestampe'
alias daterfc3339='date --rfc-3339="seconds"'
alias day='date +%A'

#function==============================================================
# epoch
#======================================================================
# Takes a number of seconds since UNIX epoch and outputs in readable format.
# Supports nanosecond epochs too.
#----------------------------------------------------------------------
# epoch [<epoch>]
#----------------------------------------------------------------------
# Outputs:
#   The formatted UTC date, eg. 2022-10-19 00:25:06.765
# Returns:
#   0 = SUCCESS
#   1 = FAILURE
#----------------------------------------------------------------------
alias epoch2date='epoch'
epoch() {
    local d="${1}"
    [ ${#d} -lt 10 ] && {
        >&2 echo "ERROR: Invalid epoch length (${#d}). Expected 10 - 13${d:+: }${d:-.}"
        return 1
    }
    [ ${#d} -gt 13 ] && {
        >&2 echo "WARNING: epoch length (${#d}) greater than expected 10-13."
    }

    local regex='^[0-9]+$'
    [[ "${d}" =~ ${regex} ]] || {
        >&2 echo "ERROR: Invalid epoch: ${d}"
        return 1
    }

    local n="${d:10}"
    [ -n "${n}" ] && n=".${n}"

    d="$(date -u -Iseconds -d @${d:0:10})"

    # Strip ISO 8601 timezone data
    d="${d:0: -6}"

    # Strip ISO 8601 'T' between date and time and add 'UTC'
    echo "${d/T/ }${n} UTC"
}



############################################################
# String manipulation
############################################################

# Performs rot13 ( try it twice for 2 x the security ;) )
alias rot13='tr "[a-mn-zA-MN-Z]" "[n-za-mN-ZA-M]"'

# Youtube-dl fork
alias yt-dlp='yt-dlp --output '"'"'%(title)s.%(release_date,upload_date)s.%(id)s.%(ext)s'"'"' --format mp4'

yt-dlp-google-link() {
    local vids=()
    [ "$#" -gt 0 ] && {
        while [ "$#" -gt 0 ]; do #{
            local vid="$(
                sed 's#^.*google.*www.youtube.com%2Fwatch%3Fv%3D##' <<<"$1"
            )"
            vids+=("${vid%%&*}")
            >&2 echo "${vids[@]}"
            shift 1
        done #}

        true
    } || {
        local url=''
        while read -r url; do #{
            local vid="$(
                sed 's#^.*google.*www.youtube.com%2Fwatch%3Fv%3D##' <<<"$url"
            )"
            vids+=("${vid%%&*}")
            >&2 echo "${vids[@]}"
        done #}
    }

    yt-dlp ${vids[@]}
    return $?
}

