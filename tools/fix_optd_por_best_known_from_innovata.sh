#!/bin/bash

##
# Input file names
INN_RAW_FILENAME=dump_from_innovata.csv
GEO_OPTD_FILENAME=optd_por_best_known_so_far.csv

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
# If the Innovata dump file is in the current directory, then the current
# directory is certainly intended to be the temporary directory.
if [ -f ${INN_RAW_FILENAME} ]
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
# Sanity check: that (executable) script should be located in the tools/
# sub-directory of the OpenTravelData project Git clone
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
DATA_DIR=${OPTD_DIR}OPTD/
TOOLS_DIR=${OPTD_DIR}tools/

##
# Log level
LOG_LEVEL=4

##
# Input files
INN_RAW_FILE=${TMP_DIR}${INN_RAW_FILENAME}
GEO_OPTD_FILE=${DATA_DIR}${GEO_OPTD_FILENAME}

##
# Innovata
INN_WPK_FILENAME=wpk_${INN_RAW_FILENAME}
SORTED_INN_WPK_FILENAME=sorted_${INN_WPK_FILENAME}
SORTED_CUT_INN_WPK_FILENAME=cut_${SORTED_INN_WPK_FILENAME}
#
INN_DMP_FILE=${TMP_DIR}${INN_DMP_FILENAME}
INN_WPK_FILE=${TMP_DIR}${INN_WPK_FILENAME}
SORTED_INN_WPK_FILE=${TMP_DIR}${SORTED_INN_WPK_FILENAME}
SORTED_CUT_INN_WPK_FILE=${TMP_DIR}${SORTED_CUT_INN_WPK_FILENAME}

##
# Output
INN_GEO_FILENAME=optd_por_best_known_so_far_null_fixed.csv
#
INN_GEO_FILE=${TMP_DIR}${INN_GEO_FILENAME}

##
# Sanity check
if [ ! -f ${INN_WPK_FILE} ]
then
	echo
	echo "[$0:$LINENO] The '${INN_WPK_FILE}' file does not exist."
	echo "[Hint] Run the following command:"
	echo "${TOOLS_DIR}prepare_innovata_dump_file.sh ${OPTD_DIR}"
	echo
	exit -1
fi

##
#
INN_GEO_FILE_TMP=${INN_GEO_FILE}.tmp
join -t'^' -a 2 ${INN_WPK_FILE} ${GEO_OPTD_FILE} > ${INN_GEO_FILE_TMP}

#
COORD_FIXER=fix_optd_por_best_known_from_innovata.awk
awk -F'^' -f ${COORD_FIXER} ${INN_GEO_FILE_TMP} > ${INN_GEO_FILE}
\rm -f ${INN_GEO_FILE_TMP}

##
# Reporting
echo
echo "Reporting"
echo "---------"
echo "The '${INN_GEO_FILE}' file has been generated from '${INN_RAW_FILE}' and '${GEO_OPTD_FILE}'."
echo "Next step:"
echo "mv ${INN_GEO_FILE} ${GEO_OPTD_FILE}"
echo
