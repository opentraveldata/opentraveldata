##
# That AWK script re-formats the full details of POR (points of reference)
# derived from a few sources:
#  * OPTD-maintained lists of:
#    * Best known POR (poins of reference): optd_por_best_known_so_far.csv
#    * PageRank values:                     ref_airport_pageranked.csv
#    * Country-associated time-zones:       optd_tz_light.csv
#    * Time-zones for a few POR:            optd_por_tz.csv
#    * Country-associated continents:       optd_cont.csv
#    * US DOT World Area Codes (WAC):       optd_usdot_wac.csv
#  * Referential data:                      dump_from_ref_city.csv
# Generated file:
#  * Non-Geonames referential data:         optd_por_no_geonames.csv
#
# Sample output lines:
# AHE^^^N^0^^Ahe PF^Ahe PF^-14.4806^-146.30279^P^PPLC^0.0111037543665^^^^PF^^French Polynesia^Oceania^^^^^^^^^^^^Pacific/Tahiti^^^^-1^AHE^Ahe PF^AHE|0|Ahe PF|Ahe PF^AHE^^C^^^823^French Polynesia
# CGX^^^N^0^^Chicago IL US Merrill C Meigs^Chicago IL US Merrill C Meigs^41.85^-87.6^S^AIRP^^^^^US^^United States^North America^^^^^^^^^^^^America/Chicago^^^^-1^CHI^Chicago^CHI|4887398|Chicago|Chicago^^IL^A^^^41^Illinois
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

	# Fix the reference data
	por_wrong_ref_list["EHD"] = 1; por_wrong_ref_list["OWZ"] = 1
	por_wrong_ref_list["QQA"] = 1; por_wrong_ref_list["QQB"] = 1
	por_wrong_ref_list["QQC"] = 1; por_wrong_ref_list["QQE"] = 1
	por_wrong_ref_list["QQF"] = 1; por_wrong_ref_list["QQG"] = 1
	por_wrong_ref_list["QQI"] = 1; por_wrong_ref_list["QQJ"] = 1
	por_wrong_ref_list["QQL"] = 1; por_wrong_ref_list["QQO"] = 1
	por_wrong_ref_list["QQV"] = 1; por_wrong_ref_list["QQZ"] = 1
	por_wrong_ref_list["VVE"] = 1; por_wrong_ref_list["VWY"] = 1
	por_wrong_ref_list["XXX"] = 1; por_wrong_ref_list["ZZW"] = 1

    # Separators
	K_TGT_SEP = ";"
    K_1ST_SEP = "^"
    K_2ND_SEP = "="
    K_3RD_SEP = "|"

    # Header
    hdr_line = "iata_code^icao_code^faa_code^is_geonames^geoname_id^envelope_id"
	hdr_line = hdr_line "^name^asciiname^latitude^longitude^fclass^fcode"
	hdr_line = hdr_line "^page_rank^date_from^date_until^comment"
	hdr_line = hdr_line "^country_code^cc2^country_name^continent_name"
	hdr_line = hdr_line "^adm1_code^adm1_name_utf^adm1_name_ascii"
	hdr_line = hdr_line "^adm2_code^adm2_name_utf^adm2_name_ascii"
	hdr_line = hdr_line "^adm3_code^adm4_code"
	hdr_line = hdr_line "^population^elevation^gtopo30"
	hdr_line = hdr_line "^timezone^gmt_offset^dst_offset^raw_offset^moddate"
	hdr_line = hdr_line "^city_code_list^city_name_list^city_detail_list^tvl_por_list"
	hdr_line = hdr_line "^state_code^location_type^wiki_link^alt_name_section"
	hdr_line = hdr_line "^wac^wac_name"

    print (hdr_line)

	# List of flags stating whether the POR are referenced by Geonames
	delete optd_por_geoname_list

    #
    today_date = mktime ("YYYY-MM-DD")
    unknown_idx = 1

    # File of PageRank values
    pr_date_generation = ""
    pr_date_from = ""
    pr_date_to = ""
}


