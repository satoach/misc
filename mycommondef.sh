#!/bin/bash

readonly RED="$(tput setaf 1)"
readonly GREEN="$(tput setaf 2)"
readonly NORMAL="$(tput sgr0)"

fatal() {
    echo -e "${RED} $@ ${NORMAL}"
    exit 1
}

function help()  ## print help
{
    eval files=$(grep -E '^(source|\.)\s+([^[:space:]]+)' "$0" |
        awk '{print $2}' |
        sort -u)

    echo -e "${GREEN} HELP $0 ${NORMAL}"
    echo "----------------------------------------"
    grep -E '^function [a-zA-Z_-]+ *\( *\) *## .*$$' $0 "$files" | cut -d " " -f2- | sort |
        awk '
            BEGIN { FS = "\\( *\\) *##" }
            {
              args = ""
              desc = ""
            
              # 説明部分の抜き出し
              n = split($2, parts, /var:[ \t]*[a-zA-Z0-9_]+/)
              desc = parts[1]
            
              # var:x var:y ... をすべてマッチ
              while (match($2, /var:[ \t]*[a-zA-Z0-9_]+/)) {
                arg = substr($2, RSTART+4, RLENGTH-4)
                args = args " " arg
                $2 = substr($2, RSTART+RLENGTH)
              }
            
              printf "%s%s\n\t%s\n", $1, args, desc
            }
        '
}
