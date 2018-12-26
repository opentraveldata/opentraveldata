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
GEO_CTRY_DATA_DIR=${EXEC_PATH}../data/geonames/data/por/data/

##
# OPTD directory
DATA_DIR=${EXEC_PATH}../opentraveldata/

##
# Country details, as maintained by Geonames
GEO_CTRY_FILENAME=countryInfo.txt
GEO_CTRY_FILE=${GEO_CTRY_DATA_DIR}${GEO_CTRY_FILENAME}

##
# Generated file
OPTD_CTRY_FILENAME=optd_countries.csv
OPTD_CTRY_FILE=${DATA_DIR}${OPTD_CTRY_FILENAME}

#
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0"
	echo "  - Geonames country data file (~250 records): '${GEO_CTRY_FILE}'"
	echo
	echo "  - Generated (CSV-formatted) data file: '${OPTD_CTRY_FILE}'"
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
echo "Extracting country/state-related information from '${GEO_CTRY_FILE}'"
STATE_EXTRACTOR=${EXEC_PATH}make_optd_country.awk
time awk -F'	' -f ${STATE_EXTRACTOR} ${GEO_CTRY_FILE} > ${OPTD_CTRY_FILE}
echo "... Done"
echo

##
# Reporting
#
echo
echo "Reporting step"
echo "--------------"
echo
echo "From the '${GEO_CTRY_FILE}' Geonames input data file, the '${OPTD_CTRY_FILE}' data file has been derived."
echo
echo "Suggested next steps:"
echo "git add ${OPTD_CTRY_FILE}"
echo "git commit -m \"[Countries] Updated the list of countries.\" ${DATA_DIR}/${OPTD_CTRY_FILE}"
echo