##
# File of PageRank values.
#
# Header:
# -------
# [PR] Generation date: 2013-05-17
# [PR] License: CC-BY-SA (http://creativecommons.org/licenses/by-sa/3.0/deed.en_US)
# [PR] Validity period:
# [PR]   From: 2013-05-16
# [PR]   To: 2013-05-22
/^# \[PR\] Generation date: ([0-9]{4}-[0-9]{2}-[0-9]{2})$/ {
    pr_date_generation = gensub ("^([^0-9]+)([0-9]{4}-[0-9]{2}-[0-9]{2})$", \
								 "\\2", "g", $0)
}
/^# \[PR\]   From: ([0-9]{4}-[0-9]{2}-[0-9]{2})$/ {
    pr_date_from = gensub ("^([^0-9]+)([0-9]{4}-[0-9]{2}-[0-9]{2})$", \
						   "\\2", "g", $0)
}
/^# \[PR\]   To: ([0-9]{4}-[0-9]{2}-[0-9]{2})$/ {
    pr_date_to = gensub ("^([^0-9]+)([0-9]{4}-[0-9]{2}-[0-9]{2})$", \
						 "\\2", "g", $0)
}


##
# File of PageRank values.
#
# Content:
# --------
# Note that the location types of that file are not the same as the ones
# in the optd_por_best_known_so_far.csv file. Indeed, the location types
# take a value from three possible ones: 'C', 'A' or 'CA', where 'A' actually
# means travel-related rather than airport. There are distinct entries for
# the city and for the corresponding travel-related POR, only when there are
# several travel-related POR serving the city.
#
# In the optd_por_best_known_so_far.csv file, instead, there are distinct
# entries when Geonames has got itself distinct entries.
#
# For instance:
#  * NCE has got:
#    - 2 distinct entries in the optd_por_best_known_so_far.csv file:
#       NCE-A-6299418^NCE^43.658411^7.215872^NCE^
#       NCE-C-2990440^NCE^43.70313^7.26608^NCE^
#    - 1 entry in the file of PageRank values:
#       NCE-CA^NCE^0.161281957529
#  * IEV has got:
#    - 2 distinct entries in the optd_por_best_known_so_far.csv file:
#       IEV-A-6300960^IEV^50.401694^30.449697^IEV^
#       IEV-C-703448^IEV^50.401694^30.449697^IEV^
#    - 2 entries in the file of PageRank values:
#       IEV-C^IEV^0.109334523229
#       IEV-A^IEV^0.0280192004497
#
# Sample input lines:
#   LON-C^LON^1.0
#   PAR-C^PAR^0.994632137197
#   NYC-C^NYC^0.948221089373
#   CHI-C^CHI^0.768305897463
#   ATL-A^ATL^0.686723208248
#   ATL-C^ATL^0.686723208248
#   NCE-CA^NCE^0.158985215433
#   ORD-A^ORD^0.677280625337
#   CDG-A^CDG^0.647060165878
#
/^([A-Z]{3})-([A-Z]{1,2})\^([A-Z]{3})\^([0-9.]{1,20})$/ {
    # Primary key (IATA code and location pseudo-code)
    pk = $1

    # IATA code
    iata_code = substr (pk, 1, 3)

    # Location pseudo-type ('C' means City, but 'A' means any related to travel,
    # e.g., airport, heliport, port, bus or train station)
    por_type = substr (pk, 5)

    # Sanity check
    if (iata_code != $2) {
		print ("[" awk_file "] !!! Error at recrod #" FNR \
			   ": the IATA code ('" iata_code			  \
			   "') should be equal to the field #2 ('" $2 \
			   "'), but is not. The whole line " $0) > error_stream
    }

    # PageRank value
    pr_value = $3

    #
    registerPageRankValue(iata_code, por_type, $0, FNR, pr_value)
}


