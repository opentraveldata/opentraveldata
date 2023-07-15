#!/usr/bin/env bash
#
# OpenTravelData (OPTD) utility
# Git repository:
#   https://github.com/opentraveldata/opentraveldata/tree/master/tools
#
# That Bash script extracts from the 'allCountries_w_alt.txt' data file
# (itself a Geonames-derived data file) the POR relevant for
# OpenTravelData (OPTD).
#
# See ../geonames/data/por/admin/aggregateGeonamesPor.sh for more details on
# the way to derive the 'allCountries_w_alt.txt' data file from Geonames
# daily dump data files.
#
#set -x

##
# GNU tools, including on MacOS
source setGnuTools.sh || exit -1

##
# Directories
source setDirs.sh "$0" || exit -1

##
# Snapshot date
SNAPSHOT_DATE="$(${DATE_TOOL} +%Y%m%d)"
SNAPSHOT_DATE_HUMAN="$(${DATE_TOOL})"

##
# Retrieve the latest dump files, if any
POR_FILE_PFX1="por_intorg"
POR_FILE_PFX2="por_all"
declare -a LATEST_EXTRACT_DATE="$(ls ${EXEC_PATH}${POR_FILE_PFX1}_????????.csv 2> /dev/null)"
if [ "${LATEST_EXTRACT_DATE}" != "" ]
then
	# (Trick to) Extract the latest entry
	for myfile in "${LATEST_EXTRACT_DATE[@]}"; do echo > /dev/null; done
	LATEST_EXTRACT_DATE="$(echo ${myfile} | ${SED_TOOL} -E "s/${POR_FILE_PFX1}_([0-9]+)\.csv/\1/" | xargs basename)"
fi
if [ "${LATEST_EXTRACT_DATE}" != "" ]
then
	LATEST_EXTRACT_DATE_HUMAN="$($DATE_TOOL -d ${LATEST_EXTRACT_DATE})"
fi
if [ "${LATEST_EXTRACT_DATE}" != "" \
	-a "${LATEST_EXTRACT_DATE}" != "${SNAPSHOT_DATE}" ]
then
	LATEST_DUMP_INTORG_FILENAME="${POR_FILE_PFX1}_${LATEST_EXTRACT_DATE}.csv"
	LATEST_DUMP_ALL_FILENAME="${POR_FILE_PFX2}_${LATEST_EXTRACT_DATE}.csv"
fi

##
# Geonames data store
GEO_POR_DATA_DIR="${EXEC_PATH}../data/geonames/data/por/data/"

##
# OPTD directory
DATA_DIR="${EXEC_PATH}../opentraveldata/"

##
# Extract airport/city information from the Geonames data file
GEO_POR_FILENAME="allCountries_w_alt.txt"
GEO_CTY_FILENAME="countryInfo.txt"
GEO_CNT_FILENAME="continentCodes.txt"
#
GEO_POR_FILE="${GEO_POR_DATA_DIR}${GEO_POR_FILENAME}"
GEO_CTY_FILE="${GEO_POR_DATA_DIR}${GEO_CTY_FILENAME}"
GEO_CNT_FILE="${GEO_POR_DATA_DIR}${GEO_CNT_FILENAME}"

##
# Generated files
DUMP_GEO_FILENAME="dump_from_geonames.csv"
DUMP_INTORG_FILENAME="${POR_FILE_PFX1}_${SNAPSHOT_DATE}.csv"
DUMP_ALL_FILENAME="${POR_FILE_PFX2}_${SNAPSHOT_DATE}.csv"
# Light version of the country-related time-zones
OPTD_TZ_FILENAME="optd_tz_light.csv"
# Mapping between countries and continents
OPTD_CNT_FILENAME="optd_cont.csv"

