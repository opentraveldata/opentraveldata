#!/bin/bash

#
# OpenTravelData (OPTD) utility
# Git repository:
#   https://github.com/opentraveldata/opentraveldata/tree/master/tools
#

#
# One parameter is optional for this script:
# - the file-path of the data dump file extracted from UN/LOCODE
#

##
# GNU tools, including on MacOS
source setGnuTools.sh || exit -1

##
# Directories
source setDirs.sh "$0" || exit -1

##
#
displayLOCODEDetails() {
    echo
    echo "####### Note #######"
    echo "# The data dump from UN/LOCODE has to be obtained from UNECE directly."
    echo "# The UN/LOCODE dump file ('${LOCODE_TAB_FILENAME}') should be in the ${TOOLS_DIR} directory"
    echo "#####################"
    echo
}

##
# Cleaning
cleanTempFiles() {
    \rm -f ${LOCODE_CSV_UNSTD_FILE} ${LOCODE_CSV_HDR_FILE} \
	${LOCODE_CSV_UNSTD_NOHDR_FILE} ${LOCODE_CSV_NOHDR_FILE} \
	${LOCODE_CSV_FFNE_FILE}
}

##
# Snapshot date
SNAPSHOT_DATE="$(${DATE_TOOL} +%y%m%d)"
SNAPSHOT_DATE_HUMAN="$($DATE_TOOL)"

##
# OpenTravelData directory
OPTD_DIR="$(dirname ${EXEC_FULL_PATH})"
OPTD_DIR="${OPTD_DIR}/"

##
# OPTD sub-directory
DATA_DIR="${OPTD_DIR}opentraveldata/"
TOOLS_DIR="${OPTD_DIR}tools/"

##
# LOCODE sub-directory
LOCODE_DIR="${OPTD_DIR}data/unlocode/archives/"

##
# Retrieve the latest file
#unlocode-code-list-2020-1.csv
POR_FILE_PFX="unlocode-code-list"
SNPSHT_FILES="$(ls ${TOOLS_DIR}${POR_FILE_PFX}-????-?.csv 2> /dev/null)"
if [ "${SNPSHT_FILES}" != "" ]
then
    # (Trick to) Extract the latest entry
    for myfile in ${SNPSHT_FILES}; do echo > /dev/null; done
    SNPSHT_DATE="$(echo ${myfile} | ${SED_TOOL} -E "s/${POR_FILE_PFX}-([0-9\-]+)\.csv/\1/" | xargs basename)"
else
    echo
    echo "[$0:$LINENO] - No LOCODE-derived POR list CSV dump can be found " \
		 "in the '${TOOLS_DIR}' directory."
    echo "[$0:$LINENO] - Expecting a file named like '${TOOLS_DIR}${POR_FILE_PFX}-YYYY-N.csv'"
    echo
    exit -1
fi
if [ "${SNPSHT_DATE}" != "" ]
then
    LOCODE_TAB_FILENAME="${POR_FILE_PFX}-${SNPSHT_DATE}.csv"
    LOCODE_CSV_FILENAME="${POR_FILE_PFX}-${SNPSHT_DATE}.csv"
else
	echo
    echo "[$0:$LINENO] - There seems to be UN/LOCODE snapshot files " \
		 "(${SNPSHT_FILES})"
	echo "[$0:$LINENO] - However, for some reason, the extraction time-stamp " \
		 "cannot be properly extracted; check for potential errors above (e.g., with sed/gsed)"
	echo
	exit -1
fi

##
# Input files
LOCODE_TAB_FILE="${TOOLS_DIR}${LOCODE_TAB_FILENAME}"
GEO_OPTD_FILENAME="optd_por_best_known_so_far.csv"
#
GEO_OPTD_FILE="${DATA_DIR}${GEO_OPTD_FILENAME}"

##
# Output files
LOCODE_CSV_FILE="${LOCODE_DIR}${LOCODE_CSV_FILENAME}"

##
# Reporting
echo "Source: ${LOCODE_TAB_FILE}"
echo "Target: ${LOCODE_CSV_FILE}"
echo

##
# Temporary
LOCODE_CSV_FFNE_FILE="${TMP_DIR}${LOCODE_CSV_FILENAME}.ffne"
LOCODE_CSV_UNSTD_FILE="${TMP_DIR}${LOCODE_CSV_FILENAME}.unsorted"
LOCODE_CSV_HDR_FILE="${TMP_DIR}${LOCODE_CSV_FILENAME}.hdr"
LOCODE_CSV_UNSTD_NOHDR_FILE="${TMP_DIR}${LOCODE_CSV_FILENAME}.unsorted_nohdr"
LOCODE_CSV_NOHDR_FILE="${TMP_DIR}${LOCODE_CSV_FILENAME}.nohdr"

