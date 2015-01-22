#!/bin/bash
# Program: happysync.sh 
# Writed by JA Nache <nache.nache@gmail.com>
# Description: Keep two dirs (local or remote) synced
# Dependences: rsync inotify-tools
# License: Public Domain

#############################
# CONFIG:
# Set events to watch
EVENTS="modify,attrib,close_write,move,move_self,create,delete,delete_self"

# Set extra arguments to rsync, for example, differente ssh port
#RSYNC_EXTRA_ARGS="-e 'ssh -p 2222'"
#############################

#####################
# COREVARS, NO EDIT
SYNCPID="none"
#####################

waittosync(){
	for i in 1 2 3 4 5
	do
		sleep 1s
	done
}

dosync(){
	echo "Wait to sync..."
	waittosync
	echo "syncing..."
	rsync -rlptz --delete --exclude '*.git*' $RSYNC_EXTRA_ARGS $1/ $2/
	if [ "$?" -eq "0" ];then
		echo "DONE"
	else
		echo "Error in sync"
	fi
}

showhelp(){
	echo -e "\n    HappySync v0.1"
	echo    "    Script Writed by J.A. Nache <nache.nache@gmail.com>"
	echo -e "\n      Usage:"
	echo    "               $0 <source dir> <destination dir>"
        echo -e "\n\n"
        exit 1
}

if [ -z $2 ];then
        showhelp
fi

inotifywait -r -m -e $EVENTS $1 | while read THEFILE
do
	echo "Changes detected on $THEFILE"
	ps --pid $SYNCPID >/dev/null 2>&1
	if [ "$?" -eq "1" ];then
		echo "Starting rsync..."
		(dosync $1 $2) &
		SYNCPID=$!
	fi
done
