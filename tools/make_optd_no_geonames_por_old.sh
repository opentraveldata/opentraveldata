#!/bin/sh

##
# To be removed once the make_optd_por_public.{awk,sh} scripts are updated

##
# OpenTravelData
OPTD_DIR=../
DATA_DIR=${OPTD_DIR}opentraveldata/

##
# Input
OPTD_POR_FILE=${DATA_DIR}optd_por_public.csv

##
# Output
OPTD_POR_NO_GEOID_FILE=${DATA_DIR}optd_por_no_geonames_old.csv

##
# Temporary
HEADER_FILE=${OPTD_POR_NO_GEOID_FILE}.hdr
OPTD_POR_NO_GEOID_FILE_TMP=${OPTD_POR_NO_GEOID_FILE}.tmp

##
# Header
echo "iata_code^icao_code^faa_code^is_geonames^geoname_id^envelope_id^name^asciiname^latitude^longitude^fclass^fcode^page_rank^date_from^date_until^comment^country_code^cc2^country_name^continent_name^adm1_code^adm1_name_utf^adm1_name_ascii^adm2_code^adm2_name_utf^adm2_name_ascii^adm3_code^adm4_code^population^elevation^gtopo30^timezone^gmt_offset^dst_offset^raw_offset^moddate^city_code_list^city_name_list^city_detail_list^tvl_por_list^state_code^location_type^wiki_link^alt_name_section^wac^wac_name" > ${HEADER_FILE}

##
# Extraction of non Geonames POR
awk -F'^' '{if ($4=="N" && $6=="") {print $0}}' ${OPTD_POR_FILE} > ${OPTD_POR_NO_GEOID_FILE_TMP}

##
# Addition of the header
cat ${HEADER_FILE} ${OPTD_POR_NO_GEOID_FILE_TMP} > ${OPTD_POR_NO_GEOID_FILE}

##
# Cleaning
\rm -f ${HEADER_FILE} ${OPTD_POR_NO_GEOID_FILE_TMP}

##
# Reporting
echo
echo "Status"
echo "------"
echo "Generated '${OPTD_POR_NO_GEOID_FILE}' from '${OPTD_POR_FILE}'."
echo

