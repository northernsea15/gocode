#!/bin/bash
. ~/.bashrc

function quit {
    exit
}

function echo_info {
    echo $1
}

BUILD_SRC_ROOT="/data/build/QQ_HXSJ_1.2Beta06Build01"
SERVER_ROOT="/data/build/dwc"
UPDATE_RES_ROOT="/data/build/data"

cd /data/build/QQ_HXSJ_1.2Beta06Build01/webmanager/tools

cd $BUILD_SRC_ROOT/

echo_info "先更新svn......."
/usr/local/subversion/bin/svn update

script_num=`find $UPDATE_RES_ROOT -name '*.mxt' |wc -l`
res_num=`find $UPDATE_RES_ROOT -name '*.xml' -o -name '*.bin' |wc -l`
npc_num=`find $UPDATE_RES_ROOT -name '*.npc' -o -name '*.flybin' -o -name '*.link' -o -name '*.trigger' -o -name '*.prc' -o -name '*.pth' -o -name '*.rgn' -o -name '*.timer' -o -name '*.pat' -o -name '*.msk' -o -name '*.lst' |wc -l`

echo_info "拷贝要更新的资源脚本等到svn目录......."
if [ $script_num -gt 0 ]; then
	find /data/build/data/ -name '*.mxt'|awk '{system("md5sum "$0)}'|sed 's/\/.*\///'|awk '{print $2"  "$1}'
	find $UPDATE_RES_ROOT -name '*.mxt' -exec mv {} $BUILD_SRC_ROOT/tool/script_compiler/scripts \;
fi

if [ $res_num -gt 0 ]; then
	find $UPDATE_RES_ROOT -name '*.xml' -o -name '*.bin'|awk '{system("md5sum "$0)}'|sed 's/\/.*\///'|awk '{print $2"  "$1}'
	find $UPDATE_RES_ROOT -name '*.xml' -exec mv {} $BUILD_SRC_ROOT/datafile \;
	find $UPDATE_RES_ROOT -name '*.bin' -exec mv {} $BUILD_SRC_ROOT/datafile \;
fi

if [ $npc_num -gt 0 ]; then
	find $UPDATE_RES_ROOT -name '*.npc' -o -name '*.flybin' -o -name '*.link' -o -name '*.trigger' -o -name '*.prc' -o -name '*.pth' -o -name '*.rgn' -o -name '*.timer' -o -name '*.pat' -o -name '*.msk' -o -name '*.lst'|awk '{system("md5sum "$0)}'|sed 's/\/.*\///'|awk '{print $2"  "$1}'
	find $UPDATE_RES_ROOT -name '*.npc' -exec mv {} $BUILD_SRC_ROOT/map \;
	find $UPDATE_RES_ROOT -name '*.flybin' -exec mv {} $BUILD_SRC_ROOT/map \;
	find $UPDATE_RES_ROOT -name '*.link' -exec mv {} $BUILD_SRC_ROOT/map \;
	find $UPDATE_RES_ROOT -name '*.trigger' -exec mv {} $BUILD_SRC_ROOT/map \;
	find $UPDATE_RES_ROOT -name '*.prc' -exec mv {} $BUILD_SRC_ROOT/map \;
	find $UPDATE_RES_ROOT -name '*.pth' -exec mv {} $BUILD_SRC_ROOT/map \;
	find $UPDATE_RES_ROOT -name '*.rgn' -exec mv {} $BUILD_SRC_ROOT/map \;
	find $UPDATE_RES_ROOT -name '*.timer' -exec mv {} $BUILD_SRC_ROOT/map \;
	find $UPDATE_RES_ROOT -name '*.pat' -exec mv {} $BUILD_SRC_ROOT/map \;
	find $UPDATE_RES_ROOT -name '*.msk' -exec mv {} $BUILD_SRC_ROOT/map \;
	find $UPDATE_RES_ROOT -name '*.lst' -exec mv {} $BUILD_SRC_ROOT/map \;
fi

echo_info "提交svn......"
cd $BUILD_SRC_ROOT/
/usr/local/subversion/bin/svn -m "autobuild" commit /data/build/QQ_HXSJ_1.2Beta06Build01/tool/script_compiler/scripts/
/usr/local/subversion/bin/svn -m "autobuild" commit /data/build/QQ_HXSJ_1.2Beta06Build01/datafile/
/usr/local/subversion/bin/svn -m "autobuild" commit /data/build/QQ_HXSJ_1.2Beta06Build01/map/

echo_info "编译脚本......"
cd $BUILD_SRC_ROOT/tool/script_compiler/
./make_script.sh 2>&1 >/dev/null
cd $BUILD_SRC_ROOT

echo_info "拷贝文件到服务器目录......."
cp scripts/* ${SERVER_ROOT}/scripts/
cp datafile/* ${SERVER_ROOT}/resource/
cp map/* ${SERVER_ROOT}/map/

cd ${SERVER_ROOT}/
cd ./sbin

echo_info "重启服务器......."
./servers_pwd.sh stop >/dev/null 2>&1 
./ipcrm.sh
./servers_pwd.sh start >/dev/null 2>&1 