#
DUMP_GEO_FILE="${TMP_DIR}${DUMP_GEO_FILENAME}"
DUMP_INTORG_FILE="${TMP_DIR}${DUMP_INTORG_FILENAME}"
DUMP_ALL_FILE="${TMP_DIR}${DUMP_ALL_FILENAME}"
DUMP_GEO_FILE_HDR="${DUMP_INTORG_FILE}.hdr"
DUMP_GEO_FILE_TMP="${DUMP_INTORG_FILE}.tmp"
# OPTD-related data files
OPTD_TZ_FILE="${DATA_DIR}${OPTD_TZ_FILENAME}"
OPTD_CNT_FILE="${DATA_DIR}${OPTD_CNT_FILENAME}"
OPTD_CNT_FILE_TMP="${TMP_DIR}${OPTD_CNT_FILENAME}.tmp"
OPTD_CNT_FILE_TMP_SORTED="${TMP_DIR}${OPTD_CNT_FILENAME}.tmp.sorted"
OPTD_CNT_FILE_HDR="${TMP_DIR}${OPTD_CNT_FILENAME}.tmp.hdr"

##
# Latest snapshot data files
LATEST_DUMP_INTORG_FILE="${TMP_DIR}${LATEST_DUMP_INTORG_FILENAME}"
LATEST_DUMP_ALL_FILE="${TMP_DIR}${LATEST_DUMP_ALL_FILENAME}"

#
if [ "$1" = "-h" -o "$1" = "--help" ]
then
	echo
	echo "Usage: $0"
	echo "  - Snapshot date: '${SNAPSHOT_DATE}' (${SNAPSHOT_DATE_HUMAN})"
	if [ "${LATEST_EXTRACT_DATE}" != "" \
		-a "${LATEST_EXTRACT_DATE}" != "${SNAPSHOT_DATE}" ]
	then
		echo "  - Latest extraction date: '${LATEST_EXTRACT_DATE}' (${LATEST_EXTRACT_DATE_HUMAN})"
	fi
	echo "  - Geonames input data files from '${GEO_POR_DATA_DIR}':"
	echo "      + Detailed POR entry data file (~9 millions): '${GEO_POR_FILE}'"
	echo "      + Detailed country information data file: '${GEO_CTY_FILE}'"
	echo "      + Continent information data file: '${GEO_CNT_FILE}'"
	echo
	echo "  - Generated (CSV-formatted) data files in '${EXEC_PATH}':"
	echo "      + '${DUMP_INTORG_FILE}'"
	echo "      + '${DUMP_ALL_FILE}'"
	echo
	echo "  - Generated (CSV-formatted) data files in '${DATA_DIR}':"
	echo "      + '${OPTD_TZ_FILE}' (maybe sometimes in the future)"
	echo "      + '${OPTD_CNT_FILE}'"
	echo
	exit
fi

##
#
if [ "$1" = "--clean" ]
then
	if [ "${TMP_DIR}" = "/tmp/por/" ]
	then
		\rm -rf ${TMP_DIR}
	else
		\rm -f ${OPTD_CNT_FILE_HDR} ${OPTD_CNT_FILE_TMP}
		\rm -f ${OPTD_CNT_FILE_TMP_SORTED}
		\rm -f ${DUMP_GEO_FILE_HDR} ${DUMP_GEO_FILE_TMP}
	fi
	exit
fi

##
# Data extraction from the Geonames data files

# For country-related information (continent, for now)
echo
echo "Extracting country-related information from '${GEO_CTY_FILE}'"
CONT_EXTRACTOR="${EXEC_PATH}extract_continent_mapping.awk"
${AWK_TOOL} -F'\t' -f ${CONT_EXTRACTOR} ${GEO_CNT_FILE} ${GEO_CTY_FILE} \
	> ${OPTD_CNT_FILE_TMP}
# Extract and remove the header
grep -E "^country_code(.+)" ${OPTD_CNT_FILE_TMP} > ${OPTD_CNT_FILE_HDR}
${SED_TOOL} -i"" -E "s/^country_code(.+)//g" ${OPTD_CNT_FILE_TMP}
${SED_TOOL} -i"" -E "/^$/d" ${OPTD_CNT_FILE_TMP}
# Sort by country code
sort -t'^' -k1,1 ${OPTD_CNT_FILE_TMP} > ${OPTD_CNT_FILE_TMP_SORTED}
# Re-add the header
cat ${OPTD_CNT_FILE_HDR} ${OPTD_CNT_FILE_TMP_SORTED} > ${OPTD_CNT_FILE_TMP}
${SED_TOOL} -E "/^$/d" ${OPTD_CNT_FILE_TMP} > ${OPTD_CNT_FILE}

