#!/bin/bash

#
# OpenTravelData (OPTD) utility
# Git repository:
#   https://github.com/opentraveldata/opentraveldata/tree/master/tools
#

#
# One parameter is optional for this script:
# - the file-path of the data dump file extracted from Innovata.
#

##
# GNU tools, including on MacOS
source setGnuTools.sh || exit -1

##
# Directories
source setDirs.sh "$0" || exit -1

#
displayInnovataDetails() {
    ##
    # Snapshot date
    SNAPSHOT_DATE=`$DATE_TOOL "+%Y%m%d"`
    SNAPSHOT_DATE_HUMAN=`$DATE_TOOL`
    echo
    echo "####### Note #######"
    echo "# The data dump from Innovata has to be obtained from Innovata directly."
    echo "# The Innovata dump file ('${INN_RAW_FILENAME}') should be in the ${INN_DIR} directory:"
    ls -la ${INN_DIR}
    echo "#####################"
    echo
}

##
# Input file names
INN_RAW_FILENAME="innovata_stations.dat"
GEO_OPTD_FILENAME="optd_por_best_known_so_far.csv"

##
# OpenTravelData directory
OPTD_DIR="$(dirname ${EXEC_FULL_PATH})"
OPTD_DIR="${OPTD_DIR}/"

##
# OPTD sub-directory
DATA_DIR="${OPTD_DIR}opentraveldata/"
TOOLS_DIR="${OPTD_DIR}tools/"

##
# Innovata sub-directory
INN_DIR="${OPTD_DIR}data/Innovata/"

##
# Log level
LOG_LEVEL=4

##
# Input files
INN_RAW_FILE="${INN_DIR}${INN_RAW_FILENAME}"
GEO_OPTD_FILE="${DATA_DIR}${GEO_OPTD_FILENAME}"

##
# Innovata
INN_RAW_BASE_FILENAME="$(basename ${INN_RAW_FILENAME} .dat)"
INN_RAW_CSV_FILENAME="${INN_RAW_BASE_FILENAME}.csv"
INN_DMP_FILENAME="dump_from_innovata.csv"
INN_WPK_FILENAME="wpk_${INN_DMP_FILENAME}"
SORTED_INN_WPK_FILENAME="sorted_${INN_WPK_FILENAME}"
SORTED_CUT_INN_WPK_FILENAME="cut_${SORTED_INN_WPK_FILENAME}"
#
INN_DMP_FILE="${TMP_DIR}${INN_DMP_FILENAME}"
INN_WPK_FILE="${TMP_DIR}${INN_WPK_FILENAME}"
SORTED_INN_WPK_FILE="${TMP_DIR}${SORTED_INN_WPK_FILENAME}"
SORTED_CUT_INN_WPK_FILE="${TMP_DIR}${SORTED_CUT_INN_WPK_FILENAME}"


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
    echo "Usage: $0 [<root directory of the OpenTravelData project Git clone> [<Innovata data dump file> [<log level>]]]"
    echo "  - Default root directory for the OpenTravelData project Git clone: '${OPTD_DIR}'"
    echo "  - Default path for the OPTD-maintained file of best known coordinates: '${GEO_OPTD_FILE}'"
    echo "  - Default path for the Innovata derived data dump file: '${INN_RAW_FILE}'"
    echo "  - Default log level: ${LOG_LEVEL}"
    echo "    + 0: No log; 1: Critical; 2: Error; 3; Notification; 4: Debug; 5: Verbose"
    echo "  - Generated files:"
    echo "    + '${INN_DMP_FILE}'"
    echo "    + '${INN_WPK_FILE}'"
    echo "    + '${SORTED_INN_WPK_FILE}'"
    echo "    + '${SORTED_CUT_INN_WPK_FILE}'"
    echo
    exit
fi
#
if [ "$1" = "-r" -o "$1" = "--innovata" ]
then
    displayInnovataDetails
    exit
fi

