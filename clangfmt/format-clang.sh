#!/bin/bash


fileout="-i"

bold="$(tput bold)"
underline="$(tput smul)"
normal="$(tput sgr0)"
black="$(tput setaf 0)"
red="$(tput setaf 1)"
green="$(tput setaf 2)"
yellow="$(tput setaf 3)"
blue="$(tput setaf 4)"
white="$(tput setaf 7)"

echo_bold() { echo -e "${bold}$1${normal}"; }
echo_red() { echo -e "${red}$1${normal}"; }

function help() ## print help
{
    echo_bold "USAGE:"
    echo "$0 [-ph] [-t <f|d>] command"
    echo ""
    echo_bold "COMMAND:"
    grep -E '^function [a-zA-Z_-]+ *\( *\) *## .*$$' $0 | cut -d " " -f2- | sort \
        | awk ' \
             BEGIN {FS = "\\( *\\) *##"} \
             {args = ""; breif = ""} \
             match($2, /a:.+b:/) {args = substr($2, RSTART+2, RLENGTH-2-2)} \
             {printf "\033[33m%s\033[36m%s\033[0m\n\t%s\n",\
                       $1, args, substr($2, RSTART+RLENGTH), length($2)-RSTART}'
    echo ""
    echo_bold "OPTION:"
    echo "-p: printonly, not file out"
    echo "-t: set find type 'd'(directly) or 'f'(file)"
    echo "-h: print help"
    echo ""
}

function _is_valid_command()
{
    which $1 > /dev/null 2>&1 || { echo_red "$1 is not installed."; return 127; }
    return 0
}

function _find_target()
{
    local ftype="f"
    test $# -ge 2 && ftype=$2

    local ignorepath=""
    while read line; do
        ignorepath=$(eval echo "$ignorepath -path $line -prune -o")
    done < ${shpath}/.formatignore

    find $1 $ignorepath -type $ftype
}

function _start_format()
{
    clang-format $fileout -style=file $1
}

_start_format_list()
{
    test $# -lt 1 && { echo_red "no path"; exit 1; }

    echo "target file is follows:"
    cat $1

    while read line; do
        _start_format $line
    done < $1

    rm $1
}

function diff()    ## start clang-format with only changed files.
{
    local listfile="./.difflist.tmp"

    gitdiff=$(git status --short 2> /dev/null)
    svndiff=$(svn diff --summarize 2> /dev/null)

    if [ -n "$gitdiff" ]; then
        echo "$gitdiff" | rev | cut -d " " -f1 | rev | grep -E ".+\.[c|h]$" > $listfile
    elif [ -n "$svndiff" ]; then
        # TODO check svn mode.
        echo -e "${yellow}TODO check svn mode.${normal}"
        echo "$svndiff" | grep -E "^[M|A]" | cut -d " " -f2- | grep -E ".+\.[c|h]$" > $listfile
    else
        echo_red "this dir is not git or svn repos."
        exit 1
    fi

    _start_format_list $listfile

    exit 0
}

function run()   ## a: path b: start clang-format.
{
    test $# -lt 1 && { echo_red "no path"; exit 1; }

    echo "path: $1"
    local listfile="./.targetlist.tmp"
    if [ -d $1 ]; then
        _find_target $1 "f" | grep -E ".+\.[c|h]$" > $listfile
    else
        echo $1 > $listfile
    fi

    _start_format_list $listfile

    exit 0
}

function runinter()    ## start clang-format with interactive mode.
{
    _is_valid_command "peco" || exit 1

    local ftype=$1
    test $1 != "d" && ftype="f"

    local targetpath=$(_find_target "${shpath}/../" $ftype | peco)
    test ! -n "$targetpath" && { echo_red "no targetpath"; exit 1; }

    run $targetpath
}

function _main()
{
    _is_valid_command "clang-format" || exit 1

    local findtype="f"
    while getopts "dit:ph" flag; do
        case $flag in
            \?) OPT_ERR=1; break;;
            t) findtype="$OPTARG";;
            p) fileout="";;
            h) help; return 0;;
        esac
    done

    shift $(($OPTIND - 1))
    test $OPT_ERR && { help; exit 1; }

    case $1 in
        "diff" |\
        "run")      $1 ${@:2};;
        "runinter") $1 $findtype;;
        "help")     $1;;
        * ) echo -e "invalid command [$1]\n"; help ;;
    esac
}


shpath=$(dirname $0)
_main $@
