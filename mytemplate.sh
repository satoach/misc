#!/bin/bash

readonly red="$(tput setaf 1)"
readonly green="$(tput setaf 2)"
readonly normal="$(tput sgr0)"

fuzzy=
command -v peco > /dev/null && {
    fuzzy=peco
}
command -v fzf > /dev/null && {
    fuzzy=fzf
}

function help() ## print help
{
    echo -e "${green} HELP $0 ${normal}"
    echo "----------------------------------------"
    grep -E '^function [a-zA-Z_-]+ *\( *\) *## .*$$' $0 | cut -d " " -f2- | sort \
        | awk ' \
             BEGIN {FS = "\\( *\\) *##"} \
             {args = ""; breif = ""} \
             match($2, /a:.+b:/) {args = substr($2, RSTART+2, RLENGTH-2-2)} \
             # {printf "\033[33m%s\033[36m%s \033[0m\n\t%s\n",\
             {printf "%s %s\n\t%s\n",\
                        $1, args, substr($2, RSTART+RLENGTH), length($2)-RSTART}'
}

function chat() ## select command by using fuzzy command.
{
    local cmd=$(help | grep -o -E "^[a-z_]+" | tr ":" " " | $fuzzy)
    if [ $cmd ]; then
        echo "$cmd $@"
        $cmd $@
    else
        echo "no cmd"
        help
    fi
}

function main()
{
    case $1 in
        "chat" | \
        "help") $1 ${@:2};;
        * ) help; exit 1;;
    esac
}
main $@
