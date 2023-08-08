#!/bin/bash

source mycommondef.sh

CMD=
CONTAINER=

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

function restart() ## restart the container
{
    select_container $1
    ${CMD} stop ${CONTAINER}
    ${CMD} stop ${CONTAINER}
    ${CMD} start ${CONTAINER}
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
    "restart") restart ${@:2};;
    "show") show;;
    *) help;;
esac
