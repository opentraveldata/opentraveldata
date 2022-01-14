#!/bin/bash

#
# OpenTravelData (OPTD) utility
# Git repository:
#   https://github.com/opentraveldata/opentraveldata/tree/master/tools
#

#
# Three parameters are needed:
# - The path (directory) of the (compressed) CSV-ified schedule data file,
#   resulting from the pre-processing by the
#   ../ssim7_to_csv/launch_oag_ssim7_to_csv.sh script.
#   That (compressed) CSV-ified data file should be named like
#   oag_schedule_YYMMDD.csv.bz2.
# - The date of the snapshot of the schedule data file. That date should
#   corresponding to the schedule file and be like YYMMDD.
#

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

##
# Snapshot date
SNAPSHOT_DATE="$(${DATE_TOOL} +%y%m%d)"
SNAPSHOT_DATE_HUMAN="$(${DATE_TOOL})"

##
# Operating airline (owner of the schedule)
AIRLINE_CODE="ALL"

##
# OPTD-maintained list of POR (from which the airport-city relationship
# is derived)
OPTD_POR_FILENAME="optd_por_best_known_so_far.csv"
OPTD_AIR_POR_FILENAME="optd_airline_por.csv"
SORTED_OPTD_POR_FILE="sorted_${OPTD_POR_FILENAME}"
SORTED_CUT_OPTD_POR_FILE="cut_sorted_${OPTD_POR_FILENAME}"
#
OPTD_POR_FILE="${DATA_DIR}${OPTD_POR_FILENAME}"
OPTD_AIR_POR_FILE="${DATA_DIR}/${OPTD_AIR_POR_FILENAME}"

##
# Path of the schedule data store
OPTD_SCHEDULE_PATH="${HOME}/data/schedules/reconciled"
SCH_FILE_PFX1="all_catalog_"
SCH_FILE_PFX2="oag_schedule_"

##
# Output CSV data files
CSV_OUT_APT_PREFIX="oag_schedule_opt_"
CSV_OUT_ALL_PREFIX="oag_schedule_with_cities_"


##
# Usage
#
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<Schedule directory> [<Snapshot date (format: YYMMDD)>]]"
	echo "  - Default schedule directory: '${OPTD_SCHEDULE_PATH}'"
	echo "  - Snapshot date: '${SNAPSHOT_DATE}' (${SNAPSHOT_DATE_HUMAN})"
	echo "  - Default OPTD-maintained file: '${OPTD_POR_FILE}'"
	echo "  - Generated (CSV-formatted) data file prefix for airports: ${CSV_OUT_APT_PREFIX}"
	echo "  - Generated (CSV-formatted) data file prefix for all POR: ${CSV_OUT_ALL_PREFIX}"
	echo
	exit -1
fi

##
# Data dump file with geographical coordinates
if [ "$1" != "" -a "$1" != "--clean" ]
then
	OPTD_SCHEDULE_PATH="$1"
fi

##
# Sanity check
if [ ! -d ${OPTD_SCHEDULE_PATH} ]
then
	echo
	echo "The OPTD data store directory ('${OPTD_SCHEDULE_PATH}'), dedicated OAG processed schedules, does not exist. Please set up an existing directory."
	echo
	exit -1
fi

# Read the extract date from the command-line option, if any
if [ "$2" != "" -a "$2" != "--clean" ]
then
	SNAPSHOT_DATE="$2"
fi

##
# Retrieve the latest schedule file
LATEST_EXTRACT_DATA=$(ls ${OPTD_SCHEDULE_PATH} | \
						  grep "${SCH_FILE_PFX1}" | \
						  tail -1 | \
						  ${SED_TOOL} -E "s/${SCH_FILE_PFX1}([0-9]+)\.txt/\1/")
if [ "${LATEST_EXTRACT_DATA}" = "" ]
then
	LATEST_EXTRACT_DATA=$(ls ${OPTD_SCHEDULE_PATH} | \
							  grep "${SCH_FILE_PFX2}" | \
							  tail -1 | \
							  ${SED_TOOL} -E "s/${SCH_FILE_PFX2}([0-9]+)\.csv\.bz2/\1/")
fi

##
# Input OAG CSV data files
CSV_SCH_FILENAME1="${SCH_FILE_PFX1}${SNAPSHOT_DATE}.txt"
CSV_SCH_FILE1="${OPTD_SCHEDULE_PATH}/${CSV_SCH_FILENAME1}"
CSV_SCH_FILENAME2="${SCH_FILE_PFX2}${SNAPSHOT_DATE}.csv.bz2"
CSV_SCH_FILE2="${OPTD_SCHEDULE_PATH}/${CSV_SCH_FILENAME2}"

