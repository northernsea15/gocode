#!/bin/bash
function echo_info {
    echo "__info_start__"$1"__info_end__"
}
cd /data/test/for-test/dwc/sbin/

time_now=`date +'%Y-%m-%d %H:%M:%S'`
echo_info "当前时间 $time_now"
echo_info "停止服务器......"
./servers_pwd.sh stop >/dev/null 2>&1
./ipcrm.sh >/dev/null 2>&1
echo_info "启动服务......"
./servers_pwd.sh start >/dev/null 2>&1

while true; do
	zonenum=`ps aux|grep fo2zone|awk '{if(NF>15)print $8}'|wc -l`
	if [ $zonenum -lt 3 ]; then
	    echo_info "zone 启动失败，请联系开发处理"
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

echo_info "------------------------------------重启OK------------------------------------";
