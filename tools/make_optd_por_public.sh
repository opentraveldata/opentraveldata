#!/bin/bash

##
# cd tools/
# ./make_optd_por_public.sh
# ./make_optd_por_public.sh --clean
# sh prepare_por_no_geonames.sh # => ../opentraveldata/optd_por_no_geonames.csv
# sh prepare_por_no_geonames.sh --clean
# git diff ../opentraveldata/optd_por_no_geonames.csv
# git add ../opentraveldata/optd_por_no_geonames.csv
# ./make_optd_por_public.sh
# ./make_optd_por_public.sh --clean
# git diff ../opentraveldata/optd_por_public.csv
# git add ../opentraveldata/optd_por_public.csv
# git commit -m "[POR] Integrated the last updates of Geonames; xx POR has been updated." ../opentraveldata/optd_por_public.csv ../opentraveldata/optd_por_no_geonames.csv


##
# Create the public version of the OPTD-maintained list of POR, from:
# - optd_por_best_known_so_far.csv
# - optd_por_no_longer_valid.csv
# - optd_por_no_geonames.csv
# - optd_countries.csv
# - optd_country_states.csv
# - ref_airport_pageranked.csv
# - optd_tz_light.csv
# - optd_por_tz.csv
# - optd_cont.csv
# - optd_usdot_wac.csv
# - dump_from_geonames.csv
#
# => optd_por_public.csv
#

##
# Temporary path
TMP_DIR="/tmp/por"

##
# Path of the executable: set it to empty when this is the current directory.
EXEC_PATH=`dirname $0`
# Trick to get the actual full-path
pushd ${EXEC_PATH} > /dev/null
EXEC_FULL_PATH=`popd`
popd > /dev/null
EXEC_FULL_PATH=`echo ${EXEC_FULL_PATH} | sed -e 's|~|'${HOME}'|'`
#
CURRENT_DIR=`pwd`
if [ ${CURRENT_DIR} -ef ${EXEC_PATH} ]
then
	EXEC_PATH="."
	TMP_DIR="."
fi
# If the Geonames dump file is in the current directory, then the current
# directory is certainly intended to be the temporary directory.
if [ -f ${GEO_RAW_FILENAME} ]
then
	TMP_DIR="."
fi
EXEC_PATH="${EXEC_PATH}/"
TMP_DIR="${TMP_DIR}/"

if [ ! -d ${TMP_DIR} -o ! -w ${TMP_DIR} ]
then
	\mkdir -p ${TMP_DIR}
fi

##
# Sanity check: that (executable) script should be located in the
# tools/ sub-directory of the OpenTravelData project Git clone
EXEC_DIR_NAME=`basename ${EXEC_FULL_PATH}`
if [ "${EXEC_DIR_NAME}" != "tools" ]
then
	echo
	echo "[$0:$LINENO] Inconsistency error: this script ($0) should be located in the tools/ sub-directory of the OpenTravelData project Git clone, but apparently is not. EXEC_FULL_PATH=\"${EXEC_FULL_PATH}\""
	echo
	exit -1
fi

##
# OpenTravelData directory
OPTD_DIR=`dirname ${EXEC_FULL_PATH}`
OPTD_DIR="${OPTD_DIR}/"

##
# OPTD sub-directories
DATA_DIR=${OPTD_DIR}opentraveldata/
TOOLS_DIR=${OPTD_DIR}tools/

##
# Log level
LOG_LEVEL=3

##
# File of best known coordinates
OPTD_POR_FILENAME=optd_por_best_known_so_far.csv
OPTD_POR_FILE=${DATA_DIR}${OPTD_POR_FILENAME}

##
# File of no longer valid IATA entries
OPTD_NOIATA_FILENAME=optd_por_no_longer_valid.csv
OPTD_NOIATA_FILE=${DATA_DIR}${OPTD_NOIATA_FILENAME}

##
# File of non-Geonames POR
OPTD_NOGEONAMES_FILENAME=optd_por_no_geonames.csv
OPTD_NOGEONAMES_FILE=${DATA_DIR}${OPTD_NOGEONAMES_FILENAME}

##
# List of country details
OPTD_CTRY_DTLS_FILENAME=optd_countries.csv
OPTD_CTRY_DTLS_FILE=${DATA_DIR}${OPTD_CTRY_DTLS_FILENAME}

##
# List of state codes for a few countries (e.g., US, CA, AU, AR, BR)
OPTD_CTRY_STATE_FILENAME=optd_country_states.csv
OPTD_CTRY_STATE_FILE=${DATA_DIR}${OPTD_CTRY_STATE_FILENAME}

