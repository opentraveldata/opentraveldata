#!/bin/bash

# Derive the list of active POR (point of reference) entries
# for any given language and airline combination,
# from the OPTD-maintained data file of POR:
# ../opentraveldata/optd_por_public.csv
#
# => optd_por_public_<language_code>_<airline_code>.csv
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
# Target airline
TARGET_AIR="QF"

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
# File of OPTD-maintained POR (points of reference)
OPTD_POR_BASEFILENAME=optd_por_public
OPTD_POR_FILENAME=${OPTD_POR_BASEFILENAME}.csv
OPTD_POR_FILE=${DATA_DIR}${OPTD_POR_FILENAME}
OPTD_AIR_POR_FILENAME=optd_airline_por.csv
OPTD_AIR_POR_FILE=${DATA_DIR}${OPTD_AIR_POR_FILENAME}

##
# Target (generated files)
OPTD_POR_TGT_FILENAME=${OPTD_POR_BASEFILENAME}_${TARGET_LANG}_${TARGET_AIR}.csv
OPTD_POR_TGT_FILE=${DATA_DIR}${OPTD_POR_TGT_FILENAME}

##
# Parse command-line options
if [ "$1" = "-h" -o "$1" = "--help" ]
then
	echo
	echo "Usage: $0 [<target language> [<target airline>]]"
	echo "  - Target language (eg, 'en', 'ru', 'zh'): '${TARGET_LANG}'"
	echo "  - Target airline (eg, 'aa', 'ba', 'qf'):  '${TARGET_AIR}'"
	echo "    + ${OPTD_POR_FILE} contains the OPTD-maintained list of Points of Reference (POR)"
	echo "    + ${OPTD_AIR_POR_FILE} contains the OPTD-maintained list of POR per airline"
	echo "    + ${OPTD_POR_TGT_FILE} contains the list of OPTD-maintained POR for that language and airline combination"
	echo
	exit -1
fi

##
# Target date
if [ "$1" != "" ]
then
	TARGET_LANG=`echo $1 | tr [:upper:] [:lower:]`
	OPTD_POR_TGT_FILENAME=${OPTD_POR_BASEFILENAME}_${TARGET_LANG}_${TARGET_AIR}.csv
	OPTD_POR_TGT_FILE=${DATA_DIR}${OPTD_POR_TGT_FILENAME}
fi

##
# Target airline
if [ "$2" != "" ]
then
	TARGET_AIR=`echo $2 | tr [:lower:] [:upper:]`
	OPTD_POR_TGT_FILENAME=${OPTD_POR_BASEFILENAME}_${TARGET_LANG}_${TARGET_AIR}.csv
	OPTD_POR_TGT_FILE=${DATA_DIR}${OPTD_POR_TGT_FILENAME}
fi

##
# Cleaning
#
if [ "$1" = "--clean" ]
then
	OPTD_POR_TGT_ALL_FILENAME=${OPTD_POR_BASEFILENAME}_??_??.csv
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
EXTRACTER=extract_por_per_airline.awk
time awk -F'^' -v tgt_lang=${TARGET_LANG} -v tgt_air=${TARGET_AIR} \
	 -f ${EXTRACTER} ${OPTD_AIR_POR_FILE} ${OPTD_POR_FILE} > ${OPTD_POR_TGT_FILE}

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
echo "# Filter only on the airports"
echo "awk -F';' '/^[A-Z]{3};[AC]{1,2}/ {if (\$2 != \"C\") {print \$0}}' ${OPTD_POR_TGT_FILE} | less"
echo
echo "# Combine both rules above"
echo "awk -F';' '/^[A-Z]{3};[AC]{1,2}/ {if (\$2 != \"C\") {print \$0}}' ${OPTD_POR_TGT_FILE} | sort -t';' -k5nr,5 | less"
echo
echo "# Filter only on the airports having no name for that language"
echo "awk -F';' '/^[A-Z]{3};[AC]{1,2}/ {if (\$2 != \"C\" && \$9 == \"\") {print \$0}}' ${OPTD_POR_TGT_FILE} | sort -t';' -k5nr,5 | less"
echo
echo "# Display the number of airports: 1. having a name for that language, having no name for that language, 3. in total"
echo "awk -F';' '/^[A-Z]{3};[AC]{1,2}/ {if (\$2 != \"C\" && \$5 != \"\" && \$9 != \"\") {print \$0}}' ${OPTD_POR_TGT_FILE} | wc -l"
echo "awk -F';' '/^[A-Z]{3};[AC]{1,2}/ {if (\$2 != \"C\" && \$5 != \"\" && \$9 == \"\") {print \$0}}' ${OPTD_POR_TGT_FILE} | wc -l"
echo "awk -F';' '/^[A-Z]{3};[AC]{1,2}/ {if (\$2 != \"C\" && \$5 != \"\") {print \$0}}' ${OPTD_POR_TGT_FILE} | wc -l"
echo
