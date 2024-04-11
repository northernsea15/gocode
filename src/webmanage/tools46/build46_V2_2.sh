#!/bin/bash
function echo_info {
    echo  $1 
}

cd /data/test/for-test/

chmod -R 0777 *

if [ -d "./dwc/sbin" ]
then
  cd ./dwc/sbin/
  echo_info "ֹͣ������......"
  ./servers_pwd.sh stop;./ipcrm.sh
  cd ../../
fi
echo_info "��ѹ��45��tar��......"
rm -rf dwc
tar xvf dwc.tar.gz >/dev/null 2>&1
rm -f dwc.tar.gz

./rsync.sh 73 >/dev/null 2>&1
cd dwc/sbin
echo_info "��������......"
./servers_pwd.sh start >/dev/null 2>&1

while true; do
	zonenum=`ps aux|grep fo2zone|awk '{if(NF>15)print $8}'|wc -l`
	if [ $zonenum -lt 3 ]; then
	    echo_info "zone ����ʧ�ܣ�����ϵ��������"
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

echo_info "------------------------------------ͬ��OK------------------------------------";
