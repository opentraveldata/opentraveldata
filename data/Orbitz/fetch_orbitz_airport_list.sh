#!/bin/sh

#
ORBITZ_URL=http://www.orbitz.com/App/global/airportCodes.jsp
POR_HTML_FILE=orbitz_airport_list.html
POR_TXT_FILE=orbitz_airport_list.txt
POR_TXT_CSV=orbitz_airport_list.csv

# Fetch the file, in HTML format
wget ${ORBITZ_URL}

# Just rename it
\mv -f airportCodes.jsp ${POR_HTML_FILE}

# Extract airport information only
grep "([A-Z][A-Z][A-Z])" ${POR_HTML_FILE} | cut -d'<' -f1 > ${POR_TXT_FILE}

# Convert into CSV
sed -e 's/\(.\+\)\,\ \(.\+\)\ (\([A-Z][A-Z][A-Z]\))/\3^\1\^\2/g' ${POR_TXT_FILE} > ${POR_TXT_CSV}

# Reporting
NB_LINES=`wc -l ${POR_TXT_CSV} | cut -d' ' -f1`
echo
echo "Reporting"
echo "---------"
echo "The airport list fetched from Orbitz (${ORBITZ_URL}) is ${POR_TXT_CSV}, with ${NB_LINES} lines."
echo

# Cleaning
\rm -f ${POR_HTML_FILE} ${POR_TXT_FILE}

