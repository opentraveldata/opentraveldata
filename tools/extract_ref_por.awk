##
# That AWK script extracts a few details from the POR reference data file.
#  * Referential data:                      dump_from_ref_city.csv
# Generated file:
#  * OPTD-maintained referential data:      optd_por_ref.csv
#
# Sample output lines:
# AHE^CA^AHE^^PF^^-14.4281^-146.257
# ORD^A^CHI^IL^US^^41.9797^-87.9044
# CGX^A^CHI^IL^US^^41.85^-87.6^889
#

##
# Helper functions
@include "awklib/geo_lib.awk"


##
#
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "extract_non_geonames_por.awk"

    # Lists
    ctry_name_list["ZZ"] = "Not relevant/available"
    ctry_cont_code_list["ZZ"] = "ZZ"
    ctry_cont_name_list["ZZ"] = "Not relevant/available"

    # Separators
	K_TGT_SEP = ";"
    K_1ST_SEP = "^"
    K_2ND_SEP = "="
    K_3RD_SEP = "|"

    # Header
    hdr_line = "iata_code^loc_type^cty_code^state_code^ctry_code^lat^lon"
    print (hdr_line)
}


##
# Reference data
#
# Sample input lines:
# AHE^CA^AHE^^AHE^AHE/PF^AHE^AHE^Y^^PF^PACIF^ITC3^PF087^-14.4281^-146.257^0^Y
# ORD^A^CHICAGO ORD^O HARE INTERNATIONAL^CHICAGO ORD^CHICAGO/IL/US:O HARE INTERNATI^CHICAGO^CHI^Y^IL^US^NAMER^ITC1^US107^41.9797^-87.9044^3729^Y
# CGX^A^CHICAGO CGX^MERRILL C MEIGS^CHICAGO CGX^CHICAGO/IL/US:MERRILL C MEIGS^CHICAGO^CHI^Y^IL^US^NAMER^ITC1^US107^41.85^-87.6^889^N
#
/^([A-Z]{3})\^([A-Z]{1,2})\^/ {
    # IATA code
    iata_code = $1

	# Location type
	loc_type = $2

	# City code
	city_code = $8

	# State code
	state_code = $10

	# Country code
	ctry_code = $11

	# Geographical coordinates
	coord_lat = $15
	coord_lon = $16

	# Generate the output line
	output_line = iata_code "^" loc_type "^" city_code "^" state_code
	output_line = output_line "^" ctry_code "^" coord_lat "^" coord_lon
	print (output_line)
}


##
#
END {
    #
}

