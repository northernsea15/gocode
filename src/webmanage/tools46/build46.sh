#!/bin/bash

cd /data/test/for-test/

echo "copy files from 45......"
i=1
while [ $i -lt 10 ]
do
echo "try scp $i:"
expect expbuild46
if [ "$?" != "11" ]
then
    echo "scp done"
    break
fi

i=$[$i+1]
done

cd ./dwc/sbin/
echo "stop server......"
! ./servers_pwd.sh stop;! ./ipcrm.sh

if [[ $1 == "time" ]]
then
  echo "please reset time"
  exit 0
fi

cd /data/test/for-test/

echo "untar files......"
rm -rf dwc
tar xvf dwc.tar.gz >/dev/null 2>&1
./rsync.sh 73 >/dev/null 2>&1

echo "ready to recover cs info"
cp ~/cs_info/servers_pwd.sh ~/for-test/dwc/sbin/
cp -R ~/cs_info/csserver ~/for-test/dwc/conf/
echo "recover cs_info success!"


cd dwc/sbin
echo "start server......"
./servers_pwd.sh start

while true; do
	zonenum=`ps aux|grep fo2zone|awk '{if(NF>15)print $8}'|wc -l`
	if [ $zonenum -lt 3 ]; then
	    echo "zone start failed"
	    break
	fi
	okzonenum=`ps aux|grep fo2zone|awk '{if(NF>15)print $8}'|awk '{if($1=="S")print $1}'|wc -l`
	if [ $okzonenum -ge 3 ]; then
	    echo ""
	    echo "server start OK"
	    break
	fi
	#echo -n "..."
	sleep 1
done
