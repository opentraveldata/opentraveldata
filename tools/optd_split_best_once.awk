##
# That AWK script has been run once (June 2012), and is not intended to be
# re-processed. It is left here, just as a sample.
#
# The script aims at splitting single combined POR lines (e.g., with location
# types such as 'CA' or 'AR') into the corresponding distinct POR lines (e.g.,
# a line with 'A' and the other with 'C' as location type). All the other
# fields remain identical (untouched).
#
# Way it was used:
# 
# sed -e "s/^iata\(.\+\)//g" optd_por_public.csv > optd_por_public.csv.woh
# sed -i -e "/^$/d" optd_por_public.csv.woh
# join -t'^' -a 1 -1 2 -2 1 optd_por_best_known_so_far.csv optd_por_public.csv.woh > optd_por_best_known_so_far.csv.tmp
# awk -F'^' -f optd_split_best_once.awk optd_por_cty.csv optd_por_best_known_so_far.csv.tmp > optd_por_best_known_so_far.csv.new
# diff -c optd_por_best_known_so_far.csv optd_por_best_known_so_far.csv.new | less
# \mv -f optd_por_best_known_so_far.csv.new optd_por_best_known_so_far.csv
# \rm -f optd_por_best_known_so_far.csv.tmp


##
# RFD derived list of cities.
#
# Note that, by construction of the por_cty_rfd_????????.csv file (filtered in
# by the sequence below), at least two POR (point of reference, e.g., airport,
# heliport, railway station, bus station) serve the city.
#
# Among all the entries for a given city, the entry having the same IATA code
# for the airport and for the city (which has got "CA" for location_type),
# must be split. Indeed, the airport and the city must be distinguised for
# some of their details (e.g, geographical coordinates, PageRank).
#
/^([A-Z]{3})\^([0-9]{1,2})/ {
	# IATA code of the city
	iata_code = $1

	# Number of POR serving that city
	nb_of_por = $2

	# Register the information
	city_por_freq[iata_code] = nb_of_por
}


##
# ORI best
#
/^([A-Z]{3})\^([A-Z]{3})-([A-Z]{1,2})/ {
	# IATA code of the airport
	iata_code = $1

	# Location type
	location_type = $34
	location_type_size = length(location_type)

	# Primary key
	primary_key = iata_code "-" location_type
	
	# IATA code of the city
	city_code = $31

	# Latitude
	latitude = $3

	# Latitude
	longitude = $4

	#
	por_details = latitude "^" longitude

	#
	if (city_code in city_por_freq && iata_code == city_code && \
		location_type == "CA") {
		# For the POR being referenced as both a city and an airport ("CA"),
        # split that POR into two distinct entries:
		# one for the city ("C") and another one for the airport ("A").

		primary_key = iata_code "-A"
		printf ("%s", primary_key "^" iata_code "^" por_details "\n")
		primary_key = iata_code "-C"
		printf ("%s", primary_key "^" iata_code "^" por_details "\n")

	} else {
		# Standard POR. When that POR is both a city and an airport,
		# by construction of the por_cty_rfd_????????.csv file, there is a
		# single airport serving the city. For now (as of June 2012),
		# those POR are not split, as they may be considered as a single
		# entity for many processes (e.g., PageRank).
		printf ("%s", primary_key "^" iata_code "^" por_details "\n")
	}

}
