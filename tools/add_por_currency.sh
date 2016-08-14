#!/bin/bash

##
# That script is intended to be run just once, and adds the currency code
# to the no longer valid POR.
# - optd_countries.csv
# - optd_por_no_longer_valid.csv (without currency codes)
#
# => optd_por_no_longer_valid.csv (with currency codes)
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
# List of country details
OPTD_CTRY_DTLS_FILENAME=optd_countries.csv
OPTD_CTRY_DTLS_FILE=${DATA_DIR}${OPTD_CTRY_DTLS_FILENAME}

##
# File of no longer valid IATA entries
OPTD_NOIATA_FILENAME=optd_por_no_longer_valid.csv
OPTD_NOIATA_FILE=${DATA_DIR}${OPTD_NOIATA_FILENAME}

##
# Target (generated files)
OPTD_NOIATA_NEW_FILENAME=${OPTD_NOIATA_FILENAME}.new
OPTD_NOIATA_NEW_FILE=${DATA_DIR}${OPTD_NOIATA_NEW_FILENAME}


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
	echo "That script adds the currency codes to the no longer valid POR lines"
	echo
	echo "Usage: $0 [<log level (0: quiet; 5: verbose)>]"
	echo " - Default log level (from 0 to 5): ${LOG_LEVEL}"
	echo
	echo "* Input data files"
	echo "------------------"
	echo " - OPTD-maintained file of country details: '${OPTD_CTRY_DTLS_FILE}'"
	echo " - OPTD-maintained file of non longer valid IATA POR (without currency codes): '${OPTD_NOIATA_FILE}'"
	echo
	echo "* Output data file"
	echo "------------------"
	echo " - OPTD-maintained file of non longer valid IATA POR (with currency codes): '${OPTD_NOIATA_NEW_FILE}'"
	echo
	exit
fi


##
# Cleaning
#
if [ "$1" = "--clean" ]
then
	exit
fi


##
# Log level
if [ "$1" != "" ]
then
	LOG_LEVEL="$1"
fi


##
# Add the currency codes. See ${ADDER} for more details and samples.
echo
echo "Add Step"
echo "--------"
echo
ADDER=add_por_currency.awk
awk -F'^' -v log_level="${LOG_LEVEL}" -f ${ADDER} \
	${OPTD_CTRY_DTLS_FILE} ${OPTD_NOIATA_FILE} > ${OPTD_NOIATA_NEW_FILE}

#echo "awk -F'^' -v log_level=\"${LOG_LEVEL}\" -f ${REDUCER} \
# ${OPTD_CTRY_DTLS_FILE} ${OPTD_NOIATA_FILE} > ${OPTD_NOIATA_NEW_FILE}

#echo "less ${OPTD_NOIATA_NEW_FILE}"
#exit

##
# Reporting
#
echo
echo "Reporting Step"
echo "--------------"
echo
echo "wc -l ${OPTD_NOIATA_FILE} ${OPTD_NOIATA_NEW_FILE}"
echo
