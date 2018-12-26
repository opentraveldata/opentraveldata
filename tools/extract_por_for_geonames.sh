#!/bin/bash

# That Bash script extracts a POR from:
# - optd_por_best_known_so_far.csv
# - optd_por_no_longer_valid.csv
# - dump_from_ref_city.csv
# - dump_from_geonames.csv
# - dump_from_innovata.csv
# - ref_airport_pageranked.csv
# - por_schedule_counts_YYYY_MM_to_YYYY_MM.csv
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
# Target (generated files)
OPTD_POR_PUBLIC_FILENAME=optd_por_public.csv
#
OPTD_POR_PUBLIC_FILE=${DATA_DIR}${OPTD_POR_PUBLIC_FILENAME}

##
# iata_code (1) ^ icao_code (2) ^ faa_code (3) ^
# is_geonames (4) ^ geoname_id (5) ^
# envelope_id (6) ^ name (7) ^ asciiname (8) ^ latitude (9) ^ longitude (10) ^
# fclass (11) ^ fcode (12) ^ page_rank (13) ^
# date_from (14) ^ date_until (15) ^ comment (16) ^
# country_code (17) ^ cc2 (18) ^ country_name (19) ^ continent_name (20) ^
# adm1_code (21) ^ adm1_name_utf (22) ^ adm1_name_ascii (23) ^
# adm2_code (24) ^ adm2_name_utf (25) ^ adm2_name_ascii (26) ^
# adm3_code (27) ^ adm4_code (28) ^
# population (29) ^ elevation (30) ^ gtopo30 (31) ^
# timezone (32) ^ gmt_offset (33) ^ dst_offset (34) ^ raw_offset (35) ^
# moddate (36) ^
# city_code_list (37) ^ city_name_list (38) ^ city_detail_list (39) ^
# tvl_por_list (40) ^
# state_code (41) ^
# location_type (42) ^ wiki_link (43) ^ alt_name_section (44) ^
# wac (45) ^ wac_name (46)

####
## Valid combined Geonames POR, appearing in schedules (i.e., important)
echo "================"
echo "Valid combined Geonames POR, appearing in schedules (i.e., important)"
echo "--------"

##
# Valid combined Geonames airport POR, appearing in schedules (i.e., important)
NB_POR=`awk -F'^' '{if ($5 != 0 && $6 == "" && $13 != "" && $42 == "CA") {print $0}}' ${OPTD_POR_PUBLIC_FILE} | wc -l`
echo "${NB_POR} airports:"
echo "awk -F'^' '{if (\$5 != 0 && \$6 == \"\" && \$13 != \"\" && \$42 == \"CA\") {print \$0}}' ${OPTD_POR_PUBLIC_FILE} | sort -t'^' -k13nr,13 | less"

##
# Valid combined Geonames heliport POR, appearing in schedules (i.e., important)
NB_POR=`awk -F'^' '{if ($5 != 0 && $6 == "" && $13 != "" && $42 == "CH") {print $0}}' ${OPTD_POR_PUBLIC_FILE} | wc -l`
echo "${NB_POR} heliports:"
echo "awk -F'^' '{if (\$5 != 0 && \$6 == \"\" && \$13 != \"\" && \$42 == \"CH\") {print \$0}}' ${OPTD_POR_PUBLIC_FILE} | sort -t'^' -k13nr,13 | less"

##
# Valid combined Geonames rail POR, appearing in schedules (i.e., important)
NB_POR=`awk -F'^' '{if ($5 != 0 && $6 == "" && $13 != "" && $42 == "CR") {print $0}}' ${OPTD_POR_PUBLIC_FILE} | wc -l`
echo "${NB_POR} railway stations:"
echo "awk -F'^' '{if (\$5 != 0 && \$6 == \"\" && \$13 != \"\" && \$42 == \"CR\") {print \$0}}' ${OPTD_POR_PUBLIC_FILE} | sort -t'^' -k13nr,13 | less"

