#!/bin/bash

##
# MacOS 'date' vs GNU date
DATE_TOOL=date
if [ -f /usr/bin/sw_vers ]
then
	DATE_TOOL=gdate
fi


displayUSDOTDetails() {
    ##
    # Snapshot date
    SNAPSHOT_DATE=`$DATE_TOOL "+%Y%m%d"`
    SNAPSHOT_DATE_HUMAN=`$DATE_TOOL`
    echo
    echo "####### Note #######"
    echo "# The World Area Code (WAC) data extraction file has to be obtained from the US DOT directly."
	echo "# See the README file in that directory (or on http://github.com/opentraveldata/opentraveldata/blob/master/data/countries/DOT/README)."
    echo "# The WAC file ('${RAW_USDOT_FILENAME}') should be in the ${USDOT_DIR} directory:"
    ls -la ${USDOT_DIR}
    echo "#####################"
    echo
}

##
# Input file names
#RAW_USDOT_FILENAME=L_WORLD_AREA_CODES.csv
RAW_USDOT_FILENAME=495998804_T_WAC_COUNTRY_STATE.csv
# OpenTravelData version
OPTD_USDOT_FILENAME=optd_usdot_wac.csv

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
# OpenTravelData root directory
OPTD_DIR=`dirname ${EXEC_FULL_PATH}`
OPTD_DIR=${OPTD_DIR}/

##
# OPTD sub-directory
DATA_DIR=${OPTD_DIR}opentraveldata/
TOOLS_DIR=${OPTD_DIR}tools/

##
# US DOT World Area Codes (WAC)
USDOT_DIR=${OPTD_DIR}data/countries/DOT/

##
# Log level
LOG_LEVEL=4

##
# US DOT (input) file
RAW_USDOT_FILE=${USDOT_DIR}${RAW_USDOT_FILENAME}
# OpenTravelData (generated) file
OPTD_USDOT_FILE=${DATA_DIR}${OPTD_USDOT_FILENAME}

# Temporary
OPTD_USDOT_FILE_TMP1=${OPTD_USDOT_FILE}.tmp1
OPTD_USDOT_FILE_TMP2=${OPTD_USDOT_FILE}.tmp2
OPTD_USDOT_FILE_TMP3=${OPTD_USDOT_FILE}.tmp3

##
# Cleaning
if [ "$1" = "--clean" ]
then
    if [ "${TMP_DIR}" = "/tmp/por" ]
    then
		\rm -rf ${TMP_DIR}
    else
		\rm -f ${OPTD_USDOT_FILE_TMP1} ${OPTD_USDOT_FILE_TMP2}
		\rm -f ${OPTD_USDOT_FILE_TMP3}
    fi
    exit
fi


##
#
if [ "$1" = "-h" -o "$1" = "--help" ]
then
    echo
    echo "Usage: $0 [<refdata directory of the OpenTravelData project Git clone> [<log level>]]"
    echo "  - Default refdata directory for the OpenTravelData project Git clone: '${OPTD_DIR}'"
    echo "  - Default log level: ${LOG_LEVEL}"
    echo "    + 0: No log; 1: Critical; 2: Error; 3; Notification; 4: Debug; 5: Verbose"
    echo "  - Default path for the US DOT WAC data dump file: '${RAW_USDOT_FILE}'"
    echo "  - Generated files:"
    echo "    + '${OPTD_USDOT_FILE}'"
    echo
    exit
fi
#
if [ "$1" = "-d" -o "$1" = "--dot" -o "$1" = "--usdot" ]
then
    displayUSDOTDetails
    exit
fi

##
# The OpenTravelData refdata/ sub-directory contains, among other things,
# the OPTD-maintained list of POR file with geographical coordinates.
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
    DATA_DIR=${OPTD_DIR}opentraveldata/
    TOOLS_DIR=${OPTD_DIR}tools/
    OPTD_USDOT_FILE=${DATA_DIR}${OPTD_USDOT_FILE}
fi

##
# Log level
if [ "$2" != "" ]
then
    LOG_LEVEL="$2"
fi

##
# Replace the double comma (,) separator by a comma-hat (,^) pair.
# That is a trick, as the comma pair is not detected afterwards.
sed -e 's/,,/,\^/g' ${RAW_USDOT_FILE} > ${OPTD_USDOT_FILE_TMP1}

# Replace the comma (,) separator by a hat (^) for the numeric fields
# at the beginning of the line
sed -e 's/^\([[:digit:]]\+\),/\1\^/g' \
	${OPTD_USDOT_FILE_TMP1} > ${OPTD_USDOT_FILE_TMP2}

# Replace the comma (,) separator by a hat (^) for the other numeric fields
sed -e 's/\([,^-]\)\([[:digit:]]\+\),/\1\2\^/g' \
	${OPTD_USDOT_FILE_TMP2} > ${OPTD_USDOT_FILE_TMP3}

# Remove the quote characters (")
sed -e 's/\"\([^\"]*\)\",/\1\^/g' ${OPTD_USDOT_FILE_TMP3} > ${OPTD_USDOT_FILE}

##
# Consistency check
awk -F'^' '{if (NF != 17) {\
             print "[Error] The expected number of fields is 17;"\
                   " the following line has got " NF " fields:\n" $0 \
               > "/dev/stderr"}\
           }' ${OPTD_USDOT_FILE}

##
# Reporting
echo
echo "The Open Travel Data (OPTD) version of the US DOT World Area Code (WAC) file, ${OPTD_USDOT_FILE}, has been generated."
echo "git add ${OPTD_USDOT_FILE}"
echo "git diff --cached ${OPTD_USDOT_FILE}"
echo "git commit -m \"[Countries] The US DOT World Area Code (WAC) file now reflects the latest updates.\" ${OPTD_USDOT_FILE}"
echo
