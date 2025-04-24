############################################################
# ~/.bash_aliases
############################################################
# vim:set ts=4 sw=4 tw=80 et ai si cindent cino=L0,b1,(1s,U1,m1,j1,J1,)50,*90 cinkeys=0{,0},0),0],\:,0#,!^F,o,O,e,0=break:

# Are we being run?
[ "${0}" == "${BASH_SOURCE[0]}" ] && {
    # Oh HELL no
    >&2 echo "ERROR: Non-executable, source file instead"
    exit 1
}



##############################################################################{
# Tpyos
#-----------------------------------------------------------------------------

# Mistakes are made
alias gerp='grep'

# Oops - slip of the fingers
alias psax='ps ax'

# You _probably_ meant vim right?
type -P vim &>/dev/null && {
    alias vi='vim'
}

#=============================================================================}



##############################################################################{
# Shell Basics
#-----------------------------------------------------------------------------

# The greatest thing EVER! Because alias get's expanded out first, the end
# result is sudo/fork supporting YOUR aliases (NOTE: the command could be used
# as the alias name directly to make it do it all the time :D)
alias sudoa='sudo '
alias forka='fork '

# Kill current terminal (no history writing, immediate bailout)
alias killme='kill -9 $$'
alias km='kill -9 $$'

# Use !!, it's quicker and easier
## sudo the last command typed
#alias sudothat='echo "sudo $(fc -ln -1)" && sudo $(fc -ln -1)'

# Disable stdin, stderr, stdout
alias closestdin='exec 0>&-'
alias closestdout='exec 1>&-'
alias closestderr='exec 2>&-'

# Bash caches executable locations
# you should enable 'shopt -s checkhash'
alias path_cmd_cache_del='hash -d'
alias path_cmd_cache_del_all='hash -r'

#======================================================================
# shopt push/pop functionality
#======================================================================

declare -a _shoptpstack

