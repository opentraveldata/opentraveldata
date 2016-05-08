##
# That AWK script converts a fixed-width file into a CSV one
#
# Sample input lines:
# ALV       LOAndorra la Vella Off-Line Point        AD  Andorra                              00  0142.31.00N001.32.00EI
# ABIKABIABIAAAbilene Regional Apt                   US  USA                                  TX  0332.24.41N099.40.55W 
# ABI       M Abilene                                US  USA                                  TX  0332.25.00N099.41.00W 
# BGN       LABelaya Gora                            RUEARussian Federation                   00  1068.33.25N146.13.52E 
# CDGLFPGPARAAParis Charles de Gaulle Apt            FR  France                               00  0149.00.35N002.32.52E 
# PAR       M Paris                                  FR  France                               00  0148.52.00N002.20.00E 
# AAHEDKA   LAAachen                                 DE  Germany                              00  0150.49.23N006.11.11EI
# XHJ       LRAachen                                 DE  Germany                              00  0150.46.06N006.05.28E 
# JSL    ACYAAAtlantic City Steel Pier Heliport      US  USA                                  NJ  0139.22.00N074.25.00WI
# ACY       M Atlantic City                          US  USA                                  NJ  0139.21.46N074.25.35W 
# ADLYPADADLAAAdelaide International                 AU  Australia                            SA  0534.56.42S138.31.50E 
# ADL       M Adelaide                               AU  Australia                            SA  0534.56.00S138.36.00E 
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
    awk_file = "prepare_oag_dump_file.awk"
	FIELDWIDTHS="3 4 3 2 39 2 2 37 2 2 2 9 10 1"
	SEP = "^"

	# Header
	header_line = "por_code^icao_code^city_code^loc_type^por_name^country_code^country_subcode^country_name^state_code^reg_code^tz_code^latitude^longitude^inactive_flag"
	print (header_line)
}

# Trim the white of the beginning and of the end of the string
function trim(__tString) {
	gsub ("^[ \t]+", "", __tString)
	gsub ("[ \t]+$", "", __tString)
	return __tString
}

function toLocType(__tltLocType) {
	__resultLocType = ""
    switch (__tltLocType) {
    case "LO":
		__resultLocType = "O"
		break
    case "M":
		__resultLocType = "C"
		break
    case "AA":
		__resultLocType = "A"
		break
    case "LA":
		__resultLocType = "A"
		break
    case "AB":
		__resultLocType = "B"
		break
    case "LB":
		__resultLocType = "B"
		break
    case "AR":
		__resultLocType = "R"
		break
    case "LR":
		__resultLocType = "R"
		break
    case "AH":
		__resultLocType = "H"
		break
    case "LH":
		__resultLocType = "H"
		break
    case "LV":
		__resultLocType = "P"
		break
    }
	return __resultLocType
}

##
#
/^[A-Z]{3}/ {
	# Travel-related POR code
	tvl_code = $1

	# ICAO code
	icao_code = trim($2)

	# City IATA code
	city_code = trim($3)

	# Location type
	loc_code = trim($4)
	loc_type = toLocType(loc_code)

	# Sanity check
	if (length(loc_type) == 0) {
		print ("[" awk_file "] !!! Error at record #" FNR				\
			   ". Location type ('" loc_type "') unrecognized. Full line: " $0) \
			> error_stream
	}

	# Travel-related POR name
	tvl_name = trim($5)

	# Country code
	ctry_code = $6

	# Country sub-code
	ctry_subcode = trim($7)

	# Country name
	ctry_name = trim($8)

	# State code
	state_code = trim($9)

	# Regional code
	reg_code = trim($10)

	# Time-Zone code
	tz_code = trim($11)

	# Geographical latitude
	geo_lat = convertLatToStd($12)

	# Geographical lontitude
	geo_lon = convertLonToStd($13)

	# Flag of inactivity
	inactivity_flag = trim($14)

	# Output line
	output_line = tvl_code SEP icao_code SEP city_code
	output_line = output_line SEP loc_type SEP tvl_name
	output_line = output_line SEP ctry_code SEP ctry_subcode SEP ctry_name
	output_line = output_line SEP state_code SEP reg_code SEP tz_code
	output_line = output_line SEP geo_lat SEP geo_lon
	output_line = output_line SEP inactivity_flag

	print (output_line)
}

##
#
END {
}
