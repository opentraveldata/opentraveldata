##
# That AWK script merges the file of best known coordinates with the newly
# created de-duplicated one. They both have got the same format.
# For instance, a 'CA' (city and airport) entry in the original file (passed
# as the second data file to that AWK script) may be split into a city and
# an airport in the newly created file (passed as the first data file to
# that AWK script).
#
# For instance, the following POR entries of the
# ../opentraveldata/optd_por_best_known_so_far.csv data file:
# is made of the IATA code and location type. For instance:
#  * NCE-CA^NCE^43.658411^7.215872^NCE^
# will be de-duplicated in the optd_por_to_be_split.csv data file:
#  * NCE-A^NCE^43.658411^7.215872^NCE^
#  * NCE-C^NCE^43.70313^7.26608^NCE^
#
# A few examples of IATA location types:
#  * 'C' for city
#  * 'A' for airport
#  * 'CA' for a combination of both
#  * 'H' for heliport
#  * 'R' for railway station
#  * 'B' for bus station,
#  * 'P' for (maritime) port,
#  * 'G' for ground station,
#  * 'O' for off-line point (usually a small city/village or a railway station)
#
# Format of both data files:
# pk^iata_code^latitude^longitude^city_code^date_from
# NCE-A^NCE^43.658411^7.215872^NCE^
# NCE-C^NCE^43.70313^7.26608^NCE^


##
# Derive the boolean values for all the location types, as well as the
# myLocTypes[] array.
#
function deriveLocationTypes(myLocType) {
    # City-related type
    is_city = match (myLocType, "[C]")

    # Travel-related type
    is_airport = match (myLocType, "[A]")
    is_heliport = match (myLocType, "[H]")
    is_rail = match (myLocType, "[R]")
    is_bus = match (myLocType, "[B]")
    is_port = match (myLocType, "[P]")
    is_ground = match (myLocType, "[G]")
    is_offpoint = match (myLocType, "[O]")
    is_travel = is_airport + is_rail + is_bus + is_heliport + is_port	\
	+ is_ground + is_offpoint

    # Remaining location type, when the city is removed
    myRemainingLocType = gensub ("[C]", "", "g", myLocType)

    #
    if (is_city != 0) {
	myLocTypes[0] = "C"
    } else {
	myLocTypes[0] = ""
    }

    #
    myLocTypeSize = length(myRemainingLocType)
    if (myLocTypeSize == 0) {
	# Nothing more to be done at that stage
	# Notification
	if (log_level >= 5) {
	    print ("[" awk_file "] !! Notification: the POR #" FNR " and #"	\
		   FNR-1 ", with IATA code=" myIataCode ", have got a rare " \
		   "location type: '" myLocType "'.") > error_stream
	}

    } else if (myLocTypeSize == 1) {
	# A single location type in addition to the city, if that latter exists
	myLocTypes[1] = myRemainingLocType

    } else if (myLocTypeSize == 2) {
	# Several location types in addition to the city, if that latter exists
	for (idx = 1; idx <= myLocTypeSize; idx++) {
	    myLocTypes[idx] = substr (myRemainingLocType, idx, 1)
	}

    } else {
	# Several location types in addition to the city, if that latter exists
	for (idx = 1; idx <= myLocTypeSize; idx++) {
	    myLocTypes[idx] = substr (myRemainingLocType, idx, 1)
	}

	# Notification
	if (log_level >= 5) {
	    print ("[" awk_file "] !! Notification: the POR #" FNR " and #"	\
		   FNR-1 ", with IATA code=" myIataCode ", have got a rare " \
		   "location type: '" myLocType "'.") > error_stream
	}
    }
    #return myLocTypes
}



##
#
BEGINFILE {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "optd_por_merger.awk"

    #
    is_deduplicated["0"] = 1
    last_iata_code = ""
    last_location_type = ""
    last_full_line = ""
    last_is_city = 0
    last_is_travel = 0
    nb_of_por = 0
}

####
## File of de-duplicated POR entries

##
# Header line
/^pk/ {
    print ("pk^iata_code^latitude^longitude^city_code^date_from")
}

