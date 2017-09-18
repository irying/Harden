#!bin/sh
Resettem=${tput sgr0}
Nginxserver='http://10.156.11.173/nginx_status'

Check_Nginx_Server(){
    Status_code=$(curl -m 5 -s -w %{http_code} ${Nginxserver} -o /dev/null)
    if[ $Status_code -eq 000 -o $Status_code -ge 500 ];then
        echo -e '\E[32m' "check http server error! Response status
        code is' $Status_code
    else
        Http_content=$(curl -s ${Nginxserver})
        echo -e '\E[ 32m' "check http server ok! \n"
        $Resettem $Http_content
    fi
}

Check_Nginx_Server	


Check_Mysql_Server()
{
    nc -z -w2 ${MysqlServer} 3306
    if [ $? eq 0 ];then
    mysql -u${Mysql_User} -p${Mysql_Pass} -h${Mysql_Slave_Server} -e "show slave status|G"|grep "Slave_IO_Running"|awk '{if($2 !="Yes"){print "Slave thread not running!";exit 1}}'
    if [$? -eq 0];then
    mysql -u${Mysql_User} -p${Mysql_Pass} -h${Mysql_Slave_Server} -e "show slave status\G"|grep"Seconds_Behind_Master"
    fi
    else
    echo "Connect Mysql Slave Server not succeeded"
    else
    echo "connected ${MysqlServer} is Ok!"
    fi
}

Check_Mysql_Server
