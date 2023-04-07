#!/bin/bash


if [ $# -lt 1 ]; then
    echo "no path"
    exit 1
fi

file=$1

while true
do
    while inotifywait -e modify,attrib,close_write,move,create,delete $file; do
        ls -lh $file
    done
done

