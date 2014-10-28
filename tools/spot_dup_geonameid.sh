#!/bin/bash
#
# Detect distinct POR having the same Geoname ID, eg:
#  * Geonames ID=3451668: REZ and QRZ
#  * Geonames ID=3578420: SFG and CCE
#  * Geonames ID=4368301: LTW and XSM
#  * Geonames ID=5568159: RKC and ROF
#  * Geonames ID=6297031: HAH and YVA
#  * Geonames ID=6299466: MLH and BSL
#

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
EXEC_PATH="${EXEC_PATH}/"
TMP_DIR="${TMP_DIR}/"

if [ ! -d ${TMP_DIR} -o ! -w ${TMP_DIR} ]
then
	\mkdir -p ${TMP_DIR}
fi

##
# Log level
LOG_LEVEL=3

##
# OpenTravelData directory
OPTD_DIR=`dirname ${EXEC_FULL_PATH}`
OPTD_DIR="${OPTD_DIR}/"

##
# ORI sub-directories
ORI_DIR=${OPTD_DIR}ORI/
TOOLS_DIR=${OPTD_DIR}tools/

##
# Log level
LOG_LEVEL=2

##
# Initial
ORI_POR_FILENAME=optd_por_best_known_so_far.csv
ORI_POR_FILE=${ORI_DIR}${ORI_POR_FILENAME}

##
# Temporary
ORI_POR_NEW_FILENAME=new_${ORI_POR_FILENAME}
#
ORI_POR_NEW_FILE=${TMP_DIR}${ORI_POR_NEW_FILENAME}

##
# Usage helper
#
if [ "$1" = "-h" -o "$1" = "--help" ]
then
	echo
	echo "That script detects when a same Geoname ID appears for several distinct POR."
	echo
	echo "Usage: $0 [<log level (0: quiet; 5: verbose)>]"
	echo " - Default log level (from 0 to 5): ${LOG_LEVEL}"
	echo
	echo "* Input data file"
	echo "-----------------"
	echo " - ORI-maintained file of best known coordinates: '${ORI_POR_FILE}'"
	echo
	exit
fi

##
# Extract and re-aggregate the Geoname ID
SPOTTER=spot_dup_geonameid.awk
awk -F'^' -f ${SPOTTER} ${ORI_POR_FILE}

##
# Reporting
#
echo
echo "Reporting Step"
echo "--------------"
echo
