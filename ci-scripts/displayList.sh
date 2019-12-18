#!/bin/bash

#
export OPTD_MAP_FILE="ci-scripts/titsc_delivery_map.csv"

#
extractTimeStamp() {
	if [ ! -f ${git_file} ]
	then
		echo
		echo "Error! The ${git_file} file (set by the \$git_file variable) does not seem to exist"
		echo
		exit 1
	fi

    # Extract the date and time from the Git time-stamp for that file
	git_log_full="$(git log -1 --pretty=""format:%ci"" ${git_file})"
	git_log_date_time="$(echo ${git_log_full} | cut -d' ' -f1,2)"
	#echo "${git_file}: last update time-stamp on OPTD Git: ${git_log_full}"

	# Extract the date and time
    declare -a ts_array=(${git_log_date_time})
    ts_date="${ts_array[0]}"
    ts_time="${ts_array[1]}"
    #echo "Date: ${ts_date} - Timee: ${ts_time}"
        
    # Extract the year, month and day
    declare -a ts_date_array=($(echo "${ts_date}" | sed -e 's/-/ /g'))
    ts_year="${ts_date_array[0]}"
    ts_month="${ts_date_array[1]}"
    ts_day="${ts_date_array[2]}"
    #echo "Year: ${ts_year} - Month: ${ts_month} - Day: ${ts_day}"

    # Extract the hour, minutes and seconds
    declare -a ts_time_array=($(echo "${ts_time}" | sed -e 's/:/ /g'))
    ts_hours="${ts_time_array[0]}"
    ts_mins="${ts_time_array[1]}"
    ts_secs="${ts_time_array[2]}"
    #echo "Hours: ${ts_hours} - Hours: ${ts_mins} - Seconds: ${ts_secs}"
}

#
displayItem() {
	# Extract the details of OPTD data files
	org_dir="$(echo ${optd_map_line} | cut -d'^' -f1)"
	csv_stated_filename="$(echo ${optd_map_line} | cut -d'^' -f2)"
	tgt_dir="$(echo ${optd_map_line} | cut -d'^' -f3)"

	# Index
	idx=$((idx+1))
	
	#
	csv_stated_file="${org_dir}/${csv_stated_filename}"
	if [ ! -f "${csv_stated_file}" ]
	then
		echo "\n#####"
		echo "In ci-scripts/titsc_delivery_map.csv:${idx}"
		echo "\$org_dir=${org_dir}"
		echo "\$csv_stated_filename=${csv_stated_filename}"
		echo "\$tgt_dir=${tgt_dir}"
		echo "The origin CSV data file '${csv_stated_file}' is missing "\
			 "in this repo"
		echo "It is expected to upload it to ${TITSC_SVR} into " \
			 "'${DATA_DIR_BASE}/cicd/${tgt_dir}'"
		echo "If that file has been removed from the OPTD repository, " \
			 "please update ${OPTD_MAP_FILE}"
		echo "#####\n"
		exit 1
	fi

	# If the file is actually a symbolic link, we must first get to the actual
	# data file
	if [ -L "${csv_stated_file}" ]
	then
		# The file is actually a symbolic link
		csv_file=$(realpath ${csv_stated_file})
		csv_filename=$(basename ${csv_file})
	else
		# The file is an actual data file
		csv_file="${csv_stated_file}"
		csv_filename="${csv_stated_filename}"
	fi
		
	#
	git_file="${csv_file}"
	extractTimeStamp

	#
	printf '[%s][%s][%s][%s] %s and %s => %s (%s), targetting %s\n' \
		   "${idx}" "${optd_map_line}" \
		   "${ts_date}" "${ts_time}" \
		   "${org_dir}" "${csv_stated_filename}" \
		   "${csv_file}" "${csv_filename}" "${tgt_dir}"
}

# Main
idx=0
while IFS="" read -r -u3 optd_map_line
do
	displayItem
done 3< "${OPTD_MAP_FILE}"

