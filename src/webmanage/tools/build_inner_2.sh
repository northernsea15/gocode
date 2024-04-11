#!/bin/bash

function quit {
    exit
}

function echo_info {
    echo $1
}

BUILD_ROOT="/data/build/webmanager/tools"
cd $BUILD_ROOT

file_lock_name="/data/build/webmanager/tools/data/build.lock"
rm -f $file_lock_name

echo_info "------------------------------------��ʼ����------------------------------------";

./build_res_2.sh

echo_info "������������......."
while true; do
	zonenum=`ps aux|grep fo2zone|awk '{if(NF>15)print $8}'|wc -l`
	if [ $zonenum -lt 3 ]; then
	    echo_info "zone ����ʧ�ܣ�����ϵ��ũ����"
	    break
	fi
	okzonenum=`ps aux|grep fo2zone|awk '{if(NF>15)print $8}'|awk '{if($1=="S")print $1}'|wc -l`
	if [ $okzonenum -ge 3 ]; then
	    echo_info "����������OK"
	    break
	fi
	echo -n "..."
	sleep 1
done

quit


