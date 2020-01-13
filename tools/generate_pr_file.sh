#!/bin/bash

##
# That Shell script manages the calculation of the PageRank values for all
# the POR (points of reference) appearing in a SSIM7 schedule files.
#

##
# Input file names
GEO_OPTD_FILENAME=optd_por_best_known_so_far.csv

##
# Output files
# PageRank
PR_GEN_FILENAME=page_ranked_all.csv
PR_GEN_SORTED_FILENAME=sorted_page_ranked_all.csv
PR_OUT_FILENAME=ref_airport_pageranked.csv
PR_HDR_FILENAME=ref_airport_pageranked_header.csv
# Number of flight-dates
FA_OUT_FILENAME=ref_airline_nb_of_flights.csv
FA_HDR_FILENAME=ref_airline_nb_of_flights_header.csv

##
# Temporary path
TMP_DIR="/tmp/por"
MYCURDIR=`pwd`

##
# Path of the executable: set it to empty when this is the current directory.
EXEC_PATH=`dirname $0`
# Trick to get the actual full-path
EXEC_FULL_PATH=`pushd ${EXEC_PATH}`
EXEC_FULL_PATH=`echo ${EXEC_FULL_PATH} | cut -d' ' -f1`
EXEC_FULL_PATH=`echo ${EXEC_FULL_PATH} | sed -e 's|~|'${HOME}'|'`
#
CURRENT_DIR=`pwd`
if [ ${CURRENT_DIR} -ef ${EXEC_PATH} ]
then
	EXEC_PATH="."
	TMP_DIR="."
fi
# If the OPTD-maintained POR file is in the current directory, then the current
# directory is certainly intended to be the temporary directory.
if [ -f ${GEO_OPTD_FILENAME} ]
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
# Sanity check: that (executable) script should be located in the tools/
# sub-directory of the OPTD project Git clone
EXEC_DIR_NAME=`basename ${EXEC_FULL_PATH}`
if [ "${EXEC_DIR_NAME}" != "tools" ]
then
	echo
	echo "[$0:$LINENO] Inconsistency error: this script ($0) should be located in the tools/ sub-directory of the OPTD project Git clone, but apparently is not. EXEC_FULL_PATH=\"${EXEC_FULL_PATH}\""
	echo
	exit -1
fi

##
# OpenTravelData directory
OPTD_DIR="<OpenTravelData DIR>"
OPTD_DIR="${OPTD_DIR}/"

##
# OPTD sub-directory
OPTD_DIR=${OPTD_DIR}opentraveldata/
TOOLS_DIR=${OPTD_DIR}tools/

##
# Schedule-service directories
SCHSVC_DIR=`dirname ${EXEC_FULL_PATH}`
SCHSVC_DUMP_DIR="${SCHSVC_DIR}/ssim7_to_csv/"
SCHSVC_DIR="${SCHSVC_DIR}/use_cases/"

##
# Log level
LOG_LEVEL=4

##
# Input files
GEO_OPTD_FILE=${SCHSVC_DIR}${GEO_OPTD_FILENAME}

##
# Snapshot/generation date
SNAPSHOT_DATE=`date "+%Y-%m-%d"`
SNAPSHOT_DATE_HUMAN=`date`

##
# Retrieve the latest schedule file
POR_FILE_PFX1=oag_schedule
POR_FILE_PFX2=oag_schedule_opt
POR_FILE_PFX3=oag_schedule_with_cities
POR_FILE_PFX4=oag_schedule_air
LST_EXTRACT_DATE=`ls ${SCHSVC_DUMP_DIR}${POR_FILE_PFX1}_??????.csv.bz2 2> /dev/null`
if [ "${LST_EXTRACT_DATE}" != "" ]
then
	# (Trick to) Extract the latest entry
	for myfile in ${LST_EXTRACT_DATE}; do echo > /dev/null; done
	LST_EXTRACT_DATE=`echo ${myfile} | sed -e "s/${POR_FILE_PFX1}_\([0-9]\+\)\.csv\.bz2/\1/" | xargs basename`
