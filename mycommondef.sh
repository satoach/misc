#!/bin/bash

readonly RED="$(tput setaf 1)"
readonly GREEN="$(tput setaf 2)"
readonly NORMAL="$(tput sgr0)"

fatal()
{
    echo -e "${RED} $@ ${NORMAL}"
    exit 1
}

function help() ## print help
{
    echo -e "${GREEN} HELP $0 ${NORMAL}"
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
