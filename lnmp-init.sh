#!/bin/bash

## 定义环境变量
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
export LANG="en_US.UTF-8"

## 该脚本需要以root用户运行
user=$(whoami)
if [ $user != 'root' ] ; then
    echo "该脚本需要以root用户运行, 当前用户为 $user"
    exit 1;
fi

## 更新系统到最新
echo "LOC-lnmp: 正在更新系统... "
yum -y update

## 安装依赖
echo "LOC-lnmp: 正在安装依赖包... "
yum install -y wget epel-release

## 关闭selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
echo "[7]关闭selinux"

## 修改 ulimit 配置
echo "* soft nofile 65535" >> /etc/security/limits.conf
echo "* hard nofile 65536" >> /etc/security/limits.conf
echo "[8]调整文件描述符数量"

sleep 2

setenforce 0

if [ -e /tmp/loclnmp ] ; then
    rm -rf /tmp/loclnmp
    rm -f /tmp/loclnmp.latest.tar.gz
fi

echo '[9]开始下载:  loclnmp.latest.tar.gz .... '
echo wget -q http://lnmp.liaoyongfu.com/loclnmp.latest.tar.gz
wget http://lnmp.liaoyongfu.com/loclnmp.latest.tar.gz

echo '[10]下载完成，进行解压 ..'
tar -xzf loclnmp.latest.tar.gz -C /tmp/

chmod +x /tmp/loclnmp/bin/*

echo '开始安装nginx ...'
/tmp/loclnmp/bin/install-nginx.sh

echo '开始安装php56 ...'
/tmp/loclnmp/bin/install-php56.sh
