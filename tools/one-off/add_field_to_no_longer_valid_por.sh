#
# That script is just for a single time: once the field has been added,
# its job has been performed. In other words, it is not idempotent.
#
# Add a field (eg, un_locode) to a POR file, eg optd_por_no_longer_valid.csv or
# optd_por_no_geonames.csv.
# Concretely, it just adds a the field separator, ie the hat sign ("^"),
# to every row. Hence, the added field is empty.
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
	echo "[$0:$LINENO] Inconsistency error: this script ($0) should be located in the tools/ sub-directory of the OpenTravelData project Git clone, but apparently is not. EXEC_FULL_PATH=\"${EXEC_FULL_PATH}\""
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
LOG_LEVEL=3

##
# File of best known coordinates
OPTD_POR_FILENAME=optd_por_best_known_so_far.csv
OPTD_POR_FILE=${DATA_DIR}${OPTD_POR_FILENAME}

##
# File of no longer valid IATA entries
OPTD_NOIATA_FILENAME=optd_por_no_longer_valid.csv
OPTD_NOIATA_FILE=${DATA_DIR}${OPTD_NOIATA_FILENAME}

##
# File of non-Geonames POR
OPTD_NOGEONAMES_FILENAME=optd_por_no_geonames.csv
OPTD_NOGEONAMES_FILE=${DATA_DIR}${OPTD_NOGEONAMES_FILENAME}

##
# Main process
#TGT_FILE=${OPTD_NOIATA_FILE}
TGT_FILE=${OPTD_NOGEONAMES_FILE}
tmpfile=${TGT_FILE}.tmp
awk -F'^' '{print ($0 FS)}' ${TGT_FILE} > ${tmpfile}
\mv -f ${tmpfile} ${TGT_FILE}
