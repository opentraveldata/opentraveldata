#!/bin/sh

GEO_DB_NAME="IpToCountry2.csv"
ZIP_SUFFIX=".gz"
CREATE_TABLE_SQL="create_table_ip_to_country.sql"
LOAD_TABLE_SQL="load_table_ip_to_country.sql"
DB_USER=magicolta
DB_PASSWD=mag3030
DB_NAME=magicolta

# Un-compress the database file
#gunzip ${GEO_DB_NAME}${ZIP_SUFFIX}

# Remove all the entries from the ip_to_country table
mysql -u ${DB_USER} --password=${DB_PASSWD} ${DB_NAME} -e "drop table ip_to_country;"

# Re-create the ip_to_country table
mysql -u ${DB_USER} --password=${DB_PASSWD} ${DB_NAME} < ${CREATE_TABLE_SQL}

# Load the GeoIP table into MySQL
mysql -u ${DB_USER} --password=${DB_PASSWD} ${DB_NAME} < ${LOAD_TABLE_SQL}

# Re-compress the database file
#gzip ${GEO_DB_NAME}