##
# Output file with only the airports, per airline
AIRLINE_LOWER="$(echo "${AIRLINE_CODE}" | tr '[:upper:]' '[:lower:]')"
CSV_OUT_APT_PAL_FILENAME="${CSV_OUT_APT_PREFIX}${SNAPSHOT_DATE}_${AIRLINE_LOWER}.csv"
CSV_OUT_APT_PAL_FILE="${TMP_DIR}${CSV_OUT_APT_PAL_FILENAME}"
SPE_CSV_OUT_APT_PAL_FILE="${CSV_OUT_APT_PAL_FILE}.cut"
CSV_OUT_APT_PAL_FILE_TMP="${CSV_OUT_APT_PAL_FILE}.tmp"
CSV_OUT_APT_PAL_FILE_TMP2="${CSV_OUT_APT_PAL_FILE}.tmp2"

##
# Output file with all the POR (airports and cities), per airline
CSV_OUT_ALL_PAL_FILENAME="${CSV_OUT_ALL_PREFIX}${SNAPSHOT_DATE}_${AIRLINE_LOWER}.csv"
CSV_OUT_ALL_PAL_FILE="${TMP_DIR}${CSV_OUT_ALL_PAL_FILENAME}"
SPE_CSV_OUT_ALL_PAL_FILE="${CSV_OUT_ALL_PAL_FILE}.cut"
CSV_OUT_ALL_PAL_FILE_TMP="${CSV_OUT_ALL_PAL_FILE}.tmp"
CSV_OUT_ALL_CTED_FILE_TMP="${CSV_OUT_ALL_PAL_FILE}.tmp.cted"

##
# Output file with only the airports, merged
CSV_OUT_APT_MGD_FILENAME="${CSV_OUT_APT_PREFIX}${SNAPSHOT_DATE}_merged.csv"
CSV_OUT_APT_MGD_FILE="${TMP_DIR}${CSV_OUT_APT_MGD_FILENAME}"
CSV_OUT_APT_MGD_FILE_TMP="${CSV_OUT_APT_MGD_FILE}.tmp"
CSV_OUT_APT_MGD_FILE_TMP2="${CSV_OUT_APT_MGD_FILE}.tmp2"
CSV_OUT_APT_MGD_FILE_TMP3="${CSV_OUT_APT_MGD_FILE}.tmp3"

##
# Output file with all the POR (airports and cities), merged
CSV_OUT_ALL_MGD_FILENAME="${CSV_OUT_ALL_PREFIX}${SNAPSHOT_DATE}_merged.csv"
CSV_OUT_ALL_MGD_FILE="${TMP_DIR}${CSV_OUT_ALL_MGD_FILENAME}"
CSV_OUT_ALL_MGD_FILE_TMP="${CSV_OUT_ALL_MGD_FILE}.tmp"
CSV_OUT_ALL_MGD_FILE_TMP2="${CSV_OUT_ALL_MGD_FILE}.tmp2"
CSV_OUT_ALL_MGD_FILE_TMP3="${CSV_OUT_ALL_MGD_FILE}.tmp3"


##
# Clean
#
if [ "$1" = "--clean" -o "$2" = "--clean" -o "$3" = "--clean" ]
then
	if [ "${TMP_DIR}" != "/tmp/por/" ]
	then
		if [ ! -f ${CSV_SCH_FILE1} -a ! -f ${CSV_SCH_FILE2} ]
		then
			SNAPSHOT_DATE="${LATEST_EXTRACT_DATA}"
			CSV_OUT_ALL_PAL_FILE="${TMP_DIR}${CSV_OUT_ALL_PREFIX}${SNAPSHOT_DATE}.csv"
			SPE_CSV_OUT_ALL_PAL_FILE="${CSV_OUT_ALL_PAL_FILE}.cut"
			CSV_OUT_ALL_PAL_FILE_TMP="${CSV_OUT_ALL_PAL_FILE}.tmp"
			CSV_OUT_ALL_CTED_FILE_TMP="${CSV_OUT_ALL_PAL_FILE}.tmp.cted"
		fi
		\rm -f ${CSV_OUT_APT_PAL_FILE_TMP} ${CSV_OUT_APT_PAL_FILE_TMP2}
		\rm -f ${CSV_OUT_ALL_PAL_FILE_TMP} ${CSV_OUT_ALL_CTED_FILE_TMP}
		\rm -f ${SPE_CSV_OUT_APT_PAL_FILE} ${SPE_CSV_OUT_ALL_PAL_FILE}
		\rm -f ${SORTED_OPTD_POR_FILE} ${SORTED_CUT_OPTD_POR_FILE}
		\rm -f ${CSV_OUT_APT_MGD_FILE_TMP} ${CSV_OUT_ALL_MGD_FILE_TMP}
		\rm -f ${CSV_OUT_APT_MGD_FILE_TMP2} ${CSV_OUT_ALL_MGD_FILE_TMP2}
		\rm -f ${CSV_OUT_APT_MGD_FILE_TMP3} ${CSV_OUT_ALL_MGD_FILE_TMP3}
	else
		echo "\rm -rf ${TMP_DIR}"
	fi
	exit 0
