#!bin/bash

#提取操作系统信息（内核、版本、网络地址等）
#分析系统的运行状态（cpu负载、内存及磁盘使用率等 df -h; top -n 1 -b）
#Cache和Buffer的作用：因为操作系统的CPU对于主存之间的读取信息它们的时钟频率存在的很大的差别，此时需要内存开辟一个缓存区，这样才能够实时打开我们需要的目录和文件。
#Cache和Buffer的区别：功能上来说，Cache主要用于缓存打开过的文件，Buffer主要缓存目录项和inode节点（文件的索引头）。

#读取策略上来说，Cache采用最少使用原则（LRU），即很少使用的文件就会优先淘汰
#如果操作系统Cache内存占有量比较大的时，说明当前操作系统对于文件的读取十分频繁并缓存的比较高。
#Buffer采用先进先出的原则（FIFO），如果Buffer占有量比较大，说明当前操作系统的inode节点数量比较高。

clear
reset_terminal = $(tput sgr0)

os = $(uname -v)
echo -e "\033[32m OS: " $reset_terminal $os

external_ip = $(curl -s http://ipecho.net/plain)
echo -e "\033[32m external_ip: " $reset_terminal $external_ip

nameservers = $(cat /etc/resolv.conf | grep -E "nameserver" | awk 'print $NF')
echo -e "\033[32m nameservers: " $reset_terminal $nameservers

ping -c 2 baidu.com &>/dev/null && echo "Internet Connected" || echo "Internet Disconnected"

system_mem_usages = $(awk '/MemTotal/{total = $2}/MenFree/{free = $2}END{print (total-free)/1024}' /proc/meminfo)
echo -e "\033[32m nameservers: " $reset_terminal $system_mem_usages
