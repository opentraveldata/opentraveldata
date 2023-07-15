#!/bin/bash

#
# OpenTravelData (OPTD) utility
# Git repository:
#   https://github.com/opentraveldata/opentraveldata/tree/master/tools
#

##
# GNU tools, including on MacOS
source setGnuTools.sh || exit -1

##
# Directories
source setDirs.sh "$0" || exit -1

##
# Snapshot date
SNAPSHOT_DATE="$(${DATE_TOOL} +%Y%m%d)"
SNAPSHOT_DATE_HUMAN="$(${DATE_TOOL})"

##
# OpenTravelData directory
OPTD_DIR="$(dirname ${EXEC_FULL_PATH})"
OPTD_DIR="${OPTD_DIR}/"

##
# OPTD sub-directory
DATA_DIR="${OPTD_DIR}opentraveldata/"
TOOLS_DIR="${OPTD_DIR}tools/"

##
# List of state codes for a few countries (e.g., US, CA, AU, AR, BR)
OPTD_CTRY_STATE_FILENAME="optd_country_states.csv"
OPTD_CTRY_STATE_FILE="${DATA_DIR}${OPTD_CTRY_STATE_FILENAME}"

##
# Retrieve the latest file
POR_FILE_PFX="por_intorg"
POR_ALL_FILE_PFX="por_all"
SNPSHT_DATE="$(ls ${TOOLS_DIR}${POR_FILE_PFX}_????????.csv 2> /dev/null)"
if [ "${SNPSHT_DATE}" != "" ]
then
        # (Trick to) Extract the latest entry
        for myfile in ${SNPSHT_DATE}
	do
		echo > /dev/null
	done
	SNPSHT_DATE="$(echo ${myfile} | ${SED_TOOL} -E "s/${POR_FILE_PFX}_([0-9]+)\.csv/\1/" | xargs basename)"
else
        echo
        echo "[$0:$LINENO] No non-IATA POR list CSV dump can be found in the '${TOOLS_DIR}' directory."
        echo "Expecting a file named like '${TOOLS_DIR}${POR_FILE_PFX}_YYYYMMDD.csv'"
        echo
        exit -1
fi

#
SNPSHT_DATE_HUMAN="$(${DATE_TOOL} -d ${SNPSHT_DATE})"
POR_INTORG_FILE="${POR_FILE_PFX}_${SNPSHT_DATE}.csv"
POR_ALL_FILE="${POR_ALL_FILE_PFX}_${SNPSHT_DATE}.csv"
TGT_FILE="${DATA_DIR}optd_por_unlc.csv"
TMP_TGT_FILE="${TGT_FILE}.tmp"
STD_TGT_FILE="${TGT_FILE}.std"
HDR_TGT_FILE="${TGT_FILE}.hdr"

# Processing
PROCESSOR="extract_por_unlc.awk"
time ${AWK_TOOL} -F'^' -f ${PROCESSOR} ${OPTD_CTRY_STATE_FILE} \
     ${POR_INTORG_FILE} ${POR_ALL_FILE} > ${TMP_TGT_FILE}
sort -t'^' -k1,1 ${TMP_TGT_FILE} | uniq > ${STD_TGT_FILE}
echo "unlocode^latitude^longitude^geonames_id^iso31662_code^iso31662_name^feat_class^feat_code" \
	 > ${HDR_TGT_FILE}
cat ${HDR_TGT_FILE} ${STD_TGT_FILE} > ${TGT_FILE}

# Cleaning
\rm -f ${TMP_TGT_FILE} ${HDR_TGT_FILE} ${STD_TGT_FILE}

# Reporting
NB_POR="$(wc -l ${TGT_FILE} | ${SED_TOOL} -E 's/^([^0-9]*)([0-9]+)([^0-9])*$/\2/g')"
echo
echo "The UN/LOCODE POR file ('${TGT_FILE}') has been generated from" \
	 "'${POR_INTORG_FILE}' and '${POR_ALL_FILE}'"
echo "There are ${NB_POR} records"
echo

