#!/bin/bash


if [ $# -lt 1 ]; then
    echo "no path"
    exit 1
fi

file=$1

OPT=modify,attrib,close_write,move,create,delete
while true
do
    while inotifywait -e $OPT $file &> /dev/null; do
        echo `date +%H%M%S` `ls -lh $file | cut -d ' ' -f5 -`
    done
done

