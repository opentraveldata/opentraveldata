#!/bin/bash

# Sort the optd_airlines.csv data file
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
# Target (generated files)
OPTD_AIR_PUBLIC_FILENAME=optd_airlines.csv
#
OPTD_AIR_PUBLIC_FILE=${DATA_DIR}${OPTD_AIR_PUBLIC_FILENAME}

##
# Temporary
OPTD_AIR_HEADER=${OPTD_AIR_FILE}.tmp.hdr
OPTD_AIR_WITH_NOHD=${OPTD_AIR_FILE}.wohd
OPTD_AIR_UNSORTED_NOHDR=${OPTD_AIR_FILE}.wohd.unsorted


##
# Sanity check
if [ ! -d ${TOOLS_DIR} ]
then
	echo
	echo "[$0:$LINENO] The tools/ sub-directory ('${TOOLS_DIR}') does not exist or is not accessible."
	echo "Check that your Git clone of the OpenTravelData is complete."
	echo
	exit -1
fi


##
# Usage helper
#
if [ "$1" = "-h" -o "$1" = "--help" ]
then
	echo
	echo "That script generates the public version of the OPTD-maintained list of airlines"
	echo
	echo "Usage: $0 [<log level (0: quiet; 5: verbose)>]"
	echo " - Default log level (from 0 to 5): ${LOG_LEVEL}"
	echo
	echo "* Input data files"
	echo "------------------"
	echo " - OPTD-maintained public file of airlines: '${OPTD_AIR_PUBLIC_FILE}'"
	echo
	echo "* Output data file"
	echo "------------------"
	echo " - OPTD-maintained public file of airlines: '${OPTD_AIR_PUBLIC_FILE}'"
	echo
	exit
fi


##
# Log level
if [ "$1" != "" ]
then
	LOG_LEVEL="$1"
fi


##
# Extract the header into temporary files
grep "^pk\(.\+\)" ${OPTD_AIR_PUBLIC_FILE} > ${OPTD_AIR_HEADER}

##
# Remove the header
sed -e "s/^pk\(.\+\)//g" ${OPTD_AIR_PUBLIC_FILE} > ${OPTD_AIR_WITH_NOHD}
sed -i -e "/^$/d" ${OPTD_AIR_WITH_NOHD}

##
# Sort on the IATA code, feature code and Geonames ID, in that order
sort -t'^' -k1,1 -k2,2 ${OPTD_AIR_WITH_NOHD} > ${OPTD_AIR_UNSORTED_NOHDR}

##
# Re-add the header
cat ${OPTD_AIR_HEADER} ${OPTD_AIR_UNSORTED_NOHDR} > ${OPTD_AIR_PUBLIC_FILE}

##
# Remove the header
\rm -f ${OPTD_AIR_HEADER} ${OPTD_AIR_WITH_NOHD} ${OPTD_AIR_UNSORTED_NOHDR}

##
# Reporting
#
echo
echo "Reporting Step"
echo "--------------"
echo
echo "wc -l ${OPTD_AIR_PUBLIC_FILE}"
echo
