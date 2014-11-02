#!/bin/bash

# Input
OPTD_GEO_FILE=../opentraveldata/optd_por_best_known_so_far.csv

# Output
OPTD_APT_FOR_GEO_FILE=../opentraveldata/optd_por_apt_for_geonames.csv

#
echo
echo "Extracting all the airports not identified in Geonames..."
awk -F'^' '{if (match ($1, "A-0")) {print $0}}' ${OPTD_GEO_FILE} > ${OPTD_APT_FOR_GEO_FILE}
echo
echo "wc -l ${OPTD_APT_FOR_GEO_FILE}"
echo "less ${OPTD_APT_FOR_GEO_FILE}"
echo

