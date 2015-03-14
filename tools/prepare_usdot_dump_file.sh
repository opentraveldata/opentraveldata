#!/bin/sh

# US DOT World Area Codes (WAC)
USDOT_DIR=../data/countries/DOT
#RAW_USDOT_FILENAME=L_WORLD_AREA_CODES.csv
RAW_USDOT_FILENAME=495998804_T_WAC_COUNTRY_STATE.csv
OPTD_USDOT_FILENAME=optd_usdot_wac.csv
#
RAW_USDOT_FILE=$USDOT_DIR/$RAW_USDOT_FILENAME
OPTD_USDOT_FILE=$OPTD_USDOT_FILENAME
#
OPTD_USDOT_FILE_TMP1=$OPTD_USDOT_FILE.tmp1
OPTD_USDOT_FILE_TMP2=$OPTD_USDOT_FILE.tmp2
OPTD_USDOT_FILE_TMP3=$OPTD_USDOT_FILE.tmp3

# Replace the double comma (,) separator by a comma-hat (,^) pair.
# That is a trick, as the comma pair is not detected afterwards.
sed -e 's/,,/,\^/g' $RAW_USDOT_FILE > $OPTD_USDOT_FILE_TMP1
#awk -F',' '{myline=$0; OFS="^"; NF++; NF--; print $0}' $RAW_USDOT_FILE > $OPTD_USDOT_FILE

# Replace the comma (,) separator by a hat (^) for the numeric fields at the beginning of the line
sed -e 's/^\([[:digit:]]\+\),/\1\^/g' $OPTD_USDOT_FILE_TMP1 > $OPTD_USDOT_FILE_TMP2

# Replace the comma (,) separator by a hat (^) for the other numeric fields
sed -e 's/\([,^-]\)\([[:digit:]]\+\),/\1\2\^/g' $OPTD_USDOT_FILE_TMP2 > $OPTD_USDOT_FILE_TMP3

# Remove the quote characters (")
sed -e 's/\"\([^\"]*\)\",/\1\^/g' $OPTD_USDOT_FILE_TMP3 > $OPTD_USDOT_FILE

# Remove temporary files
\rm -f $OPTD_USDOT_FILE_TMP1 $OPTD_USDOT_FILE_TMP2 $OPTD_USDOT_FILE_TMP3

# Consistency check
awk -F'^' '{if (NF != 17) {\
             print "[Error] The expected number of fields is 17; the following line has got " NF " fields:\n" $0 > "/dev/stderr"}\
           }' $OPTD_USDOT_FILE

# Reporting
echo
echo "The Open Travel Data (OPTD) version of the US DOT World Area Code (WAC) file, $OPTD_USDOT_FILE, has been generated."
echo "\mv -f $OPTD_USDOT_FILE $USDOT_DIR"
echo "git add $USDOT_DIR/$OPTD_USDOT_FILE"
echo "git diff --cached $USDOT_DIR/$OPTD_USDOT_FILE"
echo "git commit -m \"[Countries] The US DOT World Area Code (WAC) file now reflects the latest updates.\" $USDOT_DIR"
echo

