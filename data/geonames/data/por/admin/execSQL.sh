#!/bin/sh
#
# One parameter is required:
# - the file-path of the SQL script to execute
#

##
# Database Server Hostname
DB_HOST="localhost"

# Database Server Port
DB_PORT="3306"

# Database User
DB_USER="geo"

# Database Password
DB_PASSWD="geo"

# Database Name
DB_NAME="geo_geonames"

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
	echo
	echo "The '${SQL_FILE}' SQL file can not be read. Please provide a SQL file that can be read."
	echo
	exit -1
fi

####
## Execute the script
##
mysql -u ${DB_USER} --password=${DB_PASSWD} --default-character-set=utf8 -P ${DB_PORT} -h ${DB_HOST} -D ${DB_NAME} < ${SQL_FILE}

