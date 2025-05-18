#!/bin/bash

# NOTE: Will need to chmod +w /sys/class/backlight/intel_backlight/brightness

script="$(basename "${0}")"

f_path="/sys/class/backlight/intel_backlight"
f_b_cur="${f_path}/brightness"
f_b_max="${f_path}/max_brightness"

b_max="1000"
[ ! -z "${f_b_max}" ] && [ -r "${f_b_max}" ] && read -r b_max <"${f_b_max}"
b_cur='0'
[ ! -z "${f_b_cur}" ] && [ -r "${f_b_cur}" ] && read -r b_cur <"${f_b_cur}"

b_step="$(((b_max - b_min) / 20))"
[ "${b_step}" -lt 1 ] && b_step=1

b_min="${b_step}"
[ ! -z "${f_b_min}" ] && [ -r "${f_b_min}" ] && read -r b_min <"${f_b_min}"

[ "${1}" == '-q' ] || [ "${1}" == '--query' ] && {
    echo "${b_cur} ( ${b_min} - ${b_max} )"
    exit 0
}

[ "${1}" == '-d' ] || [ "${1}" == '--down' ] && {
    b_new=$((b_cur - b_step))
    [ "${b_new}" -lt "${b_min}" ] && b_new="${b_min}"
    b_cur="${b_new}"
    [ ! -z "${f_b_cur}" ] && tee "${f_b_cur}" <<<"${b_cur}"
    exit $?
}

[ "${1}" == '-u' ] || [ "${1}" == '--up' ] && {
    b_new=$((b_cur + b_step))
    [ "${b_new}" -gt "${b_max}" ] && b_new="${b_max}"
    b_cur="${b_new}"
    [ ! -z "${f_b_cur}" ] && tee "${f_b_cur}" <<<"${b_cur}"
    exit $?
}

[ "${1}" == '-s' ] || [ "${1}" == '--set' ] && {
    b_new="${2}"
    [ "${b_new}" -lt "${b_min}" ] && b_new="${b_min}"
    [ "${b_new}" -gt "${b_max}" ] && b_new="${b_max}"
    b_cur="${b_new}"
    [ ! -z "${f_b_cur}" ] && tee "${f_b_cur}" <<<"${b_cur}"
    exit $?
}

cat <<EOF
${script} -q|--query
${script//[^ ]/ } -d|--down
${script//[^ ]/ } -u|--up
${script//[^ ]/ } -s|--set <value>
EOF