#function==============================================================
# shoptprint
#======================================================================
# Prints shell options (`shopt`) on the shopt stack (_shoptpstack)
#----------------------------------------------------------------------
# shoptprint
#----------------------------------------------------------------------
# Outputs:
#   Current shopt stack
# Returns:
#   0 = shopts popped
#   1 = shopt stack empty
#----------------------------------------------------------------------
shoptprint() {
    local f
    local i

    f="${FUNCNAME[0]}"
    [ "${FUNCNAME[1]}" != "source" ] && f="${FUNCNAME[1]}"

    [ ${#_shoptpstack[@]} -lt 1 ] && {
        >&2 echo "FAILED: ${f}: shopt stack empty"
        return 1
    }

    for i in $(seq $(( ${#_shoptpstack[@]} - 1 )) -1 0); do #{
        echo "shopt ${_shoptpstack[i]}"
    done #}
}

#function==============================================================
# shoptpush
#======================================================================
# Pushs the current shell options (`shopt`) onto the shopt stack (_shoptpstack)
#
# If no options are specified, pushes all shell options
#----------------------------------------------------------------------
# shoptpush [<shopt> [...]]
#----------------------------------------------------------------------
# Outputs:
#   Current shopt stack
# Returns:
#   0 = shopts popped
#   1 = shopt stack empty
#----------------------------------------------------------------------
shoptpush() {
    _shoptpstack+=("$(\
        shopt -p "${@}"\
            |sort\
            |sed 's#^shopt ##'\
            |tr '\n' ' '\
            |sed 's#\(.\) -s #\1 #g;s# -u#&&#;s# -u # #g'\
    )")

    shoptprint
}

#function==============================================================
# shoptpop
#======================================================================
# Pops shell options (`shopt`) off the shopt stack (_shoptpstack)
#----------------------------------------------------------------------
# shoptpop
#----------------------------------------------------------------------
# Outputs:
#   Current shopt stack
# Returns:
#   0 = shopts popped
#   1 = shopt stack empty
#----------------------------------------------------------------------
shoptpop() {
    local shoptss shoptsu

    shoptprint

    [ ${#_shoptpstack[@]} -ge 1 ] && {
        shoptss="$(sed -n 's#^\(-s.*\)-u.*$#\1#p' <<<"${_shoptpstack[-1]}")"
        shoptsu="$(sed -n 's#^.*\(-u.*\)$#\1#p'   <<<"${_shoptpstack[-1]}")"
        unset '_shoptpstack[-1]'

        # SC2086 (info): Double quote to prevent globbing and word splitting.
        # We want these expanded as each shopt is a single parameter and these
        # variables contain the '-s'/'-u' flag and the parameters all in one.
        # shellcheck disable=SC2086 # We want these expanded
        [ -n "${shoptss}" ] && shopt ${shoptss}
        # shellcheck disable=SC2086 # We want these expanded
        [ -n "${shoptsu}" ] && shopt ${shoptsu}
    }
}



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
    return "${1:-0}"
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

    declare -p "${1}" &>/dev/null
} # isset()

#function==============================================================
# test_params
#======================================================================
# Outputs the parameters passed to it
#----------------------------------------------------------------------
# test_params [<PARAM1> [<PARAM2> [...]]]
#----------------------------------------------------------------------
test_params() {
    echo -n "${#} parameter(s) passed"
    [ "${#}" -lt 1 ] && echo && return 0
    echo ':'
    i=0
    while [ "${#}" -gt 0 ]; do #{
        i=$((i + 1))
        printf "  %${##}d:|" "${i}"
        echo "${1}|"
        shift 1
    done #}
} # test_params()

#=============================================================================}



##############################################################################{
# Number processing
#-----------------------------------------------------------------------------

#function==============================================================
# isint v0.9
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
alias isnum='isint'
isint() {
    [ $# -lt 1 ] && return 1

    local ret=0
    while [ $# -gt 0 ]; do #{
        local num="${1#}"
        # Ensure param is an integer
        #[ "${1}" -eq "${1}" ] 2>/dev/null
        # shellcheck disable=SC2003 # expr returns error here which we want
        expr "${num}" + 1 &>/dev/null || {
            # Invalid integer
            >&2 echo "WARNING: Invalid integer: ${num}"
            ret=1
            shift 1
            continue
        }

        shift 1
    done #}

    return ${ret}
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
    local prec=''
    local fl=''

    [ $# -lt 1 ] && return 1

    ret=0
    while [ $# -gt 0 ]; do #{
        # Ensure param is a float
        prec="${1#*.}"; [ "${prec}" == "${1}" ] && prec=0 || prec="${#prec}"
        # shellcheck disable=SC2015 # Useless warning - this is not an if-then-else
        fl="$(printf "%.${prec}f" "${1}" 2>/dev/null)$([ "${1: -1}" == '.' ] && echo '.')" && [ "${fl}" == "${1}" ] || {
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

#=============================================================================}



##############################################################################{
# String processing
#-----------------------------------------------------------------------------

# Performs rot13 ( try it twice for 2 x the security ;) )
alias rot13='tr "[a-mn-zA-MN-Z]" "[n-za-mN-ZA-M]"'

alias       utf82ascii='iconv -f  utf8 -t ASCII'
alias      utf162ascii='iconv -f utf16 -t ASCII'
alias  utf82iso-8859-1='iconv -f  utf8 -t ISO_8859-1'
alias utf162iso-8859-1='iconv -f utf16 -t ISO_8859-1'
alias       ascii2utf8='iconv -f ASCII -t  utf8'
alias      ascii2utf16='iconv -f ASCII -t utf16'

# Undo what fold does
alias fold_undo='dlof'
alias dlof='sed -e '"'"':g;N;s/\n\([^\n ]\)/ \1/;tg;p;d'"'"

# Pad a base32 string to make it standards compliant
base32pad() {
    local line pad

    while read -r line; do #{
        # Pad base32 secret if needed
        pad="$(( 10 ** $(( (8 - (${#line} % 8)) % 8 )) ))"
        pad="$(tr '0' '=' <<<"${pad:1}")"
        echo "${line}${pad}"
    done < <(
        # Explicitly stdin
        [ ${#} -eq 1 ] && [ "${1}" == '-' ] && shift 1

        # Command line supplied
        [ ${#} -gt 0 ] && {
            while [ ${#} -gt 0 ]; do #{
                echo "${1}"
                shift 1
            done #}
            return $?
        }

        # Implicitly stdin
        cat
    ) #}
}

#=============================================================================}



##############################################################################{
# Shell Navigation and Filesystem Actions
#-----------------------------------------------------------------------------

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
alias cd.='cdd 0'
alias cd..='cdd 1'
alias cd...='cdd 2'
alias cd....='cdd 3'
alias cd.....='cdd 4'
alias cd......='cdd 5'
alias ..='cdd 1'
alias ...='cdd 2'
alias ....='cdd 3'
alias .....='cdd 4'
alias ......='cdd 5'
cdd() {
    # Blank parameter
    [ -z "${1}" ] && return

    [ ${#} -gt 1 ] && {
        >&2 echo "ERROR: Too many parameter(s): " "${@}"
        return 1
    }

    local num=''

    # Periods?
    [ -z "${1//./}" ] && {
        num="$((${#1} - 1))"
    }

    [ -z "${num}" ] && num="${1}"

    [ -z "${num}" ] && {
        >&2 echo "ERROR: Too few parameter(s): " "${@}"
        return 1
    }

    isint "${num}" || {
        >&2 echo "ERROR: Parameter not periods (.) or an integer: ${num}"
        return 1
    }

    # Exponentiate 10 by the number of directories
    # ie. '1' followed by numdirs '0's
    local dirs="$((10 ** ${num:-1}))"

    # Now, lose the '1' at the front
    dirs="${dirs:1}"

    # Finally, cd but change each '0' to '../'
    # shellcheck disable=SC2164 # We want this to fall through
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
        # shellcheck disable=SC2164 # We want this to fall through
        cd "${1}"
        return $?
    }

    # File I guess, CD to it's parent
    # shellcheck disable=SC2164 # We want this to fall through
    cd "${1%/*}"
} # cdf()

#function==============================================================
# mkcd
#======================================================================
# Makes a directory, then cd's into it
# (if more than one DIR specified, CD to last)
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

        [ ${#} -eq 1 ] && {
            cd "${1}" || return $?
        }

        shift 1
    done #}

    pwd
} # mkcd()

#function==============================================================
# mkpushd
#======================================================================
# Makes a directory, then pushd's into it
# (if more than one DIR specified, each is made and pushd'd into in order)
#----------------------------------------------------------------------
mkpushd() {
    if [ ${#} -lt 1 ]; then #{
        >&2 echo "Usage: mkpushd <DIR> [...]"
        >&2 echo "(if more than one DIR specified, each is made and pushd'd into in order)"
        return 1
    fi #}

    while [ ${#} -gt 0 ]; do #{
        if [ -d "${1}" ]; then #{
            >&2 echo "WARNING: Directory '${1}' exists..."
        else #} {
            mkdir -p "${1}"
        fi #}

        pushd "${1}" || {
            echo "ERROR: Failed to pushd to '${1}'"
            return 1
        }

        shift 1
    done #}

    pwd
} # mkpushd()

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
        if [ "$(wc -l < <(echo -n "${clip_p}"))" -gt "$(wc -l < <(echo -n "${clip_c}"))" ]; then #{
            dirs=("${clip_c}" "${dirs[@]}")
        else #} {
            dirs+=("${clip_c}")
        fi #}
    }

    for d in "${dirs[@]}"; do #{
        # Exists and is directory
        [ -d "${d}" ] && {
            # shellcheck disable=SC2164 # We want this to fall through
            cd "${d}"
            return $?
        }

        # Exists but not a directory? Assume file, CD to it's parent
        [ -e "${d}" ] && {
            # shellcheck disable=SC2164 # We want this to fall through
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

#function==============================================================
# pwdd
#======================================================================
# Prints the name of the current working directory (WITHOUT it's path)
#----------------------------------------------------------------------
pwdd() {
    local pwd
    read -r pwd < <(pwd "${@}")
    # Strip trailing '/'s
    while [ "${pwd: -1:1}" == '/' ]; do #{
        pwd="${pwd:0: -1}"
    done #}
    echo "${pwd##*/}"
} # pwdd()

#function==============================================================
# unziptodir
#======================================================================
# Unzip, windows style (to a subdirectory)
#----------------------------------------------------------------------
unziptodir() {
    local cmd param

    if type -P 7z &>/dev/null; then #{
        cmd='7z'
        param='x'
    else #} {
        cmd='unzip'
        param='-x'
    fi #}

    while [ $# -gt 0 ]; do #{
        local f="${1}"
        local d="${f%.*}"
        shift 1

        mkdir "${d}" || {
            >&2 echo "ERROR: Failed to mkdir ${d}"
            continue
        }

        (cd "${d}"/ && "${cmd}" "${param}" ../"${f}")
    done #}
} # unziptodir()

#=============================================================================}



##############################################################################{
# Time and date
#-----------------------------------------------------------------------------

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
alias daterfc3339z='date -u --rfc-3339="seconds"'
alias dateiso8601='date --iso-8601="seconds"'
alias dateiso8601z='date -u --iso-8601="seconds"'
alias day='date +%A'
alias datecmdsetformat='date +%m%d%H%M%Y.%S'

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

    d="$(date -u -Iseconds -d "@${d:0:10}")"

    # Strip ISO 8601 timezone data
    d="${d:0: -6}"

    # Strip ISO 8601 'T' between date and time and add 'UTC'
    echo "${d/T/ }${n} UTC"
} # epoch()

#=============================================================================}



##############################################################################{
# SSH
#-----------------------------------------------------------------------------

alias ssh-key-fingerprint='ssh-keygen -lf'
alias ssh-key-fingerprint-md5='ssh-keygen -E md5 -lf'

alias ssh-nohostcheck='ssh -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking no"'

#=============================================================================}



##############################################################################{
# Misc
#-----------------------------------------------------------------------------

# Youtube-dl fork
alias yt-dlp='yt-dlp                --output '"'"'%(title)s.%(release_date,upload_date)s.%(id)s.%(ext)s'"'"' --format '"'"'bestvideo*[height=768]+bestaudio/bestvideo*[height=720]+ba/bestvideo*[height=1080]+ba/bv+ba/best'"'"
alias yt-dlp-768='yt-dlp'
alias yt-dlp-1080='yt-dlp                                                                                    --format '"'"'bv*[height=1080]+ba/bv*[height=768]+ba/bv*[height=720]+ba/bv+ba/best'"'"
alias yt-dlp-best='yt-dlp                                                                                    --format '"'"'bv+ba/best/bv*[height=1080]+ba/bv*[height=768]+ba/bv*[height=720]+ba'"'"
alias yt-dlp-mp4='yt-dlp                                                                                     --format mp4'
alias yt-dlp-playlist='yt-dlp       --output '"'"'%(playlist_title)s.%(playlist_index)s.%(title)s.%(release_date,upload_date)s.%(id)s.%(ext)s'"'"
alias yt-dlp-playlist-date='yt-dlp  --output '"'"'%(playlist_title)s.%(release_date,upload_date)s.%(title)s.%(playlist_index)s.%(id)s.%(ext)s'"'"
alias yt-dlp-playlist-index='yt-dlp --output '"'"'%(playlist_title)s.%(playlist_index)s.%(title)s.%(id)s.%(ext)s'"'"

yt-dlp-google-link() {
    local vid=''
    local vids=()
    if [ "$#" -gt 0 ]; then #{
        while [ "$#" -gt 0 ]; do #{
            vid="${1/#*google.com*www.youtube.com\/watch\?v=/}"
            vid="${vid/#*google.com*www.youtube.com%3Fwatch%3Fv%3D/}"
            vids+=("${vid%%&*}")
            >&2 echo "${vids[@]}"
            shift 1
        done #}

        true
    else #} {
        local url=''
        while read -r url; do #{
            vid="${url/#*google.com*www.youtube.com\/watch\?v=/}"
            vid="${vid/#*google.com*www.youtube.com%3Fwatch%3Fv%3D/}"
            vids+=("${vid%%&*}")
            >&2 echo "${vids[@]}"
        done #}
    fi #}

    yt-dlp -- "${vids[@]}"
    return $?
}

#=============================================================================}
