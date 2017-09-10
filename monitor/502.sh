#!bin/bash

time = $(date -d "-1 min" +%H:%M)
count = $(grep :$time: $log | grep '502' | wc -l)

if [ $count -gt 10 ] && [ $send == 1 ];
then
    echo "$address $time 502 count is $count" > ../log/502.tmp
    /bin/bash ../mail/mail.sh $address $count ../log/502.tmp
fi

echo "$(date -T) 502 $count"
