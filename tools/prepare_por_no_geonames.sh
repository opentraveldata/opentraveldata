#!/bin/bash

#
# OpenTravelData (OPTD) utility
# Git repository:
#   https://github.com/opentraveldata/opentraveldata/tree/master/tools
#

#
# One parameter is optional for this script:
# - the file-path of the dump file extracted from the reference data.
#
# Create the OPTD-maintained list of POR absent from Geonames, from:
# - optd_por_best_known_so_far.csv
# - ref_airport_pageranked.csv
# - optd_por_exceptions.csv
# - optd_tz_light.csv
# - optd_por_tz.csv
# - optd_countries.csv
# - optd_cont.csv
# - optd_usdot_wac.csv
# - dump_from_ref_city.csv
#
# => optd_por_no_geonames.csv and optd_por_tz_wrong.csv

##
# GNU tools, including on MacOS
source setGnuTools.sh || exit -1

##
# Directories
source setDirs.sh "$0" || exit -1

##
# OpenTravelData directory
OPTD_DIR="$(dirname ${EXEC_FULL_PATH})"
OPTD_DIR="${OPTD_DIR}/"

##
# OPTD sub-directories
DATA_DIR="${OPTD_DIR}opentraveldata/"
TOOLS_DIR="${OPTD_DIR}tools/"
REF_DIR="${TOOLS_DIR}"

##
# Log level
LOG_LEVEL=4

#
displayRefDetails() {
    ##
    # Snapshot date
	SNAPSHOT_DATE=`$DATE_TOOL "+%Y%m%d"`
	SNAPSHOT_DATE_HUMAN=`$DATE_TOOL`
	echo
	echo "####### Note #######"
	echo "# The data dump from reference data can be obtained from this project"
	echo "# (https://bitbucket.org/AmadeusTI/data-analysis-general.git)."
	echo "For instance:"
	echo "DAREF=~/dev/dataanalysis/dataanalysisgit/data_generation"
	echo "mkdir -p ~/dev/dataanalysis"
	echo "cd ~/dev/dataanalysis"
	echo "git clone git@bitbucket.org:AmadeusTI/data-analysis-general.git dataanalysisgit"
	echo "cd \${DAREF}/REF"
	echo "# The following script fetches a SQLite file, holding reference data,"
	echo "# and translates it into three MySQL-compatible SQL files:"
	echo "./fetch_sqlite_ref.sh # it may take several minutes"
	echo "# It produces three create_*_ref_*${SNAPSHOT_DATE}.sql files, which are then"
	echo "# used by the following script, in order to load the reference data into MySQL:"
	echo "./create_ref_user.sh"
	echo "./create_ref_db.sh"
	echo "./create_all_tables.sh ref ref_ref ${SNAPSHOT_DATE} localhost"
	if [ "${TMP_DIR}" = "/tmp/por/" ]
	then
		echo "mkdir -p ${TMP_DIR}"
	fi
	echo "cd ${MYCURDIR}"
	echo "# The POR database table has then to be exported into a CSV file."
	echo "\${DAREF}/por/extract_ref_por.sh ref ref_ref localhost"
	echo "\cp -f ${TMP_DIR}por_all_ref_${SNAPSHOT_DATE}.csv ${TMP_DIR}dump_from_ref_city.csv"
	echo "\cp -f ${OPTDDIR}/opentraveldata/optd_por_best_known_so_far.csv ${TMP_DIR}"
	echo "\cp -f ${OPTDDIR}/opentraveldata/ref_airport_pageranked.csv ${TMP_DIR}"
	echo "\cp -f ${OPTDDIR}/opentraveldata/optd_por.csv ${TMP_DIR}optd_airports.csv"
	echo "\${DAREF}/update_airports_csv_after_getting_ref_city_dump.sh"
	echo "ls -l ${TMP_DIR}"
	echo "#####################"
	echo
}

##
# REF (to be found, as temporary files, within the ../tools directory)
GEO_REF_FILENAME="dump_from_ref_city.csv"

##
# File of best known coordinates
OPTD_POR_FILENAME="optd_por_best_known_so_far.csv"

##
# File of exceptions for POR, referencing known issues
# For instance, when the POR is still referenced but no longer valid
OPTD_REF_DPCTD_FILENAME="optd_por_exceptions.csv"

##
# PageRank values
OPTD_PR_FILENAME="ref_airport_pageranked.csv"

##
# Light (and inaccurate) version of the country-related time-zones
OPTD_TZ_CNT_FILENAME="optd_tz_light.csv"
# Time-zones derived from the closest city in Geonames: more accurate,
# only when the geographical coordinates are themselves accurate of course
OPTD_TZ_POR_FILENAME="optd_por_tz.csv"

