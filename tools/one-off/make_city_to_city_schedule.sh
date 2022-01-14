#!/bin/bash

#
# OpenTravelData (OPTD) utility
# Git repository:
#   https://github.com/opentraveldata/opentraveldata/tree/master/tools
#

#
# Three parameters are optional:
#  - Snapshot date (format: YYMMDD)
#  - OPTD-maintained file
#  - Whether or not that script should report any thing
#

##
# GNU tools, including on MacOS
source setGnuTools.sh || exit -1

##
# Directories
source setDirs.sh "$0" || exit -1

#
displayGeonamesDetails() {
	if [ -z "${OPTDDIR}" ]
	then
		export OPTDDIR="${HOME}/dev/geo/optdgit/opentraveldata/   # -- Sample --"
	fi
	if [ -z "${MYCURDIR}" ]
	then
		export MYCURDIR=`pwd`
	fi
	echo
	echo "The data dump from Geonames can be obtained from the OpenTravelData project"
	echo "(http://github.com/opentraveldata/opentraveldata). For instance:"
	echo "MYCURDIR=`pwd`"
	echo "OPTDDIR=${OPTDDIR}"
	echo "mkdir -p ~/dev/geo"
	echo "cd ~/dev/geo"
	echo "git clone git://github.com/opentraveldata/opentraveldata.git optdgit"
	echo "ls -l ${OPTDDIR}/opentraveldata/optd_por_best_known_so_far.csv"
	echo "ls -l ${OPTDDIR}/opentraveldata/ref_airport_popularity.csv"
	echo "ls -l ${OPTDDIR}/opentraveldata/${OPTD_RAW_FILENAME}"
	echo
}


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

# Operating airline (owner of the schedule)
AIRLINE_CODE="ALL"

# OPTD-maintained list of POR (from which the airport-city relationship
# is derived)
OPTD_POR_FILENAME="optd_por_best_known_so_far.csv"
SORTED_OPTD_POR_FILE="sorted_${OPTD_POR_FILENAME}"
SORTED_CUT_OPTD_POR_FILE="cut_sorted_${OPTD_POR_FILENAME}"
#
OPTD_POR_FILE="${DATA_DIR}${OPTD_POR_FILENAME}"

# OPTD-formatted schedule file
SCH_FILE_PFX="oag_schedule_opt_"

# Output CSV data file
CSV_OUT_ALL_PREFIX="oag_schedule_with_cities_"

# Whether or not that script should report any thing
REPORT_FLAG=1

#
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<Snapshot date (format: YYMMDD)> [<OPTD-maintained file>]]"
	echo "  - Snapshot date: '${SNAPSHOT_DATE}' (${SNAPSHOT_DATE_HUMAN})"
	echo "  - Default OPTD-maintained file-path: '${OPTD_POR_FILE}'"
	echo "  - Generated (CSV-formatted) data file prefix: ${CSV_OUT_ALL_PREFIX}"
	echo
	exit -1
fi

# Read the airline code from the command-line option, if any
if [ "$1" != "" -a "$1" != "--clean" ]
then
	SNAPSHOT_DATE="$1"
fi

# Input OAG CSV data files
AIRLINE_LOWER="$(echo "${AIRLINE_CODE}" | tr '[:upper:]' '[:lower:]')"
CSV_SCH_FILENAME="${SCH_FILE_PFX}${SNAPSHOT_DATE}_${AIRLINE_LOWER}.csv"
CSV_SCH_FILE="${EXEC_PATH}${CSV_SCH_FILENAME}"

# Output file with all the POR (airports as well as cities)
CSV_OUT_ALL_FILENAME="${CSV_OUT_ALL_PREFIX}${SNAPSHOT_DATE}_${AIRLINE_LOWER}.csv"
CSV_OUT_ALL_FILE="${TMP_DIR}${CSV_OUT_ALL_FILENAME}"
SPE_CSV_OUT_ALL_FILE="${CSV_OUT_ALL_FILE}.cut"
CSV_OUT_ALL_FILE_TMP="${CSV_OUT_ALL_FILE}.tmp"

