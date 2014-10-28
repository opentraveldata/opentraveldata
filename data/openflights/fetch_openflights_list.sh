#!/bin/sh

#
OPEN_URL=http://openflights.svn.sourceforge.net/viewvc/openflights/openflights/data/airports.dat

POR_DAT_FILE=airports.dat
POR_CSV_FILE=openflights_airport_list.csv

#
wget ${OPEN_URL}
\mv -f ${POR_DAT_FILE} ${POR_CSV_FILE}


