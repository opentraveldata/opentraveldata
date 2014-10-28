#!/bin/sh
# Parameters required
# - name of user
# - name of database
# - name of table
# - host 
# - port

# if [ "$1" = "" -o "$2" = "" ];
if [ $# != 5 ]
then
	echo "Usage: $0 <Username> <Database name> <table> <Database Host> <Port>"
	echo ""
	exit -1
fi
						
DB_USER="$1"
DB_PASSWD="${DB_USER}"
DB_NAME="$2"
DB_TABLE="$3"
DB_HOST="$4"
DB_PORT="$5"

QUERY_DELETE="delete from ${DB_TABLE}"
QUERY_COUNT="select count(*) from ${DB_TABLE}"

echo "Before:"
mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} -e "${QUERY_COUNT}" ${DB_NAME}

echo "Deleting all the rows from ${DB_NAME}.${DB_TABLE}"
mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} -e "${QUERY_DELETE}" ${DB_NAME}

echo "Result:"
mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} -e "${QUERY_COUNT}" ${DB_NAME}

