#!/bin/bash

# Input
ORI_GEO_FILE=../ORI/ori_por_best_known_so_far.csv

# Output
ORI_APT_FOR_GEO_FILE=../ORI/ori_por_apt_for_geonames.csv

#
echo
echo "Extracting all the airports not identified in Geonames..."
awk -F'^' '{if (match ($1, "A-0")) {print $0}}' ${ORI_GEO_FILE} > ${ORI_APT_FOR_GEO_FILE}
echo
echo "wc -l ${ORI_APT_FOR_GEO_FILE}"
echo "less ${ORI_APT_FOR_GEO_FILE}"
echo

