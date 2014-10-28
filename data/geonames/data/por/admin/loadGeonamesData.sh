#!/bin/sh
#
# Two parameters are optional:
# - the host server of the database
# - the port of the database
#

if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo "Usage: $0 [<Database Server Hostname> [<Database Server Port>]]"
	echo ""
	exit -1
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

# Database User
DB_USER="geo"

# Database Password
DB_PASSWD="geo"

# Database Name
DB_NAME="geo_geonames"


##
# Alter a few input data files

# Split the administrative 1 code in two parts, the country and the code
ADMIN1_CODE_FILE=../../por/data/admin1CodesASCII.txt
SHOULD_BE_SPLIT=`head ${ADMIN1_CODE_FILE} | grep "^\([A-Z][A-Z]\)\." > /dev/null 2>&1 && echo "YES"`
if [ "${SHOULD_BE_SPLIT}" = "YES" ]
then
	echo "Split the administrative 1 codes within ${ADMIN1_CODE_FILE}..."
	sed -i -e "s/^\([A-Z][A-Z]\)\.*/\1\t/g" ${ADMIN1_CODE_FILE}
	echo "... Done"
fi

# Split the administrative 2 code in three parts, the country, the admin1 and
# admin2 codes
ADMIN2_CODE_FILE=../../por/data/admin2Codes.txt
SHOULD_BE_SPLIT=`head ${ADMIN2_CODE_FILE} | grep "^\([A-Z]\+\)\.\([A-Z0-9]*\)\.\([a-zA-Z0-9]\+\)" > /dev/null 2>&1 && echo "YES"`
if [ "${SHOULD_BE_SPLIT}" = "YES" ]
then
	echo "Split the administrative 2 codes within ${ADMIN2_CODE_FILE}..."
	sed -i -e "s/^\([A-Z]\+\)\.\([^.]*\)\.\(.*\).*$/\1\t\2\t\3\t/g" ${ADMIN2_CODE_FILE}
	echo "... Done"
fi

# Split the feature code in two parts, the class and the code
FEATURE_CODE_FILE=../../por/data/featureCodes_en.txt
SHOULD_BE_SPLIT=`head ${FEATURE_CODE_FILE} | grep "^\([A-Z]\)\." > /dev/null 2>&1 && echo "YES"`
if [ "${SHOULD_BE_SPLIT}" = "YES" ]
then
	echo "Split the feature class and code within ${FEATURE_CODE_FILE}..."
	sed -i -e "s/^\([A-Z]\)\.*/\1\t/g" ${FEATURE_CODE_FILE}
	echo "... Done"
fi

# Remove the header/comments
COUNTRY_INFO_FILE=../../por/data/countryInfo.txt
TMP_FILE=countryInfo.tmp.txt
SHOULD_REMOVE_COMMENTS=`head ${COUNTRY_INFO_FILE} | grep "^#" > /dev/null 2>&1 && echo "YES"`
if [ "${SHOULD_REMOVE_COMMENTS}" = "YES" ]
then
	echo "Remove the comments/header from ${COUNTRY_INFO_FILE}..."
	sed -e "s/^#.*//g" ${COUNTRY_INFO_FILE} | grep -v "^$" > ${TMP_FILE}
	\mv -f ${TMP_FILE} ${COUNTRY_INFO_FILE}
	echo "... Done"
fi

##
# Load the data of the smallest tables, i.e., all the tables but
# geoname and alternate_name
SQL_FILE="fill_geo_tables_small.sql"
echo "Load data into the tables of Geonames:"
mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} < ${SQL_FILE}
