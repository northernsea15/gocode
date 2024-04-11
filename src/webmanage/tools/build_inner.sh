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

file_lock_name="/data/build/webmanager/tools/data/build.lock"
rm -f $file_lock_name

echo_info "------------------------------------开始构建------------------------------------";

./build_res.sh

echo_info "服务器启动中......."
while true; do
	zonenum=`ps aux|grep fo2zone|awk '{if(NF>15)print $8}'|wc -l`
	if [ $zonenum -lt 3 ]; then
	    echo_info "zone 启动失败，请联系码农处理"
	    break
	fi
	okzonenum=`ps aux|grep fo2zone|awk '{if(NF>15)print $8}'|awk '{if($1=="S")print $1}'|wc -l`
	if [ $okzonenum -ge 3 ]; then
	    echo_info "服务器启动OK"
	    break
	fi
	echo -n "..."
	sleep 1
done

quit