##
# Valid combined Geonames bus POR, appearing in schedules (i.e., important)
NB_POR=`awk -F'^' '{if ($5 != 0 && $6 == "" && $13 != "" && $42 == "CB") {print $0}}' ${OPTD_POR_PUBLIC_FILE} | wc -l`
echo "${NB_POR} bus stations:"
echo "awk -F'^' '{if (\$5 != 0 && \$6 == \"\" && \$13 != \"\" && \$42 == \"CB\") {print \$0}}' ${OPTD_POR_PUBLIC_FILE} | sort -t'^' -k13nr,13 | less"

##
# Valid combined Geonames port POR, appearing in schedules (i.e., important)
NB_POR=`awk -F'^' '{if ($5 != 0 && $6 == "" && $13 != "" && $42 == "CP") {print $0}}' ${OPTD_POR_PUBLIC_FILE} | wc -l`
echo "${NB_POR} ferry ports:"
echo "awk -F'^' '{if (\$5 != 0 && \$6 == \"\" && \$13 != \"\" && \$42 == \"CP\") {print \$0}}' ${OPTD_POR_PUBLIC_FILE} | sort -t'^' -k13nr,13 | less"


####
# Valid combined non-Geonames POR, appearing in schedules (i.e., important)
echo
echo "================"
echo "Valid combined non-Geonames POR, appearing in schedules (i.e., important)"
echo "--------"

##
# Valid combined non-Geonames airport POR, appearing in schedules (i.e., important)
NB_POR=`awk -F'^' '{if ($5 == 0 && $6 == "" && $13 != "" && $42 == "CA") {print $0}}' ${OPTD_POR_PUBLIC_FILE} | wc -l`
echo "${NB_POR} airports:"
echo "awk -F'^' '{if (\$5 == 0 && \$6 == \"\" && \$13 != \"\" && \$42 == \"CA\") {print \$0}}' ${OPTD_POR_PUBLIC_FILE} | less"

##
# Valid combined non-Geonames heliport POR, appearing in schedules (i.e., important)
NB_POR=`awk -F'^' '{if ($5 == 0 && $6 == "" && $13 != "" && $42 == "CH") {print $0}}' ${OPTD_POR_PUBLIC_FILE} | wc -l`
echo "${NB_POR} heliports:"
echo "awk -F'^' '{if (\$5 == 0 && \$6 == \"\" && \$13 != \"\" && \$42 == \"CH\") {print \$0}}' ${OPTD_POR_PUBLIC_FILE} | less"

##
# Valid combined non-Geonames rail POR, appearing in schedules (i.e., important)
NB_POR=`awk -F'^' '{if ($5 == 0 && $6 == "" && $13 != "" && $42 == "CR") {print $0}}' ${OPTD_POR_PUBLIC_FILE} | wc -l`
echo "${NB_POR} railway stations:"
echo "awk -F'^' '{if (\$5 == 0 && \$6 == \"\" && \$13 != \"\" && \$42 == \"CR\") {print \$0}}' ${OPTD_POR_PUBLIC_FILE} | less"

##
# Valid combined non-Geonames bus POR, appearing in schedules (i.e., important)
NB_POR=`awk -F'^' '{if ($5 == 0 && $6 == "" && $13 != "" && $42 == "CB") {print $0}}' ${OPTD_POR_PUBLIC_FILE} | wc -l`
echo "${NB_POR} bus stations:"
echo "awk -F'^' '{if (\$5 == 0 && \$6 == \"\" && \$13 != \"\" && \$42 == \"CB\") {print \$0}}' ${OPTD_POR_PUBLIC_FILE} | less"

