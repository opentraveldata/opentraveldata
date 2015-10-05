#!/bin/bash
#
# One parameter is optional for this script:
# - the file-path of the dump file extracted from the reference data.
#

displayGeonamesDetails() {
	if [ -z "${OPTDDIR}" ]
	then
		export OPTDDIR=~/dev/geo/optdgit
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
	echo "\cp -f ${OPTDDIR}/opentraveldata/optd_por_best_known_so_far.csv ${TMP_DIR}"
	echo "\cp -f ${OPTDDIR}/opentraveldata/ref_airport_popularity.csv ${TMP_DIR}"
	echo "\cp -f ${OPTDDIR}/opentraveldata/optd_por_public.csv ${TMP_DIR}optd_airports.csv"
	echo "${OPTDDIR}/tools/update_airports_csv_after_getting_geonames_iata_dump.sh"
	echo "ls -l ${TMP_DIR}"
	echo
}

displayRefDetails() {
    ##
    # Snapshot date
	SNAPSHOT_DATE=`date "+%Y%m%d"`
	SNAPSHOT_DATE_HUMAN=`date`
	echo
	echo "####### Note #######"
	echo "# The data dump from reference data can be obtained from this project"
	echo "# (http://<gitorious/bitbucket>/dataanalysis/dataanalysis.git). For instance:"
	echo "DAREF=~/dev/dataanalysis/dataanalysisgit/data_generation"
	echo "mkdir -p ~/dev/dataanalysis"
	echo "cd ~/dev/dataanalysis"
	echo "git clone git://<gitorious/bitbucket>/dataanalysis/dataanalysis.git dataanalysisgit"
	echo "cd \${DAREF}/RFD"
	echo "# The following script fetches a SQLite file, holding reference data,"
	echo "# and translates it into three MySQL-compatible SQL files:"
	echo "./fetch_sqlite_rfd.sh # it may take several minutes"
	echo "# It produces three create_*_rfd_*${SNAPSHOT_DATE}.sql files, which are then"
	echo "# used by the following script, in order to load the reference data into MySQL:"
	echo "./create_rfd_user.sh"
	echo "./create_rfd_db.sh"
	echo "./create_all_tables.sh rfd rfd_rfd ${SNAPSHOT_DATE} localhost"
	if [ "${TMP_DIR}" = "/tmp/por/" ]
	then
		echo "mkdir -p ${TMP_DIR}"
	fi
	echo "cd ${MYCURDIR}"
	echo "# The MySQL CRB_CITY table has then to be exported into a CSV file."
	echo "\${DAREF}/por/extract_por_rfd_crb_city.sh rfd rfd_rfd localhost"
	echo "\cp -f ${TMP_DIR}por_all_rfd_${SNAPSHOT_DATE}.csv ${TMP_DIR}dump_from_crb_city.csv"
	echo "\cp -f ${OPTDDIR}/opentraveldata/optd_por_best_known_so_far.csv ${TMP_DIR}"
	echo "\cp -f ${OPTDDIR}/opentraveldata/ref_airport_pageranked.csv ${TMP_DIR}"
	echo "\cp -f ${OPTDDIR}/opentraveldata/optd_por.csv ${TMP_DIR}optd_airports.csv"
	echo "\${DAREF}/update_airports_csv_after_getting_crb_city_dump.sh"
	echo "ls -l ${TMP_DIR}"
	echo "#####################"
	echo
}

##
# Input file names
AIR_REF_FILENAME=dump_from_crb_airline.csv
GEO_REF_FILENAME=dump_from_crb_city.csv
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
# If the reference data file is in the current directory, then the current
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
DATA_DIR=${OPTD_DIR}opentraveldata/
TOOLS_DIR=${OPTD_DIR}tools/
REF_DIR=${TOOLS_DIR}

##
# Log level
LOG_LEVEL=4

