#!/bin/bash
# courtesy of pc; modified for centos
#	Text dump of all databases

# location of mysql databases
DATADIR=/var/lib/mysql/

# location of backupfiles
BACKUPDIR=/var/mysql/BACKUPS/

# other variables
MYSQLDUMP=/usr/bin/mysqldump
MYSQLADMIN=/usr/bin/mysqladmin
SQLPASS=`cat /mount/data/mysql/mysql/PASSWORD`
date=`/bin/date '+%d%b%Y'`
MYSQLSOCKET=/var/run/mysqld/mysqld.sock

if [ -d $BACKUPDIR ]
then

# log this to a dated file
exec > $BACKUPDIR/$date.LOG 2>&1

# get a list of database directories to dump from
# pray the databases don't have spaces in their names
cd $DATADIR
# SDBS=`find . -maxdepth 1 -type d  | grep './' | sed 's/@002d/-/g'`
SDBS=`find . -maxdepth 1 -type d  | sed 's:^\.\/::'| sed 's/@002d/-/g'`


# testing
#for name in tonyblog
#do
#echo $name
#done

# for real for real
for name in $SDBS
do
	if [ -f $BACKUPDIR/$name.$date.gz ]
	then
		echo "$BACKUPDIR/$name.$date exists, ignoring"
	else		
	$MYSQLDUMP -e --user=root --password=$SQLPASS --socket=$MYSQLSOCKET --max_allowed_packet=512M $name > $BACKUPDIR/$name.$date
		/bin/gzip --best  $BACKUPDIR/$name.$date
	fi
done

# cleanup old dump files
# see regular file system backups for older files
find $BACKUPDIR -type f -name '*.gz' -mtime +2 -exec rm {} \;
find $BACKUPDIR -type f -name '*.LOG' -mtime +2 -exec rm {} \; 

# flush cache files

#echo $MYSQLADMIN -v --user=root --password=$SQLPASS --socket=$MYSQLSOCKET flush-tables

else
		echo "$BACKUPDIR does not exist"
		echo "please look into that"
		exit 1
fi

exit 0
