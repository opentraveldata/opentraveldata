##
# That AWK script converts a TSV file into a CSV one
#
# Sample input lines:
# 3char_city_code  city_name       state_code      ctry_code    tz_code  stv     3char_por_code       por_name    loc_id    loc_type   loc_type_name       agg_por_name
# ALV     Andorra la Vella                AD                      ALV     Off-line Point          1       Off-Line Point  Andorra la Vella Off-line Point
# ABI     Abilene TX      US      2               ABI     Metropolitan Area               2       Metropolitan Area       Abilene Metropolitan Area
# PAR     Paris           FR                      CDG     Charles de Gaulle       0838    3       Airport Paris Charles de Gaulle Airport
# AAN     Al Ain          AE                      ZVH     EK Bus Station          4       Bus Station     Al Ain EK Bus Station
# AAH     Aachen          DE                      XHJ     Hbf Railway Station             5       Railway Station Aachen Hbf Railway Station
# AGH     Angelholm/Helsingborg           SE                      JHE     Heliport                6       Heliport        Angelholm/Helsingborg Heliport
# ADL     Adelaide        SA      AU      3               ZII     Ferry Port              7       Ferry Port      Adelaide Ferry Port
#
# Sample output lines:
# ALV^Andorra la Vella^^AD^^^ALV^Off-line Point^^O
# ABI^Abilene^TX^US^2^^ABI^Metropolitan Area^^C
# PAR^Paris^^FR^^^CDG^Charles de Gaulle^0838^A
# AAH^Aachen^^DE^^^AAW^Aachen Bf West Bus Stn^^B
# AAH^Aachen^^DE^^^XHJ^Hbf Railway Station^^R
# ACY^Atlantic City^NJ^US^1^^JSL^Steel Pier Heliport^^H
# ADL^Adelaide^SA^AU^3^^ZII^Ferry Port^^P
#

##
# Helper functions
@include "awklib/geo_lib.awk"

##
#
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "prepare_iata_dump_file.awk"
	SEP = "^"

	# Header
	header_line = "city_code^city_name^state_code^country_code^tz_code^stv^por_code^por_name^loc_id^loc_type^loc_type_name^agg_name"
	print (header_line)
}

# Convert the location type
function toLocType(__tltLocType) {
	__resultLocType = ""
    switch (__tltLocType) {
    case "1":
		__resultLocType = "O"
		break
    case "2":
		__resultLocType = "C"
		break
    case "3":
		__resultLocType = "A"
		break
    case "4":
		__resultLocType = "B"
		break
    case "5":
		__resultLocType = "R"
		break
    case "6":
		__resultLocType = "H"
		break
    case "7":
		__resultLocType = "P"
		break
    }
	return __resultLocType
}

##
#
/^[A-Z]{3}/ {
	# City IATA code
	city_code = $1

	# City name
	city_name = $2

	# State code
	state_code = $3

	# Country code
	ctry_code = $4

	# Time-Zone code
	tz_code = $5
	if (tz_code > 10) {
		print ("[" awk_file "] !!! Error at record #" FNR				\
			   ". TZ ('" tz_code "') code length too big. Full line: " $0) \
			> error_stream
	}

	# STV
	stv = $6
	if (length(stv) > 1) {
		print ("[" awk_file "] !!! Error at record #" FNR				\
			   ". STV ('" stv "') length too big. Full line: " $0) > error_stream
	}

	# Travel-related POR code
	tvl_code = $7

	# Travel-related POR name
	tvl_name = $8

	# POR ID
	loc_id = $9

	# Location type code
	loc_code = $10
	loc_type = toLocType(loc_code)

	# Location type name
	loc_type_name = $11

	# Aggregated name
	agg_name = $12

	# Output line
	output_line = city_code SEP city_name
	output_line = output_line SEP state_code SEP ctry_code
	output_line = output_line SEP tz_code SEP stv
	output_line = output_line SEP tvl_code SEP tvl_name
	output_line = output_line SEP loc_id SEP loc_type
	output_line = output_line SEP loc_type_name SEP agg_name
	
	print (output_line)
}

##
#
END {
}
