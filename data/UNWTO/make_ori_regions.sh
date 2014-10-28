#!/bin/sh
#
# That script extract information from the UNWTO region
# specification data file (refdata/UNWTO/unwto_region_details.tsv),
# and dump them into two output files:
# * refdata/ORI/ori_regions.csv
# * refdata/ORI/ori_region_details.csv
#
# Note that both those files may be already filled with details
# for other users (e.g., Geonames). So, the content non related to UNWTO
# is left untouched.

##
# ORI
ORI_DIR=../ORI/

##
# Input: UNTWO regions
UN_RGN_FILENAME=unwto_region_details.tsv
UN_RGN_FILE=${UN_RGN_FILENAME}

##
# Output: ORI regions
ORI_RGN_DET_FILENAME=ori_region_details.csv
ORI_RGN_SUM_FILENAME=ori_regions.csv
#
ORI_RGN_DET_FILE=${ORI_DIR}${ORI_RGN_DET_FILENAME}
ORI_RGN_SUM_FILE=${ORI_DIR}${ORI_RGN_SUM_FILENAME}

##
# Temporary files
HDR_RGN_FILE=${ORI_RGN_SUM_FILE}.hdr
TMP_RGN_WO_HDR_FILE=${ORI_RGN_SUM_FILE}.tmpwohdr
TMP_RGN_FILE=${ORI_RGN_SUM_FILE}.tmp
TMP_RGN_WO_UNWTO_FILE=${ORI_RGN_SUM_FILE}.tmpwounwto

##
# Extract the specifications of each region/continent
RGN_MAKER=make_ori_regions.awk
awk -F'\t' -f ${RGN_MAKER} ${UN_RGN_FILE} > ${TMP_RGN_FILE}
# Extract the header and save it into a dedicated file
grep "^user" ${ORI_RGN_DET_FILE} > ${HDR_RGN_FILE}
# Extract the header
grep -v "^user" ${ORI_RGN_DET_FILE} > ${TMP_RGN_WO_HDR_FILE}
# Extract the content not related to UNWTO, and add it to the new file
grep -v "^UNWTO" ${TMP_RGN_WO_HDR_FILE} >> ${TMP_RGN_FILE}
# Sort the file
sort -t'^' -k1,2 -k6,6 -k9,9 ${TMP_RGN_FILE} > ${TMP_RGN_WO_HDR_FILE}
# Re-add the header
cat ${HDR_RGN_FILE} ${TMP_RGN_WO_HDR_FILE} > ${ORI_RGN_DET_FILE}
# Remove the temporary files
\rm -f ${TMP_RGN_FILE} ${TMP_RGN_WO_UNWTO_FILE} ${HDR_RGN_FILE}
\rm -f ${TMP_RGN_WO_HDR_FILE}

##
# Extract just the region names and dump them into a dedicated file
cut -d'^' -f3 ${ORI_RGN_DET_FILE} | sort -t'^' -k1,1 | uniq > ${TMP_RGN_FILE}
# Extract the content not related to UNWTO
grep -v "^UNWTO" ${ORI_RGN_SUM_FILE} | grep -v "^user" > ${TMP_RGN_WO_UNWTO_FILE}
# Write back the UNWTO content into the ori_regions.csv file
awk -F'^' -f ${RGN_MAKER} ${TMP_RGN_FILE} >> ${TMP_RGN_WO_UNWTO_FILE}
# Sort the ori_regions.csv file
sort -t'^' -k1,2 ${TMP_RGN_WO_UNWTO_FILE} > ${TMP_RGN_FILE}
# Re-write the header of the ori_regions.csv file
echo "user^region_code^region_name^region_id" > ${HDR_RGN_FILE}
# Re-assemble the ori_regions.csv file
cat ${HDR_RGN_FILE} ${TMP_RGN_FILE} > ${ORI_RGN_SUM_FILE}
# Remove the temporary files
\rm -f ${TMP_RGN_FILE} ${TMP_RGN_WO_UNWTO_FILE} ${HDR_RGN_FILE}

##
# Reporting
echo
echo "Generated '${ORI_RGN_DET_FILE}' and '${ORI_RGN_SUM_FILE}' from '${UN_RGN_FILE}'"
echo

