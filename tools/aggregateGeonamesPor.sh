#!/bin/bash

##
# That Shell script, helped by AWK, concatenates the alternate name details,
# and add them back to the line of details for every Geoname POR.
#
# There are two input files, normally 'alternateNames.txt' for the
# alternate name details, and 'allCountries.txt' for the details of every
# Geoname POR (Point Of Reference).

##
# Log level
LOG_LEVEL=4

##
# GNU tools, including on MacOS
source setGnuTools.sh || exit -1

##
# Directories
source setDirs.sh || exit -1

##
# OpenTravelData Geonames-related directory
GEO_POR_DIR="$(dirname ${EXEC_FULL_PATH})"
GEO_POR_DIR="${GEO_POR_DIR}/"

##
# Admin sub-directory
DATA_DIR="${EXEC_PATH}../data/geonames/data/por/data/"

# Input data files
GEO_ADM1_FILENAME="admin1CodesASCII.txt"
GEO_ADM2_FILENAME="admin2Codes.txt"
GEO_CTRY_FILENAME="countryInfo.txt"
GEO_CONT_FILENAME="continentCodes.txt"
GEO_TZ_FILENAME="timeZones.txt"
GEO_POR_FILENAME="allCountries.txt"
GEO_POR_ALT_FILENAME="alternateNames.txt"
#
GEO_ADM1_FILE="${DATA_DIR}${GEO_ADM1_FILENAME}"
GEO_ADM2_FILE="${DATA_DIR}${GEO_ADM2_FILENAME}"
GEO_CTRY_FILE="${DATA_DIR}${GEO_CTRY_FILENAME}"
GEO_CONT_FILE="${DATA_DIR}${GEO_CONT_FILENAME}"
GEO_TZ_FILE="${DATA_DIR}${GEO_TZ_FILENAME}"
GEO_POR_FILE="${DATA_DIR}${GEO_POR_FILENAME}"
GEO_POR_ALT_FILE="${DATA_DIR}${GEO_POR_ALT_FILENAME}"

# Output data file
GEO_POR_CONC_FILENAME="allCountries_w_alt.txt"
GEO_POR_CONC_FILE="${DATA_DIR}${GEO_POR_CONC_FILENAME}"

# Reference details for the Nice airport (IATA/ICAO codes: NCE/LFMN,
# Geoname ID: 6299418, http://www.geonames.org/6299418)
NCE_POR_REF="NCE^LFMN^^6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.66272^7.20787^FR^^France^Europe^S^AIRP^93^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Alpes-Maritimes^Alpes-Maritimes^062^06088^0^3^5^Europe/Paris^1.0^2.0^1.0^2018-12-05^Aehroport Nicca Lazurnyj Bereg,Aeroport de Nice Cote d'Azur,Aéroport de Nice Côte d'Azur,Flughafen Nizza,LFMN,NCE,Nice Airport,Nice Cote d'Azur International Airport,Nice Côte d'Azur International Airport,Nice flygplats,Niza Aeropuerto,frwdgah nys kwt dazwr,koto・dajuru kong gang,mtar nys alryfyra alfrnsy,ni si lan se hai an ji chang,niseu koteudajwileu gonghang,Аэропорт Ницца Лазурный Берег,فرودگاه نیس کوت دازور,مطار نيس الريفيرا الفرنسي,コート・ダジュール空港,尼斯蓝色海岸机场,니스 코트다쥐르 공항^https://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de|Flughafen Nizza||en|Nice Côte d'Azur International Airport|p|es|Niza Aeropuerto|ps|fr|Aéroport de Nice Côte d'Azur||en|Nice Airport|s|wuu|尼斯蓝色海岸机场||ru|Аэропорт Ницца Лазурный Берег||ja|コート・ダジュール空港||ko|니스 코트다쥐르 공항||fa|فرودگاه نیس کوت دازور||ar|مطار نيس الريفيرا الفرنسي||sv|Nice flygplats|^FRNCE|^"