fi

##
# Sanity check
#
if [ ! -f ${CSV_SCH_FILE1} -a ! -f ${CSV_SCH_FILE2} ]
then
	echo
	echo "Neither the '${CSV_SCH_FILENAME1}' nor the '${CSV_SCH_FILENAME2}' schedule files exist."
	echo "Please check the OAG CSV data file directory ('${OPTD_SCHEDULE_PATH}') for the latest processed schedule files."
	if [ ! -z "${LATEST_EXTRACT_DATA}" ]
	then
		echo "Apparently, ${LATEST_EXTRACT_DATA} seems to be the latest extraction date."
	fi
	echo
	exit -1
fi

##
# Take the input file as being the first existing among ${CSV_SCH_FILE1}
# and ${CSV_SCH_FILE2}.
#
CSV_SCH_FILE="${CSV_SCH_FILE1}"
if [ ! -f ${CSV_SCH_FILE} ]
then
	CSV_SCH_FILE="${CSV_SCH_FILE2}"
fi

##
# Sanity check
#
if [ ! -f ${CSV_SCH_FILE} ]
then
	echo
	echo "For any reason, the '${CSV_SCH_FILE}' file does not exist."
	echo "Check the code ($0)."
	echo
	exit -1
fi


##
# Extract the operating legs for the given airline
#
# Sample output lines:
# AA^JFK^LAX
# BA^JFK^LHR
#
OPT_EXTRACTER="${EXEC_PATH}opt_extracter.awk"
bzcat ${CSV_SCH_FILE} | awk -F'^' -f ${OPT_EXTRACTER} \
							> ${SPE_CSV_OUT_APT_PAL_FILE}
sort -t'^' -k1,3 ${SPE_CSV_OUT_APT_PAL_FILE} > ${CSV_OUT_APT_PAL_FILE_TMP}

##
# Count the frequencies for the file of airports only
# Input file: ${CSV_OUT_APT_PAL_FILE_TMP} (./oag_schedule_opt_130221_all.csv.tmp)
#
# Sample output lines:
# AM^ATL^MEX^333^333^4^2
# AM^MEX^ATL^333^333^2^4
#
FREQ_COUNTER="${EXEC_PATH}count_frequencies.awk"
awk -F'^' -f ${FREQ_COUNTER} ${CSV_OUT_APT_PAL_FILE_TMP} \
	> ${CSV_OUT_APT_PAL_FILE_TMP2}
sort -t'^' -k1,3 ${CSV_OUT_APT_PAL_FILE_TMP2} > ${CSV_OUT_APT_PAL_FILE}

##
#
OPTD_AIR_POR_FILE_TMP=${OPTD_AIR_POR_FILE}.unstd
OPTD_AIR_POR_FILE_TMP2=${OPTD_AIR_POR_FILE}.wohd
OPTD_AIR_POR_FILE_HDR=${OPTD_AIR_POR_FILE}.hdr
cut -d'^' -f1-4 ${CSV_OUT_APT_PAL_FILE} > ${OPTD_AIR_POR_FILE_TMP}
sort -t'^' -k1,3 ${OPTD_AIR_POR_FILE_TMP} > ${OPTD_AIR_POR_FILE_TMP2}
echo "airline_code^apt_org^apt_dst^flt_freq" > ${OPTD_AIR_POR_FILE_HDR}
cat ${OPTD_AIR_POR_FILE_HDR} ${OPTD_AIR_POR_FILE_TMP2} > ${OPTD_AIR_POR_FILE}
\rm -f ${OPTD_AIR_POR_FILE_TMP} ${OPTD_AIR_POR_FILE_TMP2} ${OPTD_AIR_POR_FILE_HDR}

##
# Reporting
echo
echo "Generated ${OPTD_AIR_POR_FILE}"
echo

##
# Add the cities
#
# Sample output lines:
#   AM^ATL^C^MEX^A^333^333
#   AM^TRC^CA^MEX^A^1246^1246
#   AM^MEX^A^TRC^CA^1247^1247
#
CITY_ADDER_FILENAME="make_city_to_city_schedule.sh"
CITY_ADDER_FILE="${EXEC_PATH}${CITY_ADDER_FILENAME}"
CITY_ADDER="bash ${CITY_ADDER_FILE}"
${CITY_ADDER} ${SNAPSHOT_DATE} 0 || exit -1

