#!/bin/bash

#
# OpenTravelData (OPTD) utility
# Git repository:
#   https://github.com/opentraveldata/opentraveldata/tree/master/tools
#

#
# One parameter is optional for this script:
# - the file-path of the data dump file for PageRanked airports.
#

##
# GNU tools, including on MacOS
source setGnuTools.sh || exit -1

##
# Directories
source setDirs.sh "$0" || exit -1

#
displayPopularityDetails() {
	if [ -z "${OPTDDIR}" ]
	then
		export OPTDDIR="~/dev/geo/optdgit/opentraveldata"
	fi
	if [ -z "${MYCURDIR}" ]
	then
		export MYCURDIR="$(pwd)"
	fi
	echo
	echo "The data dump for PageRanked airports can be obtained from this project (OpenTravelData:"
	echo "http://github.com/opentraveldata/opentraveldata). For instance:"
	echo "MYCURDIR=`pwd`"
	echo "OPTDDIR=${OPTDDIR}"
	echo "mkdir -p ~/dev/geo"
	echo "cd ~/dev/geo"
	echo "git clone git://github.com/opentraveldata/opentraveldata.git optdgit"
	if [ "${TMP_DIR}" = "/tmp/por/" ]
	then
		echo "mkdir -p ${TMP_DIR}"
	fi
	echo "cd ${MYCURDIR}"
	echo "\cp -f ${OPTDDIR}/opentraveldata/ref_airport_pageranked.csv ${TMP_DIR}"
	echo "${OPTDDIR}/tools/update_airports_csv_after_getting_geonames_iata_dump.sh"
	echo "ls -l ${TMP_DIR}"
	echo
}

##
#
AIRPORT_PR_FILENAME="ref_airport_pageranked.csv"

##
# OPTD path
DATA_DIR="${EXEC_PATH}../opentraveldata/"

##
#
AIRPORT_PR_SORTED="sorted_${AIRPORT_PR_FILENAME}"
AIRPORT_PR_SORTED_CUT="cut_sorted_${AIRPORT_PR_FILENAME}"
#
AIRPORT_PR="${TMP_DIR}${AIRPORT_PR_FILENAME}"

#
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<PageRanked airport data file>]"
	echo "  - Default name for the PageRanked airport data file: '${AIRPORT_PR}'"
	echo
	exit -1
fi
#
if [ "$1" = "-g" -o "$1" = "--popularity" ];
then
	displayPopularityDetails
	exit -1
fi

##
# Data file
if [ "$1" != "" ];
then
	AIRPORT_PR="$1"
	AIRPORT_PR_FILENAME="$(basename ${AIRPORT_PR})"
	AIRPORT_PR_SORTED="sorted_${AIRPORT_PR_FILENAME}"
	AIRPORT_PR_SORTED_CUT="cut_sorted_${AIRPORT_PR_FILENAME}"
	if [ "${AIRPORT_PR}" = "${DATA_DIR}${AIRPORT_PR_FILENAME}" ]
	then
		AIRPORT_PR="${DATA_DIR}${AIRPORT_PR}"
	fi
fi
AIRPORT_PR_SORTED="${TMP_DIR}${AIRPORT_PR_SORTED}"
AIRPORT_PR_SORTED_CUT="${TMP_DIR}${AIRPORT_PR_SORTED_CUT}"

if [ ! -f "${AIRPORT_PR}" ]
then
	echo "The '${AIRPORT_PR}' file does not exist."
	if [ "$1" = "" ];
	then
		displayPopularityDetails
	fi
	exit -1
fi

##
# First, remove the header (first line).
AIRPORT_PR_TMP="${AIRPORT_PR}.tmp"
# As of now (June 2012), there is no header.
\cp -f ${AIRPORT_PR} ${AIRPORT_PR_TMP}
#${SED_TOOL} -E "s/^region_code(.+)//g" ${AIRPORT_PR} > ${AIRPORT_PR_TMP}
#${SED_TOOL} -i"" -E "/^$/d" ${AIRPORT_PR_TMP}


##
# The PageRanked airport file should be sorted according to the code (as are
# the Geonames data dump and the file of best coordinates).
sort -t'^' -k1,1 ${AIRPORT_PR_TMP} > ${AIRPORT_PR_SORTED}
\rm -f ${AIRPORT_PR_TMP}

##
# Only three columns/fields are kept in that version of the file:
# the airport/city IATA code, the corresponding type (e.g., 'CA' for city
# and airport, 'A' for airport only and 'C' for city only, 'O' for off-line
# point) and the PageRank.
# Note: as of now (June 2012), the file has got no other field. So, that step
# is useless.
cut -d'^' -f 1-3 ${AIRPORT_PR_SORTED} > ${AIRPORT_PR_SORTED_CUT}

##
# Convert the IATA codes from lower to upper letters
cat ${AIRPORT_PR_SORTED_CUT} | tr [:lower:] [:upper:] > ${AIRPORT_PR_TMP}
\mv -f ${AIRPORT_PR_TMP} ${AIRPORT_PR_SORTED_CUT}

##
# Reporting
echo
echo "Preparation step"
echo "----------------"
echo "The '${AIRPORT_PR_SORTED}' and '${AIRPORT_PR_SORTED_CUT}' files have been derived from '${AIRPORT_PR}'."
echo

