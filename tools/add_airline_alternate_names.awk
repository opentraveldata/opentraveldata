##
# That AWK script adds a field for the alternate names, initialised with
# the two existing names (the second one may not always exist).
# That script is intended to be executed one and only one.
#
# Input file:
#  optd_airlines.csv
# Output file:
#  optd_airlines.csv (with alternate names)
#
# Example of execution:
# awk -F'^' -f add_airline_alternate_names.awk ../opentraveldata/optd_airline_best_known_so_far.csv > ../opentraveldata/optd_airline_best_known_so_far_new.csv
#
# Sample input lines:
# alc-oneworld^^^^^*O^0^Oneworld^^^^^
# alc-skyteam^^^^^*S^0^Skyteam^^^^^
# alc-star-alliance^^^^^*A^0^Star Alliance^^^^^
# air-aerolinea-principal-chile^^^^PCP^5P^676^PAL Airlines^Aerolinea Principal Chile^^^P^http://en.wikipedia.org/wiki/PAL_Airlines
# air-air-france^^1933-10-07^^AFR^AF^57^Air France^^Skyteam^Member^^http://en.wikipedia.org/wiki/Air_France
# air-british-airways^^1974-03-31^^BAW^BA^125^British Airways^^OneWorld^Member^^http://en.wikipedia.org/wiki/British_Airways
# air-lufthansa^^1955-01-01^^DLH^LH^220^Lufthansa^^Star Alliance^Member^^http://en.wikipedia.org/wiki/Lufthansa
# air-easyjet^^1995-01-01^^EZY^U2^888^easyJet^^^^^http://en.wikipedia.org/wiki/EasyJet
#
# Sample output lines:
# alc-oneworld^^^^^*O^0^Oneworld^^^^^^en|Oneworld|
# alc-skyteam^^^^^*S^0^Skyteam^^^^^^en|Skyteam|
# alc-star-alliance^^^^^*A^0^Star Alliance^^^^^^en|Star Alliance|
# air-aerolinea-principal-chile^^^^PCP^5P^676^PAL Airlines^Aerolinea Principal Chile^^^P^http://en.wikipedia.org/wiki/PAL_Airlines^en|PAL Airlines||en|Aerolinea Principal Chile|
# air-air-france^^1933-10-07^^AFR^AF^57^Air France^^Skyteam^Member^^http://en.wikipedia.org/wiki/Air_France^en|Air France|
# air-british-airways^^1974-03-31^^BAW^BA^125^British Airways^^OneWorld^Member^^http://en.wikipedia.org/wiki/British_Airways^en|British Airways|
# air-lufthansa^^1955-01-01^^DLH^LH^220^Lufthansa^^Star Alliance^Member^^http://en.wikipedia.org/wiki/Lufthansa^en|Lufthansa|
# air-easyjet^^1995-01-01^^EZY^U2^888^easyJet^^^^^http://en.wikipedia.org/wiki/EasyJet^en|easyJet|
#

##
# Helper functions
@include "awklib/geo_lib.awk"


##
#
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "add_airline_alternate_names.awk"

    # Header
    printf ("%s", "pk^env_id^validity_from^validity_to^3char_code^2char_code")
    printf ("%s", "^num_code^name^name2")
    printf ("%s", "^alliance_code^alliance_status")
	printf ("%s", "^type(Cargo;Pax scheduled;Dummy;Gds;charTer;Ferry;Rail)")
    printf ("%s", "^wiki_link^alt_names")
    printf ("%s", "\n")

    #
    today_date = mktime ("YYYY-MM-DD")
    unknown_idx = 1
}

##
# OPTD-maintained list of airline details
#
# Sample input lines:
#
# pk^env_id^validity_from^validity_to^3char_code^2char_code^num_code^name^name2^alliance_code^alliance_status^type(Cargo;Pax scheduled;Dummy;Gds;charTer;Ferry;Rail)^wiki_link
# alc-star-alliance^^^^^*A^0^Star Alliance^^^^^
# air-lufthansa^^1955-01-01^^DLH^LH^220^Lufthansa^^Star Alliance^Member^^http://en.wikipedia.org/wiki/Lufthansa
# trn-deutsche-bahn^^^^DBB^2A^0^Deutsche Bahn^^^^R^http://en.wikipedia.org/wiki/Deutsche_Bahn
/^([a-z]{3}-[a-z0-9\-]+)\^([0-9]*)\^([0-9]{4}-[0-9]{2}-[0-9]{2})?\^([0-9]{4}-[0-9]{2}-[0-9]{2})?\^([A-Z0-9]{3})?\^([A-Z0-9*]{2})?\^/ {

	# Unified code
	pk = $1

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

	# Alliance name
	alc_name = $10

	# Alliance member type
	alc_status = $11

	# Airline type
	type = $12

	# Wikipedia link
	wiki_link = $13

	# Build the list of alternate names
	alt_names = "en|" name "|"
	if (name2 != "") {
		alt_names = alt_names "=en|" name2 "|"
	}

	# Build the output line
	current_line = pk "^" env_id "^" valid_from "^" valid_to	\
	    "^" code_3char "^" code_2char "^" code_tkt				\
	    "^" name "^" name2 "^" alc_code "^" alc_status "^" type	\
	    "^" wiki_link "^" alt_names

	# Print the full line
	print (current_line)

}

