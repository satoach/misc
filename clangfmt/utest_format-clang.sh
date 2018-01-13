#!/bin/bash


if test -t 1; then # if terminal
    ncolors=$(which tput > /dev/null && tput colors) # supports color
    if test -n "$ncolors" && test $ncolors -ge 8; then
        normal="$(tput sgr0)"
        red="$(tput setaf 1)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
    fi
fi

echo_red() { echo -e "${red}$1${normal}"; }
echo_blue() { echo -e "${blue}$1${normal}"; }
echo_utest() { echo -e "${yellow}$1${normal}"; }

function _do_test()
{
    echo_utest "test start: $@"
    bash $@
    result=$?
    echo_utest ""
    echo_utest ""
    echo_utest "test result"
    if [ $result -eq 0 ]; then
        echo_blue "OK"
    else
        echo_red "NG"
        exit 1
    fi
}

shpath=$(dirname $0)
testfile="${shpath}../version.h"

echo_utest "------ help test1 -----"
_do_test "${shpath}/format-clang.sh help"
echo_utest "-----------------------\n"

echo_utest "------ help test2 -----"
_do_test "${shpath}/format-clang.sh -h"
echo_utest "-----------------------\n"

echo_utest "------ run test -----"
_do_test "${shpath}/format-clang.sh run ${testfile}"
git status
git checkout -- ${shpath}/..
echo_utest "-----------------------\n"

echo_utest "------ print test -----"
_do_test "${shpath}/format-clang.sh -p run ${testfile}"
git status
git checkout -- ${shpath}/..
echo_utest "-----------------------\n"

echo_utest "------ interactive test -----"
_do_test "${shpath}/format-clang.sh runinter"
git status
git checkout -- ${shpath}/..
echo_utest "-----------------------\n"

echo_utest "------ dir test -----"
_do_test "${shpath}/format-clang.sh -t d runinter"
git status
git checkout -- ${shpath}/..
echo_utest "-----------------------\n"

echo_utest "------ diff test -----"
echo -e "\n\n" >> ${testfile}
git diff --name-status
_do_test "${shpath}/format-clang.sh diff"
git status
git checkout -- ${shpath}/..
echo_utest "-----------------------\n"
