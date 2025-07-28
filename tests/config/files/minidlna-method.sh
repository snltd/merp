#!/bin/ksh

# MiniDLNA SMF method

DB_FILE=/var/opt/ooce/minidlna/cache/files.db
PID_FILE=/var/opt/ooce/minidlna/minidlna.pid
MINIDLNAD=/opt/ooce/minidlna/sbin/minidlnad
CONF_FILE=/etc/opt/ooce/minidlna/minidlna.conf

if test -s $DB_FILE && test -z $(find /storage -type f -a -newer $DB_FILE)
then
	echo "no rebuild required"

	if test -s $PID_FILE && $(ps -p $(cat $PID_FILE) >/dev/null)
	then
		echo "doing nothing"
		exit 0
	else
		rm -f $PID_FILE
		echo "starting minidlna"
		$MINIDLNAD -f $CONF_FILE -P $PID_FILE
	fi
else
	echo "rebuild required"

	if test -s $PID_FILE && $(ps -p $(cat $PID_FILE) >/dev/null)
	then
		echo "stopping current instance"
		kill $(cat $PID_FILE)
		rm -f $PID_FILE
	fi

	$MINIDLNAD -R -f $CONF_FILE -P $PID_FILE
fi