else
	echo
	echo "[$0:$LINENO] No schedule CSV dump can be found in the '${SCHSVC_DUMP_DIR}' directory."
	echo "Hint: go into the '${SCHSVC_DUMP_DIR}' directory and convert the OAG SSIM7 file into a CSV file, thanks to ${SCHSVC_DUMP_DIR}launch_oag_ssim7_to_csv_local.sh."
	echo
	exit -1
fi
if [ "${LST_EXTRACT_DATE}" != "" ]
then
	LST_EXTRACT_DATE_HUMAN=`date -d ${LST_EXTRACT_DATE}`
else
	LST_EXTRACT_DATE_HUMAN=`date --date='last Thursday' "+%y%m%d"`
	LST_EXTRACT_DATE_HUMAN=`date --date='last Thursday'`
fi
if [ "${LST_EXTRACT_DATE}" != "" ]
then
	LST_SCH_DUMP_FILENAME=${POR_FILE_PFX1}_${LST_EXTRACT_DATE}.csv.bz2
	LST_SCH_TVL_ALL_FILENAME=${POR_FILE_PFX2}_${LST_EXTRACT_DATE}_all.csv
	LST_SCH_TVL_MGD_FILENAME=${POR_FILE_PFX2}_${LST_EXTRACT_DATE}_merged.csv
	LST_SCH_WCTY_FILENAME=${POR_FILE_PFX3}_${LST_EXTRACT_DATE}_merged.csv
	LST_SCH_AIR_FILENAME=${POR_FILE_PFX4}_${LST_EXTRACT_DATE}.csv
fi
## Input files
#
LST_SCH_DUMP_FILE=${SCHSVC_DUMP_DIR}${LST_SCH_DUMP_FILENAME}

##
# Output files
PR_GEN_FILE=${SCHSVC_DIR}${PR_GEN_FILENAME}
PR_GEN_SORTED_FILE=${SCHSVC_DIR}${PR_GEN_SORTED_FILENAME}
PR_OUT_FILE=${SCHSVC_DIR}${PR_OUT_FILENAME}
PR_HDR_FILE=${SCHSVC_DIR}${PR_HDR_FILENAME}
#
FA_OUT_FILE=${SCHSVC_DIR}${FA_OUT_FILENAME}
FA_HDR_FILE=${SCHSVC_DIR}${FA_HDR_FILENAME}
#
LST_SCH_TVL_ALL_FILE=${SCHSVC_DIR}${LST_SCH_TVL_ALL_FILENAME}
LST_SCH_TVL_MGD_FILE=${SCHSVC_DIR}${LST_SCH_TVL_MGD_FILENAME}
LST_SCH_WCTY_FILE=${SCHSVC_DIR}${LST_SCH_WCTY_FILENAME}
LST_SCH_AIR_FILE=${SCHSVC_DIR}${LST_SCH_AIR_FILENAME}
# Temporary
LST_SCH_TVL_ALL_FILE_TMP=${LST_SCH_TVL_ALL_FILE}.tmp

##
# Sanity checks
if [ ! -f ${LST_SCH_DUMP_FILE} ]
then
	echo
	echo "[$0:$LINENO] The '${LST_SCH_DUMP_FILENAME}' cannot be found in the schedule CSV dump directory ('${SCHSVC_DUMP_DIR}')."
	echo "Hint: go into the '${SCHSVC_DUMP_DIR}' directory and convert the OAG SSIM7 file into a (compressed) CSV file, thanks to ${SCHSVC_DUMP_DIR}launch_oag_ssim7_to_csv_local.sh."
	echo
	exit -1
fi
if [ ! -f ${GEO_OPTD_FILE} ]
then
	echo
	echo "[$0:$LINENO] The '${GEO_OPTD_FILENAME}' cannot be found in the current directory ('${SCHSVC_DIR}')."
	echo "Hint: copy it from the OpenTravelData project Git clone:"
	echo "$0 --optd"
	echo
	exit -1
