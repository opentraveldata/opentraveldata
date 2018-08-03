#!/bin/sh

##
# MacOS 'date' vs GNU date
DATE_TOOL=date
if [ -f /usr/bin/sw_vers ]
then
	DATE_TOOL=gdate
fi

##
# Snapshot date
TODAY_DATE=`$DATE_TOOL "+%Y%m%d"`
TODAY_DATE_HUMAN=`$DATE_TOOL`
YEST_DATE=`$DATE_TOOL "+%Y%m%d" --date="yesterday"`

echo "time diff -Naur por_noiata_${YEST_DATE}.csv por_noiata_${TODAY_DATE}.csv > por_noiata_${YEST_DATE}_${TODAY_DATE}.csv" 


