#!/bin/bash

file_lock_name="/data/build/QQ_HXSJ_1.2Beta06Build01/webmanager/tools/data/build.lock"
d=`date`

startnum=`ps aux|grep "build_inner.sh"|awk '{if($11 != "grep")print $0}'|wc -l`
if [ $startnum -gt 0 ]; then
    echo "$d:build already begin,so exit";
    exit 2
fi

if [ ! -f $file_lock_name ];
then
   echo "$d:no build task,so exit";
   exit 1
fi

cd /data/build/webmanager/tools

echo "$d:build start"

./build_inner.sh > data/build.txt &