##
# OPTD-maintained list of POR basic details
#
# Sample input lines:
#  ALV-C-3041563^ALV^42.50779^1.52109^ALV^
#  ALV-O-7730819^ALV^40.98^0.45^ALV^
#  ARN-A-2725346^ARN^59.651944^17.918611^STO^
#  ARN-R-8335457^ARN^59.649463^17.929^STO^
#  IES-CA-2846939^IES^51.3^13.28^IES^
#  IEV-A-6300960^IEV^50.401694^30.449697^IEV^
#  IEV-C-703448^IEV^50.401694^30.449697^IEV^
#  KBP-A-6300952^KBP^50.345^30.894722^IEV^
#  LHR-A-2647216^LHR^51.4775^-0.461389^LON^
#  LON-C-2643743^LON^51.5^-0.1667^LON^
#  NCE-CA-0^NCE^43.658411^7.215872^NCE^
#
/^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})\^([A-Z]{3})\^/ {
    # Primary key (combination of IATA code, location type and Geonames ID)
    pk = $1

    # Extract the primary key fields
    #getPrimaryKeyAsArray(pk, myPKArray)
	split (pk, myPKArray, "-")
    iata_code = myPKArray[1]
    location_type = myPKArray[2]
    geonames_id = myPKArray[3]

    # IATA code of the POR (it should be the same as the one of the primary key)
    iata_code2 = $2

	# Geographical coordinates
	coord_lat = $3
	coord_lon = $4

	# Beginning date of the validity range
	date_from = $6

    # Register the POR (only) when it is not in Geonames
	if (geonames_id == "0") {
		optd_loc_type_list[iata_code] = location_type
		optd_por_lat_list[iata_code] = coord_lat
		optd_por_lon_list[iata_code] = coord_lon
		optd_date_from_list[iata_code] = date_from
		optd_por_geoname_list[iata_code] = -1
	} else {
		optd_por_geoname_list[iata_code] = 1
	}
}


##
# File of time-zone IDs
#
# Sample lines:
# country_code^time_zone
# ES^Europe/Spain
# RU^Europe/Russia
/^([A-Z]{2})\^([A-Za-z_\/]+)$/ {
    # Country code
    country_code = $1

    # Time-zone ID
    tz_id = $2

    # Register the time-zone ID associated to that country
    ctry_tz_list[country_code] = tz_id
}


##
# File of time-zones for a few POR.
#
# Content:
# --------
# Currently, for POR not known from Geonames, the time-zone is guessed
# thanks to the country. While that method works for most of the small
# countries, it fails for countries spanning multiple time-zones (e.g.,
# United States, Russia).
#
# Sample input lines:
# AYZ^America/New_York
# LJC^America/Kentucky/Louisville
# MNP^Pacific/Port_Moresby
# QSE^America/Sao_Paulo
#
/^([A-Z]{3})\^(Africa|America|Asia|Atlantic|Australia|Europe|Indian|Pacific)\/([A-Za-z/_]+)$/ {
    # IATA code
    iata_code = $1

    # Time-zone ID
    tz_id = $2

    # Register the time-zone ID associated to that country
    por_tz_list[iata_code] = tz_id
}

##
# File of country-continent mappings
#
# Sample lines:
# country_code^country_name^continent_code^continent_name
# DE^Germany^EU^Europe
# AG^Antigua and Barbuda^NA^North America
# PE^Peru^SA^South America
/^([A-Z]{2})\^([A-Za-z,. \-]+)\^([A-Z]{2})\^([A-Za-z ]+)$/ {
    # Country code
    country_code = $1

    # Country name
    country_name = $2

    # Continent code
    continent_code = $3

    # Continent name
    continent_name = $4

    # Register the country name associated to that country
    ctry_name_list[country_code] = country_name

    # Register the continent code associated to that country
    ctry_cont_code_list[country_code] = continent_code

    # Register the continent name associated to that country
    ctry_cont_name_list[country_code] = continent_name
}


