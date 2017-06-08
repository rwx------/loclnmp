#!/bin/bash

# 目录规范
locDir=$(dirname $(dirname $(readlink -f $0)))
locSrc=$locDir/src
locBuild=$locDir/build
locConf=$locDir/conf
locLogs=$locDir/logs

mkdir -m 777 -p $locDir $locSrc $locBuild $locConf $locLogs

ngx_version=1.12.0
