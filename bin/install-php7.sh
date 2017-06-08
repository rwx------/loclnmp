#!/bin/bash

. /opt/locLNMP/config.sh

Prefix="/usr/local/php56"
pkg_name=php
pkg_version=5.6.30

## 添加用户
echo "LOC-start: 添加用户"
if ! id www &>/dev/null ; then
  groupadd -g 1000 www
  useradd -g 1000 -u 1000 -s /sbin/nologin www
fi

## 安装依赖
yum -y install libxml2.x86_64 libxml2-devel.x86_64 openssl-devel libcurl-devel freetype.x86_64 freetype-devel.x86_64 libpng-devel  libjpeg-devel libmcrypt-devel bison bison-devel libicu-devel libicu

## 安装re2c 词法解释器

echo "正在编译安装re2c ...."
cd $locSrc/re2c-0.16
./configure >${locLogs}-re2c-configure.log  2>${locLogs}-re2c-configure.err
make >${locLogs}-re2c-make.log  2>${locLogs}-re2c-make.err
make install >${locLogs}-re2c-install.log  2>${locLogs}-re2c-install.err

cd $locSrc/${pkg_name}-${pkg_version}

### 编译配置
./configure --prefix=${Prefix}  \
--with-config-file-path=${Prefix}/etc \
--with-config-file-scan-dir=${Prefix}/etc/ini.d \
--enable-fpm  \
--with-mysqli  --with-pdo-mysql \
--with-iconv-dir \
--with-freetype-dir=/usr/ \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--with-libxml-dir=/usr \
--with-pcre-regex \
--enable-exif \
--enable-bcmath \
--with-curl \
--enable-mbstring \
--with-mcrypt \
--with-gd \
--enable-gd-native-ttf \
--with-openssl \
--with-mhash \
--enable-sockets \
--enable-zip \
--enable-soap \
--with-gettext \
--enable-opcache \
--enable-intl  >${locLogs}-${pkg_name}-${pkg_version}-configure.log  2>${locLogs}-${pkg_name}-${pkg_version}-configure.err

make -j 2 >${locLogs}-${pkg_name}-${pkg_version}-make.log  2>${locLogs}-${pkg_name}-${pkg_version}-make.err
make install >${locLogs}-${pkg_name}-${pkg_version}-install.log  2>${locLogs}-${pkg_name}-${pkg_version}-install.err

# 配置
mkdir -m 777 -p /data/logs/php
mkdir -p ${Prefix}/etc/ini.d
chown www.www -R ${Prefix}

# 配置
if [ -f $locConf/php-fpm.conf ]; then
    /bin/cp -f $locConf/php56-fpm.conf  ${Prefix}/etc/php-fpm.conf
    /bin/cp -f $locConf/www.conf  ${Prefix}/etc/php-fpm.d/www.conf
fi

# 配置
if [ -f $locConf/php.ini ]; then
    /bin/cp -f $locConf/php.ini  ${Prefix}/etc/php.ini
fi

# 启动systemd
# 启动
if [ -f $locConf/php56-fpm.service ];  then
  /bin/cp -f $locConf/php56-fpm.service /etc/systemd/system/php56-fpm.service
fi

systemctl enable php56-fpm
systemctl start php56-fpm

# 模块的编译（redis模块）
