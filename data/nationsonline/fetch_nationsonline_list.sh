#!/bin/sh

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

# Snapshot date
SNAPSHOT_DATE=`date "+%Y%m%d"`
SNAPSHOT_DATE_HUMAN=`date`

#
OPEN_URL=http://www.nationsonline.org/oneworld/IATA_Codes/airport_code_list.htm

#
POR_HTML_FILE=airport_code_list.htm
POR_CSV_ORIG_FILE=nationsonline_airport_list.csv
POR_CSV_FILE=nationsonline_airport_list_${SNAPSHOT_DATE}.csv
POR_HDR_FILE=${POR_CSV_FILE}.hdr
POR_TMP_FILE=${POR_CSV_FILE}.tmp
#
EXTRACTER=extract_airport_list.awk

# Fetch the HTML file with the list of airports
wget ${OPEN_URL}

# Extract the POR details from the HTML file
awk -f ${EXTRACTER} ${POR_HTML_FILE} > ${POR_CSV_FILE}

# Extract the header
grep '^iata_code\^' ${POR_CSV_FILE} > ${POR_HDR_FILE}
sed -i -e 's/^iata_code\^\(.+\)//g' ${POR_CSV_FILE}
sed -i -e '/^$/d' ${POR_CSV_FILE}

# Sort by IATA code
sort -t'^' -k1,1 ${POR_CSV_FILE} > ${POR_TMP_FILE}

# Re-add the header
cat ${POR_HDR_FILE} ${POR_TMP_FILE} > ${POR_CSV_FILE}

# Cleaning
\rm -f ${POR_HTML_FILE} ${POR_HDR_FILE} ${POR_TMP_FILE}

# Reporting
NB_LINES=`wc -l ${POR_CSV_FILE} | cut -d' ' -f1`
echo
echo "Reporting"
echo "---------"
echo "The ${POR_CSV_FILE} file has been generated from the NationsOnline Web-site (${OPEN_URL})."
echo "There are ${NB_LINES} rows. To compare with the archived data file:"
echo "diff -c ${POR_CSV_ORIG_FILE} ${POR_CSV_FILE}"
echo "If there is no difference:"
echo "\rm -f ${POR_CSV_FILE}"
echo

