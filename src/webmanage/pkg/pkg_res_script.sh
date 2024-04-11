#!/bin/bash

if [ $# -lt 1 ]; then
  echo "$0 zip_file [scripts]"
  exit -1
fi
zip_file=$1
scripts=$2

#if [ ! -f $zip_file ]; then
  #echo "$zip_file not exist"
  #exit -2
#fi

#base_path=`echo $zip_file|awk -F'/uploads/' '{print $1}'`
base_path='/data/build/pkg_tool'
src_path="/data/build/VER-BUILD-PUBLISH/QQ_HXSJ_1.2Beta06Build01"
hostname=`hostname`
if [ $hostname == "VM_144_153_tlinux" ]; then
  src_path="/data/build/QQ_HXSJ_1.2Beta06Build01"
fi

if [ "$scripts" != "" ]; then
  ascripts=(`echo $scripts | sed 's/,/\n/g'`)
  for x in ${ascripts[@]}; do
    script_mxt_file="$src_path/tool/script_compiler/scripts/${x}.mxt"
    if [ ! -f $script_mxt_file ]; then
      echo "$script_mxt_file not exist"
      exit -3
    fi
  done
fi

pkg_time=`date +%Y%m%d"-"%H%M%S`
pkg_path="$base_path/pkgs/$pkg_time"
mkdir -p $pkg_path
mkdir -p $pkg_path/dwc/resource
mkdir -p $pkg_path/dwc/scripts

if [ -f $zip_file ]; then
  mkdir -p $pkg_path/zip
  cp $zip_file $pkg_path/zip/update.zip
  zip_file="$pkg_path/zip/update.zip"
  cd $pkg_path
  cd dwc/resource
  unzip $zip_file -d .
  for x in `ls .`; do
    if [ -d $x ]; then
      mv $x/* .
      rmdir $x
    fi
  done
fi

if [ "$scripts" != "" ]; then
  cd $pkg_path
  for x in ${ascripts[@]}; do
    echo rm "$src_path/scripts/${x}.mac"
    rm -rf "$src_path/scripts/${x}.mac"
  done
  cd "$src_path/tool/script_compiler/"
  /usr/local/subversion/bin/svn up
  make clean >/dev/null 2>&1 
  make >/dev/null 2>&1
  cd "$src_path/scripts"
  for x in ${ascripts[@]}; do
    script_file="${x}.mac"
    if [ ! -f "$script_file" ]; then
      echo "compile script[$script_file] fail."
      exit -10
    fi

    echo $script_file"  ok"
    cp $script_file $pkg_path/dwc/scripts
  done
fi

cd $pkg_path
echo '<div style="color:red">'
echo "pkg files:------------------------------------------------"
find dwc/
echo "------------------------------------------------"
echo '</div>'
echo '<div style="color:green">'
find dwc/resource/ -type f -exec md5sum {} \;
find dwc/scripts/ -type f -exec md5sum {} \;
echo "------------------------------------------------"
echo '</div>'
pkg_name="QQHXSJ-$pkg_time.tar.gz"

echo "start pkg $pkg_name.........."
tar cvzf $pkg_name dwc > /dev/null 2>&1
ls -lth $pkg_name
echo "pkg $pkg_name ok"

echo "------------------------------------------------"
echo "------------------------------------------------"
md5sum $pkg_name|awk '{print "<div style=\"color:red;font-size:30px\">"$2" "$1"</div>"}'
echo "------------------------------------------------"
echo "------------------------------------------------"
python /data/home/user00/cloudstone/upload_tools.py $pkg_name 1
