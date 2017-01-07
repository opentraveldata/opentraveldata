#!/bin/bash

# Create the public version of the OPTD-maintained list of airlines, from:
# - optd_airline_best_known_so_far.csv
# - optd_airline_no_longer_valid.csv
# - ref_airline_nb_of_flights.csv
# - optd_airline_alliance_membership.csv
# - dump_from_geonames.csv (future)
#
# => optd_airlines.csv (and optd_airline_diff_w_alc.csv as a collateral effect)
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
	echo "[$0:$LINENO] Inconsistency error: this script ($0) should be located in the refdata/tools/ sub-directory of the OpenTravelData project Git clone, but apparently is not. EXEC_FULL_PATH=\"${EXEC_FULL_PATH}\""
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
# File of best known airline details (future)
OPTD_AIR_FILENAME=optd_airline_best_known_so_far.csv
# File of no longer valid IATA entries (future)
OPTD_NOIATA_FILENAME=optd_airline_no_longer_valid.csv
# File of alliance membership details
OPTD_AIR_ALC_FILENAME=optd_airline_alliance_membership.csv
#
OPTD_AIR_FILE=${DATA_DIR}${OPTD_AIR_FILENAME}
OPTD_NOIATA_FILE=${DATA_DIR}${OPTD_NOIATA_FILENAME}
OPTD_AIR_ALC_FILE=${DATA_DIR}${OPTD_AIR_ALC_FILENAME}

##
# Importance values
OPTD_NF_FILENAME=ref_airline_nb_of_flights.csv
OPTD_NF_FILE=${DATA_DIR}${OPTD_NF_FILENAME}

##
# Target (generated files)
OPTD_AIR_PUBLIC_FILENAME=optd_airlines.csv
OPTD_AIR_ALC_DIFF_FILENAME=optd_airline_diff_w_alc.csv
#
OPTD_AIR_PUBLIC_FILE=${DATA_DIR}${OPTD_AIR_PUBLIC_FILENAME}
OPTD_AIR_ALC_DIFF_FILE=${DATA_DIR}${OPTD_AIR_ALC_DIFF_FILENAME}

##
# Temporary
OPTD_AIR_HEADER=${OPTD_AIR_FILE}.tmp.hdr
OPTD_AIR_WITH_NOHD=${OPTD_AIR_FILE}.wohd
OPTD_AIR_UNSORTED_NOHDR=${OPTD_AIR_FILE}.wohd.unsorted
OPTD_AIR_PUBLIC_UNSORTED_FILE=${OPTD_AIR_FILE}.unsorted


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
	echo "That script generates the public version of the OPTD-maintained list of airlines"
	echo
	echo "Usage: $0 [<log level (0: quiet; 5: verbose)>]"
	echo " - Default log level (from 0 to 5): ${LOG_LEVEL}"
	echo
	echo "* Input data files"
	echo "------------------"
	echo " - OPTD-maintained file of best known details: '${OPTD_AIR_FILE}'"
	echo " - OPTD-maintained file of non longer valid IATA airlines: '${OPTD_NOIATA_FILE}'"
	echo " - OPTD-maintained file of importance values: '${OPTD_NF_FILE}'"
	echo " - OPTD-maintained file of alliance membership details: '${OPTD_AIR_ALC_FILE}'"
	echo
	echo "* Output data file"
	echo "------------------"
	echo " - OPTD-maintained public file of airlines: '${OPTD_AIR_PUBLIC_FILE}'"
	echo " - List of airlines for which the alliance-derived names are different: '${OPTD_AIR_ALC_DIFF_FILE}'"
	echo
	exit
fi


##
# Cleaning
#
if [ "$1" = "--clean" ]
then
	\rm -f ${OPTD_AIR_WITH_NOHD} ${OPTD_AIR_UNSORTED_NOHDR} \
		${OPTD_AIR_PUBLIC_UNSORTED_FILE}
	exit
fi


##
# Log level
if [ "$1" != "" ]
then
	LOG_LEVEL="$1"
fi


##
# Initialise the generated file of name differences appearing in the alliance
# file. That file is normally empty; so, if it were not initialized to an empty
# file, the latest version (even if not empty) would be left untouched.
\rm -f ${OPTD_AIR_ALC_DIFF_FILE}
touch ${OPTD_AIR_ALC_DIFF_FILE}

##
# Re-format the aggregated entries. See ${REDUCER} for more details and samples.
REDUCER=make_optd_airline_public.awk
awk -F'^' -v air_name_alc_diff_file=${OPTD_AIR_ALC_DIFF_FILE} \
	-f ${REDUCER} ${OPTD_AIR_ALC_FILE} ${OPTD_NF_FILE} \
	${OPTD_AIR_FILE} ${OPTD_NOIATA_FILE} \
	> ${OPTD_AIR_PUBLIC_UNSORTED_FILE}

##
# Extract the header into temporary files
grep "^pk\(.\+\)" ${OPTD_AIR_PUBLIC_UNSORTED_FILE} > ${OPTD_AIR_HEADER}

##
# Remove the header
sed -e "s/^pk\(.\+\)//g" ${OPTD_AIR_PUBLIC_UNSORTED_FILE} \
	> ${OPTD_AIR_WITH_NOHD}
sed -i -e "/^$/d" ${OPTD_AIR_WITH_NOHD}

##
# Sort on the IATA code, feature code and Geonames ID, in that order
sort -t'^' -k1,1 -k2,2 ${OPTD_AIR_WITH_NOHD} > ${OPTD_AIR_UNSORTED_NOHDR}

##
# Re-add the header
cat ${OPTD_AIR_HEADER} ${OPTD_AIR_UNSORTED_NOHDR} > ${OPTD_AIR_PUBLIC_FILE}

##
# Remove the header
\rm -f ${OPTD_AIR_HEADER}

##
# Reporting
#
echo
echo "Reporting Step"
echo "--------------"
echo
echo "wc -l ${OPTD_AIR_PUBLIC_FILE} ${OPTD_AIR_ALC_DIFF_FILE}"
echo