##
# File of US DOT World Area Codes (WAC)
#
# Sample lines:
# WAC^WAC_SEQ_ID2^WAC_NAME^WORLD_AREA_NAME^COUNTRY_SHORT_NAME^COUNTRY_TYPE^CAPITAL^SOVEREIGNTY^COUNTRY_CODE_ISO^STATE_CODE^STATE_NAME^STATE_FIPS^START_DATE^THRU_DATE^COMMENTS^IS_LATEST^
# 1^101^Alaska^United States (Includes territories and possessions)^United States^Independent State in the World^Washington, DC^^US^AK^Alaska^02^1950-01-01^^An organized territory on May 11, 1912 and the 49th state of the U.S. on January 3, 1959.^1^
# 4^401^U.S. Virgin Islands^United States (Includes territories and possessions)^United States^Independent State in the World^Washington, DC^^US^VI^U.S. Virgin Islands^78^1990-01-01^^The U.S. took possession of the islands on March 31, 1917 and the territory was renamed the Virgin Islands of the United States^1^
# 427^42701^France^Europe^France^Independent State in the World^Paris^^FR^^^^1950-01-01^^Includes Corsica^1^
# 802^80201^Australia^Australasia and Oceania^Australia^Independent State in the World^Canberra^^AU^^^^1950-01-01^^Includes: Norfolk Island and Tasmania^1^
# 906^90601^British Columbia^Canada and Greenland^Canada^Independent State in the World^Ottawa^^CA^BC^British Columbia^^1950-01-01^^^1^
/^([0-9.]{1,3})\^([0-9.]{1,5})\^([A-Za-z,.()' \-]+)\^([A-Za-z,.()' \-]+)\^([A-Za-z,.()' \-]+)\^(Dependency and Area of Special Sovereignty|Independent State in the World)\^([A-Za-z,.()' \-]*)\^([A-Za-z0-9,.()' \-]*)\^([A-Z]{0,2})\^([A-Z]{0,2})\^/ {
    # World Area Code (WAC)
    world_area_code = $1

    # World Area Code (WAC) name
    wac_name = $3

    # Country ISO code
    country_iso_code = $9

    # State code
    state_code = $10

    # Through date
    through_date = $14

	# Register the relationships for that WAC
	registerWACLists(world_area_code, through_date,				\
					 country_iso_code, state_code, wac_name)
}


##
# Retrieve the time-zone ID for that POR IATA code
function getTimeZoneFromIATACode(myIATACode) {
    tz_id = por_tz_list[myIATACode]
    return tz_id
}

##
# Retrieve the time-zone ID for that country
function getTimeZoneFromCountryCode(myCountryCode) {
    tz_id = ctry_tz_list[myCountryCode]
    return tz_id
}

##
# Retrieve the country name for that country
function getCountryName(myCountryCode) {
    ctry_name = ctry_name_list[myCountryCode]
    return ctry_name
}

##
# Retrieve the continent code for that country
function getContinentCode(myCountryCode) {
    cnt_code = ctry_cont_code_list[myCountryCode]
    return cnt_code
}

##
# Retrieve the continent name for that country
function getContinentName(myCountryCode) {
    cnt_name = ctry_cont_name_list[myCountryCode]
    return cnt_name
}


##
# Reference data
#
# Sample input lines:
# AHE^CA^AHE^^AHE^AHE/PF^AHE^AHE^Y^^PF^PACIF^ITC3^PF087^-14.4281^-146.257^0^Y
# CGX^A^CHICAGO CGX^MERRILL C MEIGS^CHICAGO CGX^CHICAGO/IL/US:MERRILL C MEIGS^CHICAGO^CHI^Y^IL^US^NAMER^ITC1^US107^41.85^-87.6^889^N
#
/^([A-Z]{3})\^([A-Z]{1,2})\^/ {
    # IATA code
    iata_code = $1

	# Keep only if not in Geonames
	isGeonames = optd_por_geoname_list[iata_code]

	#
	shouldDiscard = por_wrong_ref_list[iata_code]
	if (isGeonames != 1 && !shouldDiscard) {
		# Feature code
		if (isGeonames == -1) {
			# Retrieved from the best known details
			location_type = optd_loc_type_list[iata_code]
		} else {
			# Retrieved from reference data
			location_type = $2
		}

		# Primary key
		pk = $1

		# Geonames ID
		geonameID = "0"
		isGeonamesStr = "N"

		# PageRank value
		page_rank = getPageRank(iata_code, location_type)

		# Name and ASCII name
		name_utf8 = capitaliseWords($6)
		name_ascii = name_utf8
		
		# Geographical coordinates
		if (isGeonames == -1) {
			# Retrieved from the best known details
			coord_lat = optd_por_lat_list[iata_code]
			coord_lon = optd_por_lon_list[iata_code]
		} else {
			# Retrieved from the reference data
			coord_lat = $15
			coord_lon = $16
		}

		# City code
		city_code = $8

        # Envelope ID
		envelope_id = ""

        # IATA code ^ ICAO code ^ FAA ^ Is in Geonames ^ GeonameID ^ Envelope ID
		out_line = iata_code "^^^" isGeonamesStr "^" geonameID "^" envelope_id

		# ^ Name ^ ASCII name
		out_line = out_line "^" name_utf8 "^" name_ascii

		# ^ Latitude ^ Longitude
		out_line = out_line "^" coord_lat "^" coord_lon

		# ^ Feat. class ^ Feat. code
		is_city = isLocTypeCity(location_type)
		is_offpoint = match (location_type, "O")
		is_airport = isLocTypeAirport(location_type)
		is_heliport = match (location_type, "H")
		is_railway = match (location_type, "R")
		is_bus = match (location_type, "B")
		is_port = match (location_type, "P")
		is_ground = match (location_type, "G")
		if (is_airport != 0) {
			# The POR is an airport. Note that it takes precedence over the
			# city, when the POR is both an airport and a city. 
			out_line = out_line "^S^AIRP"
		} else if (is_heliport != 0) {
			# The POR is an heliport
			out_line = out_line "^S^AIRH"
		} else if (is_railway != 0) {
			# The POR is a railway station
			out_line = out_line "^S^RSTN"
		} else if (is_bus != 0) {
			# The POR is a bus station
			out_line = out_line "^S^BUSTN"
		} else if (is_port != 0) {
			# The POR is a (maritime) port
			out_line = out_line "^S^PRT"
		} else if (is_ground != 0) {
			# The POR is a ground station
			out_line = out_line "^S^XXXX"
		} else if (is_city != 0) {
			# The POR is (only) a city
			out_line = out_line "^P^PPLC"
		} else if (is_offpoint != 0) {
			# The POR is an off-line point, which could be
			# a bus/railway station, or even a city/village.
			out_line = out_line "^X^XXXX"
		} else {
			# The location type can not be determined
			out_line = out_line "^Z^ZZZZ"
			print ("[" awk_file "] !!!! Warning !!!! The location type " \
				   "cannot be determined for the record #" FNR ":")		\
				> error_stream
			print ($0) > error_stream
		}

		# ^ PageRank value
		out_line = out_line "^" page_rank

		# ^ Valid from date ^ Valid until date ^ Comment
		date_from = optd_date_from_list[iata_code]
		out_line = out_line "^" date_from "^^"

		# State code
		state_code = $10

		# ^ Country code ^ Alt. country codes ^ Country name ^ Continent name
		country_code = $11
		country_code_alt = ""
		country_name = getCountryName(country_code)
		time_zone_id = getTimeZoneFromIATACode(iata_code)
		if (time_zone_id == "") {
			time_zone_id = getTimeZoneFromCountryCode(country_code)

			print ("[" awk_file "] !!!! Warning !!!! No time-zone " \
				   "for the record #" FNR " - Default time-zone: "	\
				   time_zone_id ". Record: " $0)					\
				> error_stream
		}
		continent_name = getContinentName(country_code)
		# continent_name = gensub ("/[A-Za-z_]+", "", "g", time_zone_id)
		out_line = out_line "^" country_code "^^" country_name "^" continent_name

		# ^ Admin1 code ^ Admin1 UTF8 name ^ Admin1 ASCII name
		out_line = out_line "^^^"
		# ^ Admin2 code ^ Admin2 UTF8 name ^ Admin2 ASCII name
		out_line = out_line "^^^"
		# ^ Admin3 code ^ Admin4 code
		out_line = out_line "^^"

		# ^ Population ^ Elevation ^ gtopo30
		out_line = out_line "^^^"

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		out_line = out_line "^" time_zone_id "^^^"

		# ^ Modification date
		out_line = out_line "^" today_date

		# ^ City code ^ City UTF8 name ^ City ASCII name ^ Travel-related list
		# Notes:
		#   1. The actual name values are added by the add_city_name.awk script.
		#   2. The city code is the one from the file of best known POR,
		#      not the one from reference data (as it is sometimes inaccurate).
		out_line = out_line "^" city_code "^"  "^"  "^"

		# ^ State code
		out_line = out_line "^" state_code

		# ^ Location type
		out_line = out_line "^" location_type

		# ^ Wiki link (empty here)
		out_line = out_line "^"

		# ^ Section of alternate names (empty here)
		out_line = out_line "^"

		# ^ US DOT World Area Code (WAC) ^ WAC name
		world_area_code = getWorldAreaCode(country_code, state_code,	\
										   country_code_alt)
		wac_name = getWorldAreaCodeName(world_area_code)
		out_line = out_line "^" world_area_code "^" wac_name

		#
		print (out_line)
	}
}


##
#
END {
    #
}