##
# Count the frequencies for the file of all the POR (airports as well as cities).
#
# Note 1: The input file, namely ${CSV_OUT_ALL_PAL_FILE}
#         (./oag_schedule_with_cities_130221_all.csv.tmp), is generated by the
#         ${CITY_ADDER_FILE} (./make_city_to_city_schedule.sh) script.
#
# Note 2: The ./count_frequencies.awk AWK script is used again here, but on
#         a file with a different format than above.
#
# Sample output lines:
#   AM^ATL^C^MEX^A^333^333^8^2
#   AM^TRC^CA^MEX^A^1246^1246^108^2
#   AM^MEX^A^TRC^CA^1247^1247^2^108
#
\mv -f ${CSV_OUT_ALL_PAL_FILE} ${CSV_OUT_ALL_PAL_FILE_TMP}
awk -F'^' -f ${FREQ_COUNTER} ${CSV_OUT_ALL_PAL_FILE_TMP} \
	> ${CSV_OUT_ALL_CTED_FILE_TMP}
sort -t'^' -k1,5 ${CSV_OUT_ALL_CTED_FILE_TMP} \
	> ${CSV_OUT_ALL_PAL_FILE}

##
# Merge all the airline specific entries into general ones
${SED_TOOL} -E "s/^([A-Z0-9]{2})\^(.*)$/ALL\^\2/g" ${CSV_OUT_APT_PAL_FILE} \
			> ${CSV_OUT_APT_MGD_FILE_TMP}
${SED_TOOL} -E "s/^([A-Z0-9]{2})\^(.*)$/ALL\^\2/g" ${CSV_OUT_ALL_PAL_FILE} \
			> ${CSV_OUT_ALL_MGD_FILE_TMP}

##
# Re-order the merged files
sort -t'^' -k2,3 ${CSV_OUT_APT_MGD_FILE_TMP} > ${CSV_OUT_APT_MGD_FILE_TMP2}
sort -t'^' -k2,5 ${CSV_OUT_ALL_MGD_FILE_TMP} > ${CSV_OUT_ALL_MGD_FILE_TMP2}

##
# Re-count the frequencies for the merged files
awk -F'^' -f ${FREQ_COUNTER} ${CSV_OUT_APT_MGD_FILE_TMP2} \
	> ${CSV_OUT_APT_MGD_FILE_TMP3}
sort -t'^' -k2,3 ${CSV_OUT_APT_MGD_FILE_TMP3} > ${CSV_OUT_APT_MGD_FILE}
awk -F'^' -f ${FREQ_COUNTER} ${CSV_OUT_ALL_MGD_FILE_TMP2} \
	> ${CSV_OUT_ALL_MGD_FILE_TMP3}
sort -t'^' -k2,5 ${CSV_OUT_ALL_MGD_FILE_TMP3} > ${CSV_OUT_ALL_MGD_FILE}


##
# Reporting
#
echo
echo "Reporting"
echo "---------"
echo "Extracted all the operating legs from ${CSV_SCH_FILE} into the ${CSV_OUT_APT_PAL_FILE} CSV file."
echo "Generated a schedule file with cities (and airports): ${CSV_OUT_ALL_PAL_FILE}"
echo "${WC_TOOL} -l ${CSV_OUT_APT_PAL_FILE} ${CSV_OUT_ALL_PAL_FILE}"
echo
echo "Merged all the airline specific entries:"
echo "${WC_TOOL} -l ${CSV_OUT_APT_MGD_FILE} ${CSV_OUT_ALL_MGD_FILE}"
echo


##
# Cleaning
#
echo
echo "Cleaning"
echo "--------"
echo "\\\rm -f ${CSV_OUT_APT_PAL_FILE_TMP} ${CSV_OUT_APT_PAL_FILE_TMP2}"
echo "\\\rm -f ${SPE_CSV_OUT_APT_PAL_FILE}"
echo "\\\rm -f ${CSV_OUT_ALL_PAL_FILE_TMP} ${CSV_OUT_ALL_CTED_FILE_TMP}"
echo "\\\rm -f ${SPE_CSV_OUT_ALL_PAL_FILE}"
echo "\\\rm -f ${SORTED_OPTD_POR_FILE} ${SORTED_CUT_OPTD_POR_FILE}"
echo "\\\rm -f ${CSV_OUT_APT_MGD_FILE_TMP} ${CSV_OUT_ALL_MGD_FILE_TMP}"
echo "\\\rm -f ${CSV_OUT_APT_MGD_FILE_TMP2} ${CSV_OUT_ALL_MGD_FILE_TMP2}"
echo "\\\rm -f ${CSV_OUT_APT_MGD_FILE_TMP3} ${CSV_OUT_ALL_MGD_FILE_TMP3}"
echo
