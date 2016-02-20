#!/bin/bash

# Derive the list of active POR (point of reference) entries
# for any given language, from the OPTD-maintained data file of POR:
# ../opentraveldata/optd_por_public.csv
#
# => optd_por_public_lang.csv
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
# Target language
TARGET_LANG="en"

##
# OpenTravelData directory
OPTD_DIR=`dirname ${EXEC_FULL_PATH}`
OPTD_DIR="${OPTD_DIR}/"

##
# OPTD sub-directories
DATA_DIR=${OPTD_DIR}opentraveldata/
SAMPLE_DATA_DIR=${DATA_DIR}samples_4_lang/
TOOLS_DIR=${OPTD_DIR}tools/

##
# Log level
LOG_LEVEL=3

##
# File of OPTD-maintained POR (points of reference)
OPTD_POR_BASEFILENAME=optd_por_public
OPTD_POR_FILENAME=${OPTD_POR_BASEFILENAME}.csv
OPTD_POR_FILE=${DATA_DIR}${OPTD_POR_FILENAME}
# POR list on which the seeking of translations should be restricted
OPTD_POD_LANG_LIST_FILENAME=optd_por_list_for_${TARGET_LANG}.csv
OPTD_POR_LANG_LIST_FILE=${SAMPLE_DATA_DIR}${OPTD_POD_LANG_LIST_FILENAME}

##
# Target (generated files)
OPTD_POR_TGT_FILENAME=${OPTD_POR_BASEFILENAME}_${TARGET_LANG}_fltd.csv
OPTD_POR_TGT_FILE=${DATA_DIR}${OPTD_POR_TGT_FILENAME}

##
# Parse command-line options
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<Target language>]"
	echo "  - Target language: '${TARGET_LANG}'"
	echo "    + ${OPTD_POR_FILE} contains the OPTD-maintained list of Points of Reference (POR)"
	echo "    + ${OPTD_POR_LANG_LIST_FILE} contains the list of POR on which the translations are sought"
	echo "Generated:"
	echo "    + ${OPTD_POR_TGT_FILE} contains the list of OPTD-maintained POR for that language"
	echo
	exit -1
fi

##
# Target date
if [ "$1" != "" ];
then
	TARGET_LANG="$1"
	OPTD_POR_TGT_FILENAME=${OPTD_POR_BASEFILENAME}_${TARGET_LANG}_fltd.csv
	OPTD_POR_TGT_FILE=${DATA_DIR}${OPTD_POR_TGT_FILENAME}
	OPTD_POD_LANG_LIST_FILENAME=optd_por_list_for_${TARGET_LANG}.csv
	OPTD_POR_LANG_LIST_FILE=${SAMPLE_DATA_DIR}${OPTD_POD_LANG_LIST_FILENAME}
fi

##
#
if [ ! -f "${OPTD_POR_LANG_LIST_FILE}" ]
then
	echo
	echo "The POR list file ('${OPTD_POR_LANG_LIST_FILE}') is missing."
	echo "See ../opentraveldata/samples_4_lang/optd_por_list_for_ar.csv for a sample file."
	echo
	exit -1
fi

##
# Cleaning
#
if [ "$1" = "--clean" ]
then
	OPTD_POR_TGT_ALL_FILENAME=${OPTD_POR_BASEFILENAME}_??_fltd.csv
	OPTD_POR_TGT_ALL_FILE=${DATA_DIR}${OPTD_POR_TGT_ALL_FILENAME}
	\rm -f ${OPTD_POR_TGT_ALL_FILE}
	exit
fi

##
# Extraction of the valid POR entries for the given date.
echo
echo "Extraction Step"
echo "---------------"
echo
EXTRACTER=extract_por_for_a_language_with_por_list.awk
time awk -F'^' -v tgt_lang=${TARGET_LANG} -f ${EXTRACTER} \
	 ${OPTD_POR_LANG_LIST_FILE} ${OPTD_POR_FILE} > ${OPTD_POR_TGT_FILE}

##
# Reporting
#
echo
echo "Reporting Step"
echo "--------------"
echo
echo "wc -l ${OPTD_POR_FILE} ${OPTD_POR_TGT_FILE}"
echo
echo "Hints for next steps:"
echo "---------------------"
echo "# Display the list ordered by PageRank values:"
echo "sort -t';' -k5nr,5 ${OPTD_POR_TGT_FILE} | less"
echo
echo "# Filter only on airports and cities"
echo "awk -F';' '/^[A-Z]{3};[AC]{1,2}/ {print \$0}' ${OPTD_POR_TGT_FILE} | sort -t';' -k5nr,5 | less"
echo
echo "# Filter only on the airports having no name for that language"
echo "awk -F';' '/^[A-Z]{3};[AC]{1,2}/ {if (\$9 == \"\") {print \$0}}' ${OPTD_POR_TGT_FILE} | less"
echo
echo "# Display the number of airports: 1. having a name for that language, having no name for that language, 3. in total"
echo "awk -F';' '/^[A-Z]{3};[AC]{1,2}/ {if (\$5 != \"\" && \$9 != \"\") {print \$0}}' ${OPTD_POR_TGT_FILE} | wc -l"
echo "awk -F';' '/^[A-Z]{3};[AC]{1,2}/ {if (\$5 != \"\" && \$9 == \"\") {print \$0}}' ${OPTD_POR_TGT_FILE} | wc -l"
echo "awk -F';' '/^[A-Z]{3};[AC]{1,2}/ {if (\$5 != \"\") {print \$0}}' ${OPTD_POR_TGT_FILE} | wc -l"
echo
