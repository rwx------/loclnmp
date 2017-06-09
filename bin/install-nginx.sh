#!/bin/bash

. $(dirname $(readlink -f $0))/config.sh

pkg_name=nginx

# 依赖包的安装
yum install  -y gcc gcc-c++ pcre pcre-devel zlib zlib-devel jemalloc jemalloc-devel perl

## 添加用户
echo "loc-lnmp: 添加用户"
if ! id www &>/dev/null ; then
  groupadd -g 1000 www
  useradd -g 1000 -u 1000 -s /sbin/nologin www
fi

## 编译安装
echo 'loc-lnmp: 编译安装'
cd $locSrc/${pkg_name}-${ngx_version}
./configure  --prefix=/usr/local/nginx --with-http_stub_status_module --with-ld-opt=-ljemalloc --with-http_v2_module --with-openssl=$locSrc/openssl-1.0.2k --with-http_ssl_module >$locLogs/nginx-configure.log
make >$locLogs/nginx-make.log
make install

# 配置
if [ -f $locConf/nginx.conf ]; then
    /bin/cp -f $locConf/nginx.conf  /usr/local/nginx/conf/nginx.conf
fi

# 启动
if [ -f $locConf/nginx.service ];  then
  /bin/cp -f $locConf/nginx.service /lib/systemd/system/nginx.service
fi

systemctl daemon-reload
systemctl start nginx
systemctl enable nginx

## firewalld配置
fwStat=$(firewall-cmd --stat)
if [ "x$fwStat" == "xrunning" ]; then
    firewall-cmd --zone=public --add-port=80/tcp
    firewall-cmd --zone=public --add-port=443/tcp
fi
