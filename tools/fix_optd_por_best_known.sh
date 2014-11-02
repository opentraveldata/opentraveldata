#!/bin/sh

##
# Input files
BST_FILENAME=optd_por_best_known_so_far.csv
GEO_FILE=dump_from_geonames.csv
RFD_FILE=dump_from_crb_city.csv
BST_FILE=../opentraveldata/${BST_FILENAME}

##
# Output files
BST_NEW_FILE=new_${BST_FILENAME}
BST_WGEO_NEW_FILE=${BST_NEW_FILE}.wgeo
BST_WRFD_NEW_FILE=${BST_NEW_FILE}.wrfd

##
# Temporary files
BST_WGEO_FILE_TMP=${BST_WGEO_NEW_FILE}.tmp
BST_WRFD_FILE_TMP=${BST_WRFD_NEW_FILE}.tmp

#
if [ "$1" = "--clean" ];
then
	\rm -f ${BST_NEW_FILE} ${BST_WGEO_NEW_FILE} ${BST_WRFD_NEW_FILE} \
		${BST_WGEO_FILE_TMP} ${BST_WRFD_FILE_TMP}
	exit
fi

##
#
if [ ! -f ${GEO_FILE} ]
then
	echo
	echo "The ${GEO_FILE} file is missing."
	echo "Hint: launch the ./preprepare_geonames_dump_file.sh script."
	echo
	exit -1
fi
#
if [ ! -f ${RFD_FILE} ]
then
	echo
	echo "The ${RFD_FILE} file is missing."
	echo "Hint: Copy the ${RFD_FILE} from the Data Analysis project."
	echo
	exit -1
fi
#
if [ ! -f ${BST_FILE} ]
then
	echo
	echo "The ${BST_FILE} file is missing."
	echo "Hint: you probably launch the current script ($0) from another directory than <opentraveldata>/refdata/tools."
	echo
	exit -1
fi

##
# Extract the header into a temporary file
GEO_FILE_HEADER=${GEO_FILE}.tmp.hdr
grep "^iata\(.\+\)" ${GEO_FILE} > ${GEO_FILE_HEADER}
#
RFD_FILE_HEADER=${RFD_FILE}.tmp.hdr
grep "^code\(.\+\)" ${RFD_FILE} > ${RFD_FILE_HEADER}

# Remove the header
sed -i -e "s/^iata\(.\+\)//g" ${GEO_FILE}
sed -i -e "/^$/d" ${GEO_FILE}
#
sed -i -e "s/^code\(.\+\)//g" ${RFD_FILE}
sed -i -e "/^$/d" ${RFD_FILE}

##
# Extract the POR having (0, 0) as coordinates
awk -F'^' '{if ($2 == 0 || $3 == 0) {print ($1)}}' ${BST_FILE} > ${BST_NEW_FILE}
NB_ZERO_ROWS=`wc -l ${BST_NEW_FILE} | cut -d' ' -f1`

##
# Sort the list of POR
sort -t'^' -k1,1 ${BST_NEW_FILE} > ${BST_WGEO_FILE_TMP}
\mv -f ${BST_WGEO_FILE_TMP} ${BST_WGEO_NEW_FILE}
#
sort -t'^' -k1,1 ${BST_NEW_FILE} > ${BST_WRFD_FILE_TMP}
\mv -f ${BST_WRFD_FILE_TMP} ${BST_WRFD_NEW_FILE}

##
# Join the coordinates of Geonames, next to the POR IATA codes
join -t'^' -a 1 ${BST_WGEO_NEW_FILE} ${GEO_FILE} > ${BST_WGEO_FILE_TMP}
# Join the coordinates of Geonames, next to the POR IATA codes
join -t'^' -a 1 ${BST_WRFD_NEW_FILE} ${RFD_FILE} > ${BST_WRFD_FILE_TMP}

# Reduce the lines
FIX_BST_REDUCER=fix_optd_por_best_known.awk
awk -F'^' -f ${FIX_BST_REDUCER} ${BST_WGEO_FILE_TMP} > ${BST_WGEO_NEW_FILE}
NB_GEO_FIXED_ROWS=`wc -l ${BST_WGEO_NEW_FILE} | cut -d' ' -f1`
#
awk -F'^' -f ${FIX_BST_REDUCER} ${BST_WRFD_FILE_TMP} > ${BST_WRFD_NEW_FILE}
NB_RFD_FIXED_ROWS=`wc -l ${BST_WRFD_NEW_FILE} | cut -d' ' -f1`

##
# Join the coordinates of the pristine OPTD file with the one of fixed
# coordinates.
join -t'^' -a 2 ${BST_WGEO_NEW_FILE} ${BST_FILE} > ${BST_WGEO_FILE_TMP}
join -t'^' -a 2 ${BST_WRFD_NEW_FILE} ${BST_FILE} > ${BST_WRFD_FILE_TMP}

# Replace the coordinates, when those latter have been fixed by Geonames.
# The trick is that the same AWK reducer is used. Indeed, the number of
# fields is different now, when compared to the former use case.
awk -F'^' -f ${FIX_BST_REDUCER} ${BST_WGEO_FILE_TMP} > ${BST_WGEO_NEW_FILE}
awk -F'^' -f ${FIX_BST_REDUCER} ${BST_WRFD_FILE_TMP} > ${BST_WRFD_NEW_FILE}

##
# Re-add the header to the Geonames dump file
GEO_FILE_TMP=${GEO_FILE}.tmp
cat ${GEO_FILE_HEADER} ${GEO_FILE} > ${GEO_FILE_TMP}
\mv -f ${GEO_FILE_TMP} ${GEO_FILE}
\rm -f ${GEO_FILE_HEADER}
#
RFD_FILE_TMP=${RFD_FILE}.tmp
cat ${RFD_FILE_HEADER} ${RFD_FILE} > ${RFD_FILE_TMP}
\mv -f ${RFD_FILE_TMP} ${RFD_FILE}
\rm -f ${RFD_FILE_HEADER}

##
# Reporting
echo
echo "Reporting"
echo "---------"
echo "The ${BST_FILE} contains ${NB_ZERO_ROWS} POR with wrong coordinates."
echo "Among those:"
echo " - ${NB_GEO_FIXED_ROWS} may be fixed, thanks to Geonames."
echo " - ${NB_RFD_FIXED_ROWS} may be fixed, thanks to RFD."
if [ ${NB_GEO_FIXED_ROWS} -gt 0 ]
then
	echo "The ${BST_WGEO_NEW_FILE} file intends to replace ${BST_FILE}:"
	echo "wc -l ${BST_WGEO_NEW_FILE} ${BST_FILE}"
	echo "diff -c ${BST_WGEO_NEW_FILE} ${BST_FILE} | less"
fi
if [ ${NB_RFD_FIXED_ROWS} -gt 0 ]
then
	echo "The ${BST_WRFD_NEW_FILE} file intends to replace ${BST_FILE}:"
	echo "wc -l ${BST_WRFD_NEW_FILE} ${BST_FILE}"
	echo "diff -c ${BST_WRFD_NEW_FILE} ${BST_FILE} | less"
fi
echo