##
# ./optd_por_to_be_split.csv
#
# Sample lines: same as for optd_por_best_known_so_far.csv below,
# but with a "^DEDUP" tag at the end of every line.
#
# Sample lines:
#  ALV-O^ALV^40.98^0.45^ALV^         (1 line in OPTD, 2 lines in Geonames)
#  ALV-C^ALV^42.50779^1.52109^ALV^
#  ARN-A^ARN^59.651944^17.918611^STO^(2 lines in OPTD, split from a combined line,
#  ARN-R^ARN^59.649463^17.929^STO^    1 line in Geonames)
#  IES-CA^IES^51.3^13.28^IES^        (1 combined line in OPTD, 1 line in Geonames)
#  IEV-A^IEV^50.401694^30.449697^IEV^(2 lines in OPTD, split from a combined line,
#  IEV-C^IEV^50.401694^30.449697^IEV^ 2 lines in Geonames)
#  KBP-A^KBP^50.345^30.894722^IEV^   (1 line in OPTD, 1 line in Geonames)
#  LHR-A^LHR^51.4775^-0.461389^LON^  (1 line in OPTD, 1 line in Geonames)
#  LON-C^LON^51.5^-0.1667^LON^       (1 line in OPTD, 1 line in Geonames)
#  NCE-A^NCE^43.658411^7.215872^NCE^ (1 combined line in OPTD 2 lines in Geonames)
#  NCE-C^NCE^43.70313^7.26608^NCE^
#
/^([A-Z]{3})-([A-Z]{1,2})\^([A-Z]{3})\^(.+)\^DEDUP$/ {

    # Primary key (combination of IATA code and location type)
    pk = $1

    # IATA code
    iata_code = $2

    # Geographical coordinates
    geo_lat = $3
    geo_lon = $4

    # IATA code of the served city
    svd_cty_code = $5

    # Effective date (when empty, that IATA code is considered to have been
    # always effective)
    eff_date = $6

    # Location type
    location_type = substr (pk, 5)

    # Check whether the POR is a city. It can be a city only or, most often,
    # a combination of a city with a travel-related type (e.g., airport,
    # rail station). In some rare cases, an airport may be combined with
    # something else than a city (e.g., railway station); ARN is such
    # an example, and CDG might be another one in the future.
    deriveLocationTypes(location_type)

    # Sanity check
    if (length(location_type) >= 2 && is_travel == 0) {
	print ("[" awk_file "] !!!! Error at line #" FNR		\
	       ", the location type ('" location_type			\
	       "') is unknown - Full line: " $0) > error_stream
    }

    # Store the fact that that POR is de-duplicated
    is_deduplicated[iata_code] = is_deduplicated[iata_code] location_type

    # Store the geographical coordinates
    geo_lat_list[iata_code, location_type] = geo_lat
    geo_lon_list[iata_code, location_type] = geo_lon

    # Store the served city IATA code
    svd_cty_code_list[iata_code, location_type] = svd_cty_code

    # Store the effective date
    eff_date_list[iata_code, location_type] = eff_date

    # Store the location types. If there are two location types for that POR,
    # the first should be the travel-related one and the second should be
    # the city.
    # Note that in some rare cases (e.g., ARN-AR, i.e. Stockholm Arlanda airport
    # and railway station, both serving STO-C), the location type is combined
    # ('AR' here), but there is no city.
    last_location_type = location_type_list[iata_code]
    if (last_location_type == "") {
	# No location type has been registered yet
	location_type_list[iata_code] = location_type

    } else {
	# A location type has already been registered
	is_last_city = match (last_location_type, "[C]")
	is_last_airport = match (last_location_type, "[A]")
	is_last_rail = match (last_location_type, "[R]")
	is_last_bus = match (last_location_type, "[B]")
	is_last_heliport = match (last_location_type, "[H]")
	is_last_port = match (last_location_type, "[P]")
	is_last_ground = match (last_location_type, "[G]")
	is_last_offpoint = match (last_location_type, "[O]")
	is_last_travel = is_last_airport + is_last_rail + is_last_bus \
	    + is_last_heliport + is_last_port + is_last_ground + is_last_offpoint

	if (is_last_city == 1) {
	    # The previously registered location type is a city. So, it is now
	    # re-registered in second position. The first position is devoted to
	    # the travel-related POR.
	    location_type_list[iata_code] = location_type
	    location_type_alt_list[iata_code] = last_location_type

	    # Sanity check: the new location type should be travel-related
	    if (is_travel == 0) {
		print ("[" awk_file "] !!!! Rare case at line #" FNR \
		       ", there are at least two location types ('" \
		       last_location_type "' and '" location_type \
		       "'), but the latter one is neither a city nor" \
		       " travel-related - Full line: " $0) > error_stream
	    }

	} else if (is_city == 1) {
	    # The city is the new location type; the previously
	    # registered one must then be travel-related.
	    location_type_list[iata_code] = last_location_type
	    location_type_alt_list[iata_code] = location_type

	    # Sanity check: the last location type should be travel-related
	    if (is_last_travel == 0) {
		print ("[" awk_file "] !!!! Rare case at line #" FNR \
		       ", there are at least two location types ('" \
		       last_location_type "' and '" location_type \
		       "'), but the former one is neither a city nor" \
		       " travel-related - Full line: " $0) > error_stream
	    }

	} else {
	    # Neither the previously registered location type nor the current
	    # one is a city. So, if there is an airport, it will be registered
	    # in the first position; otherwise, the alphabetical order of
	    # the location type is used by construction.
	    if (is_last_airport == 1) {
		location_type_list[iata_code] = last_location_type
		location_type_alt_list[iata_code] = location_type

	    } else if (is_airport == 1) {
		location_type_list[iata_code] = location_type
		location_type_alt_list[iata_code] = last_location_type

	    } else {
		location_type_alt_list[iata_code] = location_type
	    }
	}
    }
}


