#!/bin/sh 
# 启动 Nginx 和 v2fly 并存日志 
nginx -g "daemon off;" &
/usr/local/bin/v2fly -config=/etc/v2fly/config.json  > /var/log/v2fly/v2fly.log  2>&1 &
 
# 监控 Node 应用（若需后台运行 Node 服务）
# node /app/server.js  &
 
wait -n  # 任一进程退出则终止容器
exit $?
