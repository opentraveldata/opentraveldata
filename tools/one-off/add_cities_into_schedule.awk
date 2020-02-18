##
# That script needs two files as input:
#  * The OPTD-maintained POR file.
#  * The leg flight frequencies, a processed version of the schedule file,
#    where the number of flights is specified for every leg. A leg is
#    defined by a travel-related (e.g., airport, heliport, train station) pair.
#
# 1. Input format:
# 1.1. Input format for the OPTD-maintained file:
#      ./optd_por_best_known_so_far.csv (copied from
#      http://github.com/opentraveldata/opentraveldata/tree/trunk/opentraveldata)
#   pk^iata_code^latitude^longitude^city_code^date_from
#   AOQ-C-3424906^AOQ^72.88333^-55.6^AOQ^2012-12-07
#   AOQ-H-8435663^AOQ^72.88392^-55.5982^AOQ^2012-12-07
#   ANK-A-6301794^ANK^39.949831^32.688622^ANK^
#   ANK-C-323786^ANK^39.91987^32.85427^ANK^
#   ESB-A-6299725^ESB^40.12808^32.99508^ANK,ESB^
#   ESB-C-747366^ESB^40.134^32.98525^ESB^
#   BSL-A-6299466^BSL^47.6^7.533^EAP^
#   EAP-C-2991214^EAP^47.6^7.533^EAP^
#   MLH-A-6299466^MLH^47.58958^7.52991^EAP^
#
# 1.2. Input format for the flight frequencies per leg:
#        ./oag_schedule_opt_130221_all.csv
#   airline_code^origin^destination^freq_al^freq_tot^idx_orig^idx_dest
#   AF^NCE^BSL^357^357^676^409     City/Airport -> Airport
#   AF^BSL^NCE^357^357^409^676     Airport -> City/Airport
#
# Output format:
#  al_code^org^org_type^dest^dest_type^freq_al^freq_tot
# Sample output lines:
#   AF^EAP^C^BSL^A^2294^2294         City -> Airport
#   AF^NCE^CA^BSL^A^337^337          City/Airport -> Airport
#   AF^BSL^A^CDG^A^1412^1412         Airport -> Airport
#   AF^CDG^A^PAR^C^286768^286768     Airport -> City/Airport
#   4U^CGN^C^ESB^CA^44^44^16^1146    City -> City/Airport
#   4U^ESB^CA^BER^C^4^4^1146^5       City/Airport -> City
# The type of origin or destination is 'A' for airport, 'C' for city
# and 'CA' for an undifferentiated city/airport. In that latter case,
# the Geonames ID is usually 0 (as no choice can be made between the airport
# and the city).
#

##
# Extract the list of cities as an array.
function getCityListAsArray(__gclaaCityList, __resultCityArray) {
	delete __resultCityArray
	__resultNbOfFields = split (__gclaaCityList, __resultCityArray, ",")
	return __resultNbOfFields
}

##
# Display the various global lists
function displayAirportCityList() {
	#
	print ("\nAirport-City mapping list:\n")

	# Browse all the travel-related (e.g., airport, heliport, train station) POR
	for (idx_tvl in cty_por_list_idx) {
		printf ("%s", "[tvl] " idx_tvl " serves ")
		lIdx = 1
		for (idx_cty_por = 1; idx_cty_por <= cty_por_list_idx[idx_tvl]; \
			 idx_cty_por++) {
			if (lIdx >= 2) {
				printf ("%s", "^")
			}
			printf ("%s", "[" lIdx "]" cty_por_list[idx_tvl][idx_cty_por])
			lIdx++
		}
		printf ("%s", "\n")
	}

	# Browse all the cities
	for (idx_cty in tvl_por_list_idx) {
		printf ("%s", "[cty] " idx_cty " is served by ")
		lIdx = 1
		for (idx_tvl_por = 1; idx_tvl_por <= tvl_por_list_idx[idx_cty]; \
			 idx_tvl_por++) {
			if (lIdx >= 2) {
				printf ("%s", "^")
			}
			printf ("%s", "[" lIdx "]" tvl_por_list[idx_cty][idx_tvl_por])
			lIdx++
		}
		printf ("%s", "\n")
	}
}

