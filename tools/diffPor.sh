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
YEAR=`$DATE_TOOL "+%Y"`
TODAY_DATE=`$DATE_TOOL "+%Y%m%d"`
TODAY_DATE_HUMAN=`$DATE_TOOL`

##
# Archive folder
ARCH_DIR="archives/${YEAR}"
if [ ! -d ${ARCH_DIR} ]
then
	mkdir -p ${ARCH_DIR}
fi

##
# Retrieve the latest file
POR_FILE_PFX=por_noiata
SNPSHT_DATE=`ls ${POR_FILE_PFX}_????????.{csv,.csv.bz2} 2> /dev/null`
if [ "${SNPSHT_DATE}" != "" ]
then
	# (Trick to) Extract the latest entry
	for myfile in ${SNPSHT_DATE}; do echo > /dev/null; done
	SNPSHT_DATE=`echo ${myfile} | sed -e "s/${POR_FILE_PFX}_\([0-9]\+\)\.csv.*/\1/" | xargs basename`
else
	echo
	echo "[$0:$LINENO] No Geonames-derived POR list CSV dump can be found."
	echo "Expecting a file named like '${POR_FILE_PFX}_YYYYMMDD.csv'"
	echo
	exit -1
fi
if [ "${SNPSHT_DATE}" != "" ]
then
	SNPSHT_DATE_HUMAN=`$DATE_TOOL -d ${SNPSHT_DATE}`
else
	SNPSHT_DATE_HUMAN=`$DATE_TOOL --date='yesterday'`
fi

#
echo "On the remote host:"
echo "time diff -Naur ${POR_FILE_PFX}_${SNPSHT_DATE}.csv ${POR_FILE_PFX}_${TODAY_DATE}.csv > ${POR_FILE_PFX}_${SNPSHT_DATE}_${TODAY_DATE}.csv"
echo "bzip2 ${POR_FILE_PFX}_${SNPSHT_DATE}_${TODAY_DATE}.csv"
echo
echo "On the local host:"
echo "scp myuser@remote:~/dev/geo/opentraveldata/tools/{por_iata_${TODAY_DATE}.csv.bz2,${POR_FILE_PFX}_${SNPSHT_DATE}_${TODAY_DATE}.csv.bz2} ."
echo "bunzip2 -k por_iata_${TODAY_DATE}.csv.bz2 && mv por_iata_${TODAY_DATE}.csv dump_from_geonames.csv && mv por_iata_${TODAY_DATE}.csv.bz2 ${ARCH_DIR}"
echo "bunzip2 ${POR_FILE_PFX}_${SNPSHT_DATE}_${TODAY_DATE}.csv.bz2"
echo "patch -p0 --dry-run < ${POR_FILE_PFX}_${SNPSHT_DATE}_${TODAY_DATE}.csv"
echo "patch -p0 < ${POR_FILE_PFX}_${SNPSHT_DATE}_${TODAY_DATE}.csv && mv ${POR_FILE_PFX}_${SNPSHT_DATE}.csv ${POR_FILE_PFX}_${TODAY_DATE}.csv && rm -f ${POR_FILE_PFX}_${SNPSHT_DATE}_${TODAY_DATE}.csv"