fi

##
# Cleaning
if [ "$1" = "--clean" ]
then
	if [ "${TMP_DIR}" = "/tmp/por" ]
	then
		\rm -rf ${TMP_DIR}
	else
		\rm -f ${SORTED_INN_WPK_FILE} ${SORTED_CUT_INN_WPK_FILE}
		\rm -f ${INN_WPK_FILE}
	fi
	exit
fi

##
#
if [ "$1" = "-h" -o "$1" = "--help" ]
then
	echo
	echo "Usage: $0 [<use_cases directory for the Schedule-service project Git clone> [<log level>]]"
	echo "  - Default use_cases directory for the Schedule-service project Git clone: '${SCHSVC_DIR}'"
	echo "  - Default path for the OPTD-maintained file of best known coordinates: '${GEO_OPTD_FILE}'"
	echo "  - Default log level: ${LOG_LEVEL}"
	echo "    + 0: No log; 1: Critical; 2: Error; 3; Notification; 4: Debug; 5: Verbose"
	echo "  - Latest extraction date retrieved so far: ${LST_EXTRACT_DATE_HUMAN}"
	echo "  - Latest schedule CSV dump file retrieved so far: ${LST_SCH_DUMP_FILE}"
	echo "  - Generated files:"
	echo "    + '${PR_GEN_FILE}'"
	echo "    + '${PR_GEN_SORTED_FILE}'"
	echo "    + '${PR_OUT_FILE}'"
	echo "    + '${FA_OUT_FILE}'"
	echo "    + '${LST_SCH_TVL_ALL_FILE}'"
	echo "    + '${LST_SCH_TVL_MGD_FILE}'"
	echo "    + '${LST_SCH_WCTY_FILE}'"
	echo
	exit
fi

# Reference
REF_WIKI_URL=https://en.wikipedia.org/wiki/PageRank

# Project
PRJ_TXT="Open Travel Data"
PRJ_URL=https://github.com/opentraveldata/opentraveldata

# License
LIC_URL=https://creativecommons.org/licenses/by-sa/3.0/deed.en_US
LIC_TXT="CC-BY-SA"

# Calculate the end date of the validity period (beginning date + 6 days)
VALID_DATE_FROM=`date -d ${LST_EXTRACT_DATE} "+%Y-%m-%d"`
VALID_DATE_UNTIL=`date --date='next Wednesday' "+%Y-%m-%d"`

##
# Scripts
EXT_SCRIPT=${SCHSVC_DIR}extract_ond_operating.sh
PR_SCRIPT=${SCHSVC_DIR}ond_pagerank.py

##
# 1. Extract the operating legs from the CSV-ified version of the OAG SSIM7
#    data files. The fields of the generated data file are:
# airline_code^origin^destination^nb_of_daily_flights_per_airline^nb_of_daily_flights_total^idx_origin^idx_destination
if [ ! -f ${LST_SCH_WCTY_FILE} ]
then
	echo "Extracting the operating legs from the CSV-ified version of the OAG SSIM7 (it may take nearly 10 minutes on multi-core machines)..."
	time sh ${EXT_SCRIPT} ${SCHSVC_DUMP_DIR} ${LST_EXTRACT_DATE}
	echo "... done"
else
	echo "The '${LST_SCH_WCTY_FILE}' already exists. So, it will not be generated again. If you want to re-generate it, just remove it: \rm -f ${LST_SCH_WCTY_FILE}"
fi

##
# 2. Calculate the PageRank vector for all the POR (airports as well as cities).
if [ ! -f ${PR_GEN_FILE} ]
then
	echo "Calculate the PageRank vector for all the POR (airports as well as cities)..."
	time python ${PR_SCRIPT} -o ${PR_GEN_FILE} ${LST_SCH_WCTY_FILE}
	sh ${EXT_SCRIPT} ${SCHSVC_DUMP_DIR} ${LST_EXTRACT_DATE} --clean
	echo "... done"
