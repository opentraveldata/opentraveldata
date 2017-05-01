#!/bin/bash
#
# One parameter is optional for this script:
# - the file-path of the dump file extracted from the reference data.
#
# Create a light POR reference data file, from:
# - dump_from_ref_city.csv
#
# => optd_por_ref.csv

##
# MacOS 'date' vs GNU date
DATE_TOOL=date
if [ -f /usr/bin/sw_vers ]
then
	DATE_TOOL=gdate
fi



displayRefDetails() {
    ##
    # Snapshot date
	SNAPSHOT_DATE=`$DATE_TOOL "+%Y%m%d"`
	SNAPSHOT_DATE_HUMAN=`$DATE_TOOL`
	echo
	echo "####### Note #######"
	echo "# The data dump from reference data can be obtained from this project"
	echo "# (http://<gitorious/bitbucket>/dataanalysis/dataanalysis.git). For instance:"
	echo "DAREF=~/dev/dataanalysis/dataanalysisgit/data_generation"
	echo "mkdir -p ~/dev/dataanalysis"
	echo "cd ~/dev/dataanalysis"
	echo "git clone git://<gitorious/bitbucket>/dataanalysis/dataanalysis.git dataanalysisgit"
	echo "cd \${DAREF}/REF"
	echo "# The following script fetches a SQLite file, holding reference data,"
	echo "# and translates it into three MySQL-compatible SQL files:"
	echo "./fetch_sqlite_ref.sh # it may take several minutes"
	echo "# It produces three create_*_ref_*${SNAPSHOT_DATE}.sql files, which are then"
	echo "# used by the following script, in order to load the reference data into MySQL:"
	echo "./create_ref_user.sh"
	echo "./create_ref_db.sh"
	echo "./create_all_tables.sh"
	if [ "${TMP_DIR}" = "/tmp/por/" ]
	then
		echo "mkdir -p ${TMP_DIR}"
	fi
	echo "cd ${MYCURDIR}"
	echo "# The POR database table has then to be exported into a CSV file."
	echo "\${DAREF}/por/extract_ref_por.sh"
	echo "\cp -f ${TMP_DIR}por_all_ref_${SNAPSHOT_DATE}.csv ${TMP_DIR}dump_from_ref_city.csv"
	echo "\cp -f ${OPTDDIR}/opentraveldata/optd_por_best_known_so_far.csv ${TMP_DIR}"
	echo "\cp -f ${OPTDDIR}/opentraveldata/ref_airport_pageranked.csv ${TMP_DIR}"
	echo "\cp -f ${OPTDDIR}/opentraveldata/optd_por.csv ${TMP_DIR}optd_airports.csv"
	echo "\${DAREF}/update_airports_csv_after_getting_ref_city_dump.sh"
	echo "ls -l ${TMP_DIR}"
	echo "#####################"
	echo
}

##
# REF (to be found, as temporary files, within the ../tools directory)
GEO_REF_FILENAME=dump_from_ref_city.csv

##
# Output files
OPTD_REF_FILENAME=optd_por_ref.csv

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
# If the reference data dump file is in the current directory, then the current
# directory is certainly intended to be the temporary directory.
if [ -f ${GEO_REF_FILENAME} ]
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
    echo "[$0:$LINENO] Inconsistency error: this script ($0) should be located in the tools/ sub-directory of the OpenTravelData project Git clone, but apparently is not. EXEC_FULL_PATH=\"${EXEC_FULL_PATH}\""
    echo
    exit -1
fi

##
# OpenTravelData directory
OPTD_DIR=`dirname ${EXEC_FULL_PATH}`
OPTD_DIR="${OPTD_DIR}/"

##
# OPTD sub-directory
DATA_DIR=${OPTD_DIR}opentraveldata/
TOOLS_DIR=${OPTD_DIR}tools/
REF_DIR=${TOOLS_DIR}

##
# Log level
LOG_LEVEL=4

##
# Input files
GEO_REF_FILE=${TOOLS_DIR}${GEO_REF_FILENAME}

##
# Output files
OPTD_REF_FILE=${DATA_DIR}${OPTD_REF_FILENAME}


##
# Cleaning
if [ "$1" = "--clean" ]
then
    if [ "${TMP_DIR}" = "/tmp/por" ]
    then
		\rm -rf ${TMP_DIR}
    else
		echo
    fi
    exit
fi


##
#
if [ "$1" = "-h" -o "$1" = "--help" ]
then
    echo
	echo "Usage: $0 [<root directory of the OpenTravelData (OPTD) project Git clone> [<Reference data directory for data dump files> [<log level>]]]"
	echo
	echo " - Default log level: ${LOG_LEVEL}"
	echo "   + 0: No log; 1: Critical; 2: Error; 3; Notification; 4: Debug; 5: Verbose"
	echo
	echo " - Default root directory for the OPTD project Git clone: '${OPTD_DIR}'"
	echo " - Default directory for the reference data file: '${REF_DIR}'"
	echo
	echo "* Input data files"
	echo "------------------"
	echo " - Reference data file: '${GEO_REF_FILE}'"
	echo
	echo "* Output data file"
	echo "------------------"
	echo " - OPTD-maintained list of reference POR: '${OPTD_REF_FILE}'"
    echo
    exit
fi

##
# The OpenTravelData opentraveldata/ sub-directory contains, among other things,
# the OPTD-maintained list of POR file with geographical coordinates.
if [ "$1" != "" ]
then
    if [ ! -d $1 ]
    then
		echo
		echo "[$0:$LINENO] The first parameter ('$1') should point to the root directory of the OpenTravelData project Git clone. It is not accessible here."
		echo
		exit -1
    fi
    OPTD_DIR="$1/"
    DATA_DIR=${OPTD_DIR}opentraveldata/
    TOOLS_DIR=${OPTD_DIR}tools/
	REF_DIR=${TOOLS_DIR}
	OPTD_REF_FILE=${DATA_DIR}${OPTD_REF_FILENAME}
	GEO_REF_FILE=${TOOLS_DIR}${GEO_REF_FILENAME}
fi

if [ ! -f "${GEO_REF_FILE}" ]
then
    echo
    echo "[$0:$LINENO] The '${GEO_REF_FILE}' file does not exist."
    echo
    if [ "$1" = "" ]
    then
		displayRefDetails
    fi
    exit -1
fi

##
# Reference data file with geographical coordinates
if [ "$2" != "" ]
then
	REF_DIR="$2"
	GEO_REF_FILE=${REF_DIR}${GEO_REF_FILENAME}
	if [ "${GEO_REF_FILE}" = "${GEO_REF_FILENAME}" ]
	then
		GEO_REF_FILE="${TMP_DIR}${GEO_REF_FILE}"
	fi
fi

if [ ! -f "${GEO_REF_FILE}" ]
then
	echo
	echo "[$0:$LINENO] The '${GEO_REF_FILE}' file does not exist."
	echo
	if [ "$2" = "" ]
	then
		displayRefDetails
	fi
	exit -1
fi


##
# Log level
if [ "$3" != "" ]
then
    LOG_LEVEL="$3"
fi


##
# Generate a second version of the file with the OPTD primary key
# (integrating the location type)
REF_NO_GEO_EXTRACTOR=${TOOLS_DIR}extract_ref_por.awk
awk -F'^' -v log_level=${LOG_LEVEL} -f ${REF_NO_GEO_EXTRACTOR} \
    ${GEO_REF_FILE} > ${OPTD_REF_FILE}


##
# Reporting
echo
echo "Preparation step"
echo "----------------"
echo "The '${OPTD_REF_FILE}' file has been derived from '${GEO_REF_FILE}'."
echo
