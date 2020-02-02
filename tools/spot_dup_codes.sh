#!/bin/bash

#
# OpenTravelData (OPTD) utility
# Git repository:
#   https://github.com/opentraveldata/opentraveldata/tree/master/tools
#

#
# One parameter is optional for this script:
# - whether the code is IATA, ICAO or FAA (that latter is not supported yet)
#

##
# GNU tools, including on MacOS
source setGnuTools.sh || exit -1

##
# Directories
source setDirs.sh "$0" || exit -1

##
# For each airport/city code, calculate the distance between the two
# geographical coordinate sets.
AWK_DIST="${EXEC_PATH}distance.awk"
CODE_TYPE="iata"
#
GEO_ALL_FILE_FILENAME="dump_from_geonames.csv.all"
GEO_ALL_FILE="${TMP_DIR}${GEO_ALL_FILE_FILENAME}"

# Snapshot date
SNAPSHOT_DATE="$(${DATE_TOOL} +%Y%m%d)"

#
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<Code type: IATA, ICAO or FAA> [<Geo data dump file>]]"
	echo "  - Default code type: '${CODE_TYPE}'"
	echo "  - Default data dump file: '${GEO_ALL_FILE}'"
	echo
	exit -1
fi

##
# Code type
if [ "$1" != "" ]
then
	CODE_TYPE=`echo "$1" | tr [:upper:] [:lower:]`
	if [ "${CODE_TYPE}" = "faa" ]
	then
		echo
		echo "The FAA code is not supported yet."
		echo
		exit -1
	fi
	if [ "${CODE_TYPE}" != "iata" -a "${CODE_TYPE}" != "icao" ]
	then
		CODE_TYPE="iata"
		echo
		echo "The ${CODE_TYPE} code type is not recognised. IATA is taken."
		echo
	fi
fi

# Second data file with geographical coordinates
if [ "$2" != "" ];
then
	GEO_ALL_FILE="$2"
	GEO_ALL_FILE_FILENAME=`basename ${GEO_ALL_FILE}`
	if [ "${GEO_ALL_FILE}" = "${GEO_ALL_FILE_FILENAME}" ]
	then
		GEO_ALL_FILE="${TMP_DIR}${GEO_ALL_FILE}"
	fi
fi

##
#
displayReaggregateIATA() {
	echo
	echo "cat por_all_iata_${SNAPSHOT_DATE}.csv por_all_noicao_${SNAPSHOT_DATE}.csv > ${GEO_ALL_FILE}"
	echo "${SED_TOOL} -i\"\" -E \"/^$/d\" ${GEO_ALL_FILE}"
	echo "sort -t'^' -k1,1 -k2,2 ${GEO_ALL_FILE} > ${GEO_ALL_FILE}.tmp"
	echo "\mv -f ${GEO_ALL_FILE}.tmp ${GEO_ALL_FILE}"
	echo "${SED_TOOL} -i\"\" -E \"s/^iata(.+)//g\" ${GEO_ALL_FILE}"
	echo "${SED_TOOL} -i\"\" -E \"/^$/d\" ${GEO_ALL_FILE}"
	echo
}
#
displayReaggregateICAO() {
	echo
	echo "${SED_TOOL} -E \"s/^([A-Z0-9][A-Z0-9][A-Z0-9])\^NULL\^(.+)//g\" por_all_iata_${SNAPSHOT_DATE}.csv > ${GEO_ALL_FILE}.tmp"
	echo "cat ${GEO_ALL_FILE}.tmp por_all_icao_only_${SNAPSHOT_DATE}.csv > ${GEO_ALL_FILE}"
	echo "${SED_TOOL} -i\"\" -E \"s/^NULL\^(.+)/nul\^\1/g\" ${GEO_ALL_FILE}"
	echo "${SED_TOOL} -i\"\" -E \"/^$/d\" ${GEO_ALL_FILE}"
	echo "sort -t'^' -k2,2 -k1,1 ${GEO_ALL_FILE} > ${GEO_ALL_FILE}.tmp"
	echo "\mv -f ${GEO_ALL_FILE}.tmp ${GEO_ALL_FILE}"
	echo "${SED_TOOL} -i\"\" -E \"s/^iata(.+)//g\" ${GEO_ALL_FILE}"
	echo "${SED_TOOL} -i\"\" -E \"/^$/d\" ${GEO_ALL_FILE}"
	echo
}

