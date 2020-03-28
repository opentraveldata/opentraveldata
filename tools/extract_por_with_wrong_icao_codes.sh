#!/bin/bash

#
# OpenTravelData (OPTD) utility
# Git repository:
#   https://github.com/opentraveldata/opentraveldata/tree/master/tools
#

##
# cd tools/
# ./extract_por_with_wrong_icao_codes.sh
# git diff ../opentraveldata/optd_por_wrong_icao.csv
# git add ../opentraveldata/optd_por_wrong_icao.csv
# git commit -m "[POR] Integrated the last updates of POR having a wrong ICAO code." ../opentraveldata/optd_por_wrong_icao.csv

##
# Create the list of POR having a wrong ICAO code (not made of four letters)
# - por_all_YYYYMMDD.csv
#
# => optd_por_wrong_icao.csv
#

##
# GNU tools, including on MacOS
source setGnuTools.sh || exit -1

##
# Directories
source setDirs.sh "$0" || exit -1

##
# OpenTravelData directory
OPTD_DIR="$(dirname ${EXEC_FULL_PATH})"
OPTD_DIR="${OPTD_DIR}/"

##
# OPTD sub-directories
DATA_DIR="${OPTD_DIR}opentraveldata/"
TOOLS_DIR="${OPTD_DIR}tools/"

##
# Log level
LOG_LEVEL=3

##
# Snapshot date
SNAPSHOT_DATE="$(${DATE_TOOL} +%Y%m%d)"
SNAPSHOT_DATE_HUMAN="$(${DATE_TOOL})"

##
# File of best known coordinates
POR_ALL_FILENAME="por_all_${SNAPSHOT_DATE}.csv"
POR_ALL_FILE="${TOOLS_DIR}${POR_ALL_FILENAME}"

##
# List of country details
OPTD_CTRY_DTLS_FILENAME="optd_countries.csv"
OPTD_CTRY_DTLS_FILE="${DATA_DIR}${OPTD_CTRY_DTLS_FILENAME}"

##
# List of state codes for a few countries (e.g., US, CA, AU, AR, BR)
OPTD_CTRY_STATE_FILENAME="optd_country_states.csv"
OPTD_CTRY_STATE_FILE="${DATA_DIR}${OPTD_CTRY_STATE_FILENAME}"

##
# Mapping between the Countries and their corresponding continent
OPTD_CNT_FILENAME="optd_cont.csv"
OPTD_CNT_FILE="${DATA_DIR}${OPTD_CNT_FILENAME}"

##
# US DOT World Area Codes (WAC) for countries and states
OPTD_USDOT_FILENAME="optd_usdot_wac.csv"
OPTD_USDOT_FILE="${DATA_DIR}${OPTD_USDOT_FILENAME}"

##
# Target (generated files)
# All the POR with a wrong ICAO code
OPTD_POR_WRONG_ICAO_FILENAME="optd_por_wrong_icao.csv"
OPTD_POR_WRONG_ICAO_FILE="${DATA_DIR}${OPTD_POR_WRONG_ICAO_FILENAME}"

##
# Usage helper
#
if [ "$1" = "-h" -o "$1" = "--help" ]
then
	echo
	echo "That script generates the list of POR (points of reference) having" \
		 "a wrong ICAO code (not made of four letters)"
	echo
	echo "Usage: $0 [<log level (0: quiet; 5: verbose)>]"
	echo " - Default log level (from 0 to 5): ${LOG_LEVEL}"
	echo
	echo "* Input data files"
	echo "------------------"
	echo " - Geonames data dump file: '${POR_ALL_FILE}'"
	echo
	echo "* Output data file"
	echo "------------------"
	echo " - OPTD-maintained file of POR with wrong ICAO: '${OPTD_POR_WRONG_ICAO_FILE}'"
	echo
	exit
fi


##
# Cleaning
#
if [ "$1" = "--clean" ]
then
	echo
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
if [ ! -f ${POR_ALL_FILE} ]
then
	echo
	echo "[$0:$LINENO] The '${POR_ALL_FILE}' file does not exist."
	echo
	exit -1
fi

##
#
FILTER="extract_por_with_wrong_icao_codes.awk"
awk -F'^' -v log_level="${LOG_LEVEL}" -f ${FILTER} \
	${OPTD_CTRY_DTLS_FILE} ${OPTD_CTRY_STATE_FILE} ${OPTD_CNT_FILE} \
	${OPTD_USDOT_FILE} ${POR_ALL_FILE} > ${OPTD_POR_WRONG_ICAO_FILE}

##
# Reporting
#
echo
echo "Reporting Step"
echo "--------------"
echo
echo "${WC_TOOL} -l ${OPTD_POR_WRONG_ICAO_FILE}"
echo
