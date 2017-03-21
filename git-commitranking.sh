#!/bin/bash

PrintUsage()
{
    echo "USAGE: $0 [-h] [-r sinceHASH..untilHASH] [-s since] [-u until] path"
}

since=""
until=""
range=""
while getopts "s:u:r:h:" flag; do
    case $flag in
        \?) OPT_ERR=1; break;;
        s) since="--since $OPTARG";;
        u) until="--until $OPTARG";;
        r) range="$OPTARG";;
        h) PrintUsage; exit 1;;
    esac
done

shift $(($OPTIND - 1))
if [ $OPT_ERR ];then
    PrintUsage
    exit 1
fi

git log $range $since $until --pretty=format:"%an" $1 | sort | uniq -c | sort -nr