# Retrieve the latest schedule file
LATEST_EXTRACT_DATA="$(ls ${EXEC_PATH} | grep "${SCH_FILE_PFX}" | tail -1 | ${SED_TOOL} -E "s/${SCH_FILE_PFX}([0-9]+)_${AIRLINE_LOWER}\.csv/\1/")"

##
# Clean
if [ "$1" = "--clean" -o "$2" = "--clean" ]
then
	if [ "${TMP_DIR}" != "/tmp/por/" ]
	then
		if [ ! -f ${CSV_SCH_FILE} ]
		then
			SNAPSHOT_DATE="${LATEST_EXTRACT_DATA}"
			CSV_OUT_ALL_FILE="${TMP_DIR}${CSV_OUT_ALL_PREFIX}${SNAPSHOT_DATE}.csv"
			SPE_CSV_OUT_ALL_FILE="${CSV_OUT_ALL_FILE}.cut"
			CSV_OUT_ALL_FILE_TMP="${CSV_OUT_ALL_FILE}.tmp"
		fi
		\rm -f ${CSV_OUT_ALL_FILE_TMP} ${SPE_CSV_OUT_ALL_FILE}
		# \rm -f ${SORTED_OPTD_POR_FILE} ${SORTED_CUT_OPTD_POR_FILE}
	else
		echo "\rm -rf ${TMP_DIR}"
	fi
	exit 0
fi

# Sanity check
if [ ! -f ${CSV_SCH_FILE} ]
then
	echo
	echo "[$0] The '${CSV_SCH_FILENAME}' schedule file does not exist."
	if [ ! -z "${LATEST_EXTRACT_DATA}" ]
	then
		echo "Apparently, ${LATEST_EXTRACT_DATA} seems to be " \
			 "the latest extraction date."
	fi
	echo
	exit -1
fi

##
# Sanity check
if [ ! -f ${OPTD_POR_FILE} ]
then
	echo
	echo "[$0] The OPTD-maintained file ('${OPTD_POR_FILE}') does not exist."
	echo
	exit -1
fi

##
# Flag for reporting
if [ "$2" != "" ]
then
	REPORT_FLAG="$2"
fi
if [ ${REPORT_FLAG} != 0 -a ${REPORT_FLAG} != 1 ]
then
	REPORT_FLAG=1
fi


##
# Add the cities
#
# Sample output lines:
#   AF^EAP^C^BSL^A^2294^2294^419^416       City -> Airport
#   AF^NCE^CA^BSL^A^337^337^674^416        City/Airport -> Airport
#   AF^BSL^A^CDG^A^1412^1412^416^11        Airport -> Airport
#   AF^CDG^A^PAR^C^286768^286768^11^19     Airport -> City/Airport
#
CITY_ADDER="${EXEC_PATH}add_cities_into_schedule.awk"
awk -F'^' -f ${CITY_ADDER} ${OPTD_POR_FILE} ${CSV_SCH_FILE} \
	> ${SPE_CSV_OUT_ALL_FILE}
sort -t'^' -k1,5 ${SPE_CSV_OUT_ALL_FILE} > ${CSV_OUT_ALL_FILE_TMP}
\mv ${CSV_OUT_ALL_FILE_TMP} ${CSV_OUT_ALL_FILE}


##
# Reporting
if [ ${REPORT_FLAG} = 1 ]
then
	echo
	echo "Reporting"
	echo "---------"
	echo "Generated a schedule file with cities (and airports) " \
		 "from ${CSV_SCH_FILE} into the ${CSV_OUT_ALL_FILE} CSV file."
	echo
fi


##
# Cleaning
if [ ${REPORT_FLAG} = 1 ]
then
	echo
	echo "Cleaning"
	echo "--------"
	echo "\\\rm -f ${CSV_OUT_ALL_FILE_TMP} ${SPE_CSV_OUT_ALL_FILE} " \
		 "${SORTED_OPTD_POR_FILE} ${SORTED_CUT_OPTD_POR_FILE}"
	echo
fi
