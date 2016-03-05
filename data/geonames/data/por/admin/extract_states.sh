#!/bin/sh

##
# Extract, from a Geonames-derived snapshot, the list of states
# for a few selected countries.

##
# OpenTravelData (OPTD) data directory
DATA_DIR=../../../../../opentraveldata

##
# Generated file
OPTD_CTRY_ST_LST_FILE=optd_country_states.csv

##
#
awk -F'^' -f extract_states.awk ../data/allCountries_w_alt.txt > ${OPTD_CTRY_ST_LST_FILE}

##
# Reporting
echo
echo "Next Steps"
echo "----------"
echo "mv ${OPTD_CTRY_ST_LST_FILE} ${DATA_DIR}"
echo "git add ${DATA_DIR}/${OPTD_CTRY_ST_LST_FILE}"
echo "git commit -m \"[Countries] Updated the list of states per country.\" ${DATA_DIR}/${OPTD_CTRY_ST_LST_FILE}"
echo

