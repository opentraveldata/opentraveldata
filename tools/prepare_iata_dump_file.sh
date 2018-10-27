#!/bin/bash
#
# One parameter is optional for this script:
# - the file-path of the data dump file extracted from IATA
#

##
#
displayIATADetails() {
    echo
    echo "####### Note #######"
    echo "# The data dump from IATA has to be obtained from IATA directly."
    echo "# The IATA dump file ('${IATA_TAB_FILENAME}') should be in the ${TOOLS_DIR} directory"
    echo "#####################"
    echo
}

##
# Cleaning
cleanTempFiles() {
	\rm -f ${IATA_CSV_UNSTD_FILE} ${IATA_CSV_HDR_FILE} \
		${IATA_CSV_UNSTD_NOHDR_FILE} ${IATA_CSV_NOHDR_FILE}
		
}

##
# MacOS 'date' vs GNU date
DATE_TOOL=date
if [ -f /usr/bin/sw_vers ]
then
	DATE_TOOL=gdate
fi

##
# Snapshot date
SNAPSHOT_DATE=$($DATE_TOOL "+%y%m%d")
SNAPSHOT_DATE_HUMAN=$($DATE_TOOL)

##
# Temporary path
TMP_DIR="/tmp/por"
MYCURDIR=$(pwd)

##
# Path of the executable: set it to empty when this is the current directory.
EXEC_PATH=$(dirname $0)
# Trick to get the actual full-path
EXEC_FULL_PATH=$(pushd ${EXEC_PATH})
EXEC_FULL_PATH=$(echo ${EXEC_FULL_PATH} | cut -d' ' -f1)
EXEC_FULL_PATH=$(echo ${EXEC_FULL_PATH} | sed -e 's|~|'${HOME}'|')
#
CURRENT_DIR=$(pwd)
if [ ${CURRENT_DIR} -ef ${EXEC_PATH} ]
then
    EXEC_PATH="."
    TMP_DIR="."
fi
# If the IATA dump file is in the current directory, then the current
# directory is certainly intended to be the temporary directory.
if [ -f ${IATA_TAB_FILENAME} ]
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
OPTD_DIR=$(dirname ${EXEC_FULL_PATH})
OPTD_DIR="${OPTD_DIR}/"

##
# OPTD sub-directory
DATA_DIR=${OPTD_DIR}opentraveldata/
TOOLS_DIR=${OPTD_DIR}tools/

##
# IATA sub-directory
IATA_DIR=${OPTD_DIR}data/IATA/archives/

##
# Sanity check: that (executable) script should be located in the tools/
# sub-directory of the OpenTravelData project Git clone
EXEC_DIR_NAME=$(basename ${EXEC_FULL_PATH})
if [ "${EXEC_DIR_NAME}" != "tools" ]
then
    echo
    echo "[$0:$LINENO] Inconsistency error: this script ($0) should be located in the tools/ sub-directory of the OpenTravelData project Git clone, but apparently is not. EXEC_FULL_PATH=\"${EXEC_FULL_PATH}\""
    echo
    exit -1
fi

##
# Retrieve the latest file
POR_FILE_PFX=iata_airport_list
SNPSHT_DATE=$(ls ${TOOLS_DIR}${POR_FILE_PFX}_????????.txt 2> /dev/null)
if [ "${SNPSHT_DATE}" != "" ]
then
	# (Trick to) Extract the latest entry
	for myfile in ${SNPSHT_DATE}; do echo > /dev/null; done
	SNPSHT_DATE=$(echo ${myfile} | sed -e "s/${POR_FILE_PFX}_\([0-9]\+\)\.txt/\1/" | xargs basename)
else
	echo
	echo "[$0:$LINENO] No IATA-derived POR list CSV dump can be found in the '${TOOLS_DIR}' directory."
	echo "Expecting a file named like '${TOOLS_DIR}${POR_FILE_PFX}_YYYYMMDD.txt'"
	echo
	exit -1
fi
if [ "${SNPSHT_DATE}" != "" ]
then
	SNPSHT_DATE_HUMAN=$(${DATE_TOOL} -d ${SNPSHT_DATE})
else
	SNPSHT_DATE_HUMAN=$(${DATE_TOOL} --date='last Thursday' "+%y%m%d")
	SNPSHT_DATE_HUMAN=$(${DATE_TOOL} --date='last Thursday')
