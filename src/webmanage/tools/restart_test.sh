#!/bin/bash

function quit {
    echo "__________end_magic_____________";
    exit
}

function echo_info {
    echo "__info_start__"$1"__info_end__"
}

echo_info "------------------------------------开始重启------------------------------------";

BUILD_ROOT="/data/build/QQ_HXSJ_1.2Beta06Build01/webmanager/tools"

cd $BUILD_ROOT

file_lock_name="./data/restart_test.lock";
touch $file_lock_name



hostname="9.134.144.100"

scriptsql=$(cat << END_OF_SCRIPT
        set timeout 5;
        spawn ssh -p36000 root@$hostname;
	set timeout 1000;
        expect "*root@*" { send "/data/test/for-test/restarttest_root.sh\r" };
        expect "OKOKOKOKOK" { send "logout\r" };
        expect eof;
END_OF_SCRIPT
)

expect -c "$scriptsql"

expect_result=$?

rm -f $file_lock_name

if [ "$expect_result" == "11" ]
then
    echo_info "登录46失败，请开发检查";
elif [ "$expect_result" != "0" ]
then
    echo_info "重启失败，请开发检查"
fi

if [ "$expect_result" != "0" ]
then
    quit
fi

quit