##
# The OpenTravelData refdata/ sub-directory contains, among other things,
# the OPTD-maintained list of POR file with geographical coordinates.
if [ "$1" != "" ]
then
    if [ ! -d $1 ]
    then
		echo
		echo "[$0:$LINENO] The first parameter ('$1') should point to the root directory of the OpenTravelData project Git clone. It is not accessible here."
		echo
		exit -1
    fi
    OPTD_DIR_DIR="$(dirname $1)"
    OPTD_DIR_BASE="$(basename $1)"
    OPTD_DIR="${OPTD_DIR_DIR}/${OPTD_DIR_BASE}/"
    DATA_DIR="${OPTD_DIR}opentraveldata/"
    TOOLS_DIR="${OPTD_DIR}tools/"
    GEO_OPTD_FILE="${DATA_DIR}${GEO_OPTD_FILENAME}"
fi

if [ ! -f "${GEO_OPTD_FILE}" ]
then
    echo
    echo "[$0:$LINENO] The '${GEO_OPTD_FILE}' file does not exist."
    echo
    exit -1
fi

##
# Innovata data dump file with geographical coordinates
if [ "$2" != "" ]
then
    INN_RAW_FILE="$2"
    INN_RAW_BASE_FILENAME="$(basename ${INN_RAW_FILE} .dat)"
    INN_RAW_CSV_FILENAME="${INN_RAW_BASE_FILENAME}.csv"
    INN_WPK_FILENAME="wpk_${INN_RAW_CSV_FILENAME}"
    SORTED_INN_WPK_FILENAME="sorted_${INN_WPK_FILENAME}"
    SORTED_CUT_INN_WPK_FILENAME="cut_${SORTED_INN_WPK_FILENAME}"
    if [ "${INN_RAW_FILE}" = "${INN_RAW_FILENAME}" ]
    then
		INN_RAW_FILE="${TMP_DIR}${INN_RAW_FILE}"
    fi
fi
INN_WPK_FILE="${TMP_DIR}${INN_WPK_FILENAME}"
SORTED_INN_WPK_FILE="${TMP_DIR}${SORTED_INN_WPK_FILENAME}"
SORTED_CUT_INN_WPK_FILE="${TMP_DIR}${SORTED_CUT_INN_WPK_FILENAME}"

if [ ! -f "${INN_RAW_FILE}" ]
then
    echo
    echo "[$0:$LINENO] The '${INN_RAW_FILE}' file does not exist."
    echo
    if [ "$2" = "" ]
    then
		displayInnovataDetails
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
# Dos to Unix format (in place) translation
if [ $(command -v dos2unix) ]
then
	dos2unix ${INN_RAW_FILE}
else
	echo "dos2unix cannot be found. Please install it"
	exit -1
fi

##
# Generate a second version of the file with the OPTD primary key
# (integrating the location type)
OPTD_PK_ADDER="${TOOLS_DIR}inn_pk_creator.awk"
awk -F'^' -v log_level=${LOG_LEVEL} -f ${OPTD_PK_ADDER} \
    ${GEO_OPTD_FILE} ${INN_RAW_FILE} > ${INN_WPK_FILE}
#sort -t'^' -k1,1 ${INN_WPK_FILE}

##
# Generate a dump file in a format pretty much the same
# as for reference data and Geonames
cut -d'^' -f 2- ${INN_WPK_FILE} > ${INN_DMP_FILE}

##
# Remove the header (first line)
INN_WPK_FILE_TMP="${INN_WPK_FILE}.tmp"
${SED_TOOL} -E "s/^pk(.+)//g" ${INN_WPK_FILE} > ${INN_WPK_FILE_TMP}
${SED_TOOL} -i"" -E "/^$/d" ${INN_WPK_FILE_TMP}

##
# That version of the Innovata dump file (without primary key) is sorted
# according to the IATA code.
sort -t'^' -k 1,1 ${INN_WPK_FILE_TMP} > ${SORTED_INN_WPK_FILE}
\rm -f ${INN_WPK_FILE_TMP}

##
# Only four columns/fields are kept in that version of the file:
# the primary key, airport/city IATA code and the geographical coordinates
# (latitude, longitude).
cut -d'^' -f 1,2,8,9 ${SORTED_INN_WPK_FILE} > ${SORTED_CUT_INN_WPK_FILE}

##
# Reporting
echo
echo "Preparation step"
echo "----------------"
echo "The '${INN_DMP_FILE}', '${INN_WPK_FILE}', '${SORTED_INN_WPK_FILE}' " \
	 "and '${SORTED_CUT_INN_WPK_FILE}' files have been derived " \
	 "from '${INN_RAW_FILE}'."
echo

