#!/bin/sh
#
# Two parameters are optional:
# - the host server of the database
# - the port of the database
#

if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo "Usage: $0 [<Place code> [<Database Server Hostname> [<Database Server Port>]]]"
	echo ""
	exit -1
fi

##
# IATA Code of the place
PL_CODE_RAW="JFK"
if [ "$1" != "" ];
then
	PL_CODE_RAW="$1"
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

# Database User
DB_USER="geo"

# Database Password
DB_PASSWD="geo"

# Database Name
DB_NAME="geo_geonames"

# The IATA code has to be translated into lower cases, as codes are stored
# in lower case characters.
PL_CODE=`echo "${PL_CODE_RAW}" | tr [:upper:] [:lower:]`

# Specify the SQL request
GET_CLOSEST_AIRPORT_REQUEST="
select (airpop.paxc)/1000 AS 'popularity', 
		places.code, places.code, 
		names.classical_name, names.extended_name, places.country_code,
		places.latitude, places.longitude
from airport_popularity AS airpop, 
	  ref_place_details AS places, ref_place_names AS names
WHERE places.code = '${PL_CODE}'
	  AND airpop.airport_code = places.code
	  AND names.code = places.code
ORDER BY airpop.tpax DESC"

# Get the closest airports
echo "Get the closest airports of the (${PL_LAT} +/-${PL_TOL}, ${PL_LON} +/-${PL_TOL}) location:"
mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} -e "${GET_CLOSEST_AIRPORT_REQUEST}"