##
# Usage
if [ "$1" = "-h" -o "$1" = "--help" ]
then
	echo
	echo "Usage: $0 [<log level>]"
	echo "  - Default refdata Geonames-related directory for the OpenTravelData project Git clone: '${DATA_DIR}'"
	echo "  - Default log level: ${LOG_LEVEL}"
	echo "    + 0: No log; 1: Critical; 2: Error; 3; Notification; 4: Debug; 5: Verbose"
	echo "  - Generated files:"
	echo "    + '${GEO_POR_CONC_FILE}'"
	echo
	exit
fi

##
# Log level
if [ "$1" != "" ]
then
	LOG_LEVEL="$1"
fi

##
# Check that the Geonames dump data files have been downloaded and
# uncompressed
declare -a AGG_INPUT_FILES=("${GEO_ADM1_FILE}" "${GEO_ADM2_FILE}" \
	"${GEO_CTRY_FILE}" "${GEO_TZ_FILE}" "${GEO_CONT_FILE}" \
	"${GEO_POR_ALT_FILE}" "${GEO_POR_FILE}")
for file in "${AGG_INPUT_FILES[@]}"
do
    if [ ! -f "${file}" ]
    then
		echo "The Geonames data dump file ('${file}') does not seem " \
			 "to have been downloaded"
		echo "Content of the local directory ('${DATA_DIR}') where Geonames " \
			 "data dump files are expected to be downloaded:"
		ls -laFh ${DATA_DIR}
		echo "Hint: run ./getDataFromGeonamesWebsite.sh before"
		exit -1
    fi
done


##
# Check that the line format has not been changed and/or for outliers.
#
# Note that, contrary to awk, grep takes \t as a mere 't' (\t is not a POSIX
# standard). So, the \t of awk must be replaced by actual TAB characters,
# which may be entered thanks to the <CTRL-q TAB> sequence in Emacs and
# <CTRL-v TAB> sequence in the Shell command-line.
#
# Test 1 - Count the lines with the given regex
# The following commands:
# grep "^\([A-Z]\{2\}\)<TAB>.*<TAB>\([0-9.-]*\)<TAB>\([0-9.-]*\)<TAB>\([0-9.-]*\)$" ${GEO_TZ_FILE} | wc -l
# grep "^\([A-Z]\{2\}\)<TAB>\([A-Za-z ]\+\)<TAB>\([0-9]\{1,9\}\)$" ${GEO_CONT_FILE} | wc -l
# grep "^\([0-9]\{1,9\}\)<TAB>.*<TAB>\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)$" ${GEO_POR_FILE} | wc -l
# grep "^\([0-9]\{1,9\}\)<TAB>\([0-9]\{1,9\}\)<TAB>\([a-z]\{0,5\}[_]\{0,1\}[0-9]\{0,4\}\)<TAB>" ${GEO_POR_ALT_FILE} | wc -l
# should give the same result as:
# wc -l ${GEO_TZ_FILE} ${GEO_CONT_FILE} ${GEO_POR_FILE} ${GEO_POR_ALT_FILE}
# Note that for some POR UTF-8 alternate names, e.g., the Korean version of Nice Airport (Geonames ID: 6299418),
# the "^" sequence (spotting the beginning of the string) does not seem to work on Linux
# (it works on MacOS).
#
# Test 2 - Output the lines not matching the regex
# The following commands should yield empty results:
# grep -nv "^\([A-Z]\{2\}\)<TAB>.*<TAB>\([0-9.-]*\)<TAB>\([0-9.-]*\)<TAB>\([0-9.-]*\)$" ${GEO_TZ_FILE}
# grep -nv "^\([A-Z]\{2\}\)<TAB>\([A-Za-z ]\+\)<TAB>\([0-9]\{1,9\}\)$" ${GEO_CONT_FILE}
# grep -nv "^\([0-9]\{1,9\}\)<TAB>.*<TAB>\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)$" ${GEO_POR_FILE}
# grep -nv "^\([0-9]\{1,9\}\)<TAB>\([0-9]\{1,9\}\)<TAB>\([a-z]\{0,5\}[_]\{0,1\}[0-9]\{0,4\}\)<TAB>" ${GEO_POR_ALT_FILE}
#
# Test 3 - Output the lines of the other files matching the regex
# The following commands should yield empty results:
# grep -n "^\([A-Z]\{2\}\)<TAB>.*<TAB>\([0-9.-]*\)<TAB>\([0-9.-]*\)<TAB>\([0-9.-]*\)$" ${GEO_CONT_FILE} ${GEO_POR_FILE} ${GEO_POR_ALT_FILE}
# grep -n "^\([A-Z]\{2\}\)<TAB>\([A-Za-z ]\+\)<TAB>\([0-9]\{1,9\}\)$" ${GEO_TZ_FILE} ${GEO_POR_FILE} ${GEO_POR_ALT_FILE}
# grep -n "^\([0-9]\{1,9\}\)<TAB>.*<TAB>\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)$" ${GEO_TZ_FILE} ${GEO_CONT_FILE} ${GEO_POR_ALT_FILE}
# grep -n "^\([0-9]\{1,9\}\)<TAB>\([0-9]\{1,9\}\)<TAB>\([a-z]\{0,5\}[_]\{0,1\}[0-9]\{0,4\}\)<TAB>" ${GEO_TZ_FILE} ${GEO_CONT_FILE} ${GEO_POR_FILE}

