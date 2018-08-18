#!/bin/bash
#
# One parameter is optional for this script:
# - the file-path of the data dump file extracted from Geonames.
#

displayGeonamesDetails() {
    if [ -z "${OPTDDIR}" ]
    then
		export OPTDDIR=~/dev/geo/optdgit
    fi
    echo
    echo "The data dump from Geonames can be obtained from the OpenTravelData project"
    echo "(http://github.com/opentraveldata/opentraveldata). For instance:"
    echo "OPTDDIR=${OPTDDIR}"
    echo "mkdir -p ~/dev/geo"
    echo "cd ~/dev/geo"
    echo "git clone git://github.com/opentraveldata/opentraveldata.git optdgit"
    echo "cd ${OPTDDIR}/data/geonames/data"
    echo "./getDataFromGeonamesWebsite.sh  # it may take several minutes"
    echo "cd ${OPTDDIR}/data/geonames/data/por/admin"
    echo "./aggregateGeonamesPor.sh # it may take several minutes (~10 minutes)"
    if [ "${TMP_DIR}" = "/tmp/por/" ]
    then
		echo "mkdir -p ${TMP_DIR}"
    fi
    echo "cd ${OPTDDIR}/tools"
    echo "./extract_por_from_geonames.sh # it may take several minutes"
    echo "./extract_por_from_geonames.sh --clean"
    echo "It produces both a por_intorg_${SNAPSHOT_DATE}.csv and a por_all_${SNAPSHOT_DATE}.csv files."
    echo "por_intorg_${SNAPSHOT_DATE}.csv has to be copied into the dump_from_geonames.csv file."
    echo "\cp -f por_intorg_${SNAPSHOT_DATE} dump_from_geonames.csv"
	echo "./make_optd_por_public.sh"
	echo "./make_optd_por_public.sh --clean"
    echo "ls -l ../opentraveldata/optd_por_public.csv"
    echo
}

##
# Input file names
GEO_RAW_FILENAME=dump_from_geonames.csv
GEO_OPTD_FILENAME=optd_por_best_known_so_far.csv

##
# MacOS 'date' vs GNU date
DATE_TOOL=date
if [ -f /usr/bin/sw_vers ]
then
	DATE_TOOL=gdate
fi

##
# Snapshot date
SNAPSHOT_DATE=`$DATE_TOOL "+%y%m%d"`
SNAPSHOT_DATE_HUMAN=`$DATE_TOOL`

##
# Temporary path
TMP_DIR="/tmp/por"

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
# Sanity check: that (executable) script should be located in the tools/ sub-directory
# of the OpenTravelData project Git clone
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
# OPTD sub-directory
DATA_DIR=${OPTD_DIR}opentraveldata/
TOOLS_DIR=${OPTD_DIR}tools/

##
# Log level
LOG_LEVEL=4

##
# Input files
GEO_RAW_FILE=${TOOLS_DIR}${GEO_RAW_FILENAME}
GEO_OPTD_FILE=${DATA_DIR}${GEO_OPTD_FILENAME}

##
# Output (generated) files
GEO_WPK_FILENAME=wpk_${GEO_RAW_FILENAME}
SORTED_GEO_WPK_FILENAME=sorted_${GEO_WPK_FILENAME}
SORTED_CUT_GEO_WPK_FILENAME=cut_sorted_${GEO_WPK_FILENAME}
#
GEO_WPK_FILE=${TMP_DIR}${GEO_WPK_FILENAME}
SORTED_GEO_WPK_FILE=${TMP_DIR}${SORTED_GEO_WPK_FILENAME}
SORTED_CUT_GEO_WPK_FILE=${TMP_DIR}${SORTED_CUT_GEO_WPK_FILENAME}
#

##
# Cleaning
if [ "$1" = "--clean" ]
then
	if [ "${TMP_DIR}" = "/tmp/por" ]
	then
		\rm -rf ${TMP_DIR}
	else
		\rm -f ${SORTED_GEO_WPK_FILE} ${SORTED_CUT_GEO_WPK_FILE}
		#\rm -f ${GEO_WPK_FILE}
	fi
	exit
fi