##
# Valid combined non-Geonames port POR, appearing in schedules (i.e., important)
NB_POR=`awk -F'^' '{if ($5 == 0 && $6 == "" && $13 != "" && $42 == "CP") {print $0}}' ${OPTD_POR_PUBLIC_FILE} | wc -l`
echo "${NB_POR} ferry ports:"
echo "awk -F'^' '{if (\$5 == 0 && \$6 == \"\" && \$13 != \"\" && \$42 == \"CP\") {print \$0}}' ${OPTD_POR_PUBLIC_FILE} | less"


####
# Valid non-Geonames POR, appearing in schedules (i.e., important)
echo
echo "================"
echo "Valid non-Geonames POR, appearing in schedules (i.e., important)"
echo "--------"

##
# Valid non-Geonames off-line point POR, appearing in schedules (i.e., important)
NB_POR=`awk -F'^' '{if ($5 == 0 && $6 == "" && $13 != "" && match ($42, "O")) {print $0}}' ${OPTD_POR_PUBLIC_FILE} | wc -l`
echo "${NB_POR} off-line points:"
echo "awk -F'^' '{if (\$5 == 0 && \$6 == \"\" && \$13 != \"\" && match (\$42, \"O\")) {print \$0}}' ${OPTD_POR_PUBLIC_FILE} | less"

##
# Valid non-Geonames airport POR, appearing in schedules (i.e., important)
NB_POR=`awk -F'^' '{if ($5 == 0 && $6 == "" && $13 != "" && match ($42, "A")) {print $0}}' ${OPTD_POR_PUBLIC_FILE} | wc -l`
echo "${NB_POR} airports:"
echo "awk -F'^' '{if (\$5 == 0 && \$6 == \"\" && \$13 != \"\" && match (\$42, \"A\")) {print \$0}}' ${OPTD_POR_PUBLIC_FILE} | less"

##
# Valid non-Geonames heliport POR, appearing in schedules (i.e., important)
NB_POR=`awk -F'^' '{if ($5 == 0 && $6 == "" && $13 != "" && match ($42, "H")) {print $0}}' ${OPTD_POR_PUBLIC_FILE} | wc -l`
echo "${NB_POR} heliports:"
echo "awk -F'^' '{if (\$5 == 0 && \$6 == \"\" && \$13 != \"\" && match (\$42, \"H\")) {print \$0}}' ${OPTD_POR_PUBLIC_FILE} | less"

##
# Valid non-Geonames rail POR, appearing in schedules (i.e., important)
NB_POR=`awk -F'^' '{if ($5 == 0 && $6 == "" && $13 != "" && match ($42, "R")) {print $0}}' ${OPTD_POR_PUBLIC_FILE} | wc -l`
echo "${NB_POR} railway stations:"
echo "awk -F'^' '{if (\$5 == 0 && \$6 == \"\" && \$13 != \"\" && match (\$42, \"R\")) {print \$0}}' ${OPTD_POR_PUBLIC_FILE} | less"

##
# Valid non-Geonames bus POR, appearing in schedules (i.e., important)
NB_POR=`awk -F'^' '{if ($5 == 0 && $6 == "" && $13 != "" && match ($42, "B")) {print $0}}' ${OPTD_POR_PUBLIC_FILE} | wc -l`
echo "${NB_POR} bus stations:"
echo "awk -F'^' '{if (\$5 == 0 && \$6 == \"\" && \$13 != \"\" && match (\$42, \"B\")) {print \$0}}' ${OPTD_POR_PUBLIC_FILE} | less"

##
# Valid non-Geonames port POR, appearing in schedules (i.e., important)
NB_POR=`awk -F'^' '{if ($5 == 0 && $6 == "" && $13 != "" && match ($42, "P")) {print $0}}' ${OPTD_POR_PUBLIC_FILE} | wc -l`
echo "${NB_POR} ferry ports:"
echo "awk -F'^' '{if (\$5 == 0 && \$6 == \"\" && \$13 != \"\" && match (\$42, \"P\")) {print \$0}}' ${OPTD_POR_PUBLIC_FILE} | less"

