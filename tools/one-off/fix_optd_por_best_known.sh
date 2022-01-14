#!/bin/bash

##
# Temporary path
TMP_DIR="/tmp/por"

##
# Path of the executable: set it to empty when this is the current directory.
EXEC_PATH=`dirname $0`
# Trick to get the actual full-path
pushd ${EXEC_PATH} > /dev/null
EXEC_FULL_PATH=`popd`
popd > /dev/null
EXEC_FULL_PATH=`echo ${EXEC_FULL_PATH} | sed -e 's|~|'${HOME}'|'`
#
CURRENT_DIR=`pwd`
if [ ${CURRENT_DIR} -ef ${EXEC_PATH} ]
then
	EXEC_PATH="."
	TMP_DIR="."
fi
# If the Geonames dump file is in the current directory, then the current
# directory is certainly intended to be the temporary directory.
if [ -f ${GEO_RAW_FILENAME} ]
then
	TMP_DIR="."
fi
EXEC_PATH="${EXEC_PATH}/"
TMP_DIR="${TMP_DIR}/"

if [ ! -d ${TMP_DIR} -o ! -w ${TMP_DIR} ]
then
	\mkdir -p ${TMP_DIR}
fi

##
# Sanity check: that (executable) script should be located in the
# tools/ sub-directory of the OpenTravelData project Git clone
EXEC_DIR_NAME=`basename ${EXEC_FULL_PATH}`
if [ "${EXEC_DIR_NAME}" != "tools" ]
then
	echo
	echo "[$0:$LINENO] Inconsistency error: this script ($0) should be located in the tools/ sub-directory of the OpenTravelData project Git clone, but apparently is not. EXEC_FULL_PATH=\"${EXEC_FULL_PATH}\""
	echo
	exit -1
fi

##
# OpenTravelData directory
OPTD_DIR=`dirname ${EXEC_FULL_PATH}`
OPTD_DIR="${OPTD_DIR}/"

##
# OPTD sub-directories
DATA_DIR=${OPTD_DIR}opentraveldata/
TOOLS_DIR=${OPTD_DIR}tools/

##
# Input files
BST_FILENAME=optd_por_best_known_so_far.csv
GEO_FILE=${TOOLS_DIR}dump_from_geonames.csv
REF_FILE=${TOOLS_DIR}dump_from_ref_city.csv
BST_FILE=${DATA_DIR}${BST_FILENAME}

##
# Output files
BST_NEW_FILE=${BST_FILENAME}.new
BST_WGEO_NEW_FILE=${BST_NEW_FILE}.wgeo
BST_WREF_NEW_FILE=${BST_NEW_FILE}.wref

##
# Temporary files
BST_WGEO_FILE_TMP=${BST_WGEO_NEW_FILE}.tmp
BST_WREF_FILE_TMP=${BST_WREF_NEW_FILE}.tmp

#
if [ "$1" = "--clean" ];
then
	\rm -f ${BST_NEW_FILE} ${BST_WGEO_NEW_FILE} ${BST_WREF_NEW_FILE} \
		${BST_WGEO_FILE_TMP} ${BST_WREF_FILE_TMP}
	exit
fi

##
#
if [ ! -f ${GEO_FILE} ]
then
	echo
	echo "The ${GEO_FILE} file is missing."
	echo "Hint: launch sh prepare_geonames_dump_file.sh --geonames"
	echo
	exit -1
fi
#
if [ ! -f ${REF_FILE} ]
then
	echo
	echo "The ${REF_FILE} file is missing."
	echo "Hint: Copy the ${REF_FILE} from the Data Analysis project."
	echo
	exit -1
fi
#
if [ ! -f ${BST_FILE} ]
then
	echo
	echo "The ${BST_FILE} file is missing."
	echo "Hint: you probably launch the current script ($0) from another directory than <opentraveldata>/tools."
	echo
	exit -1
fi

##
# Extract the header into a temporary file
GEO_FILE_HEADER=${GEO_FILE}.tmp.hdr
grep "^iata\(.\+\)" ${GEO_FILE} > ${GEO_FILE_HEADER}
#
REF_FILE_HEADER=${REF_FILE}.tmp.hdr
grep "^code\(.\+\)" ${REF_FILE} > ${REF_FILE_HEADER}

# Remove the header
sed -i -e "s/^iata\(.\+\)//g" ${GEO_FILE}
sed -i -e "/^$/d" ${GEO_FILE}
#
sed -i -e "s/^code\(.\+\)//g" ${REF_FILE}
sed -i -e "/^$/d" ${REF_FILE}