##
# Light (and inaccurate) version of the country-related time-zones
OPTD_TZ_CNT_FILENAME=optd_tz_light.csv
OPTD_TZ_CNT_FILE=${DATA_DIR}${OPTD_TZ_CNT_FILENAME}

##
# Time-zones derived from the closest city in Geonames: more accurate,
# only when the geographical coordinates are themselves accurate of course
OPTD_TZ_POR_FILENAME=optd_por_tz.csv
OPTD_TZ_POR_FILE=${DATA_DIR}${OPTD_TZ_POR_FILENAME}

##
# Mapping between the Countries and their corresponding continent
OPTD_CNT_FILENAME=optd_cont.csv
OPTD_CNT_FILE=${DATA_DIR}${OPTD_CNT_FILENAME}

##
# US DOT World Area Codes (WAC) for countries and states
OPTD_USDOT_FILENAME=optd_usdot_wac.csv
OPTD_USDOT_FILE=${DATA_DIR}${OPTD_USDOT_FILENAME}

##
# PageRank values
OPTD_PR_FILENAME=ref_airport_pageranked.csv
OPTD_PR_FILE=${DATA_DIR}${OPTD_PR_FILENAME}

##
# Geonames (to be found, as temporary files, within the ../tools directory)
GEONAME_RAW_FILENAME=dump_from_geonames.csv
GEONAME_RAW_FILE=${TOOLS_DIR}${GEONAME_RAW_FILENAME}

##
# Target (generated files)
# All the POR referenced by IATA
OPTD_POR_PUBLIC_FILENAME=optd_por_public.csv
OPTD_POR_PUBLIC_FILE=${DATA_DIR}${OPTD_POR_PUBLIC_FILENAME}
# All the POR referenced by international organizations
# including IATA (ICAO, UN/LOCODE)
OPTD_POR_PUBLIC_ALL_FILENAME=optd_por_public_all.csv
OPTD_POR_PUBLIC_ALL_FILE=${DATA_DIR}${OPTD_POR_PUBLIC_ALL_FILENAME}

##
# Temporary
OPTD_POR_WITH_NOHD=${OPTD_POR_FILE}.wohd
OPTD_NOIATA_WITH_NOHD=${OPTD_NOIATA_FILE}.wohd
OPTD_POR_WITH_GEO=${OPTD_POR_FILE}.withgeo
OPTD_POR_WITH_NO_CTY_NAME=${OPTD_POR_FILE}.withnoctyname
OPTD_POR_IATA_USTD_WOHD=${OPTD_POR_FILE}.iata.wohd
OPTD_POR_IATA_STD_FILE=${OPTD_POR_FILE}.iata
OPTD_POR_PUBLIC_W_NOGEONAMES=${OPTD_POR_FILE}.wnogenames
OPTD_POR_PUBLIC_WO_NOIATA_FILE=${OPTD_POR_FILE}.wonoiata
OPTD_POR_PUBLIC_WO_NOIATA_WITH_NOHD=${OPTD_POR_FILE}.wonoiata.wohd
OPTD_POR_PUBLIC_W_NOIATA_USTD_WOHD=${OPTD_POR_FILE}.wnoiata.wohd
OPTD_POR_PUBLIC_W_NOIATA_STD_FILE=${OPTD_POR_FILE}.wnoiata.sorted
GEONAME_RAW_FILE_TMP=${GEONAME_RAW_FILE}.alt


##
# Sanity check
if [ ! -d ${TOOLS_DIR} ]
then
	echo
	echo "[$0:$LINENO] The tools/ sub-directory ('${TOOLS_DIR}') does not exist or is not accessible."
	echo "Check that your Git clone of the OpenTravelData is complete."
	echo
	exit -1
fi


