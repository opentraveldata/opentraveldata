#!/bin/bash
#
#
# OpenTravelData (OPTD) utility
# Git repository:
#   https://github.com/opentraveldata/opentraveldata/tree/master/tools
#
# Two parameters are optional for this script:
# - the first file of geographical coordinates
# - the second file of geographical coordinates
#

##
# GNU tools, including on MacOS
source setGnuTools.sh || exit -1

##
# Directories
source setDirs.sh "$0" || exit -1

##
# OpenTravelData directory
OPTD_DIR="$(dirname ${EXEC_FULL_PATH})"
OPTD_DIR="${OPTD_DIR}/"

##
# OPTD sub-directories
DATA_DIR="${OPTD_DIR}opentraveldata/"
TOOLS_DIR="${OPTD_DIR}tools/"

##
# Log level
LOG_LEVEL=3

##
# Geo data files
GEO_FILE_1_FILENAME="cut_sorted_dump_from_geonames.csv"
GEO_FILE_2_FILENAME="optd_por_best_known_so_far.csv"
#AIRPORT_PR_FILENAME="cut_sorted_ref_airport_pageranked.csv"
AIRPORT_PR_FILENAME="ref_airport_pageranked.csv"

# Comparison files
COMP_FILE_COORD_FILENAME="por_comparison_coord.csv"
COMP_FILE_DIST_FILENAME="por_comparison_dist.csv"
POR_MAIN_DIFF_FILENAME="optd_por_diff_w_geonames.csv"

# Minimal distance triggering a difference (in km)
COMP_MIN_DIST=10

##
# Geo data files
GEO_FILE_1="${TMP_DIR}${GEO_FILE_1_FILENAME}"
GEO_FILE_2="${TMP_DIR}${GEO_FILE_2_FILENAME}"
#AIRPORT_PR_FILE="${TMP_DIR}${AIRPORT_PR_FILENAME}"
AIRPORT_PR_FILE="${DATA_DIR}${AIRPORT_PR_FILENAME}"

# Comparison files
COMP_FILE_COORD="${TMP_DIR}${COMP_FILE_COORD_FILENAME}"
COMP_FILE_DIST="${TMP_DIR}${COMP_FILE_DIST_FILENAME}"
POR_MAIN_DIFF="${DATA_DIR}${POR_MAIN_DIFF_FILENAME}"

##
# Temporary
POR_MAIN_DIFF_TMP="${TMP_DIR}${POR_MAIN_DIFF_FILENAME}.tmp"


if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<Geo data file 1> [<Geo data file 2>]]"
	echo "  - Default name for the geo data file #1: '${GEO_FILE_1}'"
	echo "  - Default name for the geo data file #2: '${GEO_FILE_2}'"
	echo "  - Default name for the airport PageRank/popularity: " \
		 "'${AIRPORT_PR_FILE}'"
	echo "  - Default distance (in km) triggering a difference: " \
		 "'${COMP_MIN_DIST}'"
	echo
	exit
fi

##
# Local helper scripts
PREPARE_EXEC="bash ${EXEC_PATH}prepare_geonames_dump_file.sh"
PREPARE_PR_EXEC="bash ${EXEC_PATH}prepare_pagerank.sh"

##
# First data file with geographical coordinates
if [ "$1" != "" ];
then
	GEO_FILE_1="$1"
	GEO_FILE_1_FILENAME="$(basename ${GEO_FILE_1})"
	if [ "${GEO_FILE_1}" = "${GEO_FILE_1_FILENAME}" ]
	then
		GEO_FILE_1="${TMP_DIR}${GEO_FILE_1_FILENAME}"
	fi
fi

if [ ! -f "${GEO_FILE_1}" ]
then
	echo "[$0:$LINENO] The '${GEO_FILE_1}' file does not exist."
	if [ "$1" = "" ];
	then
		${PREPARE_EXEC} --geonames
		echo "The default name of the Geonames data dump copy is " \
			 "'${GEO_FILE_1}'."
		echo
	fi
	exit -1
fi


##
# Second data file with geographical coordinates
if [ "$2" != "" ];
then
	GEO_FILE_2="$2"
	GEO_FILE_2_FILENAME="$(basename ${GEO_FILE_2})"
	if [ "${GEO_FILE_2}" = "${GEO_FILE_2_FILENAME}" ]
	then
		GEO_FILE_2="${TMP_DIR}${GEO_FILE_2_FILENAME}"
	fi
fi


##
# Data file with airport PageRank/popularity
if [ "$3" != "" ];
then
	AIRPORT_PR_FILE="$3"
	AIRPORT_PR_FILENAME="$(basename ${AIRPORT_PR_FILE})"
	if [ "${AIRPORT_PR_FILE}" = "${AIRPORT_PR_FILENAME}" ]
	then
		AIRPORT_PR_FILE="${TMP_DIR}${AIRPORT_PR_FILENAME}"
	fi
