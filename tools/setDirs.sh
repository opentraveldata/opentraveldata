#!/bin/bash

#
# Utility for OpenTravelData (OPTD) Shell scripts
# Git repository:
#   https://github.com/opentraveldata/opentraveldata/tree/master/tools
#

##
# Caller script
CALLER_SCRIPT="setDirs.sh"
if [ "$1" != "" ]
then
	CALLER_SCRIPT="$1"
fi

##
# Variables specified in the remaining of the script
export TMP_DIR
export EXEC_PATH
export EXEC_FULL_PATH
export EXEC_DIR_NAME

##
# Temporary path
TMP_DIR="/tmp/por"

##
# Path of the executable: set it to empty when this is the current directory.
EXEC_PATH="$(dirname ${CALLER_SCRIPT})"
# Trick to get the actual full-path
EXEC_FULL_PATH="$(pushd ${EXEC_PATH})"
EXEC_FULL_PATH="$(echo ${EXEC_FULL_PATH} | cut -d' ' -f1)"
EXEC_FULL_PATH="$(echo ${EXEC_FULL_PATH} | sed -e 's|~|'${HOME}'|')"
#
CURRENT_DIR="$(pwd)"
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
EXEC_DIR_NAME="$(basename ${EXEC_FULL_PATH})"
if [ "${EXEC_DIR_NAME}" != "tools" ]
then
	echo
	echo "Inconsistency error: this script (${CALLER_SCRIPT}) should be" \
		 "located in the tools/ sub-directory of the OpenTravelData project" \
		 "Git clone, but apparently is not. EXEC_FULL_PATH=\"${EXEC_FULL_PATH}\""
	echo
	return -1
fi

##
# Reporting
echo
echo "Caller script: ${CALLER_SCRIPT}"
echo "Environment variables set:"
echo " - TMP_DIR=\"${TMP_DIR}\""
echo " - EXEC_PATH=\"${EXEC_PATH}\""
echo " - EXEC_FULL_PATH=\"${EXEC_FULL_PATH}\""
echo " - EXEC_DIR_NAME=\"${EXEC_DIR_NAME}\""
echo
