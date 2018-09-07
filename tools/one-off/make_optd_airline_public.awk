##
# That AWK script re-formats the full details of airlines
# derived from a few sources:
#  * OPTD-maintained lists of:
#    * Best known airlines:                 optd_airline_best_known_so_far.csv
#    * Alliance memberships:                optd_airline_alliance_membership.csv
#    * No longer valid airlines:            optd_airline_no_longer_valid.csv
#    * Nb of flight-dates:                  ref_airline_nb_of_flights.csv
#  * [Future] Geonames list of airlines:    dump_from_geonames.csv
#
# Sample output lines:
# alc-oneworld^^^^^*O^0^Oneworld^^^^^^^en|Oneworld|^
# alc-skyteam^^^^^*S^0^Skyteam^^^^^^^en|Skyteam|^
# alc-star-alliance^^^^^*A^0^Star Alliance^^^^^^^en|Star Alliance|^
# air-air-france^^1933-10-07^^AFR^AF^57^Air France^^Skyteam^Member^^http://en.wikipedia.org/wiki/Air_France^270088^en|Air France|^CDG=ORY
# air-british-airways^^1974-03-31^^BAW^BA^125^British Airways^^OneWorld^Member^^http://en.wikipedia.org/wiki/British_Airways^299158^en|British Airways|^LGW=LHR
# air-lufthansa^^1955-01-01^^DLH^LH^220^Lufthansa^^Star Alliance^Member^^http://en.wikipedia.org/wiki/Lufthansa^411417^en|Lufthansa|^FRA=MUC
# air-easyjet^^1995-01-01^^EZY^U2^888^easyJet^^^^^http://en.wikipedia.org/wiki/EasyJet^433807^en|easyJet|^AMS
#

##
# Helper functions
@include "awklib/geo_lib.awk"


##
#
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "make_optd_airline_public.awk"

    # Generated file for name differences
    if (air_name_alc_diff_file == "") {
		air_name_alc_diff_file = "optd_airline_diff_w_alc.csv"
    }

    # Initialisation
	delete nb_seats
    delete flt_freq

    # Header
	header_line = "pk^env_id^validity_from^validity_to^3char_code^2char_code"
	header_line = header_line "^num_code^name^name2"
    header_line = header_line "^alliance_code^alliance_status^type"
    header_line = header_line "^wiki_link^flt_freq^alt_names^bases"
    header_line = header_line "^key^version^parent_pk_list^successor_pk_list"
    print (header_line)

    #
    today_date = mktime ("YYYY-MM-DD")
    unknown_idx = 1
}

##
# OPTD-maintained list of alliance memberships
#
# By requiring the env_id field to be empty, only active alliance memberships are considered.
#
# Sample input lines:
# alliance_name^alliance_type^airline_iata_code_2c^airline_name^from_date^to_date^env_id
# Skyteam^Member^AF^Air France^2000-06-22^^
# OneWorld^Member^BA^British Airways^1999-02-01^^
# Star Alliance^Member^LH^Lufthansa^1999-05-01^^
#
/^[A-Za-z ]+\^[A-Za-z]+\^[*A-Z0-9]{2}\^.+\^[0-9-]*\^[0-9-]*\^$/ {
    # Alliance name
    alliance_name = $1

    # Alliance membership type
    alliance_type = $2

    # Airline IATA 2-character code
    air_code_2c = $3

    # Airline Name
    air_name = $4

    # Sanity check
    if (air_alliance_all_names[air_code_2c] != "") {
	print ("[" awk_file "][" FNR "] !!!! Error, '" air_name		\
	       "' airline (" air_code_2c ") already registered for the " \
	       air_alliance_all_names[air_code_2c] " alliance.\n"	\
	       "Full line: " $0) > error_stream
    }

    # Register the alliance membership details
    air_alliance_types[air_code_2c] = alliance_type
    air_alliance_all_names[air_code_2c] = alliance_name
    air_alliance_air_names[air_code_2c] = air_name

    # DEBUG
    # print ("Airline: " air_name " (" air_code_2c ") => Alliance: "	\
    #	   alliance_name " (" alliance_type ")")
}

##
# OPTD-maintained list of flight frequencies
#
# Sample input lines:
# iata_code^icao_code^nb_seats^flight_freq
# AA^AAL^21500473.30^197336.13
# DL^DAL^19361204.47^163349.86
# WN^SWA^16850529.96^114458.43
# UA^UAL^15434154.16^143459.24
# FR^RYR^12034233.17^63682.58
/^[*A-Z0-9]{0,2}\^[A-Z0-9]{3}\^[0-9.]{1,30}\^[0-9.]{1,30}$/ {

    if (NF == 4) {
		# IATA code
		iata_code = $1

		# ICAO code
		icao_code = $2

		# Number of seats
		nb_seats[iata_code, icao_code] = $3

		# Flight frequencies
		flt_freq[iata_code, icao_code] = $4

    } else {
		print ("[" awk_file "] !!!! Error for row #" FNR ", having " NF \
			   " fields: " $0) > error_stream
    }
}

