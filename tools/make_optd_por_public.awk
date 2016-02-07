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
#  * Referential Data:                      dump_from_ref_city.csv
#  * Geonames:                              dump_from_geonames.csv
#
# Notes:
# 1. When the POR is existing only in the reference data, the cryptic time-zone
#    ID is replaced by a more standard time-zone ID. That latter is a simplified
#    version of the standard time-zone ID (such as the one given by Geonames),
#    as there is then a single time-zone ID per country; that is obviously
#    inaccurate for countries such as Russia, Canada, USA, Antartica, Australia.
# 2. The city (UTF8 and ASCII) names are added afterwards, by another AWK script,
#    namely add_city_name.awk, located in the very same directory.
#
# Sample output lines:
# IEV^UKKK^^Y^6300960^^Kyiv Zhuliany International Airport^Kyiv Zhuliany International Airport^50.401694^30.449697^S^AIRP^0.0240196752049^^^^UA^^Ukraine^Europe^^^^^^^^^0^178^174^Europe/Kiev^2.0^3.0^2.0^2012-06-03^IEV^^^^^488^Ukraine^A^http://en.wikipedia.org/wiki/Kyiv_Zhuliany_International_Airport^en|Kyiv Zhuliany International Airport|=en|Kyiv International Airport|=en|Kyiv Airport|s=en|Kiev International Airport|=uk|Міжнародний аеропорт «Київ» (Жуляни)|=ru|Аэропорт «Киев» (Жуляны)|=ru|Международный аеропорт «Киев» (Жуляни)|
# NCE^LFMN^^Y^6299418^^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.658411^7.215872^S^AIRP^0.157408761216^^^^FR^^France^Europe^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^NCE^^^^^427^France^CA^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de|Flughafen Nizza|=en|Nice Côte d'Azur International Airport|=es|Niza Aeropuerto|ps=fr|Aéroport de Nice Côte d'Azur|=en|Nice Airport|s
#

##
# Helper functions
@include "awklib/geo_lib.awk"


