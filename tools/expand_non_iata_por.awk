##
# That AWK script re-formats the full details of POR (points of reference)
# for unknown POR entries. Hence, the format of the non-IATA POR entries is
# exactly the same as the one of the optd_por_public.csv data file.
#
# See also the make_optd_por_public.awk AWK script for more details.
#
# Important note: that AWK script is intended to be run very rarely,
# potentially just once.
#
# Sample output lines:
# SEJ^ZZZZ^^N^0^1^Unkown POR N^Unkown POR N^65.27^-14^S^AIRP^^^^^FR^^France^^^^^^^^^0^178^174^Europe/Paris^1.0^2.0^1.0^2013-01-01^SEJ^^^^^^^CA^^
#


##
#
BEGIN {
	# Global variables
	error_stream = "/dev/stderr"
	awk_file = "expand_non_iata_por.awk"

	# Header
	printf ("%s","iata_code^icao_code^faa_code^is_geonames^geoname_id^valid_id")
	printf ("%s", "^name^asciiname^latitude^longitude")
	printf ("%s", "^fclass^fcode")
	printf ("%s", "^page_rank^date_from^date_until^comment")
	printf ("%s", "^country_code^cc2^country_name")
	printf ("%s", "^adm1_code^adm1_name_utf^adm1_name_ascii")
	printf ("%s", "^adm2_code^adm2_name_utf^adm2_name_ascii")
	printf ("%s", "^adm3_code^adm4_code")
	printf ("%s", "^population^elevation^gtopo30")
	printf ("%s", "^timezone^gmt_offset^dst_offset^raw_offset^moddate")
	printf ("%s", "^city_code^city_name_utf^city_name_ascii^tvl_por_list")
	printf ("%s", "^state_code^wac^wac_name^location_type")
	printf ("%s", "^wiki_link")
	printf ("%s", "^alt_name_section")
	printf ("%s", "\n")

	#
	today_date = mktime ("YYYY-MM-DD")
	unknown_idx = 1
}


##
# Non-IATA POR entries with almost no information
#
# Sample input lines (16 fields):
#
# TODO:SEJ^UNKNOWN7974^UNKNOWN7974^UNKNOWN7974/ZZ^ZZZ^Y^^ZZ^ZZZZZ^ITZ1^ZZ^65.27^-14^0^N^^^CA
#
#
/^([A-Z0-9]{3})-([A-Z]{1,2})\^([A-Z]{3})\^([0-9.+-]{0,12})\^/ {

	if (NF == 16) {
		####
		## Neither in Geonames nor in RFD
		####
		# Location type (extracted from the primary key)
		location_type = "A"

		# IATA code
		iata_code = $1

		# PageRank value
		page_rank = getPageRank(iata_code, location_type)

		# Is in Geonames?
		geonameID = "0"
		isGeonames = "N"

		# IATA code ^ ICAO code ^ FAA ^ Is in Geonames ^ GeonameID ^ Validity ID
		printf ("%s", iata_code "^ZZZZ^^" isGeonames "^" geonameID "^") \
			> non_optd_por_file

		# ^ Name ^ ASCII name
		printf ("%s", "^UNKNOWN" unknown_idx "^UNKNOWN" unknown_idx) \
			> non_optd_por_file

		# ^ Alternate names
		# printf ("%s", "^") > non_optd_por_file

		# ^ Latitude ^ Longitude
		printf ("%s", "^" $3 "^" $4) > non_optd_por_file

		#  ^ Feat. class ^ Feat. code
		printf ("%s", "^S^AIRP") > non_optd_por_file

		# ^ PageRank value
		printf ("%s", "^" page_rank) > non_optd_por_file

		# ^ Valid from date ^ Valid until date ^ Comment
		printf ("%s", "^^^") > non_optd_por_file

		# ^ Country code ^ Alt. country codes ^ Country name
		printf ("%s", "^" "ZZ" "^" "Zzzzz") > non_optd_por_file

		# ^ Admin1 code ^ Admin1 UTF8 name ^ Admin1 ASCII name
		printf ("%s", "^^^") > non_optd_por_file
		# ^ Admin2 code ^ Admin2 UTF8 name ^ Admin2 ASCII name
		printf ("%s", "^^^") > non_optd_por_file
		# ^ Admin3 code ^ Admin4 code
		printf ("%s", "^^") > non_optd_por_file

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^^^") > non_optd_por_file

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" "Europe/Greenwich" "^^^") > non_optd_por_file

		# ^ Modification date
		printf ("%s", "^" today_date) > non_optd_por_file

		# ^ City code ^ City UTF8 name ^ City ASCII name ^ Travel-related list
		printf ("%s", "^" "ZZZ" "^"  "^"  "^" ) > non_optd_por_file

		# ^ State code ^ US DOT WAC ^ WAC name
		printf ("%s", "^" "^" "^") > non_optd_por_file

		#  ^ Location type (the default, i.e., city and airport)
		printf ("%s", "^CA") > non_optd_por_file

		#  ^ Wiki link (empty here)
		printf ("%s", "^") > non_optd_por_file

		#  ^ Section of alternate names  (empty here)
		printf ("%s", "^") > non_optd_por_file

		# End of line
		printf ("%s", "\n") > non_optd_por_file

		# ----
		# From ORI-POR ($1 - $6)
		# (1) SZD-C ^ (2) SZD ^ (3) 53.394256 ^ (4) -1.388486 ^ (5) SZD ^ (6)  

		#
		unknown_idx++

	} else {
		print ("[" awk_file "] !!!! Error for row #" FNR ", having " NF \
			   " fields: " $0) > error_stream
	}

}