##
# ../opentraveldata/optd_por_best_known_so_far.csv
#
# Sample lines:
#  ALV-O^ALV^40.98^0.45^ALV^         (1 line in OPTD, 2 lines in Geonames)
#  ARN-A^ARN^59.651944^17.918611^STO^(2 lines in OPTD,split from a combined line,
#  ARN-R^ARN^59.649463^17.929^STO^    1 line in Geonames)
#  IES-CA^IES^51.3^13.28^IES^        (1 combined line in OPTD,1 line in Geonames)
#  IEV-A^IEV^50.401694^30.449697^IEV^(2 lines in OPTD,split from a combined line,
#  IEV-C^IEV^50.401694^30.449697^IEV^ 2 lines in Geonames)
#  KBP-A^KBP^50.345^30.894722^IEV^   (1 line in OPTD, 1 line in Geonames)
#  LHR-A^LHR^51.4775^-0.461389^LON^  (1 line in OPTD, 1 line in Geonames)
#  LON-C^LON^51.5^-0.1667^LON^       (1 line in OPTD, 1 line in Geonames)
#  NCE-CA^NCE^43.658411^7.215872^NCE^(1 combined line in OPTD 2 lines in Geoname)
#
/^([A-Z]{3})-([A-Z]{1,2})\^([A-Z]{3})\^(.+)\^([0-9-]{0,10})$/ {

    # Primary key (combination of IATA code and location type)
    pk = $1

    # IATA code
    iata_code = $2

    # Geographical coordinates
    geo_lat = $3
    geo_lon = $4

    # IATA code of the served city
    svd_cty_code = $5

    # Effective fate (when empty, that IATA code is considered to have been
    # always effective)
    eff_date = $6

    # Location type
    location_type = substr (pk, 5)

    # Retrieve the accumulated location types for that POR
    new_loc_type = is_deduplicated[iata_code]

    if (new_loc_type != "") {
	# That POR should be de-duplicated
	nb_of_loc_types = length(new_loc_type)
	delete loc_type_array

	# Transform the (small) location_type string (e.g., 'CA' for city
	# and airport) into the corresponding array (e.g., ['C', 'A']),
	# so that it can be sorted
	for (idx = 1; idx <= nb_of_loc_types; idx++) {
	    # Extract the single location type (e.g., 'A' for airport)
	    single_loc_type = substr (new_loc_type, idx, 1)

	    # Store the single location type in the array
	    loc_type_array[idx] = single_loc_type
	}

	# Sort the array of location types
	asort (loc_type_array, sorted_loc_type_array)

	# Print a POR entry for every single location type
	for (idx in sorted_loc_type_array) {
	    # Retrieve the single location type
	    single_loc_type = sorted_loc_type_array[idx]

	    # Retrieve the geographical coordinates
	    geo_lat = geo_lat_list[iata_code, single_loc_type]
	    geo_lon = geo_lon_list[iata_code, single_loc_type]

	    # Retrieve the served city IATA code
	    svd_cty_code = svd_cty_code_list[iata_code, single_loc_type]

	    # Retrieve the effective date
	    eff_date = eff_date_list[iata_code, single_loc_type]

	    # Print the de-duplicated entry for that POR
	    print (iata_code "-" single_loc_type "^" iata_code			\
		   "^" geo_lat "^" geo_lon "^" svd_cty_code "^" eff_date)
	}

    } else {
	# That POR does not need to be de-duplicated
	print ($0)
    }

}


#
ENDFILE {
}

