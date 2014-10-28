#!/bin/bash

##
# Temporary path
TMP_DIR="/tmp/por"

##
# Path of the executable: set it to empty when this is the current directory.
EXEC_PATH=`dirname $0`
CURRENT_DIR=`pwd`
if [ ${CURRENT_DIR} -ef ${EXEC_PATH} ]
then
	EXEC_PATH="."
	TMP_DIR="."
fi
EXEC_PATH="${EXEC_PATH}/"
TMP_DIR="${TMP_DIR}/"

if [ ! -d ${TMP_DIR} -o ! -w ${TMP_DIR} ]
then
	\mkdir -p ${TMP_DIR}
fi

##
# Parsing of command-line options
APT_DTLS_FILE=../ORI/optd_por_public.csv
OND_FILE_OPTION="NO"
IS_OND_FILE_STD_INPUT="NO"
for opt_elem in $@
do
  if [ "${opt_elem}" = "-h" -o "${opt_elem}" = "-H" -o "${opt_elem}" = "--h" -o "${opt_elem}" = "--help" ]
  then
    echo
    echo " That script adds geographical coordinates (latitude and longitude)"
    echo " to a given file of O&Ds (origin and destination), which must be"
    echo " given as pairs of airport/city IATA codes, separated by the ^ (hat)"
    echo " sign."
	echo
    echo " If the file-path of the O&D file is not given, the standard input "
    echo " is used instead."
	echo
    echo " The geographical coordinates are fetched from a reference file,"
    echo " whose file-path may also be given. If not given, the "
    echo " ${APT_DTLS_FILE} file is used instead."
    echo
    echo "Usage:"
    echo "    $0 [--apt-details=<airport details CSV file>] [<O&D CSV file>]"
    echo
    exit 0
  fi
  IS_OPTION_APT_DETAILS=`echo "${opt_elem}" | grep "^--apt-details="`
  if [ "${IS_OPTION_APT_DETAILS}" != "" ]
  then
      APT_DTLS_FILE=`echo "${opt_elem}" | sed -e "s/^--apt-details=\(.*\)$/\1/"`
      continue
  fi
  OND_FILE_OPTION="${opt_elem}"
  if [ ! -f "${OND_FILE_OPTION}" ]
  then
      echo
      echo " The O&D file given in the options, namely '${OND_FILE_OPTION}' "
      echo " can not be read. Check that that file exists and that it is readable. "
      echo
      exit -1
  fi
done
#
AIRPORT_DETAILS_FILE=${APT_DTLS_FILE}
if [ "${OND_FILE_OPTION}" = "NO" ]
then
    OND_FILE=/dev/stdin
    OND_COORD_FILE=ond.csv.coord
else
    OND_FILE=${OND_FILE_OPTION}
    OND_COORD_FILE=${OND_FILE}.coord
fi

#
OND_ORG_SORTED_FILE=${TMP_DIR}/ond_org_sorted.csv
OND_DES_SORTED_FILE=${TMP_DIR}/ond_des_sorted.csv
OND_ORG_COORD_FILE=${TMP_DIR}/ond_org_coord.csv
#
TMP_AIRPORT_COORD_FILE=${TMP_DIR}/airport_coord.csv

# Extract the coordinates from the airport details file
cut -d'^' -f 1,8,9 ${AIRPORT_DETAILS_FILE} | sort -t'^' -k 1,1 > ${TMP_AIRPORT_COORD_FILE}

# Sort the O&D file by origin
sort -t'^' -k 1,1 ${OND_FILE} > ${OND_ORG_SORTED_FILE}

# Add the coordinates for the origin
join -t'^' -i -1 1 -2 1 ${TMP_AIRPORT_COORD_FILE} ${OND_ORG_SORTED_FILE} > ${OND_ORG_COORD_FILE}

# Sort the O&D file by destination
sort -t'^' -k 4,4 ${OND_ORG_COORD_FILE} > ${OND_DES_SORTED_FILE}

# Add the coordinates for the destination
join -t'^' -i -1 1 -2 4 ${TMP_AIRPORT_COORD_FILE} ${OND_DES_SORTED_FILE} > ${OND_COORD_FILE}

# Re-swap the origin and destination, as the above process has swapped them
awk -F'^' '{printf ($4 "^" $5 "^" $6 "^" $1 "^" $2 "^" $3 "\n")}' ${OND_COORD_FILE}

# Clean the place
if [ "${TMP_DIR}" != "./" ]
then
	\rm -rf ${TMP_DIR}
else
	\rm -f ${TMP_AIRPORT_COORD_FILE} ${OND_ORG_SORTED_FILE} ${OND_DES_SORTED_FILE} ${OND_ORG_COORD_FILE} ${OND_COORD_FILE}
fi