##
# List of country details
OPTD_CTRY_DTLS_FILENAME="optd_countries.csv"

##
# Mapping between the Countries and their corresponding continent
OPTD_CNT_FILENAME="optd_cont.csv"

##
# US DOT World Area Codes (WAC) for countries and states
OPTD_USDOT_FILENAME="optd_usdot_wac.csv"

##
# Output file names
REF_NO_GEO_FILENAME="optd_por_no_geonames.csv"
OPTD_POR_WRONG_TZ_FILENAME="optd_por_tz_wrong.csv"

##
# Input files
GEO_REF_FILE="${TOOLS_DIR}${GEO_REF_FILENAME}"
OPTD_POR_FILE="${DATA_DIR}${OPTD_POR_FILENAME}"
OPTD_REF_DPCTD_FILE="${DATA_DIR}${OPTD_REF_DPCTD_FILENAME}"
OPTD_PR_FILE="${DATA_DIR}${OPTD_PR_FILENAME}"
OPTD_TZ_CNT_FILE="${DATA_DIR}${OPTD_TZ_CNT_FILENAME}"
OPTD_TZ_POR_FILE="${DATA_DIR}${OPTD_TZ_POR_FILENAME}"
OPTD_CTRY_DTLS_FILE="${DATA_DIR}${OPTD_CTRY_DTLS_FILENAME}"
OPTD_CNT_FILE="${DATA_DIR}${OPTD_CNT_FILENAME}"
OPTD_USDOT_FILE="${DATA_DIR}${OPTD_USDOT_FILENAME}"

##
# Output files
REF_NO_GEO_FILE="${DATA_DIR}${REF_NO_GEO_FILENAME}"
OPTD_POR_WRONG_TZ_FILE="${DATA_DIR}${OPTD_POR_WRONG_TZ_FILENAME}"

##
# Temporary
REF_NO_GEO_WO_CTY_NAME_FILE="${OPTD_POR_FILE}.withnoctyname"


##
# Cleaning
if [ "$1" = "--clean" ]
then
    if [ "${TMP_DIR}" = "/tmp/por" ]
    then
		\rm -rf ${TMP_DIR}
    else
		\rm -f ${REF_NO_GEO_WO_CTY_NAME_FILE}
    fi
    exit
fi


##
#
if [ "$1" = "-h" -o "$1" = "--help" ]
then
    echo
	echo "Usage: $0 [<root directory of the OpenTravelData (OPTD) project " \
		 "Git clone> [<Reference data directory for data dump files> " \
		 "[<log level>]]]"
	echo
	echo " - Default log level: ${LOG_LEVEL}"
	echo "   + 0: No log; 1: Critical; 2: Error; 3; Notification; 4: Debug; " \
		 "5: Verbose"
	echo
	echo " - Default root directory for the OPTD project Git clone: " \
		 "'${OPTD_DIR}'"
	echo " - Default directory for the reference data file: '${REF_DIR}'"
	echo
	echo "* Input data files"
	echo "------------------"
	echo " - OPTD-maintained file of best known coordinates: '${OPTD_POR_FILE}'"
	echo " - OPTD-maintained file of exceptions: '${OPTD_REF_DPCTD_FILE}'"
	echo " - OPTD-maintained file of PageRanked POR: '${OPTD_PR_FILE}'"
	echo " - OPTD-maintained file of country-related time-zones: " \
		 "'${OPTD_TZ_CNT_FILE}'"
	echo " - OPTD-maintained file of POR-related time-zones: " \
		 "'${OPTD_TZ_POR_FILE}'"
	echo " - OPTD-maintained file of country details: '${OPTD_CTRY_DTLS_FILE}'"
	echo " - OPTD-maintained file of country-continent mapping: " \
		 "'${OPTD_CNT_FILE}'"
	echo " - OPTD-maintained file of US DOT World Area Codes (WAC): " \
		 "'${OPTD_USDOT_FILE}'"

	echo " - Reference data file: '${GEO_REF_FILE}'"
	echo
	echo "* Output data file"
	echo "------------------"
	echo " - OPTD-maintained list of non-IATA/outlier POR: '${REF_NO_GEO_FILE}'"
	echo " - OPTD-maintained list of POR with wrong time-zones: " \
		 "'${OPTD_POR_WRONG_TZ_FILE}'"
    echo
    exit
fi