fi

if [ ! -f "${AIRPORT_PR_FILE}" ]
then
	echo
	echo "[$0:$LINENO] The '${AIRPORT_PR_FILE}' file does not exist."
	if [ "$3" = "" ];
	then
		${PREPARE_PR_EXEC} --popularity
		echo "The default name of the airport PageRank/popularity copy " \
			 "is '${AIRPORT_PR_FILE}'."
		echo
	fi
	exit -1
fi


##
# Minimal distance (in km) triggering a difference
if [ "$4" != "" ]
then
	DIFF_EXPR="$(echo "$4 / 1" | bc 2> /dev/null)"
	if [ "${DIFF_EXPR}" = "" ]
	then
		echo
		echo "[$0:$LINENO] The minimal distance (in km) must be a number " \
			 "greater than zero, and less than 65000. It is currently $4."
		echo
		exit -1
	fi
	if [ ${DIFF_EXPR} -lt 0 -o ${DIFF_EXPR} -gt 65000 ]
	then
		echo
		echo "[$0:$LINENO] The minimal distance (in km) must be greater than " \
			 "(or equal to) zero, and less than 65000. It is currently $4."
		echo
		exit -1
	fi
	COMP_MIN_DIST=$4
fi


##
# For each airport/city code, join the two geographical coordinate sets.
COMP_FILE_COORD_TMP="${COMP_FILE_COORD}.tmp2"
join -t'^' -a 1 -1 1 -2 1 ${GEO_FILE_2} ${GEO_FILE_1} > ${COMP_FILE_COORD_TMP}
\mv -f ${COMP_FILE_COORD_TMP} ${COMP_FILE_COORD}

##
# For each airport/city code, join the airport PageRank/popularity.
#join -t'^' -a 1 -1 1 -2 1 ${COMP_FILE_COORD_TMP} ${AIRPORT_PR_FILE} \
#	> ${COMP_FILE_COORD}
#\rm -f ${COMP_FILE_COORD_TMP}

##
# Suppress empty coordinate fields, from the geonames dump file:
#sed -i -e 's/\^NULL/\^/g' ${COMP_FILE_COORD}

##
# For each airport/city code, calculate the distance between the two
# geographical coordinate sets.
# The file with the airport PageRank/popularity values is also given as input.
AWK_DIST="${EXEC_PATH}distance.awk"
awk -F'^' -v log_level=${LOG_LEVEL} -f ${AWK_DIST} \
	${AIRPORT_PR_FILE} ${COMP_FILE_COORD} > ${COMP_FILE_DIST}
#echo "head -3 ${AIRPORT_PR_FILE} ${COMP_FILE_COORD} ${COMP_FILE_DIST}"

##
# Count the differences
POR_ALL_DIFF_NB"$(${WC_TOOL} -l ${COMP_FILE_DIST} | cut -d' ' -f1)"

##
# Filter the difference data file for all the distances greater than
# ${COMP_MIN_DIST} (in km; by default 1km).
awk -F'^' -v comp_min_dist=${COMP_MIN_DIST} \
	'{if ($2 >= comp_min_dist) {print($1 "^" $2 "^" $3 "^" $4)}}' \
	${COMP_FILE_DIST} > ${POR_MAIN_DIFF_TMP}

##
# Sort the differences, weighted by the PageRank/popularity of the airport
# (equal to 1 when not specified), from the greatest to the least.
sort -t'^' -k4nr -k2nr -k1 ${POR_MAIN_DIFF_TMP} > ${POR_MAIN_DIFF}
echo "dep_city^distance^page_rank^dist_weighted_by_page_rank" \
	| cat - ${POR_MAIN_DIFF} > ${POR_MAIN_DIFF_TMP}
\mv -f ${POR_MAIN_DIFF_TMP} ${POR_MAIN_DIFF}

##
# Count the differences
POR_MAIN_DIFF_NB="$(${WC_TOOL} -l ${POR_MAIN_DIFF} | cut -d' ' -f1)"

##
# Clean
\rm -f ${COMP_FILE_COORD} ${COMP_FILE_DIST}

##
# Reporting
if [ ${POR_MAIN_DIFF_NB} -gt 0 ]
then
	echo
	echo "Comparison step"
	echo "---------------"
	echo "To see the ${POR_MAIN_DIFF_NB} main differences (greater than " \
		 "${COMP_MIN_DIST} kms), over ${POR_ALL_DIFF_NB} differences in all,"
	echo "between the Geonames coordinates ('${GEO_FILE_1}') and the best " \
		 "known ones ('${GEO_FILE_2}'),"
	echo "sorted by distance (in km), just do: less ${POR_MAIN_DIFF}"
	echo
else
	echo
	echo "Comparison step"
	echo "---------------"
	echo "There are no difference (greater than ${COMP_MIN_DIST} kms) " \
		 "between the"
	echo "Geonames coordinates and the best known ones."
	echo
fi