else
	echo "The '${PR_GEN_FILE}' already exists. So, it will not be generated again. If you want to re-generate it, just remove it: \rm -f ${PR_GEN_FILE}"
fi

# 3. Sort the page-ranked POR
#    -kgr3,3 means -k for the field, g for 'general numeric' ('n' does not work
#    because there may be numbers with e-05), r for 'reverse'
sort -t'^' -k3gr,3 ${PR_GEN_FILE} > ${PR_GEN_SORTED_FILE}

# Number of POR (points of reference)
PR_NB=`wc -l ${PR_GEN_SORTED_FILE} | cut -d' ' -f1`

#
cat > ${PR_HDR_FILE} << _EOF
#
# PageRank values (${REF_WIKI_URL})
# for the ${PR_NB} most important travel-related POR (points of reference).
#
# [PR] Project reference: ${PRJ_TXT} (${PRJ_URL})
# [PR] Generation date: ${SNAPSHOT_DATE}
# [PR] License: ${LIC_TXT} (${LIC_URL})
# [PR] Validity period:
# [PR]   From: ${VALID_DATE_FROM}
# [PR]   To: ${VALID_DATE_UNTIL}
#
# pk^iata_code^PageRank
_EOF
cat ${PR_HDR_FILE} ${PR_GEN_SORTED_FILE} > ${PR_OUT_FILE}
\rm -f ${PR_HDR_FILE}

##
# Reporting
echo
echo "The file of PageRank values, '${PR_OUT_FILE}', has been generated. It contains ${PR_NB} POR."
echo "You may want to alter the validity period, currently '${VALID_DATE_FROM} - ${VALID_DATE_UNTIL}': vi ${PR_OUT_FILE}"
echo "Next step: \mv ${PR_OUT_FILE} <OpenTravelData DIR>/refdata/opentraveldata/${PR_OUT_FILENAME}"
echo


##
# B. Calculate the frequencies per airline
FREQ_PAL_CTR=count_frequencies_for_airlines.awk
awk -F'^' -f ${FREQ_PAL_CTR} ${LST_SCH_TVL_ALL_FILE} > ${LST_SCH_TVL_ALL_FILE_TMP}
sort -t'^' -k2nr,2 ${LST_SCH_TVL_ALL_FILE_TMP} > ${LST_SCH_AIR_FILE}
\rm -f ${LST_SCH_TVL_ALL_FILE_TMP}

# Number of POR (points of reference)
FA_NB=`wc -l ${LST_SCH_AIR_FILE} | cut -d' ' -f1`

#
cat > ${FA_HDR_FILE} << _EOF
#
# Flight frequency values for ${FA_NB} airlines.
#
# [FA] Project reference: ${PRJ_TXT} (${PRJ_URL})
# [FA] Generation date: ${SNAPSHOT_DATE}
# [FA] License: ${LIC_TXT} (${LIC_URL})
# [FA] Validity period:
# [FA]   From: ${VALID_DATE_FROM}
# [FA]   To: ${VALID_DATE_UNTIL}
#
# airline_code_2c^flight_freq
_EOF
cat ${FA_HDR_FILE} ${LST_SCH_AIR_FILE} > ${FA_OUT_FILE}
\rm -f ${FA_HDR_FILE} ${LST_SCH_AIR_FILE}

##
# Reporting
echo
echo "The file of frequency values per airline, '${FA_OUT_FILE}', has been generated. It contains ${FA_NB} airlines."
echo "You may want to alter the validity period, currently '${VALID_DATE_FROM} - ${VALID_DATE_UNTIL}': vi ${FA_OUT_FILE}"
echo "Next step: \mv ${FA_OUT_FILE} <OpenTravelData DIR>/refdata/opentraveldata/${FA_OUT_FILENAME}"
echo
