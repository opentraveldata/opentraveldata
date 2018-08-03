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

#
echo "On the remote host:"
echo "time diff -Naur por_noiata_${YEST_DATE}.csv por_noiata_${TODAY_DATE}.csv > por_noiata_${YEST_DATE}_${TODAY_DATE}.csv"
echo "bzip2 por_noiata_${YEST_DATE}_${TODAY_DATE}.csv"
echo
echo "On the local host:"
echo "scp myuser@remote:~/dev/geo/opentraveldata/tools/{por_iata_${TODAY_DATE}.csv.bz2,por_noiata_${YEST_DATE}_${TODAY_DATE}.csv.bz2} ."
echo "bunzip2 -k por_iata_${TODAY_DATE}.csv.bz2 && mv por_iata_${TODAY_DATE}.csv dump_from_geonames.csv && mv por_iata_${TODAY_DATE}.csv.bz2 archives/2018/"
echo "bunzip2 por_noiata_${YEST_DATE}_${TODAY_DATE}.csv.bz2"
echo "patch -p0 --dry-run < por_noiata_${YEST_DATE}_${TODAY_DATE}.csv"
echo "patch -p0 < por_noiata_${YEST_DATE}_${TODAY_DATE}.csv"


