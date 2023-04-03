#!/bin/bash

readonly RED="$(tput setaf 1)"
readonly GREEN="$(tput setaf 2)"
readonly NORMAL="$(tput sgr0)"

CMD=
CONTAINER=

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

select_cmd()
{
    cmdlist=("podman" "docker")

    if [ -n "$1" ]; then
        CMD=$1
    else
        echo "---------------------------"
        echo "select command"
        echo "---------------------------"
        CMD=`echo ${cmdlist[@]} | tr ' ' '\n' | fzf`
    fi

    if [ -z "${CMD}" ]; then
        fatal "no cmd"
    fi
}

select_container()
{
    select_cmd $1

    echo "---------------------------"
    echo "select ${CMD} container"
    echo "---------------------------"
    CONTAINER=`${CMD} ps -a --format "{{.Names}}" | fzf`

    if [ -z "${CONTAINER}" ]; then
        fatal "no container"
    fi

    echo "container: ${CONTAINER}"
}

function start() ## start the container
{
    select_container $1
    ${CMD} start ${CONTAINER}
}

function stop() ## stop the container
{
    select_container $1
    ${CMD} stop ${CONTAINER}
}

function show()  ## show the current container list
{
    echo "---------------------------"
    echo "docker"
    echo "---------------------------"
    docker ps -a --format "{{.Names}} -> {{.Status}}"

    echo "---------------------------"
    echo "podman"
    echo "---------------------------"
    podman ps -a --format "{{.Names}} -> {{.Status}}"
}

case $1 in
    "start") start ${@:2};;
    "stop") stop ${@:2};;
    "show") show;;
    *) help;;
esac
