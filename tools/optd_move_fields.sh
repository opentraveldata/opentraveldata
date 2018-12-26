#!/bin/bash


# That Bash script moves fields for:
# - optd_por_no_longer_valid.csv
#
# Note that that script is intended to be very rarely run, for one-time actions
# only. If you want to re-use it, check the 'TO BE CUSTOMIZED' lines below.
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
# File of no longer valid IATA entries
OPTD_NOIATA_FILENAME=optd_por_no_longer_valid.csv
OPTD_NOIATA_FILE=${DATA_DIR}${OPTD_NOIATA_FILENAME}
#
OPTD_NOIATA_TMP1_FILE=${TMP_DIR}${OPTD_NOIATA_FILENAME}.tmp1
OPTD_NOIATA_TMP2_FILE=${TMP_DIR}${OPTD_NOIATA_FILENAME}.tmp2
OPTD_NOIATA_NEW_FILE=${TMP_DIR}${OPTD_NOIATA_FILENAME}.new

##
# Move the fields #42 and #43 at the end of the line
# TO BE CUSTOMIZED
cut -d'^' -f1-41,44- ${OPTD_NOIATA_FILE} > ${OPTD_NOIATA_TMP1_FILE}
cut -d'^' -f42,43 ${OPTD_NOIATA_FILE} > ${OPTD_NOIATA_TMP2_FILE}
paste -d'^' ${OPTD_NOIATA_TMP1_FILE} ${OPTD_NOIATA_TMP2_FILE} > ${OPTD_NOIATA_NEW_FILE}

##
# Cleaning
\rm -f ${OPTD_NOIATA_TMP1_FILE} ${OPTD_NOIATA_TMP2_FILE}

##
# Reporting
echo
echo "From '${OPTD_NOIATA_FILE}', generated '${OPTD_NOIATA_NEW_FILE}'."
echo "Next step:"
echo "mv ${OPTD_NOIATA_NEW_FILE} ${OPTD_NOIATA_FILE}"
echo
