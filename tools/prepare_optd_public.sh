#!/bin/bash
#
# One parameter is optional for this script:
# - the file-path of the data dump file extracted from RFD.
#

displayOriDetails() {
	echo
	echo "For this script ($0) to work properly, ORI-maintained data and tools need"
	echo "to be available. The ORI-maintained data and tools can be obtained from"
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
ORI_RAW_FILENAME=optd_por_public.csv

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
EXEC_PATH="${EXEC_PATH}/"
TMP_DIR="${TMP_DIR}/"

if [ ! -d ${TMP_DIR} -o ! -w ${TMP_DIR} ]
then
	\mkdir -p ${TMP_DIR}
fi

##
# Sanity check: that (executable) script should be located in the tools/
# sub-directory of the OpenTravelData project Git clone.
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
# ORI sub-directory
ORI_DIR=${OPTD_DIR}ORI/

##
# Log level
LOG_LEVEL=4

##
#
ORI_WPK_FILENAME=wpk_${ORI_RAW_FILENAME}
SORTED_ORI_WPK_FILENAME=sorted_${ORI_WPK_FILENAME}
SORTED_CUT_ORI_WPK_FILENAME=cut_sorted_${ORI_WPK_FILENAME}
#
ORI_RAW_FILE=${ORI_DIR}${ORI_RAW_FILENAME}
ORI_WPK_FILE=${TMP_DIR}${ORI_WPK_FILENAME}
SORTED_ORI_WPK_FILE=${SORTED_ORI_WPK_FILENAME}
SORTED_CUT_ORI_WPK_FILE=${SORTED_CUT_ORI_WPK_FILENAME}

##
# Temporary files
ORI_WPK_FILE_TMP=${ORI_WPK_FILE}.tmp
ORI_WPK_FILE_TMP2=${ORI_WPK_FILE}.tmp2


##
# Cleaning
if [ "$1" = "--clean" ]
then
	if [ "${TMP_DIR}" = "/tmp/por" ]
	then
		\rm -rf ${TMP_DIR}
	else
		\rm -f ${SORTED_ORI_WPK_FILE} ${SORTED_CUT_ORI_WPK_FILE}
		\rm -f ${ORI_WPK_FILE_TMP} ${ORI_WPK_FILE_TMP2}
		\rm -f ${ORI_WPK_FILE}
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
	echo "  - Default path for the ORI-maintained POR public file: '${ORI_RAW_FILE}'"
	echo "  - Default log level: ${LOG_LEVEL}"
	echo "    + 0: No log; 1: Critical; 2: Error; 3; Notification; 4: Debug; 5: Verbose"
	echo "  - Generated files:"
	echo "    + '${ORI_WPK_FILE}'"
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
# the ORI-maintained list of POR file with geographical coordinates.
if [ "$1" != "" ]
then
	if [ ! -d $1 ]
	then
		echo
		echo "[$0:$LINENO] The first parameter ('$1') should point to the refdata/ sub-directory of the OpenTravelData project Git clone. It is not accessible here."
		echo
		exit -1
	fi
	OPTD_DIR_DIR=`dirname $1`
	OPTD_DIR_BASE=`basename $1`
	OPTD_DIR="${OPTD_DIR_DIR}/${OPTD_DIR_BASE}/"
	ORI_DIR=${OPTD_DIR}ORI/
	OPTD_EXEC_PATH=${OPTD_DIR}tools/
	ORI_RAW_FILE=${ORI_DIR}${ORI_RAW_FILENAME}
fi
ORI_WPK_FILE=${TMP_DIR}${ORI_WPK_FILENAME}
SORTED_ORI_WPK_FILE=${TMP_DIR}${SORTED_ORI_WPK_FILENAME}
SORTED_CUT_ORI_WPK_FILE=${TMP_DIR}${SORTED_CUT_ORI_WPK_FILENAME}
ORI_WPK_FILE_TMP=${ORI_WPK_FILE}.tmp
ORI_WPK_FILE_TMP2=${ORI_WPK_FILE}.tmp2

if [ ! -f "${ORI_RAW_FILE}" ]
then
	echo "[$0:$LINENO] The '${ORI_RAW_FILE}' file does not exist."
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
# Generate a second version of the file with the ORI primary key (integrating
# the location type)
ORI_PK_ADDER=${EXEC_PATH}optd_pk_creator.awk
\cp -f ${ORI_RAW_FILE} ${ORI_WPK_FILE_TMP}
awk -F'^' -v log_level=${LOG_LEVEL} \
	-f ${ORI_PK_ADDER} ${ORI_WPK_FILE_TMP} > ${ORI_WPK_FILE}
#sort -t'^' -k1,1 ${ORI_WPK_FILE}
#echo "head -3 ${ORI_WPK_FILE_TMP} ${ORI_WPK_FILE}"

##
# First, remove the header (first line)
sed -e "s/^pk\(.\+\)//g" ${ORI_WPK_FILE} > ${ORI_WPK_FILE_TMP2}
sed -i -e "/^$/d" ${ORI_WPK_FILE_TMP2}


##
# That version of the ORI-maintained POR file is sorted according to the IATA
# code; re-sort it according to the primary key (IATA code, location type and
# Geonames ID).
sort -t'^' -k1,1 ${ORI_WPK_FILE_TMP2} > ${SORTED_ORI_WPK_FILE}

##
# Only four columns/fields are kept in that version of the file:
# the primary key, airport/city IATA code and the geographical coordinates
# (latitude, longitude).
cut -d'^' -f 1,2,9,10 ${SORTED_ORI_WPK_FILE} > ${SORTED_CUT_ORI_WPK_FILE}

##
# Reporting
echo
echo "Preparation step"
echo "----------------"
echo "The '${ORI_WPK_FILE}', '${SORTED_ORI_WPK_FILE}' and '${SORTED_CUT_ORI_WPK_FILE}' files have been derived from '${ORI_RAW_FILE}'."
echo

