#!/bin/bash

# Derive the list of active POR (point of reference) entries
# for any given date, from the ORI-maintained data file of POR:
# ../ORI/ori_por_public.csv
#
# => ori_por_public_YYYYMMDD.csv
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
# Target date
TARGET_DATE=`date "+%Y%m%d"`
TARGET_DATE_HUMAN=`date`

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
LOG_LEVEL=3

##
# File of ORI-maintained POR (points of reference)
ORI_POR_BASEFILENAME=ori_por_public
ORI_POR_FILENAME=${ORI_POR_BASEFILENAME}.csv
ORI_POR_FILE=${ORI_DIR}${ORI_POR_FILENAME}

##
# Target (generated files)
ORI_POR_TGT_FILENAME=${ORI_POR_BASEFILENAME}_${TARGET_DATE}.csv
ORI_POR_TGT_FILE=${ORI_DIR}${ORI_POR_TGT_FILENAME}

##
# Parse command-line options
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<Target date>]"
	echo "  - Target date: '${TARGET_DATE}' (${TARGET_DATE_HUMAN})"
	echo "    + ${GEO_IATA_FILE} for the list of ORI-maintained POR at that date"
	echo
	exit -1
fi

##
# Target date
if [ "$1" != "" ];
then
	TARGET_DATE="$1"
	ORI_POR_TGT_FILENAME=${ORI_POR_BASEFILENAME}_${TARGET_DATE}.csv
	ORI_POR_TGT_FILE=${ORI_DIR}${ORI_POR_TGT_FILENAME}
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
time awk -F'^' -f ${EXTRACTER} ${ORI_POR_FILE} > ${ORI_POR_TGT_FILE}

##
# Reporting
#
echo
echo "Reporting Step"
echo "--------------"
echo
echo "wc -l ${ORI_POR_FILE} ${ORI_POR_TGT_FILE}"
echo
