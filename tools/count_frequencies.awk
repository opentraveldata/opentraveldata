##
# That AWK script calculates the frequencies between any two POR (points of
# reference), e.g., airports and cities. It also allocates unique indices
# to every POR. Indeed, the PageRank algorithm, operated by the ond_pagerank.py
# Python script, needs integer IDs rather than strings (airport/city codes).
# The frequencies are counted per airline and overall.
#
# That AWK script is used twice, on two input files with distinct formats:
# 1. Operating legs derived from the schedule file:
#      oag_schedule_opt_YYMMDD_all.csv.tmp
# 2. Operating legs, combined with the corresponding cities:
#      oag_schedule_with_cities_YYMMDD_all.csv.tmp
#
# Depending on the input file, the output format is not the same.
#
# 1.1. Sample input lines (only airports, no city):
#   AM^ATL^MEX
#   K5^PDX^OTH
# 1.2. Output format:
# 	airline_code^origin^destination^freq_al^freq_tot^idx_orig^idx_dest
#   AM^ATL^MEX^333^333^4^2        City/Airport -> Airport
# 	AM^MEX^ATL^333^333^2^4        Airport -> City/Airport
# The type of origin or destination is 'A' for travel-related (e.g., airport),
# 'C' for city and 'CA' for an undifferentiated city/travel-related.
#
# 2.1. Sample input lines (airports and cities):
#   AM^ATL^A^MEX^A^333^333
#   AM^ATL^A^MEX^C^333^333
#   AM^ATL^C^MEX^A^333^333
#   K5^DFW^C^ELD^A^628^628
#   K5^DFW^C^ELD^C^628^628
# 2.2. Output format:
# 	airline_code^origin^origin_type^destination^destination_type^freq_al^freq_tot^idx_orig^idx_dest
# 	AM^ATL^C^MEX^A^333^333^8^2            City -> Airport
#   AM^TRC^CA^MEX^A^1246^1246^108^2       City/Airport -> Airport
# 	AM^MEX^A^TRC^CA^1247^1247^2^108       Airport -> City/Airport
# 	AM^MEX^A^ATL^C^333^333^2^8            Airport -> City
# The type of origin or destination is 'A' for travel-related (e.g., airport),
# 'C' for city and 'CA' for an undifferentiated city/travel-related.
#


##
# Initialisation
#
BEGINFILE {
	#
	airline_code = ""
	origin_str = ""
	destination_str = ""

	# Global POR index
	GlobalPORIdx = 1

	# Flight frequency
	freq_al = 0
}


##
# Get the index of a given POR
function getPORIndex(__porCode) {
	__porIdx = code_array[__porCode]
	return __porIdx
}

##
# * Register the POR, if needed, and assign it a unique index.
# * Register the frequency counter for that relationship.
#
function registerRelationship(__porOrg, __porDst, __freq) {
	#
	if (!(__porOrg in code_array)) {
		code_array[__porOrg] = GlobalPORIdx
		GlobalPORIdx++
	}

	#
	if (!(__porDst in code_array)) {
		code_array[__porDst] = GlobalPORIdx
		GlobalPORIdx++
	}

	# Register the frequency counter for the relationship.
	relation_str = __porOrg "^" __porDst
	freq_array[relation_str] += __freq
	__freqTot = freq_array[relation_str]

	# Return the cumulative value of the flight frequency for that relationship
	return __freqTot
}


##
# Display the POR relationship with the appropriate format:
#   airline_code^origin_string^destination_string^freq_al^freq_tot^org_id^dest_id
#
function displayRelationship(__airCode, __porOrg, __porDst, __freq, __freqTot) {
	if (__porOrg != "" && __porDst != "") {
		__porOrgIdx = getPORIndex(__porOrg)
		__porDstIdx = getPORIndex(__porDst)
		print (__airCode "^" __porOrg "^" __porDst "^" __freq "^" __freqTot \
			   "^" __porOrgIdx "^" __porDstIdx)
	}
}


##
# Register and display the relationship
#
function registerAndDisplayRelationship() {

	if (origin_str == new_origin_str && destination_str == new_destination_str) {

		if (airline_code == new_airline_code) {
			# The relationship is the same as for the previous record. So, simply
			# add the current frequency to the already registered one for the
			# current airline.
			freq_al += new_freq

		} else {
			# The relationship is the same as for the previous record, but the
			# airline has changed (if it ever happens). So, reset the frequency
			# per airline.
			freq_al = new_freq
		}

	} else {
		# The relationship is distinct from the previous record. So, register
		# and display the previous relationship.
		# Safeguard for the first record of the file:
		if (origin_str != "" && destination_str != "") {
			__freqTot =	registerRelationship(origin_str, destination_str, \
											 freq_al)
			displayRelationship(airline_code, origin_str, destination_str, \
								freq_al, __freqTot)
		}

		# Reset the airline code, leg origin and destination,
		# as well as the frequency
		airline_code = new_airline_code
		origin_str = new_origin_str
		destination_str = new_destination_str
		freq_al = new_freq
	}
}


##
# Single-flight relationships between any two airports (directly from
# the schedule file: oag_schedule_opt_YYMMDD_all.csv.tmp).
#
# Sample input lines:
#   ALL^BSL^CDG
#   AF^BSL^CDG
#
/^(ALL|[A-Z0-9]{2})\^([A-Z]{3})\^([A-Z]{3})$/ {
	# Airline code
	new_airline_code = $1

	# Origin
	new_origin_str = $2

	# Destination
	new_destination_str = $3

	# Frequency, expressed as a number of flights (1, by construction)
	new_freq = 1

	# Register and display the relationship
	registerAndDisplayRelationship()
}


##
# Single-flight relationships between any two airports (directly from
# the schedule file: oag_schedule_opt_YYMMDD_all.csv.tmp).
#
# Sample input lines:
#   ALL^BSL^CDG^1411^1411^50^50
#   AF^BSL^CDG^1411^1411^50^50
#
/^(ALL|[A-Z0-9]{2})\^([A-Z]{3})\^([A-Z]{3})\^([0-9]{1,10})\^([0-9]{1,10})/ {
	# Airline code
	new_airline_code = $1

	# Origin
	new_origin_str = $2

	# Destination
	new_destination_str = $3

	# Frequency, expressed as a number of flights
	new_freq = $4

	# Register and display the relationship
	registerAndDisplayRelationship()
}


##
# Airport and city aggregated relationships (after having added the cities
# to the result of the above function).
# Input file: oag_schedule_with_cities_YYMMDD_all.csv.tmp
#
# Sample input lines:
#   ALL^BSL^A^CDG^A^1411^1411
#   ALL^EAP^C^BSL^A^31195^31195
#   ALL^CDG^A^PAR^C^286768^286768
#
/^(ALL|[A-Z0-9]{2})\^([A-Z]{3})\^([AC]{1,2})\^([A-Z]{3})\^([AC]{1,2})\^([0-9]{1,10})\^([0-9]{1,10})/ {
	# Airline code
	new_airline_code = $1

	# Origin
	new_origin_str = $2 "^" $3

	# Destination
	new_destination_str = $4 "^" $5

	# Frequency, expressed as a number of flights
	new_freq = $6

	# Register and display the relationship
	registerAndDisplayRelationship()
}


##
# Finalisation
#
ENDFILE {
	# Last line
	__freqTot =	registerRelationship(origin_str, destination_str, freq_al)
	displayRelationship(airline_code, origin_str, destination_str, \
						freq_al, __freqTot)
}