##
# Input files
AIR_REF_FILE=${TOOLS_DIR}${AIR_REF_FILENAME}
GEO_REF_FILE=${TOOLS_DIR}${GEO_REF_FILENAME}
GEO_OPTD_FILE=${DATA_DIR}${GEO_OPTD_FILENAME}

##
# Reference data
AIR_REF_CAP_FILENAME=cap_${AIR_REF_FILENAME}
GEO_REF_CAP_FILENAME=cap_${GEO_REF_FILENAME}
GEO_REF_WPK_FILENAME=wpk_${GEO_REF_FILENAME}
SORTED_GEO_REF_WPK_FILENAME=sorted_${GEO_REF_WPK_FILENAME}
SORTED_CUT_GEO_REF_WPK_FILENAME=cut_${SORTED_GEO_REF_WPK_FILENAME}
#
AIR_REF_CAP_FILE=${TMP_DIR}${AIR_REF_CAP_FILENAME}
GEO_REF_CAP_FILE=${TMP_DIR}${GEO_REF_CAP_FILENAME}
GEO_REF_WPK_FILE=${TMP_DIR}${GEO_REF_WPK_FILENAME}
SORTED_GEO_REF_WPK_FILE=${TMP_DIR}${SORTED_GEO_REF_WPK_FILENAME}
SORTED_CUT_GEO_REF_WPK_FILE=${TMP_DIR}${SORTED_CUT_GEO_REF_WPK_FILENAME}


##
# Cleaning
if [ "$1" = "--clean" ]
then
	if [ "${TMP_DIR}" = "/tmp/por" ]
	then
		\rm -rf ${TMP_DIR}
	else
		\rm -f ${SORTED_GEO_REF_WPK_FILE} ${SORTED_CUT_GEO_REF_WPK_FILE}
		\rm -f ${AIR_REF_CAP_FILE} ${GEO_REF_CAP_FILE} ${GEO_REF_WPK_FILE}
	fi
	exit
fi


##
#
if [ "$1" = "-h" -o "$1" = "--help" ]
then
	echo
	echo "Usage: $0 [<refdata directory of the OpenTravelData project Git clone> [<Reference data directory for data dump files> [<log level>]]]"
	echo "  - Default refdata directory for the OpenTravelData project Git clone: '${OPTD_DIR}'"
	echo "  - Default path for the OPTD-maintained file of best known coordinates: '${GEO_OPTD_FILE}'"
	echo "  - Default path for the reference data files: '${REF_DIR}'"
	echo "    + 'Airlines (CRB_AIRLINE): ${AIR_REF_FILE}'"
	echo "    + 'Airports/cities (CRB_CITY): ${GEO_REF_FILE}'"
	echo "  - Default log level: ${LOG_LEVEL}"
	echo "    + 0: No log; 1: Critical; 2: Error; 3; Notification; 4: Debug; 5: Verbose"
	echo "  - Generated files:"
	echo "    + '${AIR_REF_CAP_FILE}'"
	echo "    + '${GEO_REF_CAP_FILE}'"
	echo "    + '${GEO_REF_WPK_FILE}'"
	echo "    + '${SORTED_GEO_REF_WPK_FILE}'"
	echo "    + '${SORTED_CUT_GEO_REF_WPK_FILE}'"
	echo
	exit
fi
#
if [ "$1" = "-g" -o "$1" = "--geonames" ]
then
	displayGeonamesDetails
	exit
fi
if [ "$1" = "-r" -o "$1" = "--rfd" ]
then
	displayRefDetails
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
	REF_DIR=${TOOLS_DIR}
	GEO_OPTD_FILE=${DATA_DIR}${GEO_OPTD_FILENAME}
fi

if [ ! -f "${GEO_OPTD_FILE}" ]
then
	echo
	echo "[$0:$LINENO] The '${GEO_OPTD_FILE}' file does not exist."
	echo
	if [ "$1" = "" ]
	then
		displayGeonamesDetails
	fi
	exit -1
fi

