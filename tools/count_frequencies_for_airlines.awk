##
# That AWK script calculates the number of flight-dates per airline.
#

##
#
BEGIN {
	#
	air_code = ""
	freq = 0
}

##
# Sample lines:
# air_code^org^dst^freq_al^freq_tot^org_id^dst_id
# AF^FRA^CDG^2209^2209^11^49
# CL^FRA^CDG^4^2213^11^49
# LH^FRA^CDG^3105^5318^11^49
#
{
	# Airline code
	new_air_code = $1

	if (air_code != new_air_code) {
		# The current line is not for the same airline as the previous line
		if (air_code != "") {
			print air_code "^" freq
		}

		# Reset the variables
		air_code = new_air_code
		freq = 0

	} else {
		# Number of flight-dates for the current relationship:
		# origin -> destination
		freq_rel = $4

		# Increment the global counter for the airline
		freq += freq_rel
	}
}

##
#
END {
	#
	print air_code "^" freq
}