##
#
if [ ! -f ${GEO_ALL_FILE} ]
then
	if [ "${CODE_TYPE}" = "iata" ]
	then
		displayReaggregateIATA
		exit -1
	fi
	if [ "${CODE_TYPE}" = "icao" ]
	then
		displayReaggregateICAO
		exit -1
	fi
fi

##
#
GEO_WORK_BASE="mydump.csv"
GEO_WORK_TMP="${GEO_WORK_BASE}.tmp"
# dump1
GEO_DUP_ALL_FILE="${GEO_WORK_BASE}.tmp.dup"
# dump2x
GEO_DUP_FILE_1="${GEO_WORK_BASE}.tmp.dup.1"
GEO_DUP_FILE_2="${GEO_WORK_BASE}.tmp.dup.2"
# dump3x
GEO_DUP_CUT_FILE_1="${GEO_WORK_BASE}.tmp.dup.cut.1"
GEO_DUP_CUT_FILE_2="${GEO_WORK_BASE}.tmp.dup.cut.2"
# dump4
GEO_COORD_FILE="${GEO_WORK_BASE}.tmp.coord"
# dump5
GEO_DIST_FILE="${GEO_WORK_BASE}.tmp.dist"

#  1.1. Extract only the entries having duplicated code.
if [ "${CODE_TYPE}" = "iata" ]
then
	uniq -w 3 -D ${GEO_ALL_FILE} > ${GEO_DUP_ALL_FILE}
else
	uniq -s 4 -w 4 -D ${GEO_ALL_FILE} > ${GEO_DUP_ALL_FILE}
fi

#  2.1. Extract the first entries having duplicated code.
if [ "${CODE_TYPE}" = "iata" ]
then
	uniq -w 3 ${GEO_DUP_ALL_FILE} > ${GEO_DUP_FILE_1}
else
	uniq -s 4 -w 4 ${GEO_DUP_ALL_FILE} > ${GEO_DUP_FILE_1}
fi

#  2.2. Extract the other entries having duplicated code.
#       Note: The files should be sorted by IATA codes, first, so that the
#       'comm' command can handle the difference properly.
comm -23 ${GEO_DUP_ALL_FILE} ${GEO_DUP_FILE_1} > ${GEO_DUP_FILE_2}

#  3. Extract the code and coordinates for the entries having duplicated code
cut -d'^' -f1-6 ${GEO_DUP_FILE_1} > ${GEO_DUP_CUT_FILE_1}
cut -d'^' -f1-6 ${GEO_DUP_FILE_2} > ${GEO_DUP_CUT_FILE_2}

#  4.1. Join both the coordinate sets
if [ "${CODE_TYPE}" = "iata" ]
then
	join -t'^' -a 1 ${GEO_DUP_CUT_FILE_1} ${GEO_DUP_CUT_FILE_2} > ${GEO_WORK_TMP}
else
	join -t'^' -a 1 -1 2 -2 2 ${GEO_DUP_CUT_FILE_1} ${GEO_DUP_CUT_FILE_2} > ${GEO_WORK_TMP}
fi
#  4.2. Re-order the fields/columns (put the coordinate sets at the beginning
#       of the row, after the code), so that ${AWK_DIST} (e.g., distance.awk)
#       can process it (see below the step #5).
awk -F'^' '{print $1 "^" $5 "^" $6 "^" $10 "^" $11 "^" $2 "^" $3 "^" $4 \
 "^" $7 "^" $8 "^" $9}' ${GEO_WORK_TMP} > ${GEO_COORD_FILE}

#  5. Calculate the distances (in km)
awk -F'^' -f ${AWK_DIST} ${GEO_COORD_FILE} > ${GEO_WORK_TMP}

#  6. Sort by distances (in km)
sort -t'^' -k2,2nr ${GEO_WORK_TMP} > ${GEO_DIST_FILE}

##
# Reporting
echo
echo "In order to clean all the temporary files:"
echo "\rm -f ${GEO_WORK_TMP} ${GEO_DUP_ALL_FILE} \\"
echo " ${GEO_DUP_FILE_1} ${GEO_DUP_FILE_2} \\"
echo " ${GEO_DUP_CUT_FILE_1} ${GEO_DUP_CUT_FILE_2} \\"
echo " ${GEO_COORD_FILE} ${GEO_DIST_FILE}"
echo