##
# Calculate the number of lines of the main Geoname POR file,
# so as to report the progress in the next data processing task below.
NB_POR="$(${WC_TOOL} -l ${GEO_POR_FILE} | \
	     ${SED_TOOL} -E 's/^([^0-9]*)([0-9]+)([^0-9])*$/\2/g')"

##
# Concatenate the alternate name details, and add them back to the line of
# details for every Geoname POR.
AGGREGATOR="aggregateGeonamesPor.awk"
echo
echo "Aggregating Geonames dump data files (${AGG_INPUT_FILES[@]})..."
AWKCMD="awk -F'\t' -v log_level="${LOG_LEVEL}" -v nb_por="${NB_POR}" \
	-f ${AGGREGATOR} ${AGG_INPUT_FILES[@]}"
#echo "AWK command to be executed:"
#echo "${AWKCMD} > ${GEO_POR_CONC_FILE}"
time awk -F'\t' -v log_level="${LOG_LEVEL}" -v nb_por="${NB_POR}" \
	-f ${AGGREGATOR} ${AGG_INPUT_FILES[@]} > ${GEO_POR_CONC_FILE}
echo "... done"
echo

##
# Reporting
echo
echo "The '${GEO_POR_CONC_FILE}' file has been generated from both " \
	 "the '${GEO_POR_ALT_FILE}' and '${GEO_POR_FILE}' input files."
echo

# Check #1
echo "Simple check #1 (the size of the output file should be roughly " \
	 "equal to the sum of the sizes of the input files): " \
	 "ls -lh ${GEO_POR_ALT_FILE} ${GEO_POR_FILE} ${GEO_POR_CONC_FILE}"
ls -lh ${GEO_POR_ALT_FILE} ${GEO_POR_FILE} ${GEO_POR_CONC_FILE}
echo

# Check #2
echo "Simple check #2: " \
	 "${WC_TOOL} -l ${GEO_POR_ALT_FILE} ${GEO_POR_FILE} ${GEO_POR_CONC_FILE}"
${WC_TOOL} -l ${GEO_POR_ALT_FILE} ${GEO_POR_FILE} ${GEO_POR_CONC_FILE}
echo

# Check #3
echo "Simple check #3: grep -n \"^NCE\^LFMN\" ${GEO_POR_CONC_FILE}"
NCE_POR="$(grep "^NCE\^LFMN" ${GEO_POR_CONC_FILE})"
if [ "${NCE_POR}" = "${NCE_POR_REF}" ]
then
	echo "	Strings are equal"
else
	echo "	Strings are not equal. Someone may have added some alternate names?"
	echo "	Compare (result of grep -n \"^NCE\^LFMN\" ${GEO_POR_CONC_FILE}):"
	echo "	${NCE_POR}"
	echo "	to (reference):"
	echo "	${NCE_POR_REF}"
fi
echo

#
echo

