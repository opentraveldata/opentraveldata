#!/bin/sh
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
	echo ""
	exit -1
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

# Export Tool
EXPORTER=mysqldump

# Dump file
DUMP_FILE="geo_geonames.sql"

#
${EXPORTER} -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} \
	--no-data ${DB_NAME} > ${DUMP_FILE}
