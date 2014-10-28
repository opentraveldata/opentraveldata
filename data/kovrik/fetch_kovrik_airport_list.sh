#!/bin/sh

#
OPEN_URL=http://www.kovrik.com/sib/travel/iata-airport-codes.txt

#
POR_DAT_FILE=iata-airport-codes.txt
POR_CSV_FILE=kovrik_airport_list.csv

#
wget ${OPEN_URL}
\mv -f ${POR_DAT_FILE} ${POR_CSV_FILE}

#

