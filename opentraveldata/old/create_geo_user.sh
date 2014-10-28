#!/bin/sh
#
# Two parameters are optional:
# - the host server of the database
# - the port of the database
#

if [ "$1" = "--help" -o  "$1" = "-h" ]; then
	echo "Usage: $0 [<Database Server Hostname> [<Database Server Port>]]"
	echo ""
	exit 1
fi

##
# Database Server Hostname
DB_HOST="localhost"
if [ "$1" != "" ];
then
	DB_HOST="$1"
fi

# Database Server Port
DB_PORT="3306"
if [ "$2" != "" ];
then
	DB_PORT="$2"
fi

# Database Name
DB_NAME="mysql"

# Database user
DB_USER="geo"

#
echo "Accessing MySQL database hosted on $DB_HOST:$DB_PORT to create user '${DB_USER}' user account."
echo "To create a user account, username and password of an administrator-like MySQL account"
echo "are required. On most of MySQL databases, the 'root' MySQL account has all"
echo "the administrative rights, but you may want to use a less-privileged MySQL"
echo "administrator account. Type the username of administrator followed by "
echo "[Enter]. To discontinue, type CTRL-C."
read userinput_adminname

echo "Type $userinput_adminname's password followed by [Enter]"
read -s userinput_pw

#
createGeoUser() {
	echo "Creating the geo user within the database:"
	mysql -u ${userinput_adminname} --password=${userinput_pw} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} < ${SQL_FILE}
	mysql -u ${userinput_adminname} --password=${userinput_pw} -P ${DB_PORT} -h ${DB_HOST} -e "flush privileges"
}

# Creating the geo user
SQL_FILE="create_geo_user.sql"
createGeoUser

