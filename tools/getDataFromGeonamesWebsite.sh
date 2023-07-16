#!/bin/bash

#
URL_CATCH="download_if_newer.py"
UNCOMPRESS="unzip -u -o"

# Check that Pyenv and pipenv are installed
pyenv_tools=("pyenv" "pipenv")
for pytool in ${pyenv_tools[@]}
do
	if [ ! $(which ${pytool}) ]
	then
		echo
		echo "'${pytool}' cannot be found"
		echo "See installation details on http://github.com/machine-learning-helpers/induction-python/tree/master/installation/virtual-env"
		echo
		exit -1
	fi
done

# Retrieve a file from the Geonames.org Web site, and unzip it when needed
retrieveFiles() {
	if [ ! -d ${TARGET_DIR} ]
	then
		mkdir -p ${TARGET_DIR}
	fi

	for file in ${file_list[@]}
	do
		echo "Checking whether '${file}' must be downloaded from ${BASE_URL}"
		if pipenv run ./${URL_CATCH} -s ${BASE_URL}/${file} -d ${TARGET_DIR}/${file}
		then
			echo "  Data file '${file}' has been downloaded and updated."
		fi
		if [ -r ${TARGET_DIR}/${file} ]
		then
			BASE_FILE=$(basename ${file} .zip)
			if [ "${file}" = "${BASE_FILE}.zip" ]
			then
				echo "Uncompressing '${file}' (e.g., into '${BASE_FILE}.txt') (in the '${TARGET_DIR}' directory)"
				pushd ${TARGET_DIR}
				${UNCOMPRESS} ${file}
				popd
			fi
		fi
	done
}

# Retrieve the data files for the Point Of Reference (POR), i.e., the main
# Geonames database
BASE_URL="http://download.geonames.org/export/dump"
file_list=("admin1CodesASCII.txt" "admin2Codes.txt" "allCountries.zip" \
	"alternateNamesV2.zip" "alternateNames.zip" "cities1000.zip" "cities5000.zip" \
	"cities15000.zip" "countryInfo.txt" "featureCodes_en.txt" \
	"featureCodes_ru.txt" "iso-languagecodes.txt" "hierarchy.zip" \
       "no-country.zip" "timeZones.txt" "userTags.zip")
TARGET_DIR="../data/geonames/data/por/data"
retrieveFiles

# Retrieve the data files for the Postal Codes (Zip)
#
# Note: the Postal Codes file has got the same name as the Point Of 
#       Reference (POR) one, but is by all means not the same file!
#
BASE_URL="http://download.geonames.org/export/zip"
file_list=("allCountries.zip")
TARGET_DIR="../data/geonames/data/zip"
retrieveFiles

