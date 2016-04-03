##
# That AWK script extracts the history records of airline having had several
# IATA or ICAO codes.
#
# Two input files are parsed:
#  * OPTD-maintained lists of:
#    * Best known airlines:                 optd_airline_best_known_so_far.csv
#    * No longer valid airlines:            optd_airline_no_longer_valid.csv
#
#

##
# Helper functions
@include "awklib/geo_lib.awk"


##
#
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "extract_airline_history.awk"

	# Arrays
	delete optd_air_list
	delete optd_air_hist_list

    #
    today_date = mktime ("YYYY-MM-DD")
    unknown_idx = 1
}

##
# OPTD-maintained list of airline details
#
# Sample input lines:
#
# pk^env_id^validity_from^validity_to^3char_code^2char_code^num_code^name^name2^alliance_code^alliance_status^type(Cargo;Pax scheduled;Dummy;Gds;charTer;Ferry;Rail)^wiki_link^alt_names^bases
# air-abc-aerolineas-v1^^2005-12-01^^AIJ^4O^837^Interjet^ABC Aerolíneas^^^^http://en.wikipedia.org/wiki/Interjet^en|Interjet|=en|ABC Aerolíneas|^MEX=TLC^air-abc-aerolineas^1
# gds-abacus-v1^^^^^1B^0^Abacus^Abacus^^^G^^en|Abacus|=en|Abacus|^^gds-abacus^1
# tec-bird-information-systems-v1^^^^^1R^0^Bird Information Systems^^^^^^en|Bird Information Systems|^^tec-bird-information-systems^1
# trn-accesrail-v1^^^^^9B^450^AccesRail^^^^R^http://en.wikipedia.org/wiki/9B^en|AccesRail|^^trn-accesrail^1
/^[a-z]{3}-[a-z0-9\-]+\^[0-9]*\^([0-9]{4}-[0-9]{2}-[0-9]{2})?\^([0-9]{4}-[0-9]{2}-[0-9]{2})?\^([A-Z0-9]{3})?\^([A-Z0-9*]{2})?\^/ {

	# Sanity check
    if (NF != 17) {
		print ("[" awk_file "] !!!! Error for row #" FNR ", having " NF \
			   " fields: " $0) > error_stream
		exit
    }

	# Primary key, uniquely identifying the airline at any given point in time
	pk = $1

	# Key identifying the airline throughout its history
	key = $16

	# Version of the airline throughout its history
	version = $17

    # Envelope ID
	env_id = $2

	# Validity from
	valid_from = $3

	# Validity to
	valid_to = $4

	# 3-char (ICAO) code
	code_3char = $5

	# 2-char (IATA) code
	code_2char = $6

    # Ticketing code
	code_tkt = $7

	# Name
	name = $8

	# Name2
	name2 = $9

	# Alliance code (taken from optd_airline_alliance_membership.csv)
	alc_code = $10

	# Alliance status (taken from optd_airline_alliance_membership.csv)
	alc_status = $11

	# Airline type
	type = $12

	# Wikipedia link
	wiki_link = $13

	# Alternate names
	alt_names = $14

	# Airport bases / hubs
	bases = $15

	# Build the output line
	output_line = pk "^" env_id "^" valid_from "^" valid_to
	output_line = output_line "^" code_3char "^" code_2char "^" code_tkt
	output_line = output_line "^" name "^" name2 "^" alc_code "^" alc_status
	output_line = output_line "^" type
	output_line = output_line "^" wiki_link "^" alt_names "^" bases
	output_line = output_line "^" key "^" version

	if (code_2char) {
		# Retrieve, or register, the full record for that IATA code
		full_record = optd_air_list[code_2char]
		if (!full_record) {
			optd_air_list[code_2char] = output_line

		} else {
			optd_air_list[code_2char] = full_record "\n" output_line
			optd_air_hist_list[code_2char] = 1
		}

		# DEBUG
		# if (optd_air_hist_list[code_2char]) {
		#	print ("[N-1][" code_2char "] " full_record)
		#	print ("[" version "][" code_2char "] " output_line)
		#}
	}
}


END {
    # Dump the list of airlines having history
	for (air_code in optd_air_hist_list) {
		print (optd_air_list[air_code])
	}
}
