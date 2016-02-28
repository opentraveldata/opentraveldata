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
#    * Non-Geonames referential data:       optd_por_no_geonames.csv
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

	# Countries in which the state code is needed for now.
	# To be removed when no longer needed.
	ctry_w_state_list["US"] = 1; ctry_w_state_list["AU"] = 1
	ctry_w_state_list["BR"] = 1; ctry_w_state_list["AR"] = 1
	ctry_w_state_list["CA"] = 1

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
# # In Geonames (39 fields)
# CHI-C-4887398^CHI^41.85003^-87.65005^CHI^^CHI^^^4887398^Chicago^Chicago^41.85003^-87.65005^US^^United States^North America^P^PPLA2^IL^Illinois^Illinois^031^Cook County^Cook County^^^2695598^179^180^America/Chicago^-6.0^-5.0^-6.0^2014-10-27^Chicago^http://en.wikipedia.org/wiki/Chicago^en|Chicago|p
# NCE-A-6299418^NCE^43.658411^7.215872^NCE^^NCE^LFMN^^6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.66272^7.20787^FR^^France^Europe^S^AIRP^93^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^5^Europe/Paris^1.0^2.0^1.0^2016-02-18^Aéroport de Nice Côte d'Azur^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^en|Nice Côte d'Azur International Airport|p
# ORD-A-4887479^ORD^41.978603^-87.904842^CHI^^ORD^KORD^ORD^4887479^Chicago O'Hare International Airport^Chicago O'Hare International Airport^41.97959^-87.90446^US^^United States^North America^S^AIRP^IL^Illinois^Illinois^031^Cook County^Cook County^^^0^201^202^America/Chicago^-6.0^-5.0^-6.0^2014-04-21^Chicago O’Hare International Airport^http://en.wikipedia.org/wiki/O%27Hare_International_Airport^de|Flughafen Chicago O'Hare
#
# # Not in Geonames (6 fields)
# APE-CA-0^APE^-15.35^-75.17^APE^
# CGX-A-0^CGX^41.85^-87.6^CHI^
# ECC-O-0^ECC^40.78^-73.97^ECC^2013-07-01
#
/^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,12})\^[A-Z]{3}\^[0-9.+-]{0,16}\^[0-9.+-]{0,16}\^[A-Z,]{3,19}\^[0-9-]{0,10}\^/ {

    if (NF == 39) {
		####
		## In Geonames
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
		state_code = ""
		if (ctry_w_state_list[country_code] == 1) {
			state_code = $21
		}
		printf ("%s", "^" state_code)

		# ^ Location type ^ Wiki link
		printf ("%s", "^" location_type "^" $38)

		##
		# ^ Section of alternate names
		altname_section = $39
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

		# From Geonames alternate names ($39)
		# (39) en | Nice Airport | s |
		#      en | Nice Côte d'Azur International Airport | 

    } else if (NF == 6) {
		####
		## Not in Geonames.
		## We discard those POR here, as they are then added back through
		## the optd_por_no_geonames.csv file

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