##
# Extract the POR having (0, 0) as coordinates
awk -F'^' '{if ($2 == 0 || $3 == 0) {print ($1)}}' ${BST_FILE} > ${BST_NEW_FILE}
NB_ZERO_ROWS=`wc -l ${BST_NEW_FILE} | cut -d' ' -f1`

##
# Sort the list of POR
sort -t'^' -k1,1 ${BST_NEW_FILE} > ${BST_WGEO_FILE_TMP}
\mv -f ${BST_WGEO_FILE_TMP} ${BST_WGEO_NEW_FILE}
#
sort -t'^' -k1,1 ${BST_NEW_FILE} > ${BST_WREF_FILE_TMP}
\mv -f ${BST_WREF_FILE_TMP} ${BST_WREF_NEW_FILE}

##
# Join the coordinates of Geonames, next to the POR IATA codes
join -t'^' -a 1 ${BST_WGEO_NEW_FILE} ${GEO_FILE} > ${BST_WGEO_FILE_TMP}
# Join the coordinates of Geonames, next to the POR IATA codes
join -t'^' -a 1 ${BST_WREF_NEW_FILE} ${REF_FILE} > ${BST_WREF_FILE_TMP}

# Reduce the lines
FIX_BST_REDUCER=one-off/fix_optd_por_best_known.awk
awk -F'^' -f ${FIX_BST_REDUCER} ${BST_WGEO_FILE_TMP} > ${BST_WGEO_NEW_FILE}
NB_GEO_FIXED_ROWS=`wc -l ${BST_WGEO_NEW_FILE} | cut -d' ' -f1`
#
awk -F'^' -f ${FIX_BST_REDUCER} ${BST_WREF_FILE_TMP} > ${BST_WREF_NEW_FILE}
NB_REF_FIXED_ROWS=`wc -l ${BST_WREF_NEW_FILE} | cut -d' ' -f1`

##
# Join the coordinates of the pristine OPTD file with the one of fixed
# coordinates.
join -t'^' -a 2 ${BST_WGEO_NEW_FILE} ${BST_FILE} > ${BST_WGEO_FILE_TMP}
join -t'^' -a 2 ${BST_WREF_NEW_FILE} ${BST_FILE} > ${BST_WREF_FILE_TMP}

# Replace the coordinates, when those latter have been fixed by Geonames.
# The trick is that the same AWK reducer is used. Indeed, the number of
# fields is different now, when compared to the former use case.
awk -F'^' -f ${FIX_BST_REDUCER} ${BST_WGEO_FILE_TMP} > ${BST_WGEO_NEW_FILE}
awk -F'^' -f ${FIX_BST_REDUCER} ${BST_WREF_FILE_TMP} > ${BST_WREF_NEW_FILE}

##
# Re-add the header to the Geonames dump file
GEO_FILE_TMP=${GEO_FILE}.tmp
cat ${GEO_FILE_HEADER} ${GEO_FILE} > ${GEO_FILE_TMP}
\mv -f ${GEO_FILE_TMP} ${GEO_FILE}
\rm -f ${GEO_FILE_HEADER}
#
REF_FILE_TMP=${REF_FILE}.tmp
cat ${REF_FILE_HEADER} ${REF_FILE} > ${REF_FILE_TMP}
\mv -f ${REF_FILE_TMP} ${REF_FILE}
\rm -f ${REF_FILE_HEADER}

##
# Reporting
echo
echo "Reporting"
echo "---------"
echo "The ${BST_FILE} contains ${NB_ZERO_ROWS} POR with wrong coordinates."
echo "Among those:"
echo " - ${NB_GEO_FIXED_ROWS} may be fixed, thanks to Geonames."
echo " - ${NB_REF_FIXED_ROWS} may be fixed, thanks to REF."
if [ ${NB_GEO_FIXED_ROWS} -gt 0 ]
then
	echo "The ${BST_WGEO_NEW_FILE} file intends to replace ${BST_FILE}:"
	echo "wc -l ${BST_WGEO_NEW_FILE} ${BST_FILE}"
	echo "diff -c ${BST_WGEO_NEW_FILE} ${BST_FILE} | less"
fi
if [ ${NB_REF_FIXED_ROWS} -gt 0 ]
then
	echo "The ${BST_WREF_NEW_FILE} file intends to replace ${BST_FILE}:"
	echo "wc -l ${BST_WREF_NEW_FILE} ${BST_FILE}"
	echo "diff -c ${BST_WREF_NEW_FILE} ${BST_FILE} | less"
fi
echo

