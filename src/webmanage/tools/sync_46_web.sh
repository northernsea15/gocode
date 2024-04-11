#!/bin/bash
function quit {
    echo "__________end_magic_____________";
    exit
}
function echo_info {
    echo "__info_start__"$1"__info_end__"
}
BUILD_ROOT="/data/build/webmanager/tools"
cd $BUILD_ROOT
mkdir -p data

startnum=`ps aux|grep "sync_46.sh"|awk '{if($11 != "grep")print $0}'|wc -l`
if [ $startnum -gt 0 ]; then
    echo "$d:sync already begin,so exit";
    exit 2
fi

./sync_46.sh > data/sync_test.txt &

exit 100
