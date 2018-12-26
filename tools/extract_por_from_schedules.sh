#!/bin/bash

# That Bash script extracts data from the
# 'por_schedule_all_uniq_YYYY_MM_to_YYYY_MM.csv.bz2'
# schedule-derived data file and derives a few other utility data files:
# * por_schedule_counts_YYYY_MM_to_YYYY_MM.csv:
#     Number of weeks during which the POR have been present in schedules.
# * por_schedule_periods_YYYY_MM_to_YYYY_MM.csv:
#     Number of weeks during which the POR have been present in schedules.
#
# The YYYY_MM represent the snapshot/generation dates of the schedule files,
# which have been analysed/crunched.
#
# Within the data files:
# * IATA code of the POR (point of reference, e.g., NCE for Nice)
# * The year, week number and the corresponding period,
#   which correspond to the earliest and latest departure dates
#   of the flight segments involving the corresponding POR.
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
# Schedule-derived data files
POR_SKD_DIR=${DATA_DIR}por_in_schedule/

##
# MacOS 'date' vs GNU date
DATE_TOOL=date
if [ -f /usr/bin/sw_vers ]
then
	DATE_TOOL=gdate
fi

##
# Snapshot date
SNAPSHOT_DATE=`$DATE_TOOL "+%Y%m%d"`
SNAPSHOT_DATE_HUMAN=`$DATE_TOOL`

##
# Retrieve the latest schedule-derived POR data files
POR_FILE_PFX1=por_schedule_all_uniq
POR_FILE_PFX2=por_schedule_counts
POR_FILE_PFX3=por_schedule_period_list
LATEST_EXTRACT_PRD=`ls ${POR_SKD_DIR}${POR_FILE_PFX1}_????_??_to_????_??.csv.bz2 2> /dev/null`
if [ "${LATEST_EXTRACT_PRD}" != "" ]
then
	# (Trick to) Extract the latest entry
	for myfile in ${LATEST_EXTRACT_PRD}; do echo > /dev/null; done
	LATEST_EXTRACT_PRD=`echo ${myfile} | sed -e "s/${POR_FILE_PFX1}_\([0-9]\+\)_\([0-9]\+\)_to_\([0-9]\+\)_\([0-9]\+\)\.csv.bz2/\1_\2_to_\3_\4/" | xargs basename`
fi
if [ "${LATEST_EXTRACT_PRD}" != "" ]
then
	LATEST_EXTRACT_PRD_BGN=`echo ${LATEST_EXTRACT_PRD} | sed -e "s/\([0-9]\+\)_\([0-9]\+\)_to_\([0-9]\+\)_\([0-9]\+\)/\1-\2-01/"`
	LATEST_EXTRACT_PRD_BGN_HUMAN=`$DATE_TOOL -d ${LATEST_EXTRACT_PRD_BGN}`
	LATEST_EXTRACT_PRD_END=`echo ${LATEST_EXTRACT_PRD} | sed -e "s/\([0-9]\+\)_\([0-9]\+\)_to_\([0-9]\+\)_\([0-9]\+\)/\3-\4-01/"`
	LATEST_EXTRACT_PRD_END_HUMAN=`$DATE_TOOL -d ${LATEST_EXTRACT_PRD_END}`
fi
if [ "${LATEST_EXTRACT_PRD}" != "" \
	-a "${LATEST_EXTRACT_PRD}" != "${SNAPSHOT_DATE}" ]
then
	LATEST_DUMP_POR_SKD_ALL_FILENAME=${POR_FILE_PFX1}_${LATEST_EXTRACT_PRD}.csv.bz2
	LATEST_DUMP_POR_SKD_CNT_FILENAME=${POR_FILE_PFX2}_${LATEST_EXTRACT_PRD}.csv
	LATEST_DUMP_POR_SKD_PRD_FILENAME=${POR_FILE_PFX3}_${LATEST_EXTRACT_PRD}.csv
fi
LATEST_DUMP_POR_SKD_ALL_FILE=${POR_SKD_DIR}${LATEST_DUMP_POR_SKD_ALL_FILENAME}
LATEST_DUMP_POR_SKD_CNT_FILE=${POR_SKD_DIR}${LATEST_DUMP_POR_SKD_CNT_FILENAME}
LATEST_DUMP_POR_SKD_PRD_FILE=${POR_SKD_DIR}${LATEST_DUMP_POR_SKD_PRD_FILENAME}


##
# If the data file is not sorted, sort it
TMP_DUMP_POR_SKD_ALL=${TMP_DIR}${LATEST_DUMP_POR_SKD_ALL_FILENAME}.tmp
echo
echo "Check that the ${LATEST_DUMP_POR_SKD_ALL_FILENAME} file is sorted:"
echo "bzless ${LATEST_DUMP_POR_SKD_ALL_FILE}"
echo "If not sorted, sort it:"
echo "bzcat ${LATEST_DUMP_POR_SKD_ALL_FILE} | sort -t'^' -k1,1 -k4,4 -k5,5 | bzip2 > ${TMP_DUMP_POR_SKD_ALL} && mv -f ${TMP_DUMP_POR_SKD_ALL} ${LATEST_DUMP_POR_SKD_ALL_FILE}"

##
# Counting
echo
echo "Counting the number of occurences of the POR within the ${LATEST_DUMP_POR_SKD_ALL_FILE} file."
if [ ! -f "${LATEST_DUMP_POR_SKD_CNT_FILE}" ]
then
	echo "Generating the ${LATEST_DUMP_POR_SKD_CNT_FILENAME} file..."
	bzcat ${LATEST_DUMP_POR_SKD_ALL_FILE} | cut -d'^' -f1 | uniq -c | awk -F' ' '{print $2 "^" $1}' > ${LATEST_DUMP_POR_SKD_CNT_FILE}
	echo "... done"
fi
echo "grep -e \"BER\" -e \"^NCE\" ${LATEST_DUMP_POR_SKD_CNT_FILE} =>"
grep -e "^BER" -e "^NCE" ${LATEST_DUMP_POR_SKD_CNT_FILE}

# Reporting
echo
echo "POR_SKD_DIR = ${POR_SKD_DIR}"
echo "LATEST_EXTRACT_PRD = ${LATEST_EXTRACT_PRD}"
echo "LATEST_EXTRACT_PRD_BGN = ${LATEST_EXTRACT_PRD_BGN_HUMAN}"
echo "LATEST_EXTRACT_PRD_END = ${LATEST_EXTRACT_PRD_END_HUMAN}"
echo "LATEST_DUMP_POR_SKD_ALL_FILE = ${LATEST_DUMP_POR_SKD_ALL_FILE}"
echo "LATEST_DUMP_POR_SKD_CNT_FILE = ${LATEST_DUMP_POR_SKD_CNT_FILE}"
echo "LATEST_DUMP_POR_SKD_PRD_FILE = ${LATEST_DUMP_POR_SKD_PRD_FILE}"
echo
