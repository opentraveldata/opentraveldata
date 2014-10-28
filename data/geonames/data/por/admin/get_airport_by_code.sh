#!/bin/sh
#
# Two parameters are optional:
# - the host server of the database
# - the port of the database
#

if [ "$1" = "-h" -o "$1" = "--help" -o "$1" = "" -o "$2" = "" ];
then
	echo "Usage: $0 iata|icao <airport-code> [<Database Server Hostname> [<Database Server Port>]]"
	echo " For instance:"
	echo "  $0 iata cdg will return the Charles-de-Gaulle airport"
	echo "  $0 icao lfpg will return the Charles-de-Gaulle airport"
	echo ""
	exit -1
fi

##
# Airport code type
AIRPORT_CODE_TYPE="iata"
if [ "$1" != "" ];
then
	AIRPORT_CODE_TYPE="$1"
	AIRPORT_CODE_TYPE=`echo ${AIRPORT_CODE_TYPE} | tr [:upper:] [:lower:]`
fi

##
# Airport code
AIRPORT_CODE="cdg"
if [ "$2" != "" ];
then
	AIRPORT_CODE="$2"
	AIRPORT_CODE=`echo ${AIRPORT_CODE} | tr [:lower:] [:upper:]`
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
DB_USER="geo"

# Database Password
DB_PASSWD="${DB_USER}"

# Database Name
DB_NAME="geo_geonames"

#
SQL_QUERY="select a1.alternateName, a2.alternateName, g.geonameid, g.name,
           g.latitude, g.longitude, g.country, g.fcode, g.population,
           g.timezone, g.alternatenames
from geoname as g 
left join alternate_name as a1 on g.geonameid = a1.geonameid
left join alternate_name as a2 on a1.geonameid = a2.geonameid
"

if [ "${AIRPORT_CODE_TYPE}" = "iata" ]
then
	SQL_QUERY="${SQL_QUERY} where a1.alternateName = '${AIRPORT_CODE}'"
elif [ "${AIRPORT_CODE_TYPE}" = "icao" ]
then
	SQL_QUERY="${SQL_QUERY} where a2.alternateName = '${AIRPORT_CODE}'"
fi

SQL_QUERY="${SQL_QUERY}
  and (g.fcode = 'AIRP' or g.fcode = 'AIRH')
  and a1.isoLanguage = 'iata'
  and a2.isoLanguage = 'icao'"

#
OUTPUT=`mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} -e "${SQL_QUERY}" ${DB_NAME}`

if [ "${OUTPUT}" = "" ]
then
	echo
	echo "There is no airport corresponding to the '${AIRPORT_CODE}' ${AIRPORT_CODE_TYPE} code"
	echo
else
	echo "Airport corresponding to the '${AIRPORT_CODE}' ${AIRPORT_CODE_TYPE} code:"
	echo "${OUTPUT}"
	echo
fi
