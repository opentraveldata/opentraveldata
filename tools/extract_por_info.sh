#!/bin/bash


# That Bash script tells how to extract a POR from:
# - optd_por_best_known_so_far.csv
# - optd_por_no_longer_valid.csv
# - dump_from_ref_city.csv
# - dump_from_geonames.csv
# - dump_from_innovata.csv
# - ref_airport_pageranked.csv
# - por_schedule_counts_YYYY_MM_to_YYYY_MM.csv
# - iata_airport_list_latest.csv

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
IATA_DIR=${OPTD_DIR}data/IATA/

##
# Log level
LOG_LEVEL=3

##
# File of best known coordinates
OPTD_POR_FILENAME=optd_por_best_known_so_far.csv
OPTD_POR_FILE=${DATA_DIR}${OPTD_POR_FILENAME}
# File of no longer valid IATA entries
OPTD_NOIATA_FILENAME=optd_por_no_longer_valid.csv
OPTD_NOIATA_FILE=${DATA_DIR}${OPTD_NOIATA_FILENAME}

##
# PageRank values
OPTD_PR_FILENAME=ref_airport_pageranked.csv
OPTD_PR_FILE=${DATA_DIR}${OPTD_PR_FILENAME}

##
# Geonames (to be found, as temporary files, within the ../tools directory)
GEONAME_RAW_FILENAME=dump_from_geonames.csv
#
GEONAME_RAW_FILE=${TOOLS_DIR}${GEONAME_RAW_FILENAME}

##
# REF (to be found, as temporary files, within the ../tools directory)
REF_RAW_FILENAME=dump_from_ref_city.csv
#
REF_RAW_FILE=${TOOLS_DIR}${REF_RAW_FILENAME}

##
# Innovata (to be found, as temporary files, within the ../tools directory)
INNO_RAW_FILENAME=dump_from_innovata.csv
#
INNO_RAW_FILE=${TOOLS_DIR}${INNO_RAW_FILENAME}

##
# Schedule-derived data files
POR_SKD_DIR=${DATA_DIR}por_in_schedule/

##
# Best known list of IATA POR
IATA_POR_FILENAME=iata_airport_list_latest.csv
#
IATA_POR_FILE=${IATA_DIR}${IATA_POR_FILENAME}

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
POR_FILE_PFX1=por_schedule_counts
LATEST_EXTRACT_PRD=`ls ${POR_SKD_DIR}${POR_FILE_PFX1}_????_??_to_????_??.csv 2> /dev/null`
if [ "${LATEST_EXTRACT_PRD}" != "" ]
then
	# (Trick to) Extract the latest entry
	for myfile in ${LATEST_EXTRACT_PRD}; do echo > /dev/null; done
	LATEST_EXTRACT_PRD=`echo ${myfile} | sed -e "s/${POR_FILE_PFX1}_\([0-9]\+\)_\([0-9]\+\)_to_\([0-9]\+\)_\([0-9]\+\)\.csv/\1_\2_to_\3_\4/" | xargs basename`
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
	LATEST_DUMP_POR_SKD_CNT_FILENAME=${POR_FILE_PFX1}_${LATEST_EXTRACT_PRD}.csv
fi
LATEST_DUMP_POR_SKD_CNT_FILE=${POR_SKD_DIR}${LATEST_DUMP_POR_SKD_CNT_FILENAME}

echo "grep \"^XCG\" ${OPTD_POR_FILE} ${REF_RAW_FILENAME} ${GEONAME_RAW_FILENAME} ${INNO_RAW_FILENAME} ${LATEST_DUMP_POR_SKD_CNT_FILE} ${OPTD_PR_FILE} ${IATA_POR_FILE}"