##
#
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "make_optd_por_public.awk"

    # Lists
    ctry_name_list["ZZ"] = "Not relevant/available"
    ctry_cont_code_list["ZZ"] = "ZZ"
    ctry_cont_name_list["ZZ"] = "Not relevant/available"

    # Header
    printf ("%s", "iata_code^icao_code^faa_code")
    printf ("%s", "^is_geonames^geoname_id^envelope_id")
    printf ("%s", "^name^asciiname^latitude^longitude")
    printf ("%s", "^fclass^fcode")
    printf ("%s", "^page_rank^date_from^date_until^comment")
    printf ("%s", "^country_code^cc2^country_name^continent_name")
    printf ("%s", "^adm1_code^adm1_name_utf^adm1_name_ascii")
    printf ("%s", "^adm2_code^adm2_name_utf^adm2_name_ascii")
    printf ("%s", "^adm3_code^adm4_code")
    printf ("%s", "^population^elevation^gtopo30")
    printf ("%s", "^timezone^gmt_offset^dst_offset^raw_offset^moddate")
    printf ("%s", "^city_code_list^city_name_list^city_detail_list^tvl_por_list")
    printf ("%s", "^state_code^location_type")
    printf ("%s", "^wiki_link")
    printf ("%s", "^alt_name_section")
	printf ("%s", "^wac^wac_name")
    printf ("%s", "\n")

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

    # Register the WAC associated to that country (e.g., 401 for 'AL'/Albania)
	if (through_date == "" && country_iso_code) {
		wac_by_ctry_code_list[country_iso_code] = world_area_code
	}

    # Register the WAC associated to that state (e.g., 51 for 'AL'/Alabama)
	if (through_date == "" && state_code) {
		wac_by_state_code_list[state_code] = world_area_code
	}

	# Register the WAC name
	wac_name_list[world_area_code] = wac_name

	# DEBUG
	# print ("WAC: " world_area_code "; country_code: " country_iso_code	\
	#	   "; state_code: " state_code) > error_stream
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
# Retrieve the World Area Code (WAC) for a given country or a given state
function getWorldAreaCode(myCountryCode, myStateCode, myCountryCodeAlt) {
	# If there is a WAC registered for the state code (as found in Geonames),
	# then the WAC is specified at the state level (like for US and CA states)
	world_area_code_for_state = wac_by_state_code_list[myStateCode]
	if (world_area_code_for_state) {
		return world_area_code_for_state
	}

	# Then, try to match the country code (as found in Geonames)
	world_area_code_for_ctry = wac_by_ctry_code_list[myCountryCode]
	if (world_area_code_for_ctry) {
		return world_area_code_for_ctry
	}

	# Then, try to match the alternate country code (as found in Geonames)
	world_area_code_for_ctry = wac_by_ctry_code_list[myCountryCodeAlt]
	if (world_area_code_for_ctry) {
		return world_area_code_for_ctry
	}

	# Then, try to match the country code (as found in Geonames)
	# with a WAC state code. For instance, Puerto Rico (PR) is a country
	# for Geonames, but a state (of the USA) for the US DOT WAC.
	world_area_code_for_state = wac_by_state_code_list[myCountryCode]
	if (world_area_code_for_state) {
		return world_area_code_for_state
	}
	
	# Then, try to match the alternate country code (as found in Geonames)
	# with a WAC state code. For instance, Puerto Rico (PR) is a country
	# for Geonames, but a state (of the USA) for the US DOT WAC.
	world_area_code_for_state = wac_by_state_code_list[myCountryCodeAlt]
	if (world_area_code_for_state) {
		return world_area_code_for_state
	}

	# A few specific rules. See for instance the issue #5 on Open Travel Data:
	# http://github.com/opentraveldata/opentraveldata/issues/5
	# The following countries should be mapped onto WAC #005, TT, USA:
	# * American Samoa, referenced under Geonames as AS
	# * Guam, referenced under Geonames as GU
	# * Northern Mariana Islands, referenced under Geonames as MP
	if (myCountryCode == "AS" || myCountryCode == "GU" || myCountryCode == "MP"){
		world_area_code_for_ctry = 5
		return world_area_code_for_ctry
	}
	# For some reason, the US DOT has got the wrong country code for Kosovo
	# See also https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#XK
	if (myCountryCode == "XK") {
		world_area_code_for_ctry = 494
		return world_area_code_for_ctry
	}

    # There is no WAC registered for either the state or country code
	#print ("[" awk_file "] !!!! Warning !!!! No World Area Code (WAC) can be" \
	#	   " found for either the state code ("	myStateCode				\
	#	   "), the country code (" myCountryCode						\
	#	   ") or the alternate country code (" myCountryCodeAlt			\
	#	   "). Line: " $0) > error_stream
}

##
# Retrieve the World Area Code (WAC) name for a given WAC
function getWorldAreaCodeName(myWAC) {
	if (myWAC) {
		wac_name = wac_name_list[myWAC]
		return wac_name
	}
}

##
#
function printAltNameSection(myAltNameSection) {
    # Archive the full line and the separator
    full_line = $0
    fs_org = FS

    # Change the separator in order to parse the section of alternate names
    FS = "|"
    $0 = myAltNameSection

    # Print the alternate names
    printf ("%s", "^")
    for (fld = 1; fld <= NF; fld++) {
		printf ("%s", $fld)

		# Separate the details of a given alternate name with the equal (=) sign
		# and the alternate name blocks with the pipe (|) sign.
		if (fld != NF) {

			idx = fld % 3
			if (idx == 0) {
				printf ("%s", "=")

			} else {
				printf ("%s", "|")
			}
		}
    }

    # Restore the initial separator (and full line, if needed)
    FS = fs_org
    #$0 = full_line
}