##
# Usage helper
#
if [ "$1" = "-h" -o "$1" = "--help" ]
then
	echo
	echo "That script generates the public version of the OPTD-maintained list of POR (points of reference)"
	echo
	echo "Usage: $0 [<log level (0: quiet; 5: verbose)>]"
	echo " - Default log level (from 0 to 5): ${LOG_LEVEL}"
	echo
	echo "* Input data files"
	echo "------------------"
	echo " - OPTD-maintained file of best known coordinates: '${OPTD_POR_FILE}'"
	echo " - OPTD-maintained file of non longer valid IATA POR: '${OPTD_NOIATA_FILE}'"
	echo " - OPTD-maintained file of PageRanked POR: '${OPTD_PR_FILE}'"
	echo " - OPTD-maintained file of country-related time-zones: '${OPTD_TZ_CNT_FILE}'"
	echo " - OPTD-maintained file of country details: '${OPTD_CTRY_DTLS_FILE}'"
	echo " - OPTD-maintained file of country states: '${OPTD_CTRY_STATE_FILE}'"
	echo " - OPTD-maintained file of POR-related time-zones: '${OPTD_TZ_POR_FILE}'"
	echo " - OPTD-maintained file of country-continent mapping: '${OPTD_CNT_FILE}'"
	echo " - OPTD-maintained file of US DOT World Area Codes (WAC): '${OPTD_USDOT_FILE}'"
	echo " - Geonames data dump file: '${GEONAME_RAW_FILE}'"
	echo
	echo "* Output data file"
	echo "------------------"
	echo " - OPTD-maintained public file of POR: '${OPTD_POR_PUBLIC_FILE}'"
	echo
	exit
fi


##
# Cleaning
#
if [ "$1" = "--clean" ]
then
	\rm -f ${OPTD_POR_WITH_GEO} ${OPTD_ONLY_POR_NEW_FILE} \
		${OPTD_POR_PUBLIC_WO_NOIATA_FILE} ${OPTD_POR_PUBLIC_W_NOGEONAMES} \
		${OPTD_POR_PUBLIC_WO_NOIATA_WITH_NOHD} \
		${OPTD_POR_PUBLIC_W_NOIATA_USTD_WOHD} \
		${OPTD_POR_PUBLIC_W_NOIATA_STD_FILE} \
		${OPTD_NOIATA_WITH_NOHD} \
		${OPTD_POR_WITH_NO_CTY_NAME} \
		${OPTD_POR_FILE_HEADER} ${OPTD_POR_WITH_NOHD} \
		${OPTD_POR_PUBLIC_W_NOIATA_USTD_WOHD} \
		${OPTD_POR_IATA_USTD_WOHD} \
		${OPTD_POR_IATA_STD_FILE} \
		${GEONAME_RAW_FILE_TMP}
	exit
fi


##
# Log level
if [ "$1" != "" ]
then
	LOG_LEVEL="$1"
fi


##
#
if [ ! -f ${GEONAME_RAW_FILE} ]
then
	echo
	echo "[$0:$LINENO] The '${GEONAME_RAW_FILE}' file does not exist."
	echo
	exit -1
fi

##
# Merge all the files. See ${REDUCER} for more details and samples.
echo
echo "Merge Step"
echo "----------"
echo
REDUCER=make_optd_por_public.awk
awk -F'^' -v log_level="${LOG_LEVEL}" -f ${REDUCER} \
	${OPTD_PR_FILE} ${OPTD_CTRY_DTLS_FILE} ${OPTD_CTRY_STATE_FILE} \
	${OPTD_TZ_CNT_FILE} ${OPTD_TZ_POR_FILE} ${OPTD_CNT_FILE} \
	${OPTD_USDOT_FILE} ${OPTD_POR_FILE} ${GEONAME_RAW_FILE} \
	> ${OPTD_POR_WITH_NO_CTY_NAME}

#echo "awk -F'^' -v log_level=\"${LOG_LEVEL}\" -f ${REDUCER} \
#	${OPTD_PR_FILE} ${OPTD_CTRY_DTLS_FILE} ${OPTD_CTRY_STATE_FILE} \
#	${OPTD_TZ_CNT_FILE} ${OPTD_TZ_POR_FILE} ${OPTD_CNT_FILE} \
#	${OPTD_USDOT_FILE} ${OPTD_POR_FILE} ${GEONAME_RAW_FILE} \
#	> ${OPTD_POR_WITH_NO_CTY_NAME}"

#echo "less ${OPTD_POR_WITH_NO_CTY_NAME}"
#exit

##
# Add the non Geonames POR
echo
echo "Non Geonames Step"
echo "-----------------"
echo
NOGEONAMES_ADDER=add_por_ref_no_geonames.awk
awk -F'^' -f ${NOGEONAMES_ADDER} ${OPTD_POR_WITH_NO_CTY_NAME} \
	${OPTD_NOGEONAMES_FILE} > ${OPTD_POR_PUBLIC_W_NOGEONAMES}

#echo "awk -F'^' -f ${NOGEONAMES_ADDER} ${OPTD_POR_WITH_NO_CTY_NAME} \
#	${OPTD_NOGEONAMES_FILE} > ${OPTD_POR_PUBLIC_W_NOGEONAMES}"

