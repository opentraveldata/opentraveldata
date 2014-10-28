#!/bin/bash
#
# One parameter is optional for this script:
# - the file-path of the data dump file extracted from Geonames.
#

displayGeonamesDetails() {
	if [ -z "${OPTDDIR}" ]
	then
		export OPTDDIR=~/dev/geo/optdgit/refdata
	fi
	if [ -z "${MYCURDIR}" ]
	then
		export MYCURDIR=`pwd`
	fi
	echo
	echo "The data dump from Geonames can be obtained from the OpenTravelData project"
	echo "(http://github.com/opentraveldata/optd). For instance:"
	echo "MYCURDIR=`pwd`"
	echo "OPTDDIR=${OPTDDIR}"
	echo "mkdir -p ~/dev/geo"
	echo "cd ~/dev/geo"
	echo "git clone git://github.com/opentraveldata/optd.git optdgit"
	echo "cd optdgit/refdata/geonames/data"
	echo "./getDataFromGeonamesWebsite.sh  # it may take several minutes"
	echo "cd por/admin"
	echo "./aggregateGeonamesPor.sh # it may take several minutes (~10 minutes)"
	if [ "${TMP_DIR}" = "/tmp/por/" ]
	then
		echo "mkdir -p ${TMP_DIR}"
	fi
	echo "cd ${MYCURDIR}"
	echo "${OPTDDIR}/tools/extract_por_with_iata_icao.sh # it may take several minutes"
	echo "It produces both a por_all_iata_YYYYMMDD.csv and a por_all_noicao_YYYYMMDD.csv files,"
	echo "which have to be aggregated into the dump_from_geonames.csv file."
	echo "${OPTDDIR}/tools/preprepare_geonames_dump_file.sh"
	echo "\cp -f ${OPTDDIR}/ORI/optd_por_best_known_so_far.csv ${TMP_DIR}"
	echo "\cp -f ${OPTDDIR}/ORI/ref_airport_popularity.csv ${TMP_DIR}"
	echo "\cp -f ${OPTDDIR}/ORI/optd_por_public.csv ${TMP_DIR}optd_airports.csv"
	echo "${OPTDDIR}/tools/update_airports_csv_after_getting_geonames_iata_dump.sh"
	echo "ls -l ${TMP_DIR}"
	echo
}

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
# OpenTravelData directory
OPTD_DIR=`dirname ${EXEC_FULL_PATH}`
OPTD_DIR="${OPTD_DIR}/"

##
# ORI sub-directory
ORI_DIR=${OPTD_DIR}ORI/
TOOLS_DIR=${OPTD_DIR}tools/

##
# Snapshot date
SNAPSHOT_DATE=`date "+%Y%m%d"`
SNAPSHOT_DATE_HUMAN=`date`

##
# Input files
GEO_IATA_FILENAME=por_all_iata_${SNAPSHOT_DATE}.csv
GEO_NOICAO_FILENAME=por_all_noicao_${SNAPSHOT_DATE}.csv

##
# Output (generated) files
GEO_RAW_FILENAME=dump_from_geonames.csv
#
GEO_RAW_FILE=${TMP_DIR}${GEO_RAW_FILENAME}

##
# Parse command-line options
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<Snapshot date>]"
	echo "  - Snapshot date: '${SNAPSHOT_DATE}' (${SNAPSHOT_DATE_HUMAN})"
	echo "    + ${GEO_IATA_FILE} for the list of IATA codes"
	echo "    + ${GEO_NOICAO_FILE} for the list of IATA codes without ICAO codes"
	echo "  - Default name for the (output) geo data dump file: '${GEO_RAW_FILE}'"
	echo
	exit -1
fi
#
if [ "$1" = "-g" -o "$1" = "--geonames" ];
then
	displayGeonamesDetails
	exit -1
fi

##
# Data dump file with geographical coordinates
if [ "$1" != "" ];
then
	SNAPSHOT_DATE="$1"
	GEO_IATA_FILENAME=por_all_iata_${SNAPSHOT_DATE}.csv
	GEO_NOICAO_FILENAME=por_all_noicao_${SNAPSHOT_DATE}.csv
fi

# If the Geonames dump file is in the current directory, then the current
# directory is certainly intended to be the temporary directory.
if [ -f ${GEO_IATA_FILENAME} ]
then
	TMP_DIR="./"
fi

#
GEO_IATA_FILE=${TMP_DIR}${GEO_IATA_FILENAME}
GEO_NOICAO_FILE=${TMP_DIR}${GEO_NOICAO_FILENAME}

if [ ! -f ${GEO_IATA_FILE} -o ! -f ${GEO_NOICAO_FILE} ]
then
	echo "The '${GEO_IATA_FILE}' and/or '${GEO_NOICAO_FILE}' files do not exist."
	if [ "$1" = "" ];
	then
		displayGeonamesDetails
	fi
	exit -1
fi

##
# 1.1. Aggregate both dump files
cat ${GEO_IATA_FILE} ${GEO_NOICAO_FILE} > ${GEO_RAW_FILE}

##
# 2.1. Extract the header into a temporary file
GEO_RAW_FILE_HEADER=${GEO_RAW_FILE}.tmp.hdr
grep "^iata\(.\+\)" ${GEO_RAW_FILE} > ${GEO_RAW_FILE_HEADER}

# 2.2. Remove the header
sed -i -e "s/^iata\(.\+\)//g" ${GEO_RAW_FILE}
sed -i -e "/^$/d" ${GEO_RAW_FILE}

##
# 3.1. Replace the 'NULL' fields by 'ZZZZ', so as to place them at the end
sed -i -e "s/^\([A-Z0-9]\{3\}\)\^NULL\^\(.\+\)/\1\^ZZZZ\^\2/g" ${GEO_RAW_FILE}

# 3.2. Sort the Geonames dump file according to the (IATA, ICAO, FAAC, feature)
#      code quadruplet
GEO_RAW_FILE_TMP=${GEO_RAW_FILE}.tmp
sort -t'^' -k1,1 -k2,2 -k3,3 -k13,13 ${GEO_RAW_FILE} > ${GEO_RAW_FILE_TMP}
\mv -f ${GEO_RAW_FILE_TMP} ${GEO_RAW_FILE}

# 4.1. Re-add the header
cat ${GEO_RAW_FILE_HEADER} ${GEO_RAW_FILE} > ${GEO_RAW_FILE_TMP}
sed -i -e "/^$/d" ${GEO_RAW_FILE_TMP}
\mv -f ${GEO_RAW_FILE_TMP} ${GEO_RAW_FILE}
\rm -f ${GEO_RAW_FILE_HEADER}

##
# Reporting
echo
echo "Preparation step"
echo "----------------"
echo "The '${GEO_RAW_FILE}' file has been created from the '${GEO_IATA_FILE}' and '${GEO_NOICAO_FILE}' files."
echo

