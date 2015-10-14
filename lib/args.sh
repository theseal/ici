#!/bin/sh

ICI_DAYS=30
ICI_SERIAL=0
ICI_SUBJECT_DN=""
ICI_ALTNAMES=""
ICI_COPY_EXTENSIONS="none"

if [ $ICI_CMD = "root" ]; then
   ICI_TYPE="root"
else
   ICI_TYPE="server"
fi

{
    while test $# -gt 0; do
	altnamecomma=; if [ -n "$ICI_ALTNAMES" ]; then altnamecomma=,; fi
        case "$1" in
            --serial|-s)
                ICI_SERIAL="$2"
                shift ;;
            --days|-d)
                ICI_DAYS="$2"
                shift ;;
            --subject|--subject_dn|--dn|-n)
                ICI_SUBJECT_DN="$2"
                shift ;;
            --type|-t)
                ICI_TYPE="$2"
                shift ;;
	    --bits)
		ICI_BITS="$2"
		shift ;;
            --dns)
                ICI_ALTNAMES="DNS:$2$altnamecomma$ICI_ALTNAMES"
                shift ;;
            --ip)
                ICI_ALTNAMES="IP:$2$altnamecomma$ICI_ALTNAMES"
                shift ;;
            --email)
                ICI_ALTNAMES="email:$2$altnamecomma$ICI_ALTNAMES"
                shift ;;
            --uri)
                ICI_ALTNAMES="URI:$2$altnamecomma$ICI_ALTNAMES"
                shift ;;
            --copy-extensions)
                ICI_COPY_EXTENSIONS="copy"
                ;;
            -- )
        # Stop option processing
                shift
                break ;;
            -* )
                echo "$self: unknown option $1" 1>&2
                echo "Try 'ici help $ICI_CMD' for more information." 1>&2
                exit 1 ;;
            * )
                break ;;
        esac
        shift
    done
}

export ICI_DAYS ICI_SERIAL ICI_SUBJECT_DN ICI_TYPE ICI_BITS ICI_ALTNAMES ICI_COPY_EXTENSIONS
