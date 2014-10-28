#!/bin/bash

#
CITY_CODE=IEV

#
if [ "$1" != "" ]
then
	CITY_CODE=$1
fi

#
ORI_POR_FILENAME=ori_por_public.csv
ORI_POR_FILE=${ORI_POR_FILENAME}

#
awk -F'^' -v city_code=${CITY_CODE} '{if ($28 == city_code) {print ($0)}}' ${ORI_POR_FILE} | grep --color "^\([A-Z]\{3\}\)"

