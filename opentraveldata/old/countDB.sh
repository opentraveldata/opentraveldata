#!/bin/sh

####
## Settings
##
MYSQL_CLIENT="mysql"
MYSQL_USER="geo"
MYSQL_PASSWD="geo"
MYSQL_DB="geo_geonames"
MYSQL_ROOT="${MYSQL_CLIENT} --user=${MYSQL_USER} --password=${MYSQL_PASSWD} -D ${MYSQL_DB}"


####
## Count the number of elements of each table
##
#${MYSQL_ROOT} -e "select count(*) Nb_Of_Logs from logs;"
${MYSQL_ROOT} -e "select count(*) Nb_Of_Cities from dic_cities;"
${MYSQL_ROOT} -e "select count(*) Nb_Of_Codes from dic_codes;"
${MYSQL_ROOT} -e "select count(*) Nb_Of_Countries from dic_countries;"
${MYSQL_ROOT} -e "select count(*) Nb_Of_Searches from stat_searches;"
${MYSQL_ROOT} -e "select count(*) Nb_Of_Bookings from stat_bookings;"
