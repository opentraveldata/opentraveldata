#!/bin/bash

##
# That Bash script extracts state details for a few selected countries,
# derived from the Geonames 'allCountries_w_alt.txt' data file,
# and exports them into internal standard-formatted data files.
# 
#
# See ../geonames/data/por/admin/aggregateGeonamesPor.sh for more details on
# the way to derive that file from Geonames original data files.

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

##
# Log level
LOG_LEVEL=3

##
# Geonames data store
GEO_POR_DATA_DIR=${EXEC_PATH}../data/geonames/data/por/data/

##
# OPTD directory
DATA_DIR=${EXEC_PATH}../opentraveldata/

##
# Extract airport/city information from the Geonames data file
GEO_POR_FILENAME=allCountries_w_alt.txt
GEO_POR_FILE=${GEO_POR_DATA_DIR}${GEO_POR_FILENAME}

##
# Generated file
OPTD_CTRY_ST_LST_FILENAME=optd_country_states.csv
OPTD_CTRY_ST_LST_FILE=${DATA_DIR}${OPTD_CTRY_ST_LST_FILENAME}

#
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0"
	echo "  - Geonames detailed POR entry data file (~10 millions records): '${GEO_POR_FILE}'"
	echo
	echo "  - Generated (CSV-formatted) data file: '${OPTD_CTRY_ST_LST_FILE}'"
	echo
	exit
fi

##
#
if [ "$1" = "--clean" ]
	then
	if [ "${TMP_DIR}" = "/tmp/por/" ]
	then
		\rm -rf ${TMP_DIR}
	else
		echo
	fi
	exit
fi

##
#
echo
echo "Extracting country/state-related information from '${GEO_POR_FILE}'"
STATE_EXTRACTOR=${EXEC_PATH}extract_states.awk
time awk -F'^' -f ${STATE_EXTRACTOR} ${GEO_POR_FILE} > ${OPTD_CTRY_ST_LST_FILE}
echo "... Done"
echo

##
# Reporting
#
echo
echo "Reporting step"
echo "--------------"
echo
echo "From the '${GEO_POR_FILE}' Geonames input data file, the '${OPTD_CTRY_ST_LST_FILE}' data file has been derived."
echo
echo "Suggested next steps:"
echo "git add ${OPTD_CTRY_ST_LST_FILE}"
echo "git commit -m \"[Countries] Updated the list of states per country.\" ${DATA_DIR}/${OPTD_CTRY_ST_LST_FILE}"
echo
