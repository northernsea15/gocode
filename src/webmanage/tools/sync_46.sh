#!/bin/bash

function quit {
    echo "__________end_magic_____________";
    exit
}

function echo_info {
    echo "__info_start__"$1"__info_end__"
}

echo_info "------------------------------------开始同步------------------------------------";

BUILD_ROOT="/data/build/QQ_HXSJ_1.2Beta06Build01/webmanager/tools"

cd $BUILD_ROOT

hostname="10.12.234.46"
username="test"
password="test123"

######同步文件到46
echo_info "打tar包供同步46使用......."
cd /data/build/
tar -czvf dwc.tar.gz --exclude=dwc/sbin/log --exclude=dwc/bin/log dwc 2>&1 >/dev/null
scriptsql=$(cat << END_OF_SCRIPT
        set timeout 5;
	spawn scp /data/build/dwc.tar.gz test@10.12.234.46:/data/test/for-test/;
	expect {
		"*assword:" { send "test123\r"}
		timeout     { exit 11 }
	}
	expect {
	       "$" { send "exit\r" }
	}
END_OF_SCRIPT
)
expect -c "$scriptsql"
expect_result=$?

if [ "$expect_result" == "11" ]
then
    echo_info "登录46失败，请开发检查";
elif [ "$expect_result" != "0" ]
then
    echo_info "同步文件失败，请开发检查"
fi

scriptsql=$(cat << END_OF_SCRIPT
        set timeout 5;
        spawn ssh -l $username $hostname -p36000;
        expect {
		timeout { exit 11 }; 
		"*assword:*" { send "${password}\r" } 
		"yes/no" { 
			send "yes\r" ; expect "*assword:*" { send "${password}\r" } 
		}
	};
	set timeout 1000;
        expect "*test@*" { send "/data/test/for-test/build46_V2.sh\r" };
        expect "*test@*" { send "logout\r" };
        expect eof;
END_OF_SCRIPT
)

expect -c "$scriptsql"

expect_result=$?

if [ "$expect_result" == "11" ]
then
    echo_info "登录46失败，请开发检查";
elif [ "$expect_result" != "0" ]
then
    echo_info "启动构建脚本失败，请开发检查"
fi

if [ "$expect_result" != "0" ]
then
    quit
fi

quit