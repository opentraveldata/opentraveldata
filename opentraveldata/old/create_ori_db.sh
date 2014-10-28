#!/bin/sh
#
# Three parameters are optional:
# - the name of the MySQL database
# - the host server of the database
# - the port of the database
#

if [ "$1" = "--help" -o  "$1" = "-h" ]; then
	echo "Usage: $0 [<Name of Database> [<Host> [<Port>]]]"
	echo ""
	exit -1
fi

##
# Database Name
DB_NAME="geo_ori"
if [ "$1" != "" ]; then
	DB_NAME=$1
fi

# Database Server Hostname
DB_HOST="localhost"
if [ "$2" != "" ];
then
	DB_HOST="$2"
fi

# Database Server Port
DB_PORT="3306"
if [ "$3" != "" ];
then
	DB_PORT="$3"
fi

#
echo "Accessing MySQL database hosted on $DB_HOST:$DB_PORT to create database '${DB_NAME}'."
echo "If the '${DB_NAME}' database already exists on $DB_HOST:$DB_PORT, it will be first deleted (dropped)."
echo "To create a database, username and password of an administrator-like MySQL account are required."
echo "On most of MySQL databases, the 'root' MySQL account has all the administrative rights,"
echo "but you may want to use a less-privileged MySQL administrator account."
echo "Type the username of administrator followed by "
echo "[Enter]. To discontinue, type CTRL-C."
read userinput_adminname

echo "Type $userinput_adminname's password followed by [Enter]"
read -s userinput_pw

#
SQL_STATEMENT="drop database if exists ${DB_NAME}; create database ${DB_NAME} default character set utf8 collate utf8_unicode_ci"

#
echo "The database '${DB_NAME}' will be created:"
mysql -u ${userinput_adminname} --password=${userinput_pw} -P ${DB_PORT} -h ${DB_HOST} mysql -e "${SQL_STATEMENT}"