fi
if [ "${SNPSHT_DATE}" != "" ]
then
	IATA_TAB_FILENAME=${POR_FILE_PFX}_${SNPSHT_DATE}.txt
	IATA_CSV_FILENAME=${POR_FILE_PFX}_${SNPSHT_DATE}.csv
fi

##
# Input files
IATA_TAB_FILE=${TOOLS_DIR}${IATA_TAB_FILENAME}
GEO_OPTD_FILENAME=optd_por_best_known_so_far.csv
#
GEO_OPTD_FILE=${DATA_DIR}${GEO_OPTD_FILENAME}

##
# Output files
IATA_CSV_FILE=${IATA_DIR}${IATA_CSV_FILENAME}

##
# Temporary
IATA_CSV_UNSTD_FILE=${TMP_DIR}${IATA_CSV_FILENAME}.unsorted
IATA_CSV_HDR_FILE=${TMP_DIR}${IATA_CSV_FILENAME}.hdr
IATA_CSV_UNSTD_NOHDR_FILE=${TMP_DIR}${IATA_CSV_FILENAME}.unsorted_nohdr
IATA_CSV_NOHDR_FILE=${TMP_DIR}${IATA_CSV_FILENAME}.nohdr

##
#
if [ "$1" = "-h" -o "$1" = "--help" ]
then
    echo
    echo "Usage: $0 [<root directory of the OpenTravelData project Git clone> [<log level>]]"
    echo "  - Default root directory for the OpenTravelData project Git clone: '${OPTD_DIR}'"
    echo "  - Default path for the OPTD-maintained file of best known coordinates: '${GEO_OPTD_FILE}'"
    echo "  - Default path for the IATA data dump file: '${IATA_TAB_FILE}'"
    echo "  - Default log level: ${LOG_LEVEL}"
    echo "    + 0: No log; 1: Critical; 2: Error; 3; Notification; 4: Debug; 5: Verbose"
    echo "  - Generated files:"
    echo "    + '${IATA_CSV_FILE}'"
    echo
    exit
fi
#
if [ "$1" = "-r" -o "$1" = "--iata" ]
then
    displayIATADetails
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
if [ ! -f "${IATA_TAB_FILE}" ]
then
    echo
    echo "[$0:$LINENO] The '${IATA_TAB_FILE}' file does not exist."
    echo
    if [ "$2" = "" ]
    then
		displayIATADetails
    fi
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
if [ "$2" != "" ]
then
    LOG_LEVEL="$2"
fi


##
# Convert the format
CONVERTER=prepare_iata_dump_file.awk
awk -f ${CONVERTER} ${IATA_TAB_FILE} > ${IATA_CSV_UNSTD_FILE}
#CONVERTER=prepare_iata_dump_file_from_tsv.awk
#awk -F'\t' -f ${CONVERTER} ${IATA_TAB_FILE} > ${IATA_CSV_UNSTD_FILE}

##
# Sort by IATA code

# Extract the header into a temporary file
grep "^city_code\(.\+\)" ${IATA_CSV_UNSTD_FILE} > ${IATA_CSV_HDR_FILE}

# Remove the header from the unsorted file
sed -e "s/^city_code\(.\+\)//g" ${IATA_CSV_UNSTD_FILE} \
	> ${IATA_CSV_UNSTD_NOHDR_FILE}
sed -i -e "/^$/d" ${IATA_CSV_UNSTD_NOHDR_FILE}

# Sort by IATA code the header-less file
sort -t'^' -k1,1 ${IATA_CSV_UNSTD_NOHDR_FILE} > ${IATA_CSV_NOHDR_FILE}

# Reinject the header into the sorted file
cat ${IATA_CSV_HDR_FILE} ${IATA_CSV_NOHDR_FILE} > ${IATA_CSV_FILE}

##
# Cleaning
cleanTempFiles

##
# Reporting
echo
echo "Results"
echo "-------"
echo "The '${IATA_CSV_FILE}' file has been derived from '${IATA_TAB_FILE}'."
echo "Suggested next step:"
echo "git add ${IATA_CSV_FILE}"
echo "git commit -m \"[POR] Added some screen-scraped data\" ${IATA_CSV_FILE}"
echo "\rm -f ${IATA_TAB_FILE}"
echo

