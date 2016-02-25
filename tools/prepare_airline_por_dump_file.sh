#!/bin/bash
#
# One parameter is optional for this script:
# - the file-path of the data dump file extracted from the schedule-derived file
#

displayScheduleDetails() {
    ##
    echo
    echo "####### Note #######"
    echo "# The data dump from the airline list of POR has to be derived from SSIM7 schedule files."
    echo "# The airline POR list dump file ('${SCH_RAW_FILENAME}') should be in the ${SCH_DIR} directory:"
    ls -la ${SCH_DIR}
    echo "#####################"
    echo
}

##
# Output file name
AIR_POR_LST_FILENAME=dump_from_airline_por.csv
AIR_POR_LST_IN_DATA_FILENAME=optd_airline_por.csv

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
# If the airline POR list dump file is in the current directory, then the current
# directory is certainly intended to be the temporary directory.
if [ -f ${AIR_POR_LST_FILENAME} ]
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
LOG_LEVEL=4

##
# Snapshot date
SNAPSHOT_DATE=`date "+%Y%m%d"`
SNAPSHOT_DATE_HUMAN=`date`

##
# Retrieve the latest schedule file
POR_FILE_PFX2=oag_schedule_opt
LST_EXTRACT_DATE=`ls ${TOOLS_DIR}${POR_FILE_PFX2}_??????_all.csv 2> /dev/null`
if [ "${LST_EXTRACT_DATE}" != "" ]
then
	# (Trick to) Extract the latest entry
	for myfile in ${LST_EXTRACT_DATE}; do echo > /dev/null; done
	LST_EXTRACT_DATE=`echo ${myfile} | sed -e "s/${POR_FILE_PFX2}_\([0-9]\+\)_all\.csv/\1/" | xargs basename`
else
	echo
	echo "[$0:$LINENO] No schedule-derived airline POR list CSV dump can be found in the '${TOOLS_DIR}' directory."
	echo "Expecting a file named like '${TOOLS_DIR}${POR_FILE_PFX2}_YYMMDD_all.csv'"
	echo
	exit -1
fi
if [ "${LST_EXTRACT_DATE}" != "" ]
then
	LST_EXTRACT_DATE_HUMAN=`date -d ${LST_EXTRACT_DATE}`
else
	LST_EXTRACT_DATE_HUMAN=`date --date='last Thursday' "+%y%m%d"`
	LST_EXTRACT_DATE_HUMAN=`date --date='last Thursday'`
fi
if [ "${LST_EXTRACT_DATE}" != "" ]
then
	LST_SCH_TVL_ALL_FILENAME=${POR_FILE_PFX2}_${LST_EXTRACT_DATE}_all.csv
fi

##
# Input files
LST_SCH_TVL_ALL_FILE=${TOOLS_DIR}${LST_SCH_TVL_ALL_FILENAME}

##
# Output files
AIR_POR_LST_FILE=${TMP_DIR}${AIR_POR_LST_FILENAME}
AIR_POR_LST_IN_DATA_FILE=${DATA_DIR}${AIR_POR_LST_IN_DATA_FILENAME}

##
# Temporary files
HDR_AIR_POR_LST_FILE=${TMP_DIR}${AIR_POR_LST_FILE}.hdr


##
# Cleaning
if [ "$1" = "--clean" ]
then
    if [ "${TMP_DIR}" = "/tmp/por" ]
    then
		\rm -rf ${TMP_DIR}
    else
		\rm -f ${HDR_AIR_POR_LST_FILE}
    fi
    exit
fi


##
#
if [ "$1" = "-h" -o "$1" = "--help" ]
then
    echo
    echo "Usage: $0 [<Airline POR list data file> [<log level>]]"
    echo "  - Default directory for the OpenTravelData project Git clone: '${OPTD_DIR}'"
    echo "  - Default path for the input airline POR list data file: '${LST_SCH_TVL_ALL_FILE}'"
	echo "  - Default path for the output airline POR list data file: '${AIR_POR_LST_IN_DATA_FILE}'"
    echo "  - Default log level: ${LOG_LEVEL}"
    echo "    + 0: No log; 1: Critical; 2: Error; 3; Notification; 4: Debug; 5: Verbose"
    echo "  - Generated files:"
    echo "    + '${AIR_POR_LST_FILE}'"
    echo
    exit
fi
#
if [ "$1" = "-r" -o "$1" = "--schedule" ]
then
    displayScheduleDetails
    exit
fi

##
# Airline POR list data file with flight frequencies
if [ "$1" != "" ]
then
	LST_SCH_TVL_ALL_FILE="$1"
fi

if [ ! -f "${LST_SCH_TVL_ALL_FILE}" ]
then
    echo
    echo "[$0:$LINENO] The '${LST_SCH_TVL_ALL_FILE}' file does not exist."
    echo
    if [ "$1" = "" ]
    then
		displayScheduleDetails
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
# Generate a simple dump file with the following fields
# airline_code^apt_org^apt_dst^flt_freq
echo "airline_code^apt_org^apt_dst^flt_freq" > ${AIR_POR_LST_FILE}
cut -d'^' -f 1-4 ${LST_SCH_TVL_ALL_FILE} >> ${AIR_POR_LST_FILE}

##
# Reporting
echo
echo "Preparation step"
echo "----------------"
echo "The '${AIR_POR_LST_FILE}' file has been derived from '${LST_SCH_TVL_ALL_FILE}'."
echo
echo "Next steps:"
echo "cp -f ${AIR_POR_LST_FILE} ${AIR_POR_LST_IN_DATA_FILE}"
echo "git add ${AIR_POR_LST_IN_DATA_FILE}"
echo "git commit -m \"[Airlines] Updated with latest POR network information.\" ${AIR_POR_LST_IN_DATA_FILE}"
echo