# For transport-/travel-related POR and cities.
echo
echo "Extracting travel-related points of reference (POR, i.e., airports, railway stations)"
echo "and populated place (city) data from the Geonames dump data file."
echo "The '${GEO_POR_FILE}' input data file allows to generate '${DUMP_INTORG_FILE}' and '${DUMP_ALL_FILE}' files."
echo "That operation may take several minutes..."
INTORG_EXTRACTOR="${EXEC_PATH}extract_por_from_geonames.awk"
time ${AWK_TOOL} -F'^' \
	-v intorg_file=${DUMP_INTORG_FILE} -v all_file=${DUMP_ALL_FILE} \
	-f ${INTORG_EXTRACTOR} ${GEO_POR_FILE}
echo "... Done"
echo

##
# Extract and remove the header
grep -E "^iata_code(.+)" ${DUMP_INTORG_FILE} > ${DUMP_GEO_FILE_HDR}
${SED_TOOL} -i"" -E "s/^iata_code(.+)//g" ${DUMP_INTORG_FILE}
${SED_TOOL} -i"" -E "/^$/d" ${DUMP_INTORG_FILE}
${SED_TOOL} -i"" -E "s/^iata_code(.+)//g" ${DUMP_ALL_FILE}
${SED_TOOL} -i"" -E "/^$/d" ${DUMP_ALL_FILE}

# Sort the data files
echo "Sorting ${DUMP_INTORG_FILE}..."
sort -t'^' -k1,1 -k4n,4 ${DUMP_INTORG_FILE} > ${DUMP_GEO_FILE_TMP}
cat ${DUMP_GEO_FILE_HDR} ${DUMP_GEO_FILE_TMP} > ${DUMP_INTORG_FILE}
echo "... done"
echo "Sorting ${DUMP_ALL_FILE}..."
sort -t'^' -k4n,4 ${DUMP_ALL_FILE} > ${DUMP_GEO_FILE_TMP}
cat ${DUMP_GEO_FILE_HDR} ${DUMP_GEO_FILE_TMP} > ${DUMP_ALL_FILE}
echo "... done"


##
# Reporting
#
echo
echo "Reporting step"
echo "--------------"
echo
echo "From the '${GEO_POR_FILE}' input data file, the following data files have been derived:"
echo " + '${DUMP_INTORG_FILE}'"
echo " + '${DUMP_ALL_FILE}'"
echo
echo
echo "Other temporary files have been generated. Just issue the following command to delete them:"
echo "$0 --clean"
echo
echo "Following steps:"
echo "----------------"
if [ "${LATEST_EXTRACT_DATE}" != "" \
	-a "${LATEST_EXTRACT_DATE}" != "${SNAPSHOT_DATE}" ]
then
	echo "After having checked that the updates brought by Geonames are legitimate and not disruptive, i.e.:"
	echo "diff -c ${LATEST_DUMP_INTORG_FILE} ${DUMP_INTORG_FILE} | less"
	echo "diff -c ${LATEST_DUMP_ALL_FILE} ${DUMP_ALL_FILE} | less"
	echo "mkdir -p archives && bzip2 *_${LATEST_EXTRACT_DATE}.csv && mv *_${LATEST_EXTRACT_DATE}.csv.bz2 archives"
	echo
	echo "The Geonames data file (dump_from_geonames.csv) may be updated:"
else
	echo "Today (${SNAPSHOT_DATE}), the Geonames data has already been extracted."
	echo
	echo "The Geonames data file (dump_from_geonames.csv) has to set up:"
fi
echo "\cp -f ${DUMP_INTORG_FILE} ${DUMP_GEO_FILE}"
echo
echo

