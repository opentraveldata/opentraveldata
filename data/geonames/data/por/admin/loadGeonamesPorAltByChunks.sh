#!/bin/sh

# With one Shell:
MY_FIFO=/tmp/my-fifo-alternateNames.txt
DATA_FILE=../../por/data/alternateNames.txt
# ./mk-fifo-split ${DATA_FILE} --fifo ${MY_FIFO} --lines 100000

#
# Two parameters are required for this script:
# - the administrator username
# - the administrator password
#
# Two parameters are optional:
# - the host server of the database
# - the port of the database
#

if [ "$1" = "" -o "$2" = "" -o "$1" = "-h" -o "$1" = "--help" ];
then
	echo "Usage: $0 <Admin Username> <Admin password> [<Database Server Hostname> [<Database Server Port>]]"
	echo "In another Shell, type:"
	echo "MY_FIFO=${MY_FIFO}"
	echo "DATA_FILE=${DATA_FILE}"
	echo "./mk-fifo-split \${DATA_FILE} --fifo \${MY_FIFO} --lines 100000"
	exit 1
fi

##
# Database Server Hostname
DB_HOST="localhost"
if [ "$3" != "" ];
then
        DB_HOST="$3"
fi

# Database Server Port
DB_PORT="3306"
if [ "$4" != "" ];
then
        DB_PORT="$4"
fi

# Database User
DB_USER="$1"

# Database Password
DB_PASSWD="$2"

# Database Name
DB_NAME="geo_geonames"

#
SQL_QUERY="set foreign_key_checks=0; set sql_log_bin=0; set unique_checks=0; LOAD DATA LOCAL INFILE '${MY_FIFO}' INTO TABLE alternate_name CHARACTER SET UTF8 (alternatenameid, geonameid, isoLanguage, alternateName, isPreferredName, isShortName, isColloquial, isHistoric)"

# With another Shell:
while [ -e ${MY_FIFO} ]
do
  time mysql -u ${DB_USER} --password=${DB_PASSWD} ${DB_NAME} -e "${SQL_QUERY};"
	sleep 1;
done

