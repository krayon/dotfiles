# en_KRAYON #

I have a custom locale for date formatting, ISO-8601 and a longer format
that's fairly acceptable:

    % date formats following ISO 8601-1988
    d_t_fmt     "%Y-%m-%dT%T %Z"
    d_fmt       "%Y-%m-%d"
    t_fmt       "%T"
    date_fmt    "%a %d-%b-%Y %H:%M:%S %Z"



-----
## Install System wide ##

1. cp `en_KRAYON.v0.02` `/usr/share/i18n/locales/en_KRAYON`

2. Add to `/etc/locale.gen` and `/usr/share/i18n/SUPPORTED` :

    en_KRAYON ISO-8859-1
    en_KRAYON.UTF-8 UTF-8

3. Run `locale-gen`



-----
## Install local user only ##

* http://lists.freebsd.org/pipermail/freebsd-questions/2015-June/266181.html

1. Set `PATH_LOCALE` :

    export PATH_LOCALE="${HOME}/.locale/"



-----
## Enable `en_KRAYON` `LC_TIME` ##

1. Set `LC_TIME` :

    export LC_TIME='en_KRAYON'



-----
[//]: # ( vim: set ts=4 sw=4 et cindent tw=80 ai si syn=markdown ft=markdown: )