##
# Reference data file with geographical coordinates
if [ "$2" != "" ]
then
	REF_DIR="$2"
	AIR_REF_FILE=${REF_DIR}${AIR_REF_FILENAME}
	GEO_REF_FILE=${REF_DIR}${GEO_REF_FILENAME}
	if [ "${GEO_REF_FILE}" = "${GEO_REF_FILENAME}" ]
	then
		GEO_REF_FILE="${TMP_DIR}${GEO_REF_FILE}"
	fi
fi
AIR_REF_CAP_FILE=${TMP_DIR}${AIR_REF_CAP_FILENAME}
GEO_REF_CAP_FILE=${TMP_DIR}${GEO_REF_CAP_FILENAME}
GEO_REF_WPK_FILE=${TMP_DIR}${GEO_REF_WPK_FILENAME}
SORTED_GEO_REF_WPK_FILE=${TMP_DIR}${SORTED_GEO_REF_WPK_FILENAME}
SORTED_CUT_GEO_REF_WPK_FILE=${TMP_DIR}${SORTED_CUT_GEO_REF_WPK_FILENAME}

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

if [ ! -f "${AIR_REF_FILE}" ]
then
	echo
	echo "[$0:$LINENO] The '${AIR_REF_FILE}' file does not exist."
	echo
	if [ "$2" = "" ]
	then
		displayRefDetails
	fi
fi

##
# Log level
if [ "$3" != "" ]
then
	LOG_LEVEL="$3"
fi


##
# Capitalise the names of the airline dump file, if existing
REF_CAPITILISER=rfd_capitalise.awk
if [ -f "${AIR_REF_FILE}" ]
then
	awk -F'^' -v log_level=${LOG_LEVEL} -f ${REF_CAPITILISER} ${AIR_REF_FILE} \
		> ${AIR_REF_CAP_FILE}
fi

##
# Capitalise the names of the geographical dump file
awk -F'^' -v log_level=${LOG_LEVEL} -f ${REF_CAPITILISER} ${GEO_REF_FILE} \
	> ${GEO_REF_CAP_FILE}

##
# Generate a second version of the geographical file with the OPTD primary key
# (integrating the location type)
OPTD_PK_ADDER=${TOOLS_DIR}rfd_pk_creator.awk
awk -F'^' -v log_level=${LOG_LEVEL} -f ${OPTD_PK_ADDER} \
	${GEO_OPTD_FILE} ${GEO_REF_CAP_FILE} > ${GEO_REF_WPK_FILE}
#sort -t'^' -k1,1 ${GEO_REF_WPK_FILE}

##
# Remove the header (first line) of the geographical file
GEO_REF_WPK_FILE_TMP=${GEO_REF_WPK_FILE}.tmp
sed -e "s/^pk\(.\+\)//g" ${GEO_REF_WPK_FILE} > ${GEO_REF_WPK_FILE_TMP}
sed -i -e "/^$/d" ${GEO_REF_WPK_FILE_TMP}


##
# That version of the REF geographical dump file (without primary key)
# is sorted according to the IATA code.
sort -t'^' -k 1,1 ${GEO_REF_WPK_FILE_TMP} > ${SORTED_GEO_REF_WPK_FILE}
\rm -f ${GEO_REF_WPK_FILE_TMP}

##
# Only four columns/fields are kept in that version of the geographical file:
# the primary key, airport/city IATA code and the geographical coordinates
# (latitude, longitude).
cut -d'^' -f 1,2,16,17 ${SORTED_GEO_REF_WPK_FILE} \
	> ${SORTED_CUT_GEO_REF_WPK_FILE}

##
# Reporting
echo
echo "Preparation step"
echo "----------------"
echo "The '${AIR_REF_CAP_FILE}', '${GEO_REF_CAP_FILE}', '${GEO_REF_WPK_FILE}', '${SORTED_GEO_REF_WPK_FILE}' and '${SORTED_CUT_GEO_REF_WPK_FILE}' files have been derived from '${GEO_REF_FILE}'."
echo