##
# Sample input lines:
#   ALL^NCE^BSL^357^357^676^409        City/Airport -> Airport
#   4U^CGN^ESB^44^44^8^615             City/Airport -> City/Airport
# Sample output lines:
#   ALL^NCE^CA^BSL^A^357^357^676^409   City/Airport -> Airport
#   ALL^NCE^CA^EAP^C^357^357^676^409   City/Airport -> City
#   4U^CGN^A^ESB^A^44^44^8^615         Airport -> Airport
#   4U^CGN^C^ESB^A^44^44^8^615         City -> Airport
#   4U^CGN^A^ANK^C^44^44^8^615         Airport -> City
#   4U^CGN^C^ANK^C^44^44^8^615         City -> City
#
function makeOutputLine (__molAlnCode, __molOrgTvl, __molDstTvl, \
						 __molNbFltAln, __molNbFltTot,			 \
						 __molOrgCty, __molDstCty) {
	# Sanity check
	if (__molOrgCty == "") {
		# Report the error
		print ("[" awk_file "][" FNR "] No origin city for the " __molOrgTvl \
			   " travel-related POR. The destination travel-related POR is " \
			   __molDstTvl) > error_stream

		# Cope with the error: the city is assumed to be the same as
		# the travel-related POR
		__molOrgCty = __molOrgTvl
		tvl_por_list_idx[__molOrgCty] = 1
	}
	if (__molDstCty == "") {
		# Report the error
		print ("[" awk_file "][" FNR "] No destination city for the "	\
			   __molDstTvl												\
			   " travel-related POR. The origin travel-related POR is " \
			   __molOrgTvl) > error_stream

		# Cope with the error: the city is assumed to be the same as
		# the travel-related POR
		__molDstCty = __molDstTvl
		tvl_por_list_idx[__molDstCty] = 1
	}

	# Primary key for the origin POR
	if (tvl_por_list_idx[__molOrgCty] == 1			\
		&& cty_por_list_idx[__molOrgCty] == 1) {
		# When the city (e.g., NCE) is served by a single travel-related POR
		# (majority of the cases), the city and travel-related POR are
		# considered to be the same.
		# Indeed, no additional information (e.g., PageRank) would result
		# from that.
		# The second condition is to avoid situations where the airport
		# corresponding to the same code is serving several cities. For
		# instance, BDL corresponds to both an airport (Bradley Intl Airport)
		# and to a city (Windsor Locks). The airport is serving several cities,
		# namely BDL, HFD (Hartford) and SFY (Sprinfield). In that case, BDL,
		# as a city, is served by a single airport, where as BDL, as an airport,
		# serves several cities. So, in that case, the mono-airport city is not
		# reported (here, BDL-C).
		__molOrgTvlPk = __molOrgTvl "^CA"
		__molOrgCtyPk = __molOrgCty "^CA"

	} else {
		# When the city (e.g., IEV) is served by several POR (e.g., airport,
		# heliport) the airport (e.g., IEV for Kiev Zhulyani or KBP for
		# Kiev Borispyl) is distinct from the city (e.g., Kiev).
		# Note: 'A' means airport and 'C' city.
		__molOrgTvlPk = __molOrgTvl "^A"
		__molOrgCtyPk = __molOrgCty "^C"
	}

	# Primary key for the destination POR
	if (tvl_por_list_idx[__molDstCty] == 1			\
		&& cty_por_list_idx[__molDstCty] == 1) {
		# See the corresponding comment above
		__molDstTvlPk = __molDstTvl "^CA"
		__molDstCtyPk = __molDstCty "^CA"

	} else {
		# See the corresponding comment above
		__molDstTvlPk = __molDstTvl "^A"
		__molDstCtyPk = __molDstCty "^C"
	}

	# Print the original information, if not already printed before:
	# number of flights for the given airport-to-airport relationship,
	# specifying that those POR (points of reference) are airports.
	__molFullPk = __molOrgTvlPk "^" __molDstTvlPk
	if (freq_line_list[__molFullPk] == "") {
		freq_line_list[__molFullPk] = 1
		print (__molAlnCode "^" __molFullPk	"^" __molNbFltAln "^" __molNbFltTot)
	}

	# Explicit the number of flights for the airports as well as for the cities.
	if (tvl_por_list_idx[__molOrgCty] >= 2) {
		# First, print the  (origin) city -> (destination) airport relationship
		__molFullPk = __molOrgCtyPk "^" __molDstTvlPk
		if (freq_line_list[__molFullPk] == "") {
			freq_line_list[__molFullPk] = 1
			print (__molAlnCode "^" __molOrgCtyPk "^" __molDstTvlPk	\
				   "^" __molNbFltAln "^" __molNbFltTot)

			# Then, register the (origin) city -> (origin) airport relationship
			#relation_str = sprintf ("%s", __molAlnCode "^" __molOrgCtyPk "^" __molOrgTvlPk)

			#relation_list[relation_str] += __molNbFltTot
		}
	}
	if (tvl_por_list_idx[__molDstCty] >= 2) {
		# First, print the  (origin) airport -> (destination) city relationship
		__molFullPk = __molOrgTvlPk "^" __molDstCtyPk
		if (freq_line_list[__molFullPk] == "") {
			freq_line_list[__molFullPk] = 1
			print (__molAlnCode "^" __molOrgTvlPk "^" __molDstCtyPk	\
				   "^" __molNbFltAln "^" __molNbFltTot)

			# Then, register the (destination) airport -> (destination) city
			# relationship
			#relation_str = sprintf ("%s", __molAlnCode "^" __molDstTvl "^A^" __molDstCty "^C")

			#relation_list[relation_str] += __molNbFltTot
		}
	}
	if (tvl_por_list_idx[__molOrgCty] >= 2			\
		&& tvl_por_list_idx[__molDstCty] >= 2) {
		# Print the  (origin) city -> (destination) city relationship
		__molFullPk = __molOrgCtyPk "^" __molDstCtyPk
		if (freq_line_list[__molFullPk] == "") {
			freq_line_list[__molFullPk] = 1
			print (__molAlnCode "^" __molOrgCtyPk "^" __molDstCtyPk	\
				   "^" __molNbFltAln "^" __molNbFltTot)
		}
	}
}

