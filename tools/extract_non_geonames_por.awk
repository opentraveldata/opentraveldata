##
# That AWK script re-formats the full details of POR (points of reference)
# derived from a few sources:
#  * OPTD-maintained lists of:
#    * Best known POR (poins of reference): optd_por_best_known_so_far.csv
#    * Deprecated POR still referenced:     optd_por_exceptions.csv
#    * PageRank values:                     ref_airport_pageranked.csv
#    * Country-associated time-zones:       optd_tz_light.csv
#    * Time-zones for a few POR:            optd_por_tz.csv
#    * Country details:                     optd_countries.csv
#    * Country-associated continents:       optd_cont.csv
#    * US DOT World Area Codes (WAC):       optd_usdot_wac.csv
#  * Referential data:                      dump_from_ref_city.csv
# Generated files:
#  * Non-Geonames referential data:         optd_por_no_geonames.csv
#  * POR having wrong time-zone:            optd_por_tz_wrong.csv
#
# Sample output lines:
# AHE^^^N^0^^Ahe PF^Ahe PF^-14.4806^-146.30279^P^PPLC^0.0111037543665^^^^PF^^French Polynesia^Oceania^^^^^^^^^^^^Pacific/Tahiti^^^^-1^AHE^Ahe PF^AHE|0|Ahe PF|Ahe PF^AHE^^C^^^823^French Polynesia^EUR^^^^
# CGX^^^N^0^^Chicago IL US Merrill C Meigs^Chicago IL US Merrill C Meigs^41.85^-87.6^S^AIRP^^^^^US^^United States^North America^^^^^^^^^^^^America/Chicago^^^^-1^CHI^Chicago^CHI|4887398|Chicago|Chicago^^IL^A^^^41^Illinois^USD^^^^
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

    # Fix the reference data: list of POR known to be valid in
    # the reference data, but not valid in OPTD.
    # Also, IATA references a few "fictitious" or other "test" POR.
    # All those POR should not be used in any production online systems.
    # So, it is better to remove them from OpenTravelData,
    # so that, if they are referenced within a flight schedule or a booking,
    # it is most probably an error (eg, mispelling), and it must be reported.
    # Keeping those POR in OpenTravelData would increase the difficulty of
    # detecting those simple errors.
    #
    # optd_por_wrong_tz_file set by the caller Shell script to
    #                        "../opentraveldata/optd_por_tz_wrong.csv"
    hdr_line = "iata_code^loc_type^por_name^por_name2^por_name3^por_name4^cty_name^cty_code^is_apt^state_code^ctry_code^rgn_code^cnt_code^tz_grp^lat^lon^nmc_code^is_cml"
    print (hdr_line) > optd_por_wrong_tz_file

    # 
    delete optd_por_tz_list
    optd_por_tz_list_file = "optd_por_tz.csv"

    # 
    delete optd_por_ref_dpctd_list
    optd_por_ref_dpctd_list_file = "optd_por_exceptions.csv"

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
    hdr_line = hdr_line "^wac^wac_name^ccy_code^unlc_list^uic_list"
    hdr_line = hdr_line "^geoname_lat^geoname_lon"

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
# File of rules for no longer valid (deprecated), but still referenced, POR
#
# Sample lines:
# por_code^source^actv_in_optd^actv_in_src^env_id^date_from^date_to^city_code^state_code^reason_code^comment
# AFW^R^1^0^^^^DFW^^^As of May 2016, AFW has been moved to FTW/Fort Worth, Texas (TX), United States (US)
# AIY^R^0^1^1^^2016-06-06^^^^AIY used to be Atlantic City, New Jersey (NJ), United States (US), Geonames ID: 4500546
# BVF^R^0^1^^^^^^^BVF used to be Bua Airport, Fiji (FJ), Geonames ID: 8298792
/^[A-Z]{3}\^[INO]{0,3}R[INO]{0,3}\^0\^1\^\^\^\^\^\^\^[^^]*$/ {
    # IATA code
    iata_code = $1

    # Register the fact that that POR is deprecated but still referenced
    optd_por_ref_dpctd_list[iata_code] = 1

	# DEBUG
	#if (iata_code == "AYE") {
	#	print $0
	#}
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
# File of country details (optd_countries.csv)
#
# Sample lines:
# iso_2char_code^iso_3char_code^iso_num_code^fips^name^cptl^area^pop^cont_code^tld^ccy_code^ccy_name^tel_pfx^zip_fmt^lang_code_list^geo_id^ngbr_ctry_code_list
# FR^FRA^250^FR^France^Paris^547030^64768389^EU^.fr^EUR^Euro^33^#####^fr-FR=frp=br=co=ca=eu=oc^3017382^CH=DE=BE=LU=IT=AD=MC=ES
# PF^PYF^258^FP^French Polynesia^Papeete^4167^270485^OC^.pf^XPF^Franc^689^#####^fr-PF=ty^4030656^
# US^USA^840^US^United States^Washington^9629091^310232863^NA^.us^USD^Dollar^1^#####-####^en-US=es-US=haw=fr^6252001^CA=MX=CU
#
/^[A-Z]{2}\^[A-Z]{3}\^[0-9]{1,3}\^[A-Z]{0,2}\^[a-zA-Z., -]{2,50}/ {
    # Country code
    country_code = $1

    # Currency code
    ccy_code = $11

    # Geonames ID
    geo_id = $17

    # Register the relationship between the country code and the currency code
    ctry_ccy_list[country_code] = ccy_code
}


##
# Content of file of PageRank values (ref_airport_pageranked.csv).
#
# Content:
# --------
# The beginning of the line is the same as within optd_por_best_known_so_far.csv,
# ie, the primary key and the IATA code, followed by two PageRank values,
# respectively for the average number of seats and the average flight
# frequencies
#
# Sample input lines:
# pk^iata_code^pr_seats^pr_freq
# LON-C-2643743^LON^1.0^1.0
# MOW-C-524901^MOW^0.8229903723953657^0.9681633902820295
# NYC-C-5128581^NYC^0.7658367710524969^0.8839448294206996
# PAR-C-2988507^PAR^0.6770801656831421^0.699332558702537
# IST-C-745044^IST^0.6323471740536254^0.7172930511408985
# CHI-C-4887398^CHI^0.6262218825585703^0.79279205301558
# ATL-C-4180439^ATL^0.6087993220352576^0.6478882503835618
# ATL-A-4199556^ATL^0.6085970363321758^0.6472849729692148
# EWR-A-5101809^EWR^0.2394765390077882^0.30017886155993007
# EWR-C-5099738^EWR^0.2394765390077882^0.30017886155993007
# EWR-C-5101798^EWR^0.23947653900778815^0.30017886155993007
#
/^[A-Z]{3}-[A-Z]{1,2}-[0-9]{1,15}\^[A-Z]{3}\^[0-9.]{1,30}\^[0-9.]{1,30}$/ {
    # Primary key (IATA code and location pseudo-code)
    pk = $1
    getPrimaryKeyAsArray(pk, pk_array)

    # IATA code
    iata_code = pk_array[1]

    # Location type
    por_type = pk_array[2]

    # Sanity check
    if (iata_code != $2) {
	print ("[" awk_file "] !!! Error at record #" FNR \
	       ": the IATA code ('" iata_code			  \
	       "') should be equal to the field #2 ('" $2 \
	       "'), but is not. The whole line " $0) > error_stream
    }

    # PageRank value for the average number of seats
    pr_seats = $3

    # PageRank value for the average flight frequencies
    pr_freq = $4

    #
    registerPageRankValues(pk, pr_seats, pr_freq)
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
/^[A-Z]{3}-[A-Z]{1,2}-[0-9]{1,15}\^[A-Z]{3}\^[0-9.+-]{0,16}\^[0-9.+-]{0,16}\^([A-Z]{3},?)+\^([0-9]{4}-[0-9]{2}-[0-9]{2}|)$/ {
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
/^[A-Z]{2}\^[A-Za-z_\/]+$/ {
    # Country code
    country_code = $1

    # Time-zone ID
    tz_id = $2

    # Register the time-zone ID associated to that country
    ctry_tz_list[country_code] = tz_id
}


##
# File of time-zone rules for a few non-Geonames POR
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
/^[A-Z]{3}\^(Africa|America|Asia|Atlantic|Australia|Europe|Indian|Pacific)\/([A-Za-z/_]+)$/ {
    # IATA code
    iata_code = $1

    # Time-zone ID
    tz_id = $2

    # Register the time-zone ID associated to that country
    optd_por_tz_list[iata_code] = tz_id
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
    tz_id = optd_por_tz_list[myIATACode]

    # Delete the record, so as to keep track of the ones not used
    delete optd_por_tz_list[iata_code]

    #
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
/^[A-Z]{3}\^[A-Z]{1,2}\^[A-Z0-9'./();:\- ]{2,20}\^/ {
    # IATA code
    iata_code = $1

    # Check that the POR is not known to be an exception
    if (!(iata_code in optd_por_ref_dpctd_list)) {

	# Keep only if not in Geonames
	isGeonames = optd_por_geoname_list[iata_code]

	#
	if (isGeonames != 1) {
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
	    page_rank = getPageRankFromCodeAndLocType(iata_code, location_type)

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

	    # IATA code ^ ICAO code ^ FAA
	    out_line = iata_code "^^"

	    # ^ Is in Geonames ^ GeonameID ^ Envelope ID
	    out_line = out_line "^" isGeonamesStr "^" geonameID "^" envelope_id

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
		       "cannot be determined for the record #" FNR ":")	\
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

	    # ^ Country code ^ Alt. country codes ^ Country name
	    country_code = $11
	    country_code_alt = ""
	    country_name = getCountryName(country_code)
	    out_line = out_line "^" country_code "^^" country_name

	    # ^ Continent name
	    time_zone_id = getTimeZoneFromIATACode(iata_code)
	    if (time_zone_id == "") {
		time_zone_id = getTimeZoneFromCountryCode(country_code)

		# Reporting
		print ("[" awk_file "] !!!! Warning !!!! No time-zone " \
		       "for the record #" FNR " - Default time-zone: "	\
		       time_zone_id ". Record: " $0)					\
		    > error_stream
		print ($0) > optd_por_wrong_tz_file
	    }
	    continent_name = getContinentName(country_code)
	    # continent_name = gensub ("/[A-Za-z_]+", "", "g", time_zone_id)
	    out_line = out_line "^" continent_name

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

	    # ^ City code ^ City UTF8 name ^ City ASCII name ^ Travel-rltd list
	    # Notes:
	    #   1. The actual name values are added by the add_city_name.awk
	    #      script.
	    #   2. The city code is the one from the file of best known POR,
	    #      not the one from reference data (as it is sometimes
	    #      inaccurate).
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
	    world_area_code = getWorldAreaCode(country_code, state_code, \
					       country_code_alt)
	    wac_name = getWorldAreaCodeName(world_area_code)
	    out_line = out_line "^" world_area_code "^" wac_name

	    # ^ Currency code
	    ccy_code = ctry_ccy_list[country_code]
	    out_line = out_line "^" ccy_code

	    # ^ UN/LOCODE codes (potentially a list)
	    out_line = out_line "^"

	    # ^ UIC codes (potentially a list)
	    out_line = out_line "^"

	    # ^ Geoname Latitude ^ Geoname Longitude (not known by design)
	    out_line = out_line "^^"

	    #
	    print (out_line)
	}

    } else {
	delete optd_por_ref_dpctd_list[iata_code]
    }
}


##
#
END {
    # Reporting
    for (myIdx in optd_por_ref_dpctd_list) {
	print ("[" awk_file "] !!!! Warning: " myIdx					\
	       " code is still referenced in the '"						\
	       optd_por_ref_dpctd_list_file "' file, "					\
	       "but has disappeared from reference data.") > error_stream
    }

    asorti(optd_por_tz_list, optd_por_tz_list_sorted)
    for (myIdx in optd_por_tz_list_sorted) {
	print ("[" awk_file "] !!!! Warning: " optd_por_tz_list_sorted[myIdx] \
	       " code is still referenced in the '"						\
	       optd_por_tz_list_file "' file, but is now in Geonames "	\
	       "or has disappeared from reference data.") > error_stream
    }
}

