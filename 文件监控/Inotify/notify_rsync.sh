#!/bin/bash
#这是一个用inotify和rsync联合的同步脚本
export PATH=/bin:/usr/bin:/usr/local/bin
SRC=/web_data/
DEST1=web1
DEST2=web2
Client1=192.168.1.191
Client2=192.168.1.193
User=duwenjun
#rsync的用户密码文件
Passfile=/root/rsync.pass
[ ! -e $Passfile ] && exit 2
#监控文件是否改变
/usr/local/inotify/bin/inotifywait -mrq --timefmt '%y-%m-%d %H:%M' --format '%T %w%f %e' \
--event modify,create,move,delete,attrib $SRC|while read line
do
echo "$line" > /var/log/inotify_web 2>&1
/usr/bin/rsync -avz --delete --progress --password-file=$Passfile $SRC \
${User}@$Client1::$DEST1 >> /var/log/sync_web1 2>&1
/usr/bin/rsync -avz --delete --progress --password-file=$Passfile $SRC \
${User}@$Client2::$DEST2 >> /var/log/sync_web2 2>&1
done &
