##
# That AWK script converts a fixed-width file into a CSV one
#


##
#
BEGIN {
	#
	FIELDWIDTHS="6 22 4 2 5 6 24 6 1"
	SEP = "^"

	# Header
	header_line = "city_code^city_name^state_name^country_code^country_code2^por_code^por_name^loc_id^loc_type"
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

	# Country code2
	ctry_code2 = trim($5)

	# Travel-related POR code
	tvl_code = trim($6)

	# Travel-related POR name
	tvl_name = trim($7)

	# POR ID
	loc_id = trim($8)

	# Location type
	loc_code = trim($9)
	loc_type = toLocType(loc_code)

	#
	output_line = city_code SEP city_name SEP state_code
	output_line = output_line SEP ctry_code SEP ctry_code ctry_code2
	output_line = output_line SEP tvl_code SEP tvl_name
	output_line = output_line SEP loc_id SEP loc_type
	
	print (output_line)
}

##
#
END {
}
