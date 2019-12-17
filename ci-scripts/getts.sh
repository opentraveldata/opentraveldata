#!/bin/bash

#
# Example of time-stamp: 2019-12-17 09:50:08
extractTimeStamp() {
        if [ ! -f ${git_file} ]
        then
                echo
                echo "Error! The ${git_file} file (set by the git_file variable) does not seem to exist"
                echo
                exit 1
        fi

	# Extract the date and time from the Git time-stamp for that file
        declare -a ts_array=($(git log -1 --pretty=""format:%ci"" ${git_file} | cut -d' ' -f1,2))
	ts_date="${ts_array[0]}"
	ts_time="${ts_array[1]}"
	echo "Date: ${ts_date} - Timee: ${ts_time}"
	
	# Extract the year, month and day
	declare -a ts_date_array=($(echo "${ts_date}" | sed -e 's/-/ /g'))
	ts_year="${ts_date_array[0]}"
	ts_month="${ts_date_array[1]}"
	ts_day="${ts_date_array[2]}"
	echo "Year: ${ts_year} - Month: ${ts_month} - Day: ${ts_day}"

	# Extract the hour, minutes and seconds
	declare -a ts_time_array=($(echo "${ts_time}" | sed -e 's/:/ /g'))
	ts_hours="${ts_time_array[0]}"
	ts_mins="${ts_time_array[1]}"
	ts_secs="${ts_time_array[2]}"
	echo "Hours: ${ts_hours} - Hours: ${ts_mins} - Seconds: ${ts_secs}"
}

#
git_file="opentraveldata/optd_por_public.csv"

if [ "$1" != "" ]
then
	git_file="$1"
fi

#
extractTimeStamp


