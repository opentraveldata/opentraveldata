##
# That AWK script capitalises POR names.
#
# The format of the data files is assumed to be as per the following:
#
# Geographical data file (CITY)
# - [1]  iata_code^
# - [2]  location_type^
# - [3]  ticketing_name^
# - [4]  detailed_name^
# - [5]  teleticketing_name^
# - [6]  extended_name^
# - [7]  city_name^
# - [8]  rel_city_code^
# - [9]  is_airport^
# - [10] state_code^
# - [11] rel_country_code^
# - [12] rel_region_code^
# - [13] rel_continent_code^
# - [14] rel_time_zone_grp^
# - [15] latitude^
# - [16] longitude^
# - [17] numeric_code^
# - [18] is_commercial
#
# Airline  data file (AIRLINE)
# - [1]  NEW_CODE^ #ICAO 3 digit code
# - [2]  OLD_CODE^ #IATA 2 digit code
# - [3]  NUM_CODE^ #numeric code which is mainly used in ticket
# - [4]  NAME^
# - [5]  TICKETING_NAME^ #often the same as NAME
# - [6]  CODE #one line appears with ICAO code, another line with IATA code 



##
# Helper functions
@include "awklib/geo_lib.awk"

##
#
BEGIN {
	# Global variables
	error_stream = "/dev/stderr"
	awk_file = "ref_capitalise.awk"
	idx_por = 0
}


####
## Data files

##
# Geographical header line
/^iata_code/ {
	print ($0)
}

##
# Geographical file regular lines
# Sample lines (truncated):
#  DUN^^DUNDAS^^DUNDAS^DUNDAS/GL^DUNDAS^DUN^Y^^GL^EUROP^ITC1^GL055^^^^N
#  IEV^CA^KIEV ZHULIANY INT^ZHULIANY INTL^KIEV ZHULIANY I^KIEV/UA:ZHULIANY INTL
#    ^KIEV^IEV^Y^^UA^EURAS^ITC2^UA127^50.4^30.4667^2082^Y
#  KBP^A^KIEV BORYSPIL^BORYSPIL INTL^KIEV BORYSPIL^KIEV/UA:BORYSPIL INTL
#    ^KIEV^IEV^Y^^UA^EURAS^ITC2^UA127^50.35^30.9167^2384^Y
#  LHR^A^LONDON LHR^HEATHROW^LONDON LHR^LONDON/GB:HEATHROW
#    ^LONDON^LON^Y^^GB^EUROP^ITC2^GB053^51.4761^-0.63222^2794^Y
#  LON^C^LONDON^^LONDON^LONDON/GB
#    ^LONDON^LON^N^^GB^EUROP^ITC2^GB053^51.5^-0.16667^^N
#  NCE^CA^NICE^COTE D AZUR^NICE^NICE/FR:COTE D AZUR
#    ^NICE^NCE^Y^^FR^EUROP^ITC2^FR052^43.6653^7.215^^Y
#
/^([A-Z]{3})\^([A-Z]{0,2})\^(.*)\^([YN])$/ {
	# DEBUG
	#idx_por++
	#if (idx_por >= 2) {
	#	exit
	#}

	# IATA code
	iata_code = $1

	# Sanity check: if the fields change, it is wiser to be warned.
	if (NF != 18) {
		print ("[" awk_file "] !!!! Error at line #" FNR " for the '" iata_code \
			   "' IATA code; the number of fields is not equal to 18 "	\
			   "- Full line: " $0) > error_stream
	}

	# Override the output separator (to be equal to the input one)
	OFS = FS

	# Ticketing name
	ticketing_name = capitaliseWords($3)
	$3 = ticketing_name

	# Detailed name
	detailed_name = capitaliseWords($4)
	$4 = detailed_name

	# Teleticketing name
	teleticketing_name = capitaliseWords($5)
	$5 = teleticketing_name

	# Extended name
	extended_name = capitaliseWords($6)
	$6 = extended_name

	# City name
	city_name = capitaliseWords($7)
	$7 = city_name
	
	# Print the amended line
	print ($0)

}

##
# Airline file regular lines
# Sample lines (truncated):
#  *A^^*A^0^STAR ALLIANCE^
#  *O^^*O^0^ONEWORLD^
#  *S^^*S^0^SKYTEAM^
#  AF^AFR^AF^57^AIR FRANCE^AIR FRANCE
#  AFR^AFR^AF^57^AIR FRANCE^AIR FRANCE
#  BA^BAW^BA^125^BRITISH AIRWAYS^BRITISH A/W
#  BAW^BAW^BA^125^BRITISH AIRWAYS^BRITISH A/W
#  DLH^DLH^LH^220^LUFTHANSA^LUFTHANSA
#  LH^DLH^LH^220^LUFTHANSA^LUFTHANSA
#
/^([*A-Z0-9]{2,3})\^([A-Z]{3})?\^([*A-Z0-9]{2})\^([0-9]+)\^/ {

	# Sanity check: if the format (here, the number of fields) changes,
	# it is wiser to be warned.
	exp_nb_fields = 6
	if (NF != exp_nb_fields) {
		print ("[" awk_file "] !!!! Error at line #" FNR " for the '" iata_code \
			   "' IATA code (in the dump_from_ref_airline.csv file); " NF \
			   " fields instead of " exp_nb_fields						\
			   "- Full line: " $0) > error_stream
	}

	# Override the output separator (to be equal to the input one)
	OFS = FS

	# Airline name
	airline_name = capitaliseWords($5)
	$5 = airline_name

	# Ticketing name
	ticketing_name = capitaliseWords($6)
	$6 = ticketing_name
	
	# Print the amended line
	print ($0)
}

#
ENDFILE {
	# DEBUG
}

