#!/bin/bash

opt_ignore_del=0

get_status()
{
    if [ ${opt_ignore_del} -eq 1 ]; then
        status=$(git status --short | grep -v '^ D ')
    else
        status=$(git status --short)
    fi
}

while getopts "d" opt; do
    case $opt in
        d) opt_ignore_del=1;;
        \?) echo "Usage $0 [-d]"; exit 1;;
    esac
done

get_status
echo "$status" | awk '{print $2}'
