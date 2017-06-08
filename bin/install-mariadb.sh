#!/bin/bash

. $(dirname $(readlink -f $0))/config.sh

#yum -y install MariaDB-server MariaDB-shared MariaDB-client MariaDB-common galera
yum install -y http://lnmp.liaoyongfu.com/MariaDB-10.1.24-centos73-x86_64-client.rpm http://lnmp.liaoyongfu.com/MariaDB-10.1.24-centos73-x86_64-common.rpm http://lnmp.liaoyongfu.com/MariaDB-10.1.24-centos73-x86_64-compat.rpm http://lnmp.liaoyongfu.com/MariaDB-10.1.24-centos73-x86_64-devel.rpm http://lnmp.liaoyongfu.com/MariaDB-10.1.24-centos73-x86_64-server.rpm http://lnmp.liaoyongfu.com/MariaDB-10.1.24-centos73-x86_64-shared.rpm  http://lnmp.liaoyongfu.com/galera-25.3.20-1.rhel7.el7.centos.x86_64.rpm

# xtrabackup
yum -y install libev perl-DBD-MySQL percona-xtrabackup redhat-lsb-core

Mem1=$(free -g |grep Mem |awk '{print $2}')
MyConf=$locConf/my.cnf-2G
if [ $Mem1 -ge 7 ] && [ $Mem1 -lt 16 ]; then
    MyConf=$locConf/my.cnf-6G
elif [ $Mem1 -ge 16 ]; then
    MyConf=$locConf/my.cnf-12G
fi
/usr/bin/cp -f $MyConf /etc/my.cnf

mkdir -m 777 -p /data/logs/mysql
mkdir -m 777 -p /data/mydata
mysql_install_db --defaults-file=/etc/my.cnf --user=mysql

# 启动
systemctl start mariadb.service

if [ ! -e /var/lib/mysql/mysql.sock ]; then
    ln -s /data/mydata/mysql.sock /var/lib/mysql/mysql.sock
fi

# 修改默认密码
V_PASS='loc-password'
/usr/bin/mysql -u root  -e "delete from mysql.user where user=''" &>/dev/null
/usr/bin/mysqladmin -u root password "$V_PASS"  &>/dev/null
/usr/bin/mysqladmin -u root -h 127.0.0.1 password "$V_PASS" &>/dev/null
/usr/bin/mysql -u root -p$V_PASS -e "delete from mysql.user where password=''" &>/dev/null
