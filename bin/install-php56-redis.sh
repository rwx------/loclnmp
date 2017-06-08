#!/bin/bash

. /opt/locLNMP/config.sh

Prefix="/usr/local/php56"
pkg_name=redis
pkg_version=3.1.2

php_name=php56

## 安装依赖
yum install -y autoconf

if [ ! -f "${Prefix}/bin/phpize" ]; then
    echo "There is no phpize .."
    exit 3
fi

cd $locSrc
if [ ! -f "${locSrc}/${pkg_name}-${pkg_version}.tgz" ]; then
    echo "正在下载 php-redis ...."
    wget http://pecl.php.net/get/${pkg_name}-${pkg_version}.tgz
fi
# 编译安装
if [ -d "$locBuild/${pkg_name}-${pkg_version}" ]; then
    rm -rf "$locBuild/${pkg_name}-${pkg_version}"
fi

echo "正在编译安装 php-redis ...."
tar -xzf ${pkg_name}-${pkg_version}.tgz -C $locBuild
cd $locBuild/${pkg_name}-${pkg_version}
${Prefix}/bin/phpize
./configure --with-php-config=/usr/local/$php_name/bin/php-config --enable-redis   >${locLogs}/$php_name-redis-configure.log  2>${locLogs}/$php_name-redis-configure.err
make >${locLogs}/$php_name-redis-make.log  2>${locLogs}/$php_name-redis-make.err
make install >${locLogs}/$php_name-redis-install.log  2>${locLogs}/$php_name-redis-install.err

# 配置
if [ -f $locConf/$php_name-redis.ini ]; then
    /bin/cp -f $locConf/$php_name-redis.ini  ${Prefix}/etc/ini.d/php-redis.ini
fi
