#!/bin/bash

#
# OpenTravelData (OPTD) utility
# Git repository:
#   https://github.com/opentraveldata/opentraveldata/tree/master/tools
#

#
# One parameter is optional for this script:
# - the file-path of the data dump file for airport popularity.
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
		export OPTDDIR="~/dev/geo/optdgit/refdata"
	fi
	if [ -z "${MYCURDIR}" ]
	then
		export MYCURDIR=`pwd`
	fi
	echo
	echo "The data dump for airport popularity can be obtained from this project (OpenTravelData:"
	echo "http://github.com/opentraveldata/optd). For instance:"
	echo "MYCURDIR=`pwd`"
	echo "OPTDDIR=${OPTDDIR}"
	echo "mkdir -p ~/dev/geo"
	echo "cd ~/dev/geo"
	echo "git clone git://github.com/opentraveldata/optd.git optdgit"
	if [ "${TMP_DIR}" = "/tmp/por/" ]
	then
		echo "mkdir -p ${TMP_DIR}"
	fi
	echo "cd ${MYCURDIR}"
	echo "\cp -f ${OPTDDIR}/opentraveldata/ref_airport_popularity.csv ${TMP_DIR}"
	echo "${OPTDDIR}/tools/update_airports_csv_after_getting_geonames_iata_dump.sh"
	echo "ls -l ${TMP_DIR}"
	echo
}

##
#
AIRPORT_POP_FILENAME="ref_airport_popularity.csv"

##
# OPTD path
DATA_DIR="${EXEC_PATH}../opentraveldata/"

##
#
AIRPORT_POP_SORTED="sorted_${AIRPORT_POP_FILENAME}"
AIRPORT_POP_SORTED_CUT="cut_sorted_${AIRPORT_POP_FILENAME}"
#
AIRPORT_POP="${DATA_DIR}${AIRPORT_POP_FILENAME}"

#
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0 [<Airport popularity data dump file>]"
	echo "  - Default name for the airport popularity data dump file: '${AIRPORT_POP}'"
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
# Data dump file with geographical coordinates
if [ "$1" != "" ];
then
	AIRPORT_POP="$1"
	AIRPORT_POP_FILENAME="$(basename ${AIRPORT_POP})"
	AIRPORT_POP_SORTED="sorted_${AIRPORT_POP_FILENAME}"
	AIRPORT_POP_SORTED_CUT="cut_sorted_${AIRPORT_POP_FILENAME}"
	if [ "${AIRPORT_POP}" = "${AIRPORT_POP_FILENAME}" ]
	then
		AIRPORT_POP="${TMP_DIR}${AIRPORT_POP}"
	fi
fi
AIRPORT_POP_SORTED="${TMP_DIR}${AIRPORT_POP_SORTED}"
AIRPORT_POP_SORTED_CUT="${TMP_DIR}${AIRPORT_POP_SORTED_CUT}"

if [ ! -f "${AIRPORT_POP}" ]
then
	echo "The '${AIRPORT_POP}' file does not exist."
	if [ "$1" = "" ];
	then
		displayPopularityDetails
	fi
	exit -1
fi

##
# First, remove the header (first line)
AIRPORT_POP_TMP="${AIRPORT_POP}.tmp"
${SED_TOOL} -E "s/^region_code(.+)//g" ${AIRPORT_POP} > ${AIRPORT_POP_TMP}
${SED_TOOL} -i"" -E "/^$/d" ${AIRPORT_POP_TMP}


##
# The airport popularity file should be sorted according to the code (as are
# the Geonames data dump and the file of best coordinates).
sort -t'^' -k 5,5 ${AIRPORT_POP_TMP} > ${AIRPORT_POP_SORTED}
\rm -f ${AIRPORT_POP_TMP}

##
# Only two columns/fields are kept in that version of the file:
# the airport/city IATA code and the airport popularity.
cut -d'^' -f 5,15 ${AIRPORT_POP_SORTED} > ${AIRPORT_POP_SORTED_CUT}

##
# Convert the IATA codes from lower to upper letters
cat ${AIRPORT_POP_SORTED_CUT} | tr [:lower:] [:upper:] > ${AIRPORT_POP_TMP}
\mv -f ${AIRPORT_POP_TMP} ${AIRPORT_POP_SORTED_CUT}

##
# Reporting
echo
echo "Preparation step"
echo "----------------"
echo "The '${AIRPORT_POP_SORTED}' and '${AIRPORT_POP_SORTED_CUT}' files have been derived from '${AIRPORT_POP}'."
echo