##
#
BEGIN {
	# Global variables
	error_stream = "/dev/stderr"
	awk_file = "add_cities_into_schedule.awk"

	# Header
	printf ("%s", "airline_code")
	printf ("%s", "^origin^origin_type")
	printf ("%s", "^destination^destination_type")
	printf ("%s", "^freq_al^freq_tot")
	printf ("%s", "\n")

	#
	today_date = mktime ("YYYY-MM-DD")
}


##
# OPTD-maintained best known list of POR (points of reference):
# http://github.com/opentraveldata/opentraveldata/blob/trunk/opentraveldata/optd_por_best_known_so_far.csv
#
# Sample input lines:
#   AOQ-C-3424906^AOQ^72.88333^-55.6^AOQ^2012-12-07
#   AOQ-H-8435663^AOQ^72.88392^-55.5982^AOQ^2012-12-07
#   ANK-A-6301794^ANK^39.949831^32.688622^ANK^
#   ANK-C-323786^ANK^39.91987^32.85427^ANK^
#   ESB-A-6299725^ESB^40.12808^32.99508^ANK,ESB^
#   ESB-C-747366^ESB^40.134^32.98525^ESB^
#   BSL-A-6299466^BSL^47.6^7.533^EAP^
#   EAP-C-2991214^EAP^47.6^7.533^EAP^
#   MLH-A-6299466^MLH^47.58958^7.52991^EAP^
#
/^([A-Z]{3})-([ABCGHOPR]{1,2})-([0-9]{1,10})\^([A-Z]{3})\^/ {
	# Primary key (combination of IATA code, location type and Geonames ID)
	pk = $1

	# Location type (it is not taken into account here)
	loc_type = gensub ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})$", "\\2", "g", pk)

	# Geonames ID (it is not taken into account here)
	#geonames_id = gensub ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})$", "\\3", \
	#					  "g", pk)

	# Travel-related POR IATA code
	tvl_code = $2

	# City IATA code
	cty_code_list = $5

	# For cities, do nothing more at that stage
	if (loc_type != "C") {

		getCityListAsArray(cty_code_list, cty_code_array)
		for (cty_code_idx in cty_code_array) {
			cty_code = cty_code_array[cty_code_idx]

			## Register the tvl_por(n)->city(m) relationship
			# Retrieve the number of cities already registered for
			# that travel-related POR, if any.
			# For instance:
			#  * cty_por_list["KBP"][1] = "IEV"
			#  * cty_por_list["ESB"][1] = "ANK"
			#  * cty_por_list["ESB"][2] = "ESB"
			found_cty = 0
			idx_cty_por = cty_por_list_idx[tvl_code]
			if (idx_cty_por == "") {
				idx_cty_por = 0

			} else {
				# Check whether that city code has already been registered
				for (idxCtyPor = 1; idxCtyPor <= cty_por_list_idx[tvl_code]; \
					 idxCtyPor++) {
					if (cty_por_list[tvl_code][idxCtyPor] == cty_code) {
						found_cty = 1
					}
				}
			}

			if (found_cty == 0) {
				# The city code has not been registered yet
				idx_cty_por++

				# Register the city in the dedicated list for that
				# travel-related POR.
				# For instance, cty_por_list["ESB"][1] = "ANK"
				cty_por_list[tvl_code][idx_cty_por] = cty_code

				# An additional city has been added: update the index
				cty_por_list_idx[tvl_code] = idx_cty_por
			}

			## Register the city(m)->tvl_por(n) relationship
			# Retrieve the number of travel-related POR already registered
			# for that city, if any.
			# For instance:
			#  * tvl_por_list["IEV"][1] = "IEV"
			#  * tvl_por_list["IEV"][2] = "KBP"
			#  * tvl_por_list["NCE"][1] = "NCE"
			found_tvl = 0
			idx_tvl_por = tvl_por_list_idx[cty_code]
			if (idx_tvl_por == "") {
				idx_tvl_por = 0

			} else {
				# Check whether that city code has already been registered
				for (idxTvlPor = 1; idxTvlPor <= tvl_por_list_idx[cty_code]; \
					 idxTvlPor++) {
					if (tvl_por_list[cty_code][idxTvlPor] == tvl_code) {
						found_tvl = 1
					}
				}
			}

			if (found_tvl == 0) {
				# The city code has not been registered yet
				idx_tvl_por++

				# Register the travel-related POR in the dedicated list
				# for that city. For instance, tvl_por_list["IEV"][1] = "KBP"
				tvl_por_list[cty_code][idx_tvl_por] = tvl_code

				# An additional travel-related POR has been added:
				# update the index
				tvl_por_list_idx[cty_code] = idx_tvl_por
			}

		}
	}
}


