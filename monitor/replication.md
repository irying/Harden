来自 http://blog.csdn.net/bluishglc/article/details/5744303



1.建立专门用于Replication的账户** 
首先Replication操作会涉及到的两个重要权限，这里先做一下说明：
The REPLICATION CLIENT  privilege enables the use of SHOW MASTER STATUS and SHOW SLAVE STATUS. 
REPLICATION CLIENT 使得用户可以使用SHOW MASTER STATUS和SHOW SLAVE STATUS命令，也就是说这个权限是**用于授予账户监视Replication状况的权力**。
The REPLICATION SLAVE privilege should be granted to accounts that are used by slave servers to connect to the current server as their master. Without this privilege, the slave cannot request updates that have been made to databases on the master server. 
REPLICATION SLAVE则是一个必须而基本的权限，它直接授予slave服务器以该账户连接master后可以执行replicate操作的权利。
一般来说，我们会单独在主服务器创建一个专门用于Replication的账户。这个账户必须具有REPLICATION SLAVE权限，除此之外没有必要添加不必要的权限，保证该用户的职责单一。假定我们要建立的这个账户为repl,密码为repl,那么这一操作的命令如下：
mysql> GRANT REPLICATION SLAVE ON *.* TO 'repl'@'192.168.0.%' IDENTIFIED BY 'repl';
其中要特别说明一下192.168.0.%，这个配置是指明repl用户所在服务器，这里%是通配符，表示192.168.0.0-192.168.0.255的Server都可以以repl用户登陆主服务器。如果没有使用通配符，而访问的服务器又不在上述配制里，那么你将无法使用该账户从你的服务器replicate主服务器.
另外在《Hight Performance MySql》一书中对用户权限的设置有所不同，作者建议在**主机和从机上都配置repl账户，并同时赋予REPLICATION SLAVE和REPLICATION CLIENT权限，命令如下：**
**mysql> GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO repl@'192.168.0.%' IDENTIFIED BY 'repl';**
作者解释了这样做的好处：一方面使用同一账户对Replication进行监视管理会很方便，不必区分slave,master，另一方面，repl账户在slave和master上的配制是一样的，这样如果我们切换slave和master，账户不需要做任何改动。
**2.配置主从服务器**

****
主从服务器的配置都是通过改写my.cnf/my.ini文件来完成的。
下面是主从服务器的必须的配置项：
主机必须的配置项：
log-bin //自定义，比如 log-bin=mysql-bin
server_id //为server起一个唯一的id，默认是1，推荐使用IP的最后一节。
从机必须的配置项：
server_id //为server起一个唯一的id，默认是1，推荐使用IP的最后一节.

注意：一般，我们也会为从机设定log-bin,这是因为默认的log-bin文件是根据主机名命名的，一旦机器更改主机名就会出问题，再者保持主从机的配制一致也方便做主从机切换！

主机可选的配置项：（用于配置主机哪些库会做二进制日志用以Replicate）
binlog-do-db
binlog-ignore-db
从机可选的配置项：（用于配置从机会Replicate哪些库和表）
replicate-do-db, replicate-ignore-db
replicate-do-table, replicate-ignore-table
replicate-wild-do-table
replicate-wild-ignore-table
注意：一条建议是不要在my.cnf/my.ini中配制master_host等选项，而应该使用CHANGE MASTER TO命令来动态设置！

 

对于Master端，我只需简单地设置server_id和log_bin两项即可，对于Slave端其实只需要设置server_id，但是还有一些推荐的设置项。以下是《Hight Performance MySql》一书中给出的Slave端的推荐设置

\# SLAVE-END replication-related configuration.
\# The only required option for slave-end is server_id.
\# The other options are recommanded on P 349 of《Hight Performance MySql》
server_id=234
log_bin=mysql_bin_log
relay_log = mysql_relay_bin_log
log_slave_updates = 1
read_only = 1

 

**3.连接从服务器至主服务器进行Replicate**

****
通过在从服务器上输入CHANGE MASTER TO命令可以使从服务连接到某个主服务器上进行replication.
mysql> CHANGE MASTER TO MASTER_HOST='192.168.0.246',
-> MASTER_USER='repl',
-> MASTER_PASSWORD='repl',
-> MASTER_LOG_FILE='mysql-bin.000001',
-> MASTER_LOG_POS=0;
输入上述命令后即完成了全部配置工作，通过：
start slave;
**启动从服务的replication工作，这样主从服务器就开始同步了。你可以通过：**
**SHOW SLAVE STATUS/G;**
**命令来查看从服务器的状态，如果是Slave_IO_State一项显示：Waiting for master to send event，表示所有工作已经就绪。**