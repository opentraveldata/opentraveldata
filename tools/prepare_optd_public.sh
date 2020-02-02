#!/bin/bash

#
# OpenTravelData (OPTD) utility
# Git repository:
#   https://github.com/opentraveldata/opentraveldata/tree/master/tools
#

#
# One parameter is optional for this script:
# - the file-path of the data dump file extracted from Reference Data.
#

##
# GNU tools, including on MacOS
source setGnuTools.sh || exit -1

##
# Directories
source setDirs.sh "$0" || exit -1

#
displayOriDetails() {
	echo
	echo "For this script ($0) to work properly, OPTD-maintained data and tools need"
	echo "to be available. The OPTD-maintained data and tools can be obtained from"
	echo "the OpenTravelData project (http://github.com/opentraveldata/optd)."
	echo "The OPTDDIR environment variable needs to be set properly. For instance:"
	echo "MYCURDIR=`pwd`"
	echo "export OPTDDIR=~/dev/geo/optdgit/refdata"
	echo "mkdir -p ~/dev/geo"
	echo "cd ~/dev/geo"
	echo "git clone git://github.com/opentraveldata/optd.git optdgit"
	echo
}

##
# Input file
OPTD_RAW_FILENAME="optd_por_public.csv"

##
# OpenTravelData directory
OPTD_DIR="$(dirname ${EXEC_FULL_PATH})"
OPTD_DIR="${OPTD_DIR}/"

##
# OPTD sub-directory
DATA_DIR="${OPTD_DIR}opentraveldata/"

##
# Log level
LOG_LEVEL=4

##
#
OPTD_WPK_FILENAME="wpk_${OPTD_RAW_FILENAME}"
SORTED_OPTD_WPK_FILENAME="sorted_${OPTD_WPK_FILENAME}"
SORTED_CUT_OPTD_WPK_FILENAME="cut_sorted_${OPTD_WPK_FILENAME}"
#
OPTD_RAW_FILE="${DATA_DIR}${OPTD_RAW_FILENAME}"
OPTD_WPK_FILE="${TMP_DIR}${OPTD_WPK_FILENAME}"
SORTED_OPTD_WPK_FILE="${SORTED_OPTD_WPK_FILENAME}"
SORTED_CUT_OPTD_WPK_FILE="${SORTED_CUT_OPTD_WPK_FILENAME}"

##
# Temporary files
OPTD_WPK_FILE_TMP="${OPTD_WPK_FILE}.tmp"
OPTD_WPK_FILE_TMP2="${OPTD_WPK_FILE}.tmp2"


##
# Cleaning
if [ "$1" = "--clean" ]
then
	if [ "${TMP_DIR}" = "/tmp/por" ]
	then
		\rm -rf ${TMP_DIR}
	else
		\rm -f ${SORTED_OPTD_WPK_FILE} ${SORTED_CUT_OPTD_WPK_FILE}
		\rm -f ${OPTD_WPK_FILE_TMP} ${OPTD_WPK_FILE_TMP2}
		\rm -f ${OPTD_WPK_FILE}
	fi
	exit
fi

##
# Usage
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<refdata directory of the OpenTravelData project Git clone> [<Log level>]]"
	echo "  - Default refdata directory for the OpenTravelData project Git clone: '${OPTD_DIR}'"
	echo "  - Default path for the OPTD-maintained POR public file: '${OPTD_RAW_FILE}'"
	echo "  - Default log level: ${LOG_LEVEL}"
	echo "    + 0: No log; 1: Critical; 2: Error; 3; Notification; 4: Debug; 5: Verbose"
	echo "  - Generated files:"
	echo "    + '${OPTD_WPK_FILE}'"
	echo
	exit
fi
#
if [ "$1" = "-o" -o "$1" = "--ori" ];
then
	displayOriDetails
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
		echo "[$0:$LINENO] The first parameter ('$1') should point to the refdata/ sub-directory of the OpenTravelData project Git clone. It is not accessible here."
		echo
		exit -1
	fi
	OPTD_DIR_DIR="$(dirname $1)"
	OPTD_DIR_BASE="$(basename $1)"
	OPTD_DIR="${OPTD_DIR_DIR}/${OPTD_DIR_BASE}/"
	DATA_DIR="${OPTD_DIR}opentraveldata/"
	OPTD_EXEC_PATH="${OPTD_DIR}tools/"
	OPTD_RAW_FILE="${DATA_DIR}${OPTD_RAW_FILENAME}"
fi
OPTD_WPK_FILE="${TMP_DIR}${OPTD_WPK_FILENAME}"
SORTED_OPTD_WPK_FILE="${TMP_DIR}${SORTED_OPTD_WPK_FILENAME}"
SORTED_CUT_OPTD_WPK_FILE="${TMP_DIR}${SORTED_CUT_OPTD_WPK_FILENAME}"
OPTD_WPK_FILE_TMP="${OPTD_WPK_FILE}.tmp"
OPTD_WPK_FILE_TMP2="${OPTD_WPK_FILE}.tmp2"

if [ ! -f "${OPTD_RAW_FILE}" ]
then
	echo "[$0:$LINENO] The '${OPTD_RAW_FILE}' file does not exist."
	if [ "$1" = "" ]
	then
		displayOriDetails
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
OPTD_PK_ADDER="${EXEC_PATH}optd_pk_creator.awk"
\cp -f ${OPTD_RAW_FILE} ${OPTD_WPK_FILE_TMP}
awk -F'^' -v log_level="${LOG_LEVEL}" \
	-f ${OPTD_PK_ADDER} ${OPTD_WPK_FILE_TMP} > ${OPTD_WPK_FILE}
#sort -t'^' -k1,1 ${OPTD_WPK_FILE}
#echo "head -3 ${OPTD_WPK_FILE_TMP} ${OPTD_WPK_FILE}"

##
# First, remove the header (first line)
${SED_TOOL} -E "s/^pk(.+)//g" ${OPTD_WPK_FILE} > ${OPTD_WPK_FILE_TMP2}
${SED_TOOL} -i"" -E "/^$/d" ${OPTD_WPK_FILE_TMP2}


##
# That version of the OPTD-maintained POR file is sorted according to the IATA
# code; re-sort it according to the primary key (IATA code, location type and
# Geonames ID).
sort -t'^' -k1,1 ${OPTD_WPK_FILE_TMP2} > ${SORTED_OPTD_WPK_FILE}

##
# Only four columns/fields are kept in that version of the file:
# the primary key, airport/city IATA code and the geographical coordinates
# (latitude, longitude).
cut -d'^' -f 1,2,9,10 ${SORTED_OPTD_WPK_FILE} > ${SORTED_CUT_OPTD_WPK_FILE}

##
# Reporting
echo
echo "Preparation step"
echo "----------------"
echo "The '${OPTD_WPK_FILE}', '${SORTED_OPTD_WPK_FILE}' and '${SORTED_CUT_OPTD_WPK_FILE}' files have been derived from '${OPTD_RAW_FILE}'."
echo

