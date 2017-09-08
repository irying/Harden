#!bin/bash

max = 5000;
conf = /user/local/data/nginx/conf/blockip.conf
log = /usr/local/data/nginx/logs/access.log

test -e ${conf} || touch ${conf}
block_ip = ""
for block_ip in $(cat $log | awk '{print $1}' | sort | uniq -c | sort -rn | awk '{if ($1>500) print $2}')
do
    grep -q "${block_ip}" ${conf} && eg = 1 || eg = 0;
    if ((${eg} == 0));then
        echo "deny ${block_ip};">>$conf  #把“deny IP；”语句写入封锁配置文件中
        echo ">>>>> `date '+%Y-%m-%d %H%M%S'` - 发现攻击源地址 ->  ${block_Ip} " >> /usr/local/data/nginx/logs/nginx_deny.log  #记录log
    fi
done
service nginx reload


#!/bin/bash
sed -i 's/^/#&/g' /usr/local/nginx/conf/blocl_ip.conf
service nginx reload