##
# The OpenTravelData opentraveldata/ sub-directory contains, among other things,
# the OPTD-maintained list of POR file with geographical coordinates.
if [ "$1" != "" ]
then
    if [ ! -d $1 ]
    then
		echo
		echo "[$0:$LINENO] The first parameter ('$1') should point to " \
			 "the root directory of the OpenTravelData project Git clone. " \
			 "It is not accessible here."
		echo
		exit -1
    fi
    OPTD_DIR="$1/"
    DATA_DIR="${OPTD_DIR}opentraveldata/"
    TOOLS_DIR="${OPTD_DIR}tools/"
	REF_DIR="${TOOLS_DIR}"
	REF_NO_GEO_FILE="${DATA_DIR}${REF_NO_GEO_FILENAME}"
	OPTD_POR_WRONG_TZ_FILE="${DATA_DIR}${OPTD_POR_WRONG_TZ_FILENAME}"
	GEO_REF_FILE="${TOOLS_DIR}${GEO_REF_FILENAME}"
	OPTD_POR_FILE="${DATA_DIR}${OPTD_POR_FILENAME}"
	OPTD_REF_DPCTD_FILE="${DATA_DIR}${OPTD_REF_DPCTD_FILENAME}"
	OPTD_PR_FILE="${DATA_DIR}${OPTD_PR_FILENAME}"
	OPTD_TZ_CNT_FILE="${DATA_DIR}${OPTD_TZ_CNT_FILENAME}"
	OPTD_TZ_POR_FILE="${DATA_DIR}${OPTD_TZ_POR_FILENAME}"
	OPTD_CTRY_DTLS_FILE="${DATA_DIR}${OPTD_CTRY_DTLS_FILENAME}"
	OPTD_CNT_FILE="${DATA_DIR}${OPTD_CNT_FILENAME}"
	OPTD_USDOT_FILE="${DATA_DIR}${OPTD_USDOT_FILENAME}"
fi

##
# Reference data file with geographical coordinates
if [ "$2" != "" ]
then
	REF_DIR="$2"
	GEO_REF_FILE="${REF_DIR}${GEO_REF_FILENAME}"
	if [ "${GEO_REF_FILE}" = "${GEO_REF_FILENAME}" ]
	then
		GEO_REF_FILE="${TMP_DIR}${GEO_REF_FILE}"
	fi
fi

if [ ! -f "${GEO_REF_FILE}" ]
then
	echo
	echo "[$0:$LINENO] The '${GEO_REF_FILE}' file does not exist."
	echo
	if [ "$2" = "" ]
	then
		displayRefDetails
	fi
	exit -1
fi


##
# Log level
if [ "$3" != "" ]
then
    LOG_LEVEL="$3"
fi


##
# Generate a second version of the file with the OPTD primary key
# (integrating the location type)
REF_NO_GEO_EXTRACTOR="${TOOLS_DIR}extract_non_geonames_por.awk"
awk -F'^' -v log_level=${LOG_LEVEL} \
	-v optd_por_wrong_tz_file="${OPTD_POR_WRONG_TZ_FILE}" \
	-f ${REF_NO_GEO_EXTRACTOR} \
    ${OPTD_REF_DPCTD_FILE} ${OPTD_POR_FILE} ${OPTD_CTRY_DTLS_FILE} \
	${OPTD_PR_FILE} ${OPTD_TZ_CNT_FILE} ${OPTD_TZ_POR_FILE} \
	${OPTD_CNT_FILE} ${OPTD_USDOT_FILE} \
	${GEO_REF_FILE} > ${REF_NO_GEO_WO_CTY_NAME_FILE}


##
# Write the UTF8 and ASCII names of the city served by every travel-related
# point of reference (POR).
echo
echo "City addition Step"
echo "------------------"
echo
CITY_WRITER="add_city_name.awk"
time awk -F'^' -f ${CITY_WRITER} \
	${REF_NO_GEO_WO_CTY_NAME_FILE} ${REF_NO_GEO_WO_CTY_NAME_FILE} \
	> ${REF_NO_GEO_FILE}


##
# Reporting
echo
echo "Preparation step"
echo "----------------"
echo "The '${REF_NO_GEO_FILE}' file has been derived from '${GEO_REF_FILE}'."
echo "Hint for next step:"
echo "# 0. Purge the temporary files generated by this script ($0)"
echo "$0 --clean"
echo "# 1. Check and commit the changes on the ${REF_NO_GEO_FILENAME} file"
echo "git diff ${REF_NO_GEO_FILE} # git add ${REF_NO_GEO_FILE}"
echo "# 2. Re-generate the OPTD POR data files"
echo "./make_optd_por_public.sh && ./make_optd_por_public.sh --clean"
echo