##
# Usage
if [ "$1" = "-h" -o "$1" = "--help" ]
then
	echo
	echo "Usage: $0 [<refdata directory of the OpenTravelData project Git clone> [<log level>]]"
	echo "  - Default refdata directory for the OpenTravelData project Git clone: '${OPTD_DIR}'"
	echo "  - Default path for the Geonames data dump file: '${GEO_RAW_FILE}'"
	echo "  - Default log level: ${LOG_LEVEL}"
	echo "    + 0: No log; 1: Critical; 2: Error; 3; Notification; 4: Debug; 5: Verbose"
	echo "  - OPTD-maintained list of POR (points of reference): '${GEO_OPTD_FILE}'"
	echo "  - Generated files:"
	echo "    + '${GEO_WPK_FILE}'"
	echo "    + '${SORTED_GEO_WPK_FILE}'"
	echo "    + '${SORTED_CUT_GEO_WPK_FILE}'"
	echo
	exit
fi
#
if [ "$1" = "-g" -o "$1" = "--geonames" ]
then
	displayGeonamesDetails
	exit
fi

##
# The OpenTravelData refdata/ sub-directory contains, among other things,
# the Geonames data dump.
if [ "$1" != "" ]
then
	OPTD_DIR_DIR=`dirname $1`
	OPTD_DIR_BASE=`basename $1`
	if [ "${OPTD_DIR_DIR}" = "." ]
	then
		OPTD_DIR_DIR=""
	else
		OPTD_DIR_DIR=${OPTD_DIR_DIR}/
	fi
	OPTD_DIR="${OPTD_DIR_DIR}${OPTD_DIR_BASE}/"
	if [ ! -d ${OPTD_DIR} ]
	then
		echo
		echo "[$0:$LINENO] The first parameter ('$1') should point to the refdata/ sub-directory of the OpenTravelData project Git clone. It is not accessible here."
		echo
		exit -1
	fi
	DATA_DIR=${OPTD_DIR}opentraveldata/
	TOOLS_DIR=${OPTD_DIR}tools/
	GEO_RAW_FILE=${TOOLS_DIR}${GEO_RAW_FILENAME}
	GEO_OPTD_FILE=${DATA_DIR}${GEO_OPTD_FILENAME}
fi

if [ ! -f "${GEO_RAW_FILE}" ]
then
	echo
	echo "[$0:$LINENO] The '${GEO_RAW_FILE}' file does not exist."
	echo
	if [ "$1" = "" ];
	then
		displayGeonamesDetails
	fi
	exit -1
fi

##
# Log level
if [ "$2" != "" ]
then
	LOG_LEVEL="$2"
fi

##
# Generate a second version of the file with the OPTD primary key (integrating
# the location type)
OPTD_PK_ADDER=${TOOLS_DIR}geo_pk_creator.awk
awk -F'^' -v log_level=${LOG_LEVEL} -f ${OPTD_PK_ADDER} \
	${GEO_OPTD_FILE} ${GEO_RAW_FILE} > ${GEO_WPK_FILE}

##
# Save the header
GEO_WPK_FILE_HEADER=${GEO_WPK_FILE}.tmp.hdr
grep "^pk\(.\+\)" ${GEO_WPK_FILE} > ${GEO_WPK_FILE_HEADER}

##
# Remove the header (first line)
GEO_WPK_FILE_TMP=${GEO_WPK_FILE}.tmp
sed -i -e "s/^pk\(.\+\)//g" ${GEO_WPK_FILE}
sed -i -e "/^$/d" ${GEO_WPK_FILE}

##
# Sort the file
sort -t'^' -k1,1 ${GEO_WPK_FILE} > ${SORTED_GEO_WPK_FILE}
\cp -f ${SORTED_GEO_WPK_FILE} ${GEO_WPK_FILE}

##
# Only four columns/fields are kept in that version of the file:
#  * Primary key (IATA code - location type)
#  * Airport/city IATA code
#  * Geographical coordinates (latitude, longitude).
#echo "grep \"^AIY\" ${SORTED_GEO_WPK_FILE}"
cut -d'^' -f 1,2,8,9 ${SORTED_GEO_WPK_FILE} > ${SORTED_CUT_GEO_WPK_FILE}

##
# Re-add the header
cat ${GEO_WPK_FILE_HEADER} ${GEO_WPK_FILE} > ${GEO_WPK_FILE_TMP}
sed -i -e "/^$/d" ${GEO_WPK_FILE_TMP}
\mv -f ${GEO_WPK_FILE_TMP} ${GEO_WPK_FILE}
\rm -f ${GEO_WPK_FILE_HEADER}

##
# Reporting
echo
echo "Preparation step"
echo "----------------"
echo "The '${GEO_WPK_FILE}', '${SORTED_GEO_WPK_FILE}' and '${SORTED_CUT_GEO_WPK_FILE}' files have been derived from '${GEO_RAW_FILE}'."
echo

