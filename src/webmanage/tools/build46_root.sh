#!/bin/bash
function echo_info {
    echo "__info_start__"$1"__info_end__"
}

cd /data/test/for-test/
chmod -R 0777 *
chgrp -R devel *

if [ -d "/data/test/for-test/dwc/sbin" ]
then
  echo_info "停止服务器......"
  su - test -c "cd /data/test/for-test/dwc/sbin/; ./servers_pwd.sh stop;./ipcrm.sh"
fi

echo_info "解压缩45的tar包......"
rm -rf /data/test/for-test/dwc
su - test -c "cd /data/test/for-test/; tar xvf dwc.tar.gz >/dev/null 2>&1"
su - test -c "cd /data/test/for-test/; ./rsync.sh 73 >/dev/null 2>&1"

#rm -f /data/test/for-test/dwc.tar.gz

echo_info "启动服务......"
su - test -c "cd /data/test/for-test/dwc/sbin/; ./servers_pwd.sh start >/dev/null 2>&1"

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

echo_info "------------------------------------同步OK------------------------------------";
echo OKOKOKOKOK

