##
# That AWK script is intended to be launched a single time.
# It adds two fields, the (non primary) key and the version,
# and re-formats the so-called primary key so that it actually
# becomes unique, by suffixing it with the newly introduced version.
#
# Two files are transformed:
#  * OPTD-maintained lists of:
#    * Best known airlines:                 optd_airline_best_known_so_far.csv
#    * No longer valid airlines:            optd_airline_no_longer_valid.csv
#
# Sample output lines:
# alc-oneworld-v1^^^^^*O^0^Oneworld^^^^^^^en|Oneworld|^^alc-oneworld^1^
# alc-skyteam-v1^^^^^*S^0^Skyteam^^^^^^^en|Skyteam|^^alc-skyteam^1
# alc-star-alliance-v1^^^^^*A^0^Star Alliance^^^^^^^en|Star Alliance|^^alc-star-alliance^1
# air-air-france-v1^^1933-10-07^^AFR^AF^57^Air France^^Skyteam^Member^^http://en.wikipedia.org/wiki/Air_France^270088^en|Air France|^CDG=ORY^air-air-france^1
# air-british-airways-v1^^1974-03-31^^BAW^BA^125^British Airways^^OneWorld^Member^^http://en.wikipedia.org/wiki/British_Airways^299158^en|British Airways|^LGW=LHR^air-british-airways^1
# air-lufthansa-v1^^1955-01-01^^DLH^LH^220^Lufthansa^^Star Alliance^Member^^http://en.wikipedia.org/wiki/Lufthansa^411417^en|Lufthansa|^FRA=MUC^air-lufthansa^1
# air-easyjet-v1^^1995-01-01^^EZY^U2^888^easyJet^^^^^http://en.wikipedia.org/wiki/EasyJet^433807^en|easyJet|^AMS^air-easyjet^1
#

##
# Helper functions
@include "awklib/geo_lib.awk"


##
#
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "add_version_to_airlines.awk"

	# Generated files
	optd_file_best_known = "../opentraveldata/optd_airline_best_known_so_far_new.csv"
	optd_file_no_longer_valid = "../opentraveldata/optd_airline_no_longer_valid_new.csv"
	
    # Header
	header_line = "pk^env_id^validity_from^validity_to^3char_code^2char_code"
	header_line = header_line "^num_code^name^name2"
    header_line = header_line "^alliance_code^alliance_status"
	header_line = header_line "^type(Cargo;Pax scheduled;Dummy;Gds;charTer;Ferry;Rail)"
    header_line = header_line "^wiki_link^alt_names^bases"
    header_line = header_line "^key^version"
	print (header_line) > optd_file_no_longer_valid
	print (header_line) > optd_file_best_known

	# Array
	delete optd_air_list

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
# air-abc-aerolineas^^2005-12-01^^AIJ^4O^837^Interjet^ABC Aerolíneas^^^^http://en.wikipedia.org/wiki/Interjet^en|Interjet|=en|ABC Aerolíneas|^MEX=TLC
# gds-abacus^^^^^1B^0^Abacus^Abacus^^^G^^en|Abacus|=en|Abacus|^
# tec-bird-information-systems^^^^^1R^0^Bird Information Systems^^^^^^en|Bird Information Systems|^
# trn-accesrail^^^^^9B^450^AccesRail^^^^R^http://en.wikipedia.org/wiki/9B^en|AccesRail|^
/^[a-z]{3}-[a-z0-9\-]+\^[0-9]*\^([0-9]{4}-[0-9]{2}-[0-9]{2})?\^([0-9]{4}-[0-9]{2}-[0-9]{2})?\^([A-Z0-9]{3})?\^([A-Z0-9*]{2})?\^/ {

	# Sanity check
    if (NF != 15) {
		print ("[" awk_file "] !!!! Error for row #" FNR ", having " NF \
			   " fields: " $0) > error_stream
		exit
    }

	# Unified code
	key = $1

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

	# Version
	version = optd_air_list[code_2char] + 1
	if (env_id) {
		optd_air_list[code_2char]++
		version = optd_air_list[code_2char]
	}

	# Primary key
	pk = key "-v" version

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

	# Print the full line
	if (env_id) {
		print (output_line) > optd_file_no_longer_valid
	} else {
		print (output_line) > optd_file_best_known
	}
}


END {
    # DEBUG
}