##
# Leg flight frequencies file.
#
# Sample input lines:
#   ALL^NCE^BSL^357^357^676^409        City/Airport -> Airport
#   ALL^BSL^NCE^357^357^409^676        Airport -> City/Airport
#   4U^CGN^ESB^44^44^8^615             City/Airport -> City/Airport
#   4U^ESB^CGN^44^44^615^8             City/Airport -> City/Airport
#
/^(ALL|[A-Z0-9]{2})\^([A-Z]{3})\^([A-Z]{3})\^([0-9]{1,10})\^([0-9]{1,10})\^/ {
	# Parse the line
	airline_code = $1
	org_tvl_por = $2
	dst_tvl_por = $3
	nb_of_flights_al = $4
	nb_of_flights_tot = $5

	# Retrieve the corresponding origin city, if existing
	idx_org_cty = cty_por_list_idx[org_tvl_por]
	if (idx_org_cty == "") {
		idx_org_cty = 0
		# Report the error
		print ("[" awk_file "][" FNR "] The origin travel-related POR (" \
			   org_tvl_por ") is not known. The provider is " airline_code)	\
			> error_stream
	}

	# Retrieve the corresponding destination city, if existing
	idx_dst_cty = cty_por_list_idx[dst_tvl_por]
	if (idx_dst_cty == "") {
		idx_dst_cty = 0
		# Report the error
		print ("[" awk_file "][" FNR "] The destination travel-related POR (" \
			   dst_tvl_por ") is not known. The provider is " airline_code)	\
			> error_stream
	}

	# Retrieve the corresponding origin and destination cities, when existing
	for (idxOrgCtyPor = 1; idxOrgCtyPor <= idx_org_cty; idxOrgCtyPor++) {
		org_cty = cty_por_list[org_tvl_por][idxOrgCtyPor]

		for (idxDstCtyPor = 1; idxDstCtyPor <= idx_dst_cty; idxDstCtyPor++) {
			dst_cty = cty_por_list[dst_tvl_por][idxDstCtyPor]

			#
			makeOutputLine(airline_code, org_tvl_por, dst_tvl_por,		\
						   nb_of_flights_al, nb_of_flights_tot, org_cty, dst_cty)
		}
	}
}


##
#
END {
	# DEBUG
	# For instance, after uncommenting, write in the command line:
	# awk -F'^' -f add_cities_into_schedule.awk ori_por_best_known_so_far.csv
	# displayAirportCityList()

	# Display all the city->airport and airport->city relationships
	# (number of flights)
	#for (idx_str in relation_list) {
	#	print (idx_str "^" relation_list[idx_str])
	#}
}
