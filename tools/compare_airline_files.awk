##
# That AWK script compares the OPTD-maintained best known airline details
# with reference data. Sources:
#  * OPTD-maintained:          optd_airline_best_known_so_far.csv
#  * Reference:                dump_from_ref_airline.csv
#
# In theory, the second name should be the ASCII version of
# the first name (in UTF8), and empty when both versions are equal (which is
# the case most of the times). But it happens that the second name is just
# some remembrance from legacy reference data.
#
# Sample output lines:
# 0B^1^Blue Air<>Blue Air Airline
# 0B^2^<>Blue Air
# BGH^1^BH Air<>Bh Air
# BGH^2^<>Bh Air

##
# Helper functions
@include "awklib/geo_lib.awk"


##
#
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "compare_airline_files.awk"

    # Initialisation
    delete name_utf8_list
    delete name_asc_list

    # Header
	header_line = "code^name_version^name_optd^name_ref"
    print (header_line)

    #
    today_date = mktime ("YYYY-MM-DD")
    unknown_idx = 1
}

##
# OPTD-maintained list of airline details.
#
# Note that, normally, all those airlines are active, and therefore the env_id
# field is empty.
#
# Sample input lines:
#
# pk^env_id^validity_from^validity_to^3char_code^2char_code^num_code^name^name2^alliance_code^alliance_status^type(Cargo;Pax scheduled;Dummy;Gds;charTer;Ferry;Rail)^wiki_link^alt_names^bases^key^version
# air-abc-aerolineas-v1^^2005-12-01^^AIJ^4O^837^Interjet^ABC Aerolíneas^^^^http://en.wikipedia.org/wiki/Interjet^en|Interjet|=en|ABC Aerolíneas|^MEX=TLC^air-abc-aerolineas^1
# gds-abacus-v1^^^^^1B^0^Abacus^Abacus^^^G^^en|Abacus|=en|Abacus|^^gds-abacus^1
# tec-bird-information-systems-v1^^^^^1R^0^Bird Information Systems^^^^^^en|Bird Information Systems|^^tec-bird-information-systems^1
# trn-accesrail^^^^^9B^450^AccesRail^^^^R^http://en.wikipedia.org/wiki/9B^en|AccesRail|^^trn-accesrail^1
/^[a-z]{3}-[a-z0-9\-]+\^\^([0-9]{4}-[0-9]{2}-[0-9]{2})?\^([0-9]{4}-[0-9]{2}-[0-9]{2})?\^([A-Z0-9]{3})?\^([A-Z0-9*]{2})?\^/ {

    if (NF == 18) {
		# Primary key
		pk = $1

		# 3-char (ICAO) code
		code_3char = $5
		icao_code = code_3char

		# 2-char (IATA) code
		code_2char = $6
		iata_code = code_2char

		# Name
		name = $8

		# Name2
		name2 = $9

		# Register the airline names
		if (code_2char != "" && env_id == "") {
			name_utf8_list[code_2char] = name
			name_asc_list[code_2char] = name2
		}
		if (code_3char != "" && env_id == "") {
			name_utf8_list[code_3char] = name
			name_asc_list[code_3char] = name2
		}

    } else {
		print ("[" awk_file "] !!!! Error for row #" FNR ", having " NF \
			   " fields: " $0) > error_stream
    }
}

##
# Aggregated content from reference data
#
# Sample input lines:
# *A^^*A^0^Star Alliance^
# *O^^*O^0^Oneworld^
# *S^^*S^0^Skyteam^
# AF^AFR^AF^57^Air France^Air France
# AFR^AFR^AF^57^Air France^Air France
# BA^BAW^BA^125^British Airways^British A/W
# BAW^BAW^BA^125^British Airways^British A/W
# DLH^DLH^LH^220^Lufthansa^Lufthansa
# LH^DLH^LH^220^Lufthansa^Lufthansa
#
/^[*A-Z0-9]{2,3}\^([A-Z]{3})?\^[*A-Z0-9]{2}\^[0-9]+\^/ {

    if (NF == 6) {
		# Primary key
		pk = $1

		# IATA 3-character code
		iata_code_3c = $2

		# IATA 2-character code
		iata_code_2c = $3

		# Numeric code
		numeric_code = $4

		# Reference name versions
		ref_name_utf8 = $5
		ref_name_asc = $6

		# OPTD name versions
		optd_name_utf8 = name_utf8_list[pk]
		optd_name_asc = name_asc_list[pk]

		# Comparison of the UTF8 version
		if (ref_name_utf8 != optd_name_utf8) {
			print (pk "^1^" optd_name_utf8 "<>" ref_name_utf8)
		}

		# Comparison of the ASCII version
		if (ref_name_asc != optd_name_asc) {
			print (pk "^2^" optd_name_asc "<>" ref_name_asc)
		}

    } else {
		print ("[" awk_file "] !!!! Error for row #" FNR ", having " NF \
			   " fields: " $0) > error_stream
    }
}

END {
    # DEBUG
}
