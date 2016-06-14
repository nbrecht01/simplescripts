#!/bin/bash

BACKUPDIR="/backups"
BKLOG="$BACKUPDIR/log.txt"
BKFILE="data.tar.gz"
BACKUP="/"
EXCLUDE=('/sys' '/run' '/proc' '/var/cache' '/mnt' '/tmp' '/backups')

if [ `whoami` != "root" ]; then
	echo "!! This script must be run as root, not `whoami`!"
	exit 1
fi

msg()
{
	touch $BKLOG
	echo $1 >> $BKLOG
	echo $1
}

prompt()
{
	echo -n "$1 ($2): "
}

DAY=`date +%d`
MONTH=`date +%m`
YEAR=`date +%y`

msg "---------------------------------------------------"
msg "Backup of `hostname` on $MONTH/$DAY/$YEAR"
msg "---------------------------------------------------"

if [ ! -d $BACKUPDIR ]; then
	msg "!! Backup dir '$BACKUPDIR' not found! Mount a device on $BACKUPDIR and rerun this script!"
	mkdir $BACKUPDIR
	exit 1
fi

msg ">> Starting backup for $MONTH/$DAY/$YEAR!"

if [ -d $BACKUPDIR/$YEAR/$MONTH/$DAY ]; then
	rm -rf $BACKUPDIR/$YEAR/$MONTH/$DAY
fi

msg ">> Creating backup dir '$BACKUPDIR/$YEAR/$MONTH/$DAY'"
mkdir -p $BACKUPDIR/$YEAR/$MONTH/$DAY

msg ">> Parsing Filesystem..."
for e in "${EXCLUDE[@]}"; do
		msg ">> Excluding file/dir '$e'"

		if [ -e $e ]; then
			EX="`echo -n $EX` --exclude $e"
		else
			msg "## Cannot exclude nonexistent file/dir '$e'"
		fi
done

msg ">> Now backing up files..."
tar -cpPzf $BACKUPDIR/$YEAR/$MONTH/$DAY/$BKFILE $EX $BACKUP

msg ">> Syncing FIlesystems..."
sync; sync

msg ">> Backup Complete!"


TEMP=$(ls -liha $BACKUPDIR/$YEAR/$MONTH/$DAY/$BKFILE)

SIZE=`echo -n $TEMP | awk '{printf $6}'`
PERM=`echo -n $TEMP | awk '{printf $2}'`
NAME=`echo -n $TEMP | awk '{printf $10}'`

msg "----------------------------------------------------"
msg "?? Backup File Name: $NAME"
msg "?? Backup File Permissions: $PERM"
msg "?? Backup File Size: $SIZE"

mv $BKLOG $BACKUPDIR/$YEAR/$MONTH/$DAY

msg "----------------------------------------------------"
