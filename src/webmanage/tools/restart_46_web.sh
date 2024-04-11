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

file_lock_name="data/restart_46.lock";
if [ -f $file_lock_name ];
then
   echo_info "build already begun."
   exit 1
fi

touch $file_lock_name

sh ./restart_46.sh > data/restart_test.txt &


exit 100
