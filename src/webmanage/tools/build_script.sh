#!/bin/bash
. ~/.bashrc

function quit {
    echo "__________end_magic_____________";
    exit
}

function echo_info {
    echo "__info_start__"$1"__info_end__"
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

echo_info "提交svn......"
cd $BUILD_SRC_ROOT/
/usr/local/subversion/bin/svn -m "autobuild" commit /data/build/QQ_HXSJ_1.2Beta06Build01/tool/script_compiler/scripts/

echo_info "编译脚本......"
cd $BUILD_SRC_ROOT/tool/script_compiler/
#./make_script.sh 2>&1 >/dev/null
./make_script.sh
cd $BUILD_SRC_ROOT

echo_info "拷贝文件到服务器目录......."
cp scripts/* ${SERVER_ROOT}/scripts/
cd ${SERVER_ROOT}
cd ../

cd ${SERVER_ROOT}/
cd ./sbin

./servers_pwd.sh stop >/dev/null 2>&1
./ipcrm.sh
./servers_pwd.sh start >/dev/null 2>&1


echo_info "构建脚本完成......."

quit
