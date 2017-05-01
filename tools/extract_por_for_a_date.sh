#!/bin/bash

# Derive the list of active POR (point of reference) entries
# for any given date, from the OPTD-maintained data file of POR:
# ../opentraveldata/optd_por_public.csv
#
# => optd_por_public_YYYYMMDD.csv
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
# MacOS 'date' vs GNU date
DATE_TOOL=date
if [ -f /usr/bin/sw_vers ]
then
	DATE_TOOL=gdate
fi

##
# Target date
TARGET_DATE=`$DATE_TOOL "+%Y%m%d"`
TARGET_DATE_HUMAN=`$DATE_TOOL`

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
# File of OPTD-maintained POR (points of reference)
OPTD_POR_BASEFILENAME=optd_por_public
OPTD_POR_FILENAME=${OPTD_POR_BASEFILENAME}.csv
OPTD_POR_FILE=${DATA_DIR}${OPTD_POR_FILENAME}

##
# Target (generated files)
OPTD_POR_TGT_FILENAME=${OPTD_POR_BASEFILENAME}_${TARGET_DATE}.csv
OPTD_POR_TGT_FILE=${DATA_DIR}${OPTD_POR_TGT_FILENAME}

##
# Parse command-line options
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<Target date>]"
	echo "  - Target date: '${TARGET_DATE}' (${TARGET_DATE_HUMAN})"
	echo "    + ${OPTD_POR_FILE} contains the OPTD-maintained list of Points of Reference (POR)"
	echo "    + ${OPTD_POR_TGT_FILE} contains the list of OPTD-maintained POR for that date"
	echo
	exit -1
fi

##
# Target date
if [ "$1" != "" ];
then
	TARGET_DATE="$1"
	OPTD_POR_TGT_FILENAME=${OPTD_POR_BASEFILENAME}_${TARGET_DATE}.csv
	OPTD_POR_TGT_FILE=${DATA_DIR}${OPTD_POR_TGT_FILENAME}
fi

##
# Cleaning
#
if [ "$1" = "--clean" ]
then
	exit
fi

##
# Extraction of the valid POR entries for the given date.
echo
echo "Extraction Step"
echo "---------------"
echo
EXTRACTER=extract_por_for_a_date.awk
time awk -F'^' -v tgt_date=${TARGET_DATE} -f ${EXTRACTER} \
	 ${OPTD_POR_FILE} > ${OPTD_POR_TGT_FILE}

##
# Reporting
#
echo
echo "Reporting Step"
echo "--------------"
echo
echo "wc -l ${OPTD_POR_FILE} ${OPTD_POR_TGT_FILE}"
echo