##
# Aggregated content from OPTD, reference data and Geonames
#
# Sample input lines:
#
# # Both in Geonames and in reference data (56 fields)
# NCE-A-6299418^NCE^43.658411^7.215872^NCE^6299418^NCE^LFMN^^6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.66272^7.20787^FR^^France^Europe^S^AIRP^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^Nice Airport,...^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^NCE^A^Nice^Cote D Azur^Nice^Nice FR Cote D Azur^Nice^NCE^Y^^FR^EUROP^ITC2^FR052^43.6653^7.215^^Y^en|Nice Côte d'Azur International Airport|s
#
# # In reference data (24 fields)
# XIT-R-0^XIT^51.42^12.42^LEJ^^XIT^R^Leipzig Rail^Leipzig Hbf Rail Stn^Leipzig Rail^Leipzig HALLE DE Leipzig Hbf R^Leipzig HALLE^LEJ^Y^^DE^EUROP^ITC2^DE040^51.3^12.3333^^N
#
# # In Geonames (38 fields)
# SQX-CA-7731508^SQX^-26.7816^-53.5035^SQX^7731508^SQX^SSOE^^7731508^São Miguel do Oeste Airport^Sao Miguel do Oeste Airport^-26.7816^-53.5035^BR^^Brazil^South America^S^AIRP^26^Santa Catarina^Santa Catarina^4204905^Descanso^Descanso^^^0^^655^America/Sao_Paulo^-2.0^-3.0^-3.0^2012-08-03^SQX,SSOE^^
#
/^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})\^([A-Z]{3})\^([0-9.+-]{0,12})\^/ {

    if (NF == 57) {
		####
		## Both in Geonames and in reference data
		####

		# Primary key
		pk = $1

		# Location type (extracted from the primary key)
		location_type = gensub ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})$", \
								"\\2", "g", pk)

		# Geonames ID
		geonames_id = gensub ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})$", \
							  "\\3",	"g", pk)

		# IATA code
		iata_code = $2

		# PageRank value
		page_rank = getPageRank(iata_code, location_type)

		# Is in Geonames?
		geonameID = $10
		isGeonames = "Y"
		if (geonameID == "0" || geonameID == "") {
			isGeonames = "N"
		}

		# Sanity check
		if (geonames_id != geonameID) {
			print ("[" awk_file "] !!!! Warning !!!! The two Geonames ID" \
				   " are not equal: pk="	pk " and " geonameID		\
				   " for the record #" FNR ":" $0)						\
				> error_stream
		}

		# IATA code ^ ICAO code ^ FAA ^ Is in Geonames ^ GeonameID ^ Validity ID
		printf ("%s", iata_code "^" $8 "^" $9 "^" isGeonames "^" geonameID "^")

		# ^ Name ^ ASCII name
		printf ("%s", "^" $11 "^" $12)

		# ^ Alternate names
		# printf ("%s", "^" $37)

		# ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("%s", "^" $3 "^" $4 "^" $19 "^" $20)

		# ^ PageRank value
		printf ("%s", "^" page_rank)

		# ^ Valid from date ^ Valid until date ^ Comment
		printf ("%s", "^" $6 "^^")

		# ^ Country code ^ Alt. country codes ^ Country name ^ Continent name
		country_code = $15
		country_code_alt = $16
		printf ("%s", "^" country_code "^" country_code_alt "^" $17 "^" $18)

		# ^ Admin1 code ^ Admin1 UTF8 name ^ Admin1 ASCII name
		printf ("%s", "^" $21 "^" $22 "^" $23)
		# ^ Admin2 code ^ Admin2 UTF8 name ^ Admin2 ASCII name
		printf ("%s", "^" $24 "^" $25 "^" $26)
		# ^ Admin3 code ^ Admin4 code
		printf ("%s", "^" $27 "^" $28)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^" $29 "^" $30 "^" $31)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" $32 "^" $33 "^" $34 "^" $35)

		# ^ Modification date
		printf ("%s", "^" $36)

		# ^ City code ^ City UTF8 name ^ City ASCII name ^ Travel-related list
		# Notes:
		#   1. The actual name values are added by the add_city_name.awk script.
		#   2. The city code is the one from the file of best known POR,
		#      not the one from reference data (as it is sometimes inaccurate).
		printf ("%s", "^" $5 "^"  "^"  "^" )

		# ^ State code
		state_code = $48
		printf ("%s", "^" state_code)

		# ^ Location type ^ Wiki link
		printf ("%s", "^" location_type "^" $38)

		##
		# ^ Section of alternate names
		altname_section = $57
		printAltNameSection(altname_section)

		# ^ US DOT World Area Code (WAC) ^ WAC name
		world_area_code = getWorldAreaCode(country_code, state_code,	\
										   country_code_alt)
		wac_name = getWorldAreaCodeName(world_area_code)
		printf ("%s", "^" world_area_code "^" wac_name)

		# End of line
		printf ("%s", "\n")

		# ----
		# From OPTD-POR ($1 - $6)
		# (1) NCE-A-6299418 ^ (2) NCE ^ (3) 43.658411 ^ (4) 7.215872 ^
		# (5) NCE ^ (6) 6299418 ^

		# From Geonames ($7 - $38)
		# (7) NCE ^ (8) LFMN ^ (9)  ^ (10) 6299418 ^
		# (11) Nice Côte d'Azur International Airport ^
		# (12) Nice Cote d'Azur International Airport ^
		# (13) 43.66272 ^ (14) 7.20787 ^
		# (15) FR ^ (16)  ^ (17) France ^ (18) Europe ^ (19) S ^ (20) AIRP ^
		# (21) B8 ^ (22) Provence-Alpes-Côte d'Azur ^
		# (23) Provence-Alpes-Cote d'Azur ^
		# (24) 06 ^ (25) Département des Alpes-Maritimes ^ 
		# (26) Departement des Alpes-Maritimes ^
		# (27) 062 ^ (28) 06088 ^
		# (29) 0 ^ (30) 3 ^ (31) -9999
		# (32) Europe/Paris ^ (33) 1.0 ^ (34) 2.0 ^ (35) 1.0 ^
		# (36) 2012-06-30 ^
		# (37) Aeroport de Nice Cote d'Azur, ...,Niza Aeropuerto ^
		# (38) http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport ^

		# From reference data ($39 - $56)
		# (39) NCE ^ (40) CA ^ (41) NICE ^ (42) COTE D AZUR ^ (43) NICE ^
		# (44) NICE/FR:COTE D AZUR ^ (45) NICE ^ (46) NCE ^
		# (47) Y ^ (48)  ^ (49) FR ^ (50) EUROP ^ (51) ITC2 ^ (52) FR052 ^
		# (53) 43.6653 ^ (54) 7.215 ^ (55)  ^ (56) Y ^

		# From Geonames alternate names ($57)
		# (57) en | Nice Airport | s |
		#      en | Nice Côte d'Azur International Airport | 

    } else if (NF == 24) {
		####
		## Not in Geonames
		####

		# Primary key
		pk = $1

		# Location type (extracted from the primary key)
		location_type = gensub ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})$", \
								"\\2", "g", pk)

		# Geonames ID
		geonames_id = gensub ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})$", \
							  "\\3", "g", pk)

		# IATA code
		iata_code = $2

		# PageRank value
		page_rank = getPageRank(iata_code, location_type)

		# Is in Geonames?
		geonameID = "0"
		isGeonames = "N"

		# IATA code ^ ICAO code ^ FAA ^ Is in Geonames ^ GeonameID ^ Validity ID
		printf ("%s", iata_code "^^^" isGeonames "^" geonameID "^")

		# ^ Name ^ ASCII name
		printf ("%s", "^" $12 "^" $12)

		# ^ Alternate names
		# printf ("%s", "^")

		# ^ Latitude ^ Longitude
		printf ("%s", "^" $3 "^" $4)

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
			printf ("%s", "^S^AIRP")
		} else if (is_heliport != 0) {
			# The POR is an heliport
			printf ("%s", "^S^AIRH")
		} else if (is_railway != 0) {
			# The POR is a railway station
			printf ("%s", "^S^RSTN")
		} else if (is_bus != 0) {
			# The POR is a bus station
			printf ("%s", "^S^BUSTN")
		} else if (is_port != 0) {
			# The POR is a (maritime) port
			printf ("%s", "^S^PRT")
		} else if (is_ground != 0) {
			# The POR is a ground station
			printf ("%s", "^S^XXXX")
		} else if (is_city != 0) {
			# The POR is (only) a city
			printf ("%s", "^P^PPLC")
		} else if (is_offpoint != 0) {
			# The POR is an off-line point, which could be
			# a bus/railway station, or even a city/village.
			printf ("%s", "^X^XXXX")
		} else {
			# The location type can not be determined
			printf ("%s", "^Z^ZZZZ")
			print ("[" awk_file "] !!!! Warning !!!! The location type " \
				   "cannot be determined for the record #" FNR ":")		\
				> error_stream
			print ($0) > error_stream
		}

		# ^ PageRank value
		printf ("%s", "^" page_rank)

		# ^ Valid from date ^ Valid until date ^ Comment
		printf ("%s", "^" $6 "^^")

		# ^ Country code ^ Alt. country codes ^ Country name ^ Continent name
		country_code = $17
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
		printf ("%s", "^" country_code "^^" country_name "^" continent_name)

		# ^ Admin1 code ^ Admin1 UTF8 name ^ Admin1 ASCII name
		printf ("%s", "^^^")
		# ^ Admin2 code ^ Admin2 UTF8 name ^ Admin2 ASCII name
		printf ("%s", "^^^")
		# ^ Admin3 code ^ Admin4 code
		printf ("%s", "^^")

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^^^")

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" time_zone_id "^^^")

		# ^ Modification date
		printf ("%s", "^" today_date)

		# ^ City code ^ City UTF8 name ^ City ASCII name ^ Travel-related list
		# Notes:
		#   1. The actual name values are added by the add_city_name.awk script.
		#   2. The city code is the one from the file of best known POR,
		#      not the one from reference data (as it is sometimes inaccurate).
		printf ("%s", "^" $5 "^"  "^"  "^" )

		# ^ State code
		state_code = $16
		printf ("%s", "^" state_code)

		# ^ Location type
		printf ("%s", "^" location_type)

		# ^ Wiki link (empty here)
		printf ("%s", "^")

		# ^ Section of alternate names (empty here)
		printf ("%s", "^")

		# ^ US DOT World Area Code (WAC) ^ WAC name
		world_area_code = getWorldAreaCode(country_code, state_code,	\
										   country_code_alt)
		wac_name = getWorldAreaCodeName(world_area_code)
		printf ("%s", "^" world_area_code "^" wac_name)

		# End of line
		printf ("%s", "\n")

		# ----
		# From OPTD-POR ($1 - $6)
		# (1) HDQ-CA-0 ^ (2) HDQ ^ (3) <empty lat.> ^ (4)  ^ <empty long.>
		# (5) HDQ ^ (6)  ^

		# From reference data ($7 - $24)
		# (7) HDQ ^ (8) CA ^ (9) Headquarters ^ (10) ^
		# (11) Headquarters ^ (12) Headquarters ZZ ^
		# (13) Headquarters ^
		# (14) HDQ ^ (15) Y ^ (16) ^ (17) ZZ ^ (18) NONE ^ (19) ITC2 ^
		# (20) ZZ205 ^ (21) 0.00028 ^ (22) -0.00028 ^ (23)  ^ (24) Y

    } else if (NF == 39) {
		####
		## Not in reference data
		####

		# Primary key
		pk = $1

		# Location type (extracted from the primary key)
		location_type = gensub ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})$", \
								"\\2", "g", pk)

		# Geonames ID
		geonames_id = gensub ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})$", \
							  "\\3", "g", pk)

		# IATA code
		iata_code = $2

		# PageRank value
		page_rank = getPageRank(iata_code, location_type)

		# Is in Geonames?
		geonameID = $10
		isGeonames = "Y"
		if (geonameID == "0" || geonameID == "") {
			isGeonames = "N"
		}

		# IATA code ^ ICAO code ^ FAA ^ Is in Geonames ^ GeonameID ^ Validity ID
		printf ("%s", iata_code "^" $8 "^" $9 "^" isGeonames "^" geonameID "^")

		# ^ Name ^ ASCII name
		printf ("%s", "^" $11 "^" $12)

		# ^ Alternate names
		# printf ("%s", "^" $37)

		# ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("%s", "^" $3 "^" $4 "^" $19 "^" $20)

		# ^ PageRank value
		printf ("%s", "^" page_rank)

		# ^ Valid from date ^ Valid until date ^ Comment
		printf ("%s", "^" $6 "^^")

		# ^ Country code ^ Alt. country codes ^ Country name ^ Continent name
		country_code = $15
		country_code_alt = $16
		printf ("%s", "^" country_code "^" country_code_alt "^" $17 "^" $18)

		# ^ Admin1 code ^ Admin1 UTF8 name ^ Admin1 ASCII name
		printf ("%s", "^" $21 "^" $22 "^" $23)
		# ^ Admin2 code ^ Admin2 UTF8 name ^ Admin2 ASCII name
		printf ("%s", "^" $24 "^" $25 "^" $26)
		# ^ Admin3 code ^ Admin4 code
		printf ("%s", "^" $27 "^" $28)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^" $29 "^" $30 "^" $31)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" $32 "^" $33 "^" $34 "^" $35)

		# ^ Modification date
		printf ("%s", "^" $36)

		# ^ City code ^ City UTF8 name ^ City ASCII name ^ Travel-related list
		# Notes:
		#   1. The actual name values are added by the add_city_name.awk script.
		#   2. The city code is the one from the file of best known POR,
		#      not the one from reference data (as it is sometimes inaccurate).
		printf ("%s", "^" $5 "^"  "^"  "^" )

		# ^ State code
		state_code = $21
		printf ("%s", "^" state_code)

		#  ^ Location type
		printf ("%s", "^" location_type)

		# ^ Wiki link (potentially empty)
		printf ("%s", "^" $38)

		##
		# ^ Section of alternate names
		altname_section = $39
		printAltNameSection(altname_section)

		# ^ US DOT World Area Code (WAC) ^ WAC name
		world_area_code = getWorldAreaCode(country_code, state_code, \
										   country_code_alt)
		wac_name = getWorldAreaCodeName(world_area_code)
		printf ("%s", "^" world_area_code "^" wac_name)

		# End of line
		printf ("%s", "\n")

		# ----
		# From OPTD-POR ($1 - $6)
		# (1) SQX-CA-7731508 ^ (2) SQX ^ (3) -26.7816 ^ (4) -53.5035 ^ 
		# (5) SQX ^ (6) 7731508 ^

		# From Geonames ($7 - $39)
		# (7) SQX ^ (8) SSOE ^ (9)  ^ (10) 7731508 ^
		# (11) São Miguel do Oeste Airport ^
		# (12) Sao Miguel do Oeste Airport ^ (13) -26.7816 ^ (14) -53.5035 ^
		# (15) BR ^ (16)  ^ (17) Brazil ^ (18) South America ^
		# (19) S ^ (20) AIRP ^
		# (21) 26 ^ (22) Santa Catarina ^ (23) Santa Catarina ^
		# (24) 4204905 ^ (25) Descanso ^ (26) Descanso ^ (27)  ^ (28)  ^
		# (29) 0 ^ (30)  ^ (31) 655 ^ (32) America/Sao_Paulo ^
		# (33) -2.0 ^ (34) -3.0 ^ (35) -3.0 ^ (36) 2011-03-18 ^ (37) SQX,SSOE ^
		# (38)  ^ (39)  

    } else if (NF == 6) {
		####
		## Neither in Geonames nor in reference data
		####
		# Location type (hard-coded to be an airport)
		location_type = "A"

		# Geonames ID
		geonames_id = "0"

		# IATA code
		iata_code = $1

		# PageRank value
		page_rank = getPageRank(iata_code, location_type)

		# Is in Geonames?
		geonameID = "0"
		isGeonames = "N"

		# IATA code ^ ICAO code ^ FAA ^ Is in Geonames ^ GeonameID ^ Validity ID
		printf ("%s", iata_code "^^^" isGeonames "^" geonameID "^") \
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
		printf ("%s", "^" $6 "^^") > non_optd_por_file

		# ^ Country code ^ Alt. country codes ^ Country name
		printf ("%s", "^" "ZZ" "^" "No country") > non_optd_por_file

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

		# ^ State code
		printf ("%s", "^" ) > non_optd_por_file

		#  ^ Location type (the default, i.e., city and airport)
		printf ("%s", "^CA") > non_optd_por_file

		#  ^ Wiki link (empty here)
		printf ("%s", "^") > non_optd_por_file

		#  ^ Section of alternate names  (empty here)
		printf ("%s", "^") > non_optd_por_file

		# ^ US DOT World Area Code (WAC) ^ WAC name (empty here)
		printf ("%s", "^^" ) > non_optd_por_file

		# End of line
		printf ("%s", "\n") > non_optd_por_file

		# ----
		# From OPTD-POR ($1 - $6)
		# (1) SZD-C ^ (2) SZD ^ (3) 53.394256 ^ (4) -1.388486 ^ (5) SZD ^ (6)  

		#
		unknown_idx++

    } else {
		print ("[" awk_file "] !!!! Error for row #" FNR ", having " NF \
			   " fields: " $0) > error_stream
    }

}

END {
    # DEBUG
    # print ("Generated: " pr_date_generation ", valid from: " pr_date_from \
    #	   " to " pr_date_to) > error_stream
}
