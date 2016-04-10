##
# That AWK script converts a fixed-width file into a CSV one
#
# Sample input lines:
# ALV   Andorra la Vella          AD     ALV   Off-line Point                1
# ABI   Abilene               TX  US2    ABI   Metropolitan Area             2
# PAR   Paris                     FR     CDG   Charles de Gaulle       0838  3 
# AAH   Aachen                    DE     AAW   Aachen Bf West Bus Stn        4 
# AAH   Aachen                    DE     XHJ   Hbf Railway Station           5 
# ACY   Atlantic City         NJ  US1    JSL   Steel Pier Heliport           6
# ADL   Adelaide              SA  AU3    ZII   Ferry Port                    7 
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
	FIELDWIDTHS="6 22 4 2 1 4 6 24 6 1"
	SEP = "^"

	# Header
	header_line = "city_code^city_name^state_code^country_code^tz_code^stv^por_code^por_name^loc_id^loc_type"
	print (header_line)
}

# Trim the white of the end of the string
function trim(__tString) {
	gsub ("[ \t]+$", "", __tString)
	return __tString
}

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
// {
	# City IATA code
	city_code = trim($1)

	# City name
	city_name = trim($2)

	# State code
	state_code = trim($3)

	# Country code
	ctry_code = trim($4)

	# Time-Zone code
	tz_code = trim($5)
	if (length(tz_code) > 1) {
		print ("[" awk_file "] !!! Error at record #" FNR \
			   ". TZ code length too big. Full line: " $0) > error_stream
	}

	# STV
	stv = trim($6)
	if (length(stv) > 1) {
		print ("[" awk_file "] !!! Error at record #" FNR \
			   ". STV length too big. Full line: " $0) > error_stream
	}

	# Travel-related POR code
	tvl_code = trim($7)

	# Travel-related POR name
	tvl_name = trim($8)

	# POR ID
	loc_id = trim($9)

	# Location type
	loc_code = trim($10)
	loc_type = toLocType(loc_code)

	# Output line
	output_line = city_code SEP city_name
	output_line = output_line SEP state_code SEP ctry_code
	output_line = output_line SEP tz_code SEP stv
	output_line = output_line SEP tvl_code SEP tvl_name
	output_line = output_line SEP loc_id SEP loc_type
	
	print (output_line)
}

##
#
END {
}
