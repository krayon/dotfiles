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
#
# Here, we also include our PATH (_little_ dangerous but we use it with care)
alias sudoa='sudo env "PATH=$PATH" '
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
    # global _shoptpstack
    local f i

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
    # global _shoptpstack

    # This produces a list that ALWAYS starts with '-s', followed by 0 or more
    # shopts to set, followed by '-u', followed by 0 or more shopts to unset
    _shoptpstack+=("$(\
        shopt -p "${@}"\
            |sort\
            |tr '\n' ' '\
            |sed 's/shopt //g;s/^/ -s /;s/$/ -u /;s/\(.\) -s /\1 /g;s/ -u/&&/;s/ -u / /g'
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
    # global _shoptpstack
    local shoptss shoptsu

    shoptprint

    [ ${#_shoptpstack[@]} -ge 1 ] && {
        shoptss="$(sed -n 's#^[ ]*-s\(.*\)-u.*$#\1#p' <<<"${_shoptpstack[-1]}")"
        shoptsu="$(sed -n 's#^.*-u\(.*\)$#\1#p'       <<<"${_shoptpstack[-1]}")"
        unset '_shoptpstack[-1]'

        # SC2086 (info): Double quote to prevent globbing and word splitting.
        # We want these expanded as each shopt is a single parameter and these
        # variables contain the '-s'/'-u' flag and the parameters all in one.
        # shellcheck disable=SC2086 # We want these expanded
        [ -n "${shoptss// }" ] && shopt -s ${shoptss}
        # shellcheck disable=SC2086 # We want these expanded
        [ -n "${shoptsu// }" ] && shopt -u ${shoptsu}
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

alias debextract='ar x'

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
    local ret num

    [ $# -lt 1 ] && return 1

    ret=0
    while [ $# -gt 0 ]; do #{
        num="${1#}"
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

#function==============================================================
# randnum
#======================================================================
# generates a randum number between 2 bounds
#----------------------------------------------------------------------
# randnum <LOWER> <UPPER>
#----------------------------------------------------------------------
randnum() {
    local RANDMAX tempn num

    # local is the default for declare unless -g is used
    declare -a param

    # man bash says 32767 is max
    RANDMAX=32767

    if [ $# -ne 2 ] ||\
    [ "${1}" == "--help" ] ||\
    [ "${1}" == "-h" ]\
    ; then #{

cat <<EOF >&2
Usage: randnum <LOWER> <UPPER>

Example:
  num 1 6
Output:
  3
EOF

        return
    fi #}

    # Place numbers in param[0] and param[1]
    for ((i = 0; i < 2; ++i)); do #{
        param[${i}]="${1}"

        # Ensure they are digits
        isint "${1}" || {
            >&2 echo "Param $((i + 1)) invalid: ${1}"
            return 1
        }

        shift 1
    done #}

    # Swap if req'd
    if [ "${param[0]}" -gt "${param[1]}" ]; then #{
        >&2 echo "WARNING: Swapping numbers (${param[0]} > ${param[1]})"
        tempn="${param[0]}"
        param[0]="${param[1]}"
        param[1]="${tempn}"
    fi #}

    # Number of digits in range
    num=$((param[1] - param[0] + 1))

    if [ ${num} -gt ${RANDMAX} ]; then #{
        >&2 echo "ERROR: Random range limited to ${RANDMAX}"
        return 2
    fi #}

    echo "$(((RANDOM % num) + param[0]))"
} # randnum()

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

#function==============================================================
# zeropad
#======================================================================
# zero (or any other character) pads a number
#----------------------------------------------------------------------
# zeropad <NUM> <NUMCHARS> [CHAR]
#----------------------------------------------------------------------
zeropad() {
    local char num numchars sign expo formatd numleads

    char="0"

    if\
        [ $# -lt 2 ] ||\
        [ $# -gt 3 ] ||\
        [ "${1}" == "--help" ] ||\
        [ "${1}" == "-h" ]\
    ; then #{

cat <<EOF >&2
Usage: zeropad <NUM> <NUMCHARS> [<CHAR>]

    <NUM>      - Number to zero pad
    <NUMCHARS> - Desired width (excluding negative symbol if applicable)
    <CHAR>     - Character to pad with ( DEFAULT: ${char} )

Example:
  zeropad -59 5 x
Output:
  -xxx59
EOF

        return 0
    fi #}

    [ $# -eq 3 ] && char="${3}"

    # Ensure params are numbers
    num="${1}"
    numchars="${2}"

    isint "${num}" || {
        >&2 echo "ERROR: <NUM> not a number: ${num}"
        return 2
    }

    isint "${numchars}" || {
        >&2 echo "ERROR: <NUMCHARS> not a number: ${numchars}"
        return 2
    }

    num=$((num + 0))
    numchars=$((numchars + 0))

    # Sign
    if [ "${num}" -lt 0 ]; then #{
        num=$((num * -1))
        sign=-1
    fi #}

    # Exponentiate 10 by the numchars
    expo=$((10 ** numchars))

    # Number is at least that number of digits so don't bother
    if [ "${#num}" -ge "${numchars}" ]; then #{
        echo ${sign:+'-'}${num}
        return
    fi #}

    if [ "${char}" == "0" ]; then #{
        formatd=$((num + expo))
        echo ${sign:+'-'}${formatd:1}
    else #} {
        # Need to get tricky
        numleads=$((numchars - ${#num}))
        #echo "${sign:+'-'}$(echo "${expo: -${numleads}}"|tr '0' "${char}")${num}"
        expo="${expo: -${numleads}}"
        echo "${sign:+'-'}${expo//0/${char}}${num}"
    fi #}
} # zeropad()

#function==============================================================
# strpad
#======================================================================
# pad a string with characters on the left, right or both sides
#----------------------------------------------------------------------
# strpad [-l|-r] <STRING> <NUMCHARS> [CHAR]
#----------------------------------------------------------------------
strpad() {
    local align padl padr char numchars padchars expo expon numpads numpadsx

    align=1
    padl=""
    padr=""
    char=" "

    if [ "${1}" == "-l" ]; then #{
        # Left align
        align=0
        shift 1
    elif [ "${1}" == "-r" ]; then #} {
        # Right align
        align=2
        shift 1
    fi #}

    if \
       [ $# -lt 2 ] \
    || [ $# -gt 3 ] \
    || [ "${1}" == "--help" ] \
    || [ "${1}" == "-h" ] \
    ; then #{

cat <<EOF >&2
Usage: strpad [<ALIGN>] <STRING> <NUMCHARS> [<CHAR>]

Options:
  ALIGN       - The desired alignment.  Specify left (-l) or
                right (-r) (center is default)
  CHAR        - The character to use as padding (' ' is the default

Example:
  strpad "foo" 6 x
Output:
  xfooxx
EOF

        return
    fi #}

    if [ $# -eq 3 ]; then #{
        char="${3}"
    fi #}

    str="${1}"

    # Ensure numchars is a number
    numchars="${2}"
    isint "${numchars}" || {
        >&2 echo "ERROR: <NUMCHARS> not a number: ${numchars}"
        return 2
    }
    numchars=$((numchars + 0))

    # Number is at least that number of digits so don't bother
    if [ "${#str}" -ge "${numchars}" ]; then
        echo "${str}"
        return
    fi

    # Exponentiate 10 by the numchars
    padchars="x"
    expo=${numchars}
    while [ "${expo}" -gt 10 ]; do #{
        padchars="${padchars}0000000000"
        expo=$((expo - 10))
    done #}
    expon=$((10 ** expo))
    padchars="${padchars}${expon: -${expo}}"
    unset expon
    unset expo

    numpads=$((numchars - ${#str}))
    if [ "${align}" -ne 1 ]; then #{
        # Left or Right
        padl="$(echo "${padchars: -${numpads}}"|tr '0' "${char}")"

        if [ ${align} -eq 0 ]; then #{
            # Left (aligned, so pad on the right)
            padr="${padl}"
            padl=""
        fi #}
    else #} {
        # Center
        numpadsx=$((numpads / 2))
        padl="$(echo "${padchars: -${numpadsx}}"|tr '0' "${char}")"
        [ ${numpads} -eq 1 ] && {
            # Override for numpads=1
            numpadsx=0
            padl=""
        }
        numpadsx=$((numpadsx + (numpads - (numpadsx * 2))))
        padr="$(echo "${padchars: -${numpadsx}}"|tr '0' "${char}")"
        unset numpadsx
    fi #}
    unset numpads

    #echo "$(echo "${padchars: -${numpads}}"|tr '0' "${char}")${str}"
    echo "${padl}${str}${padr}"
} # strpad()

#function==============================================================
# ltrim
#======================================================================
# Trims string(s)/line(s) of leading whitespace (spaces and tabs specifically)
#----------------------------------------------------------------------
# ltrim <STRING> [<STRING> [...]]
#----------------------------------------------------------------------
# Outputs:
#   The input string(s) with the leading whitespace (spaces and tabs) removed.
# Returns:
#   0
#----------------------------------------------------------------------
ltrim() {
    local line extglob

    extglob="$(shopt -p|grep extglob$)"
    shopt -s extglob

    [ ${#} -gt 0 ] && {
        for line in "${@}"; do #{
            echo "${line##*([ $'\t'])}"
        done #}
        ${extglob}
        return 0
    }

    while read -r line; do #{
#>&2 echo "FIRST: |${line}|"
        echo "${line##*([ $'\t'])}"
    done #}
    ${extglob}
    return 0
} # ltrim()

#function==============================================================
# rtrim
#======================================================================
# Trims string(s)/line(s) of trailing whitespace (spaces and tabs specifically)
#----------------------------------------------------------------------
# rtrim <STRING> [<STRING> [...]]
#----------------------------------------------------------------------
# Outputs:
#   The input string(s) with the trailing whitespace (spaces and tabs) removed.
# Returns:
#   0
#----------------------------------------------------------------------
rtrim() {
    local line extglob

    extglob="$(shopt -p|grep extglob$)"
    shopt -s extglob

    [ ${#} -gt 0 ] && {
        for line in "${@}"; do #{
            echo "${line%%*([ $'\t'])}"
        done #}
        ${extglob}
        return 0
    }

    while read -r line; do #{
#>&2 echo "FIRST: |${line}|"
        echo "${line%%*([ $'\t'])}"
    done #}
    ${extglob}
    return 0
} # rtrim()

#function==============================================================
# trim
#======================================================================
# Trims string(s)/line(s) of whitespace (spaces and tabs specifically)
#----------------------------------------------------------------------
# trim <STRING> [<STRING> [...]]
#----------------------------------------------------------------------
# Outputs:
#   The input string(s) with the leading and trailing whitespace (spaces and
#   tabs) removed.
# Returns:
#   0
#----------------------------------------------------------------------
trim() {
    local line

    [ ${#} -gt 0 ] && {
        #set -- $(ltrim "${@}")
        rtrim "$(ltrim "${@}")"
        return 0
    }

    while read -r line; do #{
        rtrim "$(ltrim "${line}")"
    done #}
    return 0
} # trim()

#function==============================================================
# chr
#======================================================================
# Gets an ASCII representation of a provided number
#----------------------------------------------------------------------
# chr <NUMBER> [<NUMBER> [...]]
#----------------------------------------------------------------------
# Outputs:
#   The ASCII character(s) of the provided <NUMBER>(s).
# Returns:
#   0 = Success
#   1 = (PARTIAL) FAILURE ((a) <NUMBER> is not within range (0 - 255))
#       (or no <STRING> provided)
#----------------------------------------------------------------------
chr() {
    local ret output

    # local is the default for declare unless -g is used
    declare -a a_chrs

    [ $# -lt 1 ] && return 1

    ret=0

    while [ $# -gt 0 ]; do #{
        isint "${1}" 2>/dev/null || {
            >&2 echo "WARNING: <NUMBER> not a number, ignoring: ${1}"
            ret=1
            shift 1
            continue
        }

        # shellcheck disable=SC2015 # Useless warning - this is not an if-then-else
        [ "${1}" -gt -1 ] && [ "$1" -lt 256 ] || {
            # Out of bounds (< 0 || > 255)
            >&2 echo "WARNING: <NUMBER> out of bounds, ignoring: ${1}"
            ret=1
            shift 1
            continue
        }

        a_chrs+=("$((${1} + 0))")
        shift 1
    done #}

    output="$(printf '\\%04o' "${a_chrs[@]}")"; r=$?
    [ "${r}" -ne 0 ] && ret=${r}
    echo -e "${output}"

    return ${ret}
} # chr()

#function==============================================================
# ord
#======================================================================
# Gets the ASCII value of a provided character
#----------------------------------------------------------------------
# ord <CHAR> [<CHAR> [...]]
#----------------------------------------------------------------------
# Outputs:
#   The ASCII value(s) of the provided <CHAR>(s).
# Returns:
#   0 = SUCCESS
#   1 = (PARTIAL) FAILURE
#       (or no <CHAR> provided)
#----------------------------------------------------------------------
ord() {
    [ $# -lt 1 ] && return 1

    ret=0
    while [ $# -gt 0 ]; do #{
        LC_CTYPE=C printf '%d' "'$1"; r=$?
        [ "${r}" -ne 0 ] && ret=${r}
        shift 1
    done #}

    return ${ret}
} # ord()

#function==============================================================
# dec2bin
#======================================================================
# Array of binary strings, equal to their decimal keys
#----------------------------------------------------------------------
# ${dec2bin[<NUM>]}
# dec2bin <NUM> [<NUM> [...]]
# ${num2bin[<NUM>]}
# num2bin <NUM> [<NUM> [...]]
#----------------------------------------------------------------------
# Outputs:
#   The string of 0/1's that is the binary number equating to the
#   provided <NUM>.
# Returns:
#   0
#----------------------------------------------------------------------
dec2bin=({0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1})
# shellcheck disable=SC2034 # Here to be used directly
num2bin=({0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1})
alias num2bin='dec2bin'
dec2bin() {
    local output

    [ $# -lt 1 ] && return 1

    while [ $# -gt 0 ]; do #{
        output+="${dec2bin[$1]} "
        shift 1
    done #}

    echo "${output:0: -1}"
} # dec2bin()

#function==============================================================
# dec2oct
#======================================================================
# Returns an octal number of a provided number
#----------------------------------------------------------------------
# dec2oct <NUM> [<NUM> [...]]
#----------------------------------------------------------------------
# Outputs:
#   The octal value equating to the provided <NUM>(s).
# Returns:
#   0 = SUCCESS
#   1 = (PARTIAL) FAILURE
#       (or no <NUM> provided)
#----------------------------------------------------------------------
dec2oct() {
    local ret num val output output

    [ $# -lt 1 ] && return 1

    ret=0

    while [ $# -gt 0 ]; do #{
        # Ensure param is a number
        isint "${1}" || {
            >&2 echo "WARNING: Not a number: ${1}"
            ret=1
            shift 1
            continue
        }
        num=$((${1} + 0))

        output=""
        mul=1
        val="${num}"

        while [ "${val}" -ge 8 ]; do #{
            output="$((val % 8))${output}"

            val=$((num / (8 ** mul)))
            [ ${val} -lt 8 ] && break

            mul=$((mul + 1))
        done #}

        echo "${val}${output}"

        shift 1
    done #}

    return ${ret}
} # dec2oct()

#function==============================================================
# dec2ascii
#======================================================================
# Converts a set of decimal numbers, into their ASCII counterparts
#----------------------------------------------------------------------
# dec2ascii <dec_num> [<dec_num> [...]]
# echo "<dec_num> [<dec_num> [...]]"|dec2ascii
#----------------------------------------------------------------------
# Outputs:
#   The ASCII string of characters
# Returns:
#   0 = SUCCESS
#   1 = (PARTIAL) FAILURE
#       (or no <dec_num>'s provided)
#----------------------------------------------------------------------
dec2ascii() {
    local ret line

    # local is the default for declare unless -g is used
    declare -a a_line


    ret=0

    [ "${1}" == "--help" ] || [ "${1}" == "-h" ] && {
cat <<EOF
dec2ascii

Converts a set of decimal numbers, into their ASCII counterparts

Usage:  dec2ascii <dec_num> [<dec_num> [...]]"
        echo \"<dec_num> [<dec_num> [...]]\"|dec2ascii

    <dec_num>    - A decimal number (between 0 - 255)
EOF
        return 0
    }

    [ ${#} -eq 0 ] && {
        while read -r line; do #{
            readarray -d ' ' -t a_line < <(echo -n "${line}")
            dec2ascii "${a_line[@]}" || ret=$?
        done #}

        return ${ret}
    }

    printf '%b\n' "$(printf "\\\\x%x" "${@}")"
} # dec2ascii()

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

# Used for JSON byte arrays to base32 encoded hex data and vice-a-versa
# (used by FreeOTP to store it's data)
base32-to-byte-array() {
    base32 -d < <(
        # Explicitly stdin
        [ ${#} -eq 1 ] && [ "${1}" == '-' ] && shift 1

        # Command line supplied
        [ ${#} -gt 0 ] && {
            echo -n "${*}"
            return
        }

        # Implicitly stdin
        cat
    )|od -An -t d1
} # base32-to-byte-array()

# Used for JSON byte arrays to base32 encoded hex data and vice-a-versa
# (used by FreeOTP to store it's data)
byte-array-to-base32() {
    # shellcheck disable=SC2046 # We don't care about word splitting here
    d="$(printf "\\\x%.2x" $({
        # Explicitly stdin
        [ ${#} -eq 1 ] && [ "${1}" == '-' ] && shift 1

        # Command line supplied
        [ ${#} -gt 0 ] && {
            echo -n "${*}"
            return
        }

        # Implicitly stdin
        cat
    })
    )"
    d="${d//xffffffffffffff/x}";
    printf "%b" "${d}" | base32
} # byte-array-to-base32()

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

#function==============================================================
# xclip-file
#======================================================================
# Fills clipboard with file with mimetype for direct pasting into stuffs
#----------------------------------------------------------------------
# xclip-file [--mimetype|-m <MIME_TYPE>] <FILE>
# xclip-file [--mimetype|-m <MIME_TYPE>] [-] < <FILE>
# xclip-file [--mimetype|-m <MIME_TYPE>] [-] < <( COMMAND_THAT_OUTPUTS_FILE )
#
# xclip-img [--mimetype|-m <MIME_TYPE>] <FILE>
# xclip-img [--mimetype|-m <MIME_TYPE>] [-] < <FILE>
# xclip-img [--mimetype|-m <MIME_TYPE>] [-] < <( COMMAND_THAT_OUTPUTS_FILE )
#----------------------------------------------------------------------
# Outputs:
#   NOTHING
# Returns:
#   0 = Success
#   1 = Failure
#       (or no <VAR_NAME> provided)
# Actions:
#   Stores the file contents in the clipboard with the appropriate (or
#   supplied) mimetype.
#----------------------------------------------------------------------
alias xclip-img='xclip-file'
xclip-file() {
    local mimetype infile
    declare -A mimetypes

    infile=''
    mimetype=''

    if [ "$1" == '-m' ] || [ "$1" == '--mimetype' ]; then #{
        # Mimetype

        [ $# -lt 2 ] && {
            >&2 echo "ERROR: No mimetype provided but '$1' specified"
            return 1
        }

        mimetype="$2"
        shift 2

        sed '/^#/d;/^$/d;s#\t.*$##' </etc/mime.types\
        |grep "^${mimetype}$" &>/dev/null || {
            >&2 echo "WARNING: Mimetype unknown: ${mimetype}"
        }
    fi #}

    [ $# -gt 0 ] && {
        [ "$1" != '-' ] && [ ! -e "$1" ] && {
            >&2 echo "ERROR: File does not exist: $1"
            return 1
        }

        [ "$1" != '-' ] && infile="$1"
        shift 1
    }

    [ $# -gt 0 ] && {
        >&2 echo "ERROR: Too many parameters: ${*}"
        return 1
    }

    [ -z "${infile}" ] && {
        # stdin
        infile="$(mktemp --tmpdir "tmp.${FUNCNAME[0]}.$$.XXXXX")" || {
            echo "ERROR: Failed to create temp file"
            return 2
        }

        # Delete temp file when we're done
        trap 'rm "'"${infile}"'"' 0 1 2 15 RETURN

        cat >"${infile}"
    }

    [ -z "${mimetype}" ] && {
        read mimetype < <(\
            file --mime-type --no-pad --print0 --separator '' "${infile}"\
            |cut -d '' -f2\
        )

        [ -z "${mimetype}" ] && >&2 echo "WARNING: Unable to identify mimetype"
    }

    xclip -selection clipboard -t "${mimetype}" <"${infile}"
}

# Youtube-dl fork
#alias yt-dlp='yt-dlp -S width:1920 -f '"'"'bv*+ba*/best'"'"' --output '"'"'%(title)s.%(release_date,upload_date)s.%(id)s.%(ext)s'"'"
#alias yt-dlp='yt-dlp                --format mp4 --output '"'"'%(title)s.%(release_date,upload_date)s.%(id)s.%(ext)s'"'"
alias yt-dlp='yt-dlp                --output '"'"'%(title)s.%(release_date,upload_date)s.%(id)s.%(ext)s'"'"' --format '"'"'bestvideo*[height=768]+bestaudio/bestvideo*[height=720]+ba/bestvideo*[height=1080]+ba/bv+ba/best'"'"
alias yt-dlp-768='yt-dlp'
alias yt-dlp-1080='yt-dlp                                                                                    --format '"'"'bv*[height=1080]+ba/bv*[height=768]+ba/bv*[height=720]+ba/bv+ba/best'"'"
alias yt-dlp-best='yt-dlp                                                                                    --format '"'"'bv+ba/best/bv*[height=1080]+ba/bv*[height=768]+ba/bv*[height=720]+ba'"'"
alias yt-dlp-mp4='yt-dlp                                                                                     --format mp4'
alias yt-dlp-audio-only='yt-dlp                                                                              --format '"'"'best*[vcodec=none]'"'"' -x'
alias yt-dlp-playlist='yt-dlp       --output '"'"'%(playlist_title)s.%(playlist_index)s.%(title)s.%(release_date,upload_date)s.%(id)s.%(ext)s'"'"
alias yt-dlp-playlist-date='yt-dlp  --output '"'"'%(playlist_title)s.%(release_date,upload_date)s.%(title)s.%(playlist_index)s.%(id)s.%(ext)s'"'"
alias yt-dlp-playlist-index='yt-dlp --output '"'"'%(playlist_title)s.%(playlist_index)s.%(title)s.%(id)s.%(ext)s'"'"

yt-dlp-google-link() {
    local vid=''
    local vids=()
    if [ "$#" -gt 0 ]; then #{
        while [ "$#" -gt 0 ]; do #{
            vid="${1/#*google.com*www.youtube.com\/watch\?v=/}"
            vid="${vid/#*google.com*www.youtube.com\/watch%3Fv%3D/}"
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
            vid="${vid/#*google.com*www.youtube.com\/watch%3Fv%3D/}"
            vid="${vid/#*google.com*www.youtube.com%3Fwatch%3Fv%3D/}"
            vids+=("${vid%%&*}")
            >&2 echo "${vids[@]}"
        done #}
    fi #}

    yt-dlp -- "${vids[@]}"
    return $?
}

#=============================================================================}


############################################################
# Misc - Android
############################################################

alias adb-list-open-sockets='adb shell cat /proc/net/unix'
alias adb-list-packages='adb shell pm list packages -f -i -U -u'
alias adb-dump-info-on-all-packages='adb shell dumpsys package packages'
alias adb-dump-info-on-one-package='adb shell dump'
alias adb-path-to-apk='adb shell path'

adb-chrome-list-tabs() {
    local outfile

    outfile="/tmp/adb-chrome-list-tabs.$$.json"

cat <<EOF
Please ensure you have enabled Android USB debugging in Developer options.

The following steps will then be performed:
    1. Launch 'adb', forwarding local TCP port 9222 to the android socket 'chrome_devtools_remote'
    2. Connect to that socket and send a debug command to return all tabs ( '/json/list' )
    3. Store the returned JSON in ${outfile}
    4. Parse the JSON file and output the ID, URL and page title of each tab

Press ENTER once Android USB debugging is enabled.
EOF

    read

    echo \
    adb forward tcp:9222 localabstract:chrome_devtools_remote
    adb forward tcp:9222 localabstract:chrome_devtools_remote

    wget -qO "${outfile}" http://localhost:9222/json/list
    jq -r '.[]|(.id + " " + .url + " " + .title)' <"${outfile}"
}

adb-run-apk() {
    local pkg
    local act

    [ ${#} -ne 1 ] || [ ! -f "${1}" ] && {
        echo "Usage: ${0##*/} <file.apk>"
        exit 1
    }

    pkg=$(aapt dump badging "${1}"|awk -F" " '/package/ {print $2}'|awk -F"'" '/name=/ {print $2}')
    act=$(aapt dump badging "${1}"|awk -F" " '/launchable-activity/ {print $2}'|awk -F"'" '/name=/ {print $2}')
    adb shell am start -n "${pkg}/${act}"
}