##
#
if [ "$1" = "-h" -o "$1" = "--help" ]
then
    echo
    echo "Usage: $0 [<log level>]"
    echo "  - Default root directory for the OpenTravelData project Git clone: '${OPTD_DIR}'"
    echo "  - Default path for the OPTD-maintained file of best known coordinates: '${GEO_OPTD_FILE}'"
    echo "  - Default path for the LOCODE data dump file: '${LOCODE_TAB_FILE}'"
    echo "  - Default log level: ${LOG_LEVEL}"
    echo "    + 0: No log; 1: Critical; 2: Error; 3; Notification; 4: Debug; 5: Verbose"
    echo "  - Generated files:"
    echo "    + '${LOCODE_CSV_FILE}'"
    echo
    exit
fi
#
if [ "$1" = "-u" -o "$1" = "--unlocode" -o "$1" = "--unlc" ]
then
    displayLOCODEDetails
    exit
fi
#
if [ ! -f "${GEO_OPTD_FILE}" ]
then
    echo
    echo "[$0:$LINENO] The '${GEO_OPTD_FILE}' file does not exist."
    echo
    exit -1
fi
#
if [ ! -f "${LOCODE_TAB_FILE}" ]
then
    echo
    echo "[$0:$LINENO] The '${LOCODE_TAB_FILE}' file does not exist."
    echo
    displayLOCODEDetails
    exit -1
fi

##
# Cleaning
#
if [ "$1" = "--clean" ]
then
    cleanTempFiles
    exit
fi

##
# Log level
if [ "$1" != "" ]
then
    LOG_LEVEL="$1"
fi


##
# Filter out the POR rules
# 1. Filter the regular POR
#grep -v '^\(\|\".\"\|\"\"\),\"[A-Z]\{2\}\",\"[0-9A-Z]\{3\}\"' ${LOCODE_TAB_FILE}
# 2. Filter the countries
#grep -v '^,\"[A-Z]\{2\}\",,\"\..\+\"' ${LOCODE_TAB_FILE}
# 3. Filter the alternate name rules for POR
#grep -v '^\"=\",\"[A-Z]\{2\}\",\(\|\"\"\),\".\+=.\+\"' ${LOCODE_TAB_FILE}
# 4. Filter the alternate name rules for countries (only FR apparently)
#grep -v '^\(\|\"\"\),\"[A-Z]\{2\}\",\(\|\"\"\),\".\+=.\+\"' ${LOCODE_TAB_FILE}

##
# Replace the empty first fields by 1-white-space fields, as AWK FPAT
# does not seem to be able to recognize records with empty first fields
${SED_TOOL} -E 's/^,/" ",/g' ${LOCODE_TAB_FILE} > ${LOCODE_CSV_FFNE_FILE}

##
# Convert the format
# For some reason, the FPAT pattern of the AWK script does not detect lines
# having the first field empty. We therefore use sed to replace first empty
# fields by 1-white-space fields.
CONVERTER="prepare_unlc_dump_file.awk"
awk -f ${CONVERTER} ${LOCODE_CSV_FFNE_FILE} ${LOCODE_CSV_FFNE_FILE} \
    > ${LOCODE_CSV_UNSTD_FILE}

##
# Sort by LOCODE code

# Extract the header into a temporary file
grep -E "^unlc(.+)" ${LOCODE_CSV_UNSTD_FILE} > ${LOCODE_CSV_HDR_FILE}

# Remove the header from the unsorted file
${SED_TOOL} -E "s/^unlc(.+)//g" ${LOCODE_CSV_UNSTD_FILE} \
    > ${LOCODE_CSV_UNSTD_NOHDR_FILE}
${SED_TOOL} -i"" -E "/^$/d" ${LOCODE_CSV_UNSTD_NOHDR_FILE}

# Sort by LOCODE code the header-less file
sort -t'^' -k1,1 ${LOCODE_CSV_UNSTD_NOHDR_FILE} > ${LOCODE_CSV_NOHDR_FILE}
# DEBUG (uncomment above and remove below)
#cp -f ${LOCODE_CSV_UNSTD_NOHDR_FILE} ${LOCODE_CSV_NOHDR_FILE}

# Reinject the header into the sorted file
cat ${LOCODE_CSV_HDR_FILE} ${LOCODE_CSV_NOHDR_FILE} > ${LOCODE_CSV_FILE}

##
# Cleaning
cleanTempFiles

##
# Reporting
echo
echo "Results"
echo "-------"
echo "The '${LOCODE_CSV_FILE}' file has been derived from '${LOCODE_TAB_FILE}'."
echo "Suggested next step:"
echo "git add ${LOCODE_CSV_FILE}"
echo "git commit -m \"[POR] Added some screen-scraped data\" ${LOCODE_CSV_FILE}"
echo "\rm -f ${LOCODE_TAB_FILE}"
echo

