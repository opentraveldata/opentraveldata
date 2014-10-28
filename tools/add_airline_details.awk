#


BEGIN {
	print "#iata_code2^iata_code3^airline_name"
	error_stream = "/dev/stderr"
}

# Airline reference file: ../ORI/ori_airlines.csv
# Samples:
# air-aer-lingus^^^^EIN^EI^53^Aer Lingus^Aer Lingus^^^^^67441
# air-aero-airlines^^^^^EE^350^Aero Airlines^Aero Airlines^^^^^2144
/^air-/ {
	# 3-char IATA code
	aircode3 = $5;

	# 2-char IATA code
	aircode2 = $6;

	# Airline name
	airname = $8;

	# Register the airline name
	airname_list[aircode2] = airname;

	# Register the 2-char/3-char mapping
	if (aircode3) {
		aircode2_list[aircode3] = aircode2;
		aircode3_list[aircode2] = aircode3;
	}
}

# Simple file with a single IATA code, either 2-char or 3-char, per line.
# Samples:
# K5
# KLC
/^([A-Z0-9]){2,3}$/ {
	# IATA code
	aircode = $1;
	aircodelen = length(aircode);

	# 
	if (aircodelen == 2) {
		aircode2 = aircode;
		aircode3 = aircode3_list[aircode2];

	} else if (aircodelen == 3) {
		aircode3 = aircode;
		aircode2 = aircode2_list[aircode3];

	} else {
		print "ERROR -- The airline code '" aircode "' is not recognised" > error_stream
	}

	# Airline name
	airname = airname_list[aircode2]

	#
	print aircode2 "^" aircode3 "^" airname;
}

