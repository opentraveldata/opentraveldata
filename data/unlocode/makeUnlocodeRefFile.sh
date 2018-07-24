#!/bin/bash

set -x

#
UNLC_VER="2018-1"
FILE1=${UNLC_VER}\ UNLOCODE\ CodeListPart1.csv
FILE2=${UNLC_VER}\ UNLOCODE\ CodeListPart2.csv
FILE3=${UNLC_VER}\ UNLOCODE\ CodeListPart3.csv
OUT_FILE=unlocode-code-list-${UNLC_VER}.csv
TMP_FILE=${OUT_FILE}.tmp

# Tools
ICONV_EXEC=`which iconv`
DOS2UNIX_EXEC=`which dos2unix`

if [ ! -x "${ICONV_EXEC}" ]
then
	echo
	echo "The 'iconv' utility is missing. Please install it."
	echo
	exit -1
fi

if [ ! -x "${DOS2UNIX_EXEC}" ]
then    
	echo
	echo "The 'dos2unix' utility is missing. Please install it."
	echo 
	exit -1
fi


if [ ! -f "${FILE1}" ]
then
	echo
	echo "There expected data files, namely '${FILE_LIST}' do not seem to have been downloaded."
	echo "Please have a look at https://github.com/opentraveldata/opentraveldata/tree/master/data/unlocode"
	echo
	exit -1
fi

# Concateting the files
cat "${FILE1}" "${FILE2}" "${FILE3}" > ${TMP_FILE}

# Unicode conversion
${ICONV_EXEC} -f ISO-8859-1 -t UTF-8 ${TMP_FILE} > ${OUT_FILE}

# Elimination of CR characters
${DOS2UNIX_EXEC} ${OUT_FILE}

# Cleaning
\rm -f ${TMP_FILE}


