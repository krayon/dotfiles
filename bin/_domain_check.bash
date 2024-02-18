#!/bin/bash
# vim:set ts=4 sw=4 tw=80 et ai si cindent cino=L0,b1,(1s,U1,m1,j1,J1,)50,*90 cinkeys=0{,0},0),0],\:,!^F,o,O,e,0=break:

# Usage:
#     ln -s ~/bin/_domain_check.bash ~/.ssh/domain_example.com
#
# When domain_example.com is called, if your domain is example.com, the script
# returns 0, otherwise 1. The '-n' option can be specified to invert the return
# values.
#
# NOTE: subdomains will still match so if your domain is blah.lab.example.com,
#       it will still match the domain domain_example.com
#
# Example of using this in your .ssh/config:
# 
#     # Are we connecting to the webserver ( webserver.example.com ) from WITHIN
#     # the example.com network?
#     Match host webserver exec "${HOME}/.ssh/domain_example.com"
#
#         # On the same network, webserver accepts SSH connections on port 22
#         Port 22
#
#     # Are we connecting to the webserver (webserver.example.com ) from OUTSIDE
#     # that network? For example, from our own super secret air gapped location
#     Match host webserver exec "${HOME}/.ssh/domain_example.com -n"
#
#         # The webserver firewall accepts connections from port 1234 from our
#         # super-secret location.
#         Port 1234
#
#         # Here, we're going to allow the webserver to connect to our certserv
#         # machine on port 443 so it may request it's new certificate ... or
#         # whatever. To do this, it connects to it's localhost address on port
#         # 1443.
#         RemoteForward localhost:1443 certserv:443

fqdn="$(hostname -f 2>/dev/null)"

binname="$(basename "${0}")"

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

if [ "${binname}" == 'domain_check'       ] \
|| [ "${binname}" == '_domain_check.bash' ] \
; then #{
    >&2 showhelp "${0}"

    exit 1
fi #}

[ "${binname:0:7}" != "domain_" ] && {
    echo "ERROR: Expected script to be called domain_<DOMAIN_NAME>" >&2
    exit 2
}

expdom="${binname:7}"

retpos=0; retneg=1

[ "${1}" == "-n" ] && retpos=1 && retneg=0

[ "${expdom}" == "${fqdn: -${#expdom}}" ] && {
    exit ${retpos}
} || {
    exit ${retneg}
}
