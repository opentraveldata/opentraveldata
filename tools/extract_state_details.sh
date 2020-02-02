#!/bin/bash

#
# OpenTravelData (OPTD) utility
# Git repository:
#   https://github.com/opentraveldata/opentraveldata/tree/master/tools
#

##
# cd tools/
# ./extract_state_details.sh
# ./extract_state_details.sh --clean

##
# Extract the list of POR, with their state details, for a given country
# - optd_por_public.csv
#
# => potential contribution to be included in optd_country_states.csv
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
# Country code
CTRY_CODE="AR"

##
# List of all the POR and their details
OPTD_POR_PUBLIC_FILENAME="optd_por_public.csv"
OPTD_POR_PUBLIC_FILE="${DATA_DIR}${OPTD_POR_PUBLIC_FILENAME}"

##
# List of state codes for a few countries (e.g., US, CA, AU, AR, BR)
OPTD_CTRY_STATE_FILENAME="optd_country_states.csv"
OPTD_CTRY_STATE_FILE="${DATA_DIR}${OPTD_CTRY_STATE_FILENAME}"

##
# Temporary
OPTD_CTRY_STATE_FILE_41_CTRY="${OPTD_CTRY_STATE_FILE}.41cty"
OPTD_CTRY_STATE_FILE_NSTD="${OPTD_CTRY_STATE_FILE}.nstd"
OPTD_CTRY_STATE_FILE_NHDR="${OPTD_CTRY_STATE_FILE}.nhdr"


##
# Usage helper
#
if [ "$1" = "-h" -o "$1" = "--help" ]
then
	echo
	echo "That script extracts the state details from the OPTD-maintained list of POR (points of reference)"
	echo
	echo "Usage: $0 [<country code> [<log level (0: quiet; 5: verbose)>]]"
	echo " - Default country code for which the state details need to be extracted: ${CTRY_CODE}"
	echo " - Default log level (from 0 to 5): ${LOG_LEVEL}"
	echo
	echo "* Input data files"
	echo "------------------"
	echo " - OPTD-maintained public file of POR: '${OPTD_POR_PUBLIC_FILE}'"
	echo " - OPTD-maintained file of country states: '${OPTD_CTRY_STATE_FILE}'"
	echo
	echo "* Output data file"
	echo "------------------"
	echo " - File with state details for the corresponding POR: '${OPTD_CTRY_STATE_FILE_41_CTRY}'"
	echo
	exit
fi


##
# Cleaning
#
if [ "$1" = "--clean" ]
then
	\rm -f ${OPTD_CTRY_STATE_FILE_41_CTRY} ${OPTD_CTRY_STATE_FILE_NSTD} \
		${OPTD_CTRY_STATE_FILE_NHDR}
	exit
fi


##
# Country code
if [ "$1" != "" ]
then
	CTRY_CODE="$1"
fi

##
# Log level
if [ "$2" != "" ]
then
	LOG_LEVEL="$2"
fi


##
# Extract the states for a given country.
# See ${REDUCER} for more details and samples.
REDUCER="extract_state_details.awk"
awk -F'^' -v tgt_ctry_code="${CTRY_CODE}" -v log_level="${LOG_LEVEL}" \
	-f ${REDUCER} ${OPTD_POR_PUBLIC_FILE} ${OPTD_CTRY_STATE_FILE} \
	> ${OPTD_CTRY_STATE_FILE_41_CTRY}

##
# Extract the header into a temporary file
OPTD_CTRY_STATE_FILE_HEADER="${OPTD_CTRY_STATE_FILE}.hdr"
grep -E "^ctry_code(.+)" ${OPTD_CTRY_STATE_FILE_41_CTRY} \
	 > ${OPTD_CTRY_STATE_FILE_HEADER}

# Remove the headers
${SED_TOOL} -E "s/^ctry_code(.+)//g" ${OPTD_CTRY_STATE_FILE_41_CTRY} \
	> ${OPTD_CTRY_STATE_FILE_NSTD}
${SED_TOOL} -i"" -E "/^$/d" ${OPTD_CTRY_STATE_FILE_NSTD}

##
# Sort the state details
sort -t'^' -k5,5 -k2,2 ${OPTD_CTRY_STATE_FILE_NSTD} \
	 > ${OPTD_CTRY_STATE_FILE_NHDR}

##
# Add back the header
cat ${OPTD_CTRY_STATE_FILE_HEADER} ${OPTD_CTRY_STATE_FILE_NHDR} \
	> ${OPTD_CTRY_STATE_FILE_41_CTRY}

##
# Remove almost all the temporary files
\rm -f ${OPTD_CTRY_STATE_FILE_HEADER} ${OPTD_CTRY_STATE_FILE_NSTD} \
	${OPTD_CTRY_STATE_FILE_NHDR}

##
# Reporting
#
echo
echo "Reporting Step"
echo "--------------"
echo
echo "${WC_TOOL} -l ${OPTD_CTRY_STATE_FILE_41_CTRY}"
echo
