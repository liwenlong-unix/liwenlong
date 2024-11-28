#!/bin/bash
#
#********************************************************************
#Author:		wangxiaochun
#QQ: 			29308620
#Date: 			2018-12-19
#FileName：		inotify_rsync.sh
#URL: 			http://www.magedu.com
#Description：		The test script
#Copyright (C): 	2018 All rights reserved
#********************************************************************
SRC='/data/'
DEST='rsyncuser@192.168.34.17::backup'
inotifywait -mrq --timefmt '%Y-%m-%d %H:%M' --format '%T %w %f' -e attrib,create,delete,moved_to,close_write ${SRC} |while read DATE TIME DIR FILE;do
FILEPATH=${DIR}${FILE}
rsync -az --delete --password-file=/etc/rsync.pass $SRC $DEST && echo "At ${TIME} on ${DATE}, file $FILEPATH was backuped up via rsync" >> /var/log/changelist.log
done
