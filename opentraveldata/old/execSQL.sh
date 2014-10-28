#!/bin/sh

####
## Settings
##
MYSQL_CLIENT="mysql"
MYSQL_USER="geo"
MYSQL_PASSWD="geo"
MYSQL_DB="geo_geonames"
MYSQL_ROOT="${MYSQL_CLIENT} --user=${MYSQL_USER} --password=${MYSQL_PASSWD} --default-character-set=utf8 -D ${MYSQL_DB}"

##
# Whether or not the usage should be displayed
if [ "$1" = "-h" -o "$1" = "-H" -o "$1" = "--h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 <SQL file to be executed in MySQL ${MYSQL_DB} database>"
	echo
	echo
	exit 0
fi

SQL_FILE=$1

if [ ! -f ${SQL_FILE} ];
then
	echo "The ${SQL_FILE} SQL file can not be read. Please provide a SQL file that can be read."
	exit -1
fi

####
## Execute the script
##
${MYSQL_ROOT} < ${SQL_FILE}
