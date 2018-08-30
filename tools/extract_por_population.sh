#!/bin/sh
#set -x

##
# MacOS 'date' vs GNU date
DATE_TOOL=date
if [ -f /usr/bin/sw_vers ]
then
        DATE_TOOL=gdate
fi

##
# Snapshot date
SNAPSHOT_DATE=`$DATE_TOOL "+%Y%m%d"`
SNAPSHOT_DATE_HUMAN=`$DATE_TOOL`

##
# Temporary path
TMP_DIR="/tmp/por"
MYCURDIR=`pwd`

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
# If the international org-reference POR dump file is in the current directory,
# then the current directory is certainly intended to be the temporary directory.
if [ -f ${INTORG_TAB_FILENAME} ]
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
# OpenTravelData directory
OPTD_DIR=`dirname ${EXEC_FULL_PATH}`
OPTD_DIR="${OPTD_DIR}/"

##
# OPTD sub-directory
DATA_DIR=${OPTD_DIR}opentraveldata/
TOOLS_DIR=${OPTD_DIR}tools/

##
# Sanity check: that (executable) script should be located in the tools/
# sub-directory of the OpenTravelData project Git clone
EXEC_DIR_NAME=`basename ${EXEC_FULL_PATH}`
if [ "${EXEC_DIR_NAME}" != "tools" ]
then
    echo
    echo "[$0:$LINENO] Inconsistency error: this script ($0) should be located in the tools/ sub-directory of the OpenTravelData project Git clone, but apparently is not. EXEC_FULL_PATH=\"${EXEC_FULL_PATH}\""
    echo
    exit -1
fi

##
#
POR_ALL_FILE="${DATA_DIR}optd_por_public_all.csv"
TGT_FILE="${DATA_DIR}optd_por_population.csv"

# Processing
awk -F'^' '{OFS=FS; if ($29 != 0) {print ($1 FS $7 FS $17 FS $29 FS "http://geonames.org/" $5)}}' ${POR_ALL_FILE} \
	> ${TGT_FILE}

# Reporting
NB_POR=`wc -l ${TGT_FILE}|sed -e 's/^\([^0-9]*\)\([0-9]\+\)\([^0-9]\)*$/\2/g'`
echo
echo "The data file of POR having a specified population size ('${TGT_FILE}') has been generated from '${POR_ALL_FILE}'"
echo "There are ${NB_POR} records"
echo