##
# OPTD-maintained list of airline details
#
# Note that two files are processed as input here:
# * Best known airlines:        optd_airline_best_known_so_far.csv
# * No longer valid airlines:   optd_airline_no_longer_valid.csv
# Both files have the same format. The only difference is the env_id field:
# * Empty for active airlines
# * An incremental numeric code (normally equal to the version number)
#   for no longer active airlines
#
# Common header for both files:
# pk^env_id^validity_from^validity_to^3char_code^2char_code^num_code^name^name2^alliance_code^alliance_status^type^wiki_link^alt_names^bases^key^version^parent_pk_list
#
# Sample input lines for optd_airline_best_known_so_far.csv:
# air-abc-aerolineas-v1^^2005-12-01^^AIJ^4O^837^Interjet^ABC Aerolíneas^^^^http://en.wikipedia.org/wiki/Interjet^en|Interjet|=en|ABC Aerolíneas|^MEX=TLC^air-abc-aerolineas^1^
# gds-abacus-v1^^^^^1B^0^Abacus^Abacus^^^G^^en|Abacus|=en|Abacus|^^gds-abacus^1^
# tec-bird-information-systems-v1^^^^^1R^0^Bird Information Systems^^^^^^en|Bird Information Systems|^^tec-bird-information-systems^1^
# trn-accesrail^^^^^9B^450^AccesRail^^^^R^http://en.wikipedia.org/wiki/9B^en|AccesRail|^^trn-accesrail^1^
#
# Sample input lines for optd_airline_no_longer_valid.csv:
# air-aerosvit-airlines-v1^1^1994-04-01^2013-01-31^AEW^VV^870^AeroSvit Airlines^^^^^http://en.wikipedia.org/wiki/Aerosvit_Airlines^en|AeroSvit Airlines|^^air-aerosvit-airlines^1^
# air-avianova-v1^1^2009-08-27^2011-10-10^NET^AO^0^Avianova^^^^^http://en.wikipedia.org/wiki/Avianova_(Russia)^en|Avianova Lcc|^MOW^air-avianova^1^
#
/^[a-z]{3}-[a-z0-9\-]+\^[0-9]*\^([0-9]{4}-[0-9]{2}-[0-9]{2})?\^([0-9]{4}-[0-9]{2}-[0-9]{2})?\^([A-Z0-9]{3})?\^([A-Z0-9*]{2})?\^/ {

    if (NF == 18) {
		# Primary key
		pk = $1

		# Envelope ID
		env_id = $2

        # Validity from
		valid_from = $3

		# Validity to
		valid_to = $4

		# 3-char (ICAO) code
		code_3char = $5
		icao_code = code_3char

		# 2-char (IATA) code
		code_2char = $6
		iata_code = code_2char

		# Ticketing code
		code_tkt = $7

		# UTF8 version of the name
		name_utf8 = $8

		# ASCII version of the name
		name_asc = $9

		# Alliance code (taken from optd_airline_alliance_membership.csv)
		alc_code = air_alliance_all_names[code_2char]

		# Alliance status (taken from optd_airline_alliance_membership.csv)
		alc_status = air_alliance_types[code_2char]

		# Airline type
		type = $12

		# Wikipedia link
		wiki_link = $13

		# Alternate names
		alt_names = $14

		# Airport bases / hubs
		bases = $15

		# Key
		key = $16

		# Version
		version = $17

		# List of parent primary keys
		parent_pk_list = $18
		successor_pk_list = ""

        # Retrieve the flight-date frequency, if existing,
		# and if the airline is still active
		if (env_id == "") {
			if (icao_code == "") {
				icao_code = "ZZZ"
			}
			air_freq = flt_freq[iata_code, icao_code]
			if (air_freq != "") {
				air_freq = int(air_freq)
			}
		}

		# Build the output line
		output_line = pk "^" env_id "^" valid_from "^" valid_to
		output_line = output_line "^" code_3char "^" code_2char "^" code_tkt
		output_line = output_line "^" name_utf8 "^" name_asc
		output_line = output_line "^" alc_code "^" alc_status
		output_line = output_line "^" type "^" wiki_link "^" air_freq
		output_line = output_line "^" alt_names "^" bases
		output_line = output_line "^" key "^" version
		output_line = output_line "^" parent_pk_list "^" successor_pk_list

		# Print the full line
		print (output_line)

		# Alliance name from the OPTD-maintained file of alliance
		# membership
		if (code_2char != "" && env_id == "") {
			air_name_from_alliance = air_alliance_air_names[code_2char]

			# Difference for the airline names between the files
			# of best known details and that of the alliance list
			if (air_name_from_alliance != "" &&			\
				name_utf8 != air_name_from_alliance) {
				print (code_2char "^" code_3char					\
					   "^" name_utf8 "^" air_name_from_alliance)	\
					> air_name_alc_diff_file
			}
		}

    } else {
		print ("[" awk_file "] !!!! Error for row #" FNR ", having " NF \
			   " fields: " $0) > error_stream
    }
}

END {
    # DEBUG
}