#echo "less ${OPTD_POR_PUBLIC_W_NOGEONAMES}"
#exit

##
# Write the UTF8 and ASCII names of the city served by every travel-related
# point of reference (POR).
echo
echo "City addition Step"
echo "------------------"
echo
CITY_WRITER=add_city_name.awk
awk -F'^' -f ${CITY_WRITER} \
	${OPTD_POR_PUBLIC_W_NOGEONAMES} ${OPTD_POR_PUBLIC_W_NOGEONAMES} \
	> ${OPTD_POR_PUBLIC_WO_NOIATA_FILE}

#echo "awk -F'^' -f ${CITY_WRITER} \
#	${OPTD_POR_PUBLIC_W_NOGEONAMES} ${OPTD_POR_PUBLIC_W_NOGEONAMES} \
#	> ${OPTD_POR_PUBLIC_WO_NOIATA_FILE}"
#exit

#echo "less ${OPTD_POR_PUBLIC_W_NOGEONAMES}"
#exit

##
# Extract the header into a temporary file
OPTD_POR_FILE_HEADER=${OPTD_POR_FILE}.tmp.hdr
grep "^iata_code\(.\+\)" ${OPTD_POR_WITH_NO_CTY_NAME} > ${OPTD_POR_FILE_HEADER}

# Remove the headers
sed -e "s/^iata_code\(.\+\)//g" ${OPTD_POR_PUBLIC_WO_NOIATA_FILE} \
	> ${OPTD_POR_PUBLIC_WO_NOIATA_WITH_NOHD}
sed -i -e "/^$/d" ${OPTD_POR_PUBLIC_WO_NOIATA_WITH_NOHD}

sed -e "s/^iata_code\(.\+\)//g" ${OPTD_NOIATA_FILE} > ${OPTD_NOIATA_WITH_NOHD}
sed -i -e "/^$/d" ${OPTD_NOIATA_WITH_NOHD}


##
# Add the non longer valid IATA entries
echo
echo "No longer valid IATA Step"
echo "-------------------------"
echo
NOIATA_ADDER=add_noiata_por.awk
awk -F'^' -f ${NOIATA_ADDER} \
	${OPTD_POR_PUBLIC_WO_NOIATA_WITH_NOHD} ${OPTD_NOIATA_WITH_NOHD} \
	> ${OPTD_POR_PUBLIC_W_NOIATA_USTD_WOHD}

##
# Extract and sort the IATA-referenced file
echo
echo "IATA file Step"
echo "--------------"
echo
grep "^[A-Z]\{3\}" ${OPTD_POR_PUBLIC_W_NOIATA_USTD_WOHD} \
	 > ${OPTD_POR_IATA_USTD_WOHD}
sort -t'^' -k1,1 -k42,42 -k5n,5 ${OPTD_POR_IATA_USTD_WOHD} \
	 > ${OPTD_POR_IATA_STD_FILE}
cat ${OPTD_POR_FILE_HEADER} ${OPTD_POR_IATA_STD_FILE} \
	> ${OPTD_POR_PUBLIC_FILE}

##
# Sort the final file
echo
echo "Sorting All Step"
echo "----------------"
echo
# Sort on the IATA code and Geonames ID, in that order
sort -t'^' -k1,1 -k5n,5 ${OPTD_POR_PUBLIC_W_NOIATA_USTD_WOHD} \
	 > ${OPTD_POR_PUBLIC_W_NOIATA_STD_FILE}
cat ${OPTD_POR_FILE_HEADER} ${OPTD_POR_PUBLIC_W_NOIATA_STD_FILE} \
	> ${OPTD_POR_PUBLIC_ALL_FILE}

##
# Remove the header
\rm -f ${OPTD_POR_FILE_HEADER}

##
# Reporting
#
echo
echo "Reporting Step"
echo "--------------"
echo
echo "wc -l ${OPTD_POR_FILE} ${OPTD_POR_PUBLIC_FILE} ${OPTD_POR_PUBLIC_ALL_FILE} ${OPTD_POR_PUBLIC_W_NOIATA_STD_FILE} ${OPTD_POR_PUBLIC_W_NOIATA_USTD_WOHD} ${OPTD_POR_PUBLIC_WO_NOIATA_WITH_NOHD} ${OPTD_POR_PUBLIC_WO_NOIATA_FILE} ${OPTD_POR_WITH_GEO} ${OPTD_POR_WITH_NO_CTY_NAME}"
echo
