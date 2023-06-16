#!/bin/sh

set -e
clipboard="xsel -b"
    
#########
# Usage #
#########

usage="$(basename "$0") [options] <search_term>

Wrapper for bw(bitwarden-cli). Use to search for a login info, and to 
copy credentials to clipboard. Use options to generate passwords.

arguments:
    search_term    A string corresponding to what login info you want to search for

options:
    -g             Generate a password [default 15 characters]; overriden by -l
    -n             Don't use special characters 
    -p             Generate a passphrase [default 3 words]; overriden by -l
    -c             Copy output (from generation) to clipboard
    -l <len>       Override length for password and passphrase with <len>
    -h             Show this help text"


#################
# Parse options #
#################

default_length=3

while getopts ':gnpchl:' OPTION; do
    case "$OPTION" in
        c) 
            copy=1 ;;
        h) 
            echo "$usage"; exit 0 ;;
        g) 
            password=1 ;;
        n) 
            no_special=1 ;;
        p) 
            passphrase=1 ;;
        l) 
            custom_length=$OPTARG ;;
        :) 
            printf "missing argument for -%s\n" "$OPTARG" >&2
            printf "use -h for help" >&2; exit 1 ;;
        \?) 
            printf "illegal option: -%s\n" "$OPTARG" >&2
            printf "use -h for help" >&2; exit 1 ;;

    esac && options=1 # used options -> not searching credentials
done
shift "$((OPTIND - 1))"


##############
# Main Logic #
##############

if [ -z $options ]; then
    # choose the desired login

    [ $# -eq 0 ] && (printf "Search term required!\nuse -h for help"; exit 0)

    logins=$(bw list items --search "$1")
    length=$(echo -n "$logins" | jq length)

    if [ "$length" -eq 1 ]; then
        choice=0
    else
        echo -e "\nMultiple matches:"
        echo "$logins" | jq -r 'to_entries | .[] | '`
            `'(.key | tostring) + ") " + '`
            `'(.value.login.username | tostring)'
        echo -n "Choose only one: "
        read choice

        [ "$choice" -ge 0 ] 2>/dev/null \
            && [ "$choice" -lt $length ] 2>/dev/null \
            || (echo "Invalid input!"; exit 1)
    fi

    login="$(echo -n "$logins" | jq ".[$choice].login")"

    # Copy the username to the clipboard
    echo -n "$login" | jq -r '.username' | $clipboard
    echo 'Username in clipboard'

    # Wait for user input before coping the password
    echo 'Press any key to copy password...' && read -s

    # Copy the password to the clipboard
    echo -n 'Password copied!'
    echo -n "$login" | jq -r '.password' | $clipboard
else
    # generate a password
    if [ -n "$password" ]; then
        opt="-uln"
        [ -z "$no_special" ] && opt="${opt}s"

        [ -z "$custom_length" ] \
            && length=$((default_length * 5)) \
            || length=$custom_length
        generated=$(bw generate $opt --length $length)
    elif [ -n "$passphrase" ]; then
        [ -z "$custom_length" ] \
            && length=$default_length \
            || length=$custom_length
        generated=$(bw generate -p --words "$length" -c --includeNumber)
    fi

    [ -z "$generated" ] && (echo "$usage"; exit 1)

    if [ -n "$copy" ]; then
        echo -n "$generated" | $clipboard
        echo -n "Password copied to your clipboard"
    else
        echo -en "Generated password:\n$generated"
    fi
fi
