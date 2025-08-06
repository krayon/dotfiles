#!/bin/bash

# Example for ~/.config/sxiv/exec/image-info
# Called by sxiv(1) whenever an image gets loaded,
# with the name of the image file as its first argument.
# The output is displayed in sxiv's status bar.

s=" | " # field separator

filename="$(basename "${1}")"
filesize="$(du -Hh "${1}"|cut -f1)"

# The '[0]' stands for the first frame of a multi-frame file, e.g. gif.
geometry="$(identify -format '%wx%h' "$1[0]")"

# exiv2 returns something like:
#     Iptc.Envelope.CharacterSet        String    3  G
#     Iptc.Application2.RecordVersion   Short     1  2
#     Iptc.Application2.Byline          String   10  1327021159
#     Iptc.Application2.Keywords        String    4  iron
#     Iptc.Application2.Keywords        String   14  strawberry jam
#     Iptc.Application2.Keywords        String   13  raspberry jam
#
# We want to extract the keywords and display them, comma seperated, thus in
# awk:
#     '
# = Start of awkyness {
#      $1~"Keywords"
# = RegEx(~) ( I think it's regex :S ) match the first field with the word
#   "Keywords"
#                   {
# = Start of script {
#                     sub(".*"$4,$4);
# = Sub(stitute?) everything up to $4 with $4
#                                     printf("%s,", $0);
# = Print parameter followed by comma, without a CR
#                                                        }
# = End   of script }
#                                                         '
# = End   of awkyness }
tags="$(\
    exiv2 -q -pi print "${1}"\
    |awk '$1~"Keywords" { sub(".*"$4,$4); printf("%s,", $0); }'\
)"
tags="${tags%,}"

echo "${filesize}${s}${geometry}${tags:+$s}${tags}${s}${filename}"

# vim:ts=4:tw=80:sw=4:et:ai:si
