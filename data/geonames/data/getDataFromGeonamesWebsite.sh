#!/bin/sh

#URL_CATCH=wget
#URL_CATCH=copy_if_changed.py
URL_CATCH=download_if_newer.py
UNCOMPRESS="unzip -u -o"

# Retrieve a file from the Geonames.org Web site, and unzip it when needed
retrieveFiles() {
	if [ ! -d ${TARGET_DIR} ];
	then
		mkdir -p ${TARGET_DIR}
	fi

	cd ${TARGET_DIR}

	for file in ${FILES};
	do
		echo "Checking whether '${file}' must be downloaded from ${BASE_URL}"
		if ${URL_TARGET_DIR}${URL_CATCH} -s ${BASE_URL}/${file} -d ${file};
		then
			echo "  Data file '${file}' has been downloaded and updated."
		fi
		if [ -r ${file} ];
		then
			BASE_FILE=`basename ${file} .zip`
			if [ "${file}" = "${BASE_FILE}.zip" ];
			then
				echo "Uncompressing '${file}' (e.g., into '${BASE_FILE}.txt')"
				${UNCOMPRESS} ${file}
			fi
		fi
	done

	cd -
}

# Retrieve the data files for the Point Of Reference (POR), i.e., the main
# Geonames database
BASE_URL=http://download.geonames.org/export/dump
FILES="admin1CodesASCII.txt admin2Codes.txt allCountries.zip alternateNames.zip cities1000.zip cities5000.zip cities15000.zip countryInfo.txt featureCodes_en.txt featureCodes_ru.txt iso-languagecodes.txt hierarchy.zip no-country.zip timeZones.txt userTags.zip"
TARGET_DIR=por/data
URL_TARGET_DIR=../../
retrieveFiles

# Retrieve the data files for the Postal Codes (Zip)
#
# Note: the Postal Codes file has got the same name as the Point Of 
#       Reference (POR) one, but is by all means not the same file!
#
BASE_URL=http://download.geonames.org/export/zip
FILES="allCountries.zip"
TARGET_DIR=zip
URL_TARGET_DIR=../
retrieveFiles

