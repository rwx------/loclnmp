#!/bin/bash

# 目录规范
locDir=/opt/locLNMP
locSrc=$locDir/src
locBuild=$locDir/build
locConf=$locDir/conf

pkg_version=1.12.0
pkg_name=nginx

mkdir -m 777 -p $locDir $locSrc $locBuild $locConf

# 依赖包的安装
yum install  -y  gcc gcc-c++ pcre pcre-devel zlib zlib-devel

## 添加用户
echo "LOC-start: 添加用户"
if ! id www &>/dev/null ; then
  groupadd -g 1000 www
  useradd -g 1000 -u 1000 -s /sbin/nologin www
fi

# nginx 下载
cd $locSrc
if [ ! -f ${pkg_name}-${pkg_version}.tar.gz ]; then
    wget http://nginx.org/download/${pkg_name}-${pkg_version}.tar.gz
fi

# 编译安装
if [ -d "$locBuild/${pkg_name}-${pkg_version}" ]; then
    rm -rf "$locBuild/${pkg_name}-${pkg_version}"
fi
tar -xzf ${pkg_name}-${pkg_version}.tar.gz -C $locBuild
cd $locBuild/${pkg_name}-${pkg_version}
./configure  --prefix=/usr/local/nginx
make
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
systemctl stop firewalld
