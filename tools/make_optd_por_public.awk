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
#    * Country details:                     optd_countries.csv
#    * Country states:                      optd_country_states.csv
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
# IEV^UKKK^^Y^6300960^^Kyiv Zhuliany International Airport^Kyiv Zhuliany International Airport^50.401694^30.449697^S^AIRP^0.0240196752049^^^^UA^^Ukraine^Europe^^^^^^^^^0^178^174^Europe/Kiev^2.0^3.0^2.0^2012-06-03^IEV^^^^^488^Ukraine^A^http://en.wikipedia.org/wiki/Kyiv_Zhuliany_International_Airport^en|Kyiv Zhuliany International Airport|=en|Kyiv International Airport|=en|Kyiv Airport|s=en|Kiev International Airport|=uk|Міжнародний аеропорт «Київ» (Жуляни)|=ru|Аэропорт «Киев» (Жуляны)|=ru|Международный аеропорт «Киев» (Жуляни)|^488^Ukraine^HRV^
# NCE^LFMN^^Y^6299418^^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.658411^7.215872^S^AIRP^0.157408761216^^^^FR^^France^Europe^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^NCE^^^^^427^France^CA^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de|Flughafen Nizza|=en|Nice Côte d'Azur International Airport|=es|Niza Aeropuerto|ps=fr|Aéroport de Nice Côte d'Azur|=en|Nice Airport|s^427^France^EUR^FRNCE|
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
	delete ctry_state_list
	delete ctry_ccy_list

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
	hdr_line = hdr_line "^wac^wac_name^ccy_code^unlc_list"

    print (hdr_line)

    #
    today_date = mktime ("YYYY-MM-DD")
    unknown_idx = 1

    # File of PageRank values
    pr_date_generation = ""
    pr_date_from = ""
    pr_date_to = ""

	# Log level
	if (!log_level) {
		log_level = 3
	}
	
    # Initialisation of the Geo library
    initGeoAwkLib(awk_file, error_stream, log_level)

    # Number of last registered Geonames POR entries
    nb_of_geo_por = 0
}


##
# OPTD-maintained list of POR (optd_por_best_known_so_far.csv)
#
# AYM-A-10943125^AYM^24.46682^54.6102^AUH,AYM^2014-05-01 (city code list, date)
# AYM-C-10227711^AYM^24.49784^54.60556^AYM^2014-05-01    (beginning date)
# ALV-C-3041563^ALV^42.50779^1.52109^ALV^ (2 lines in OPTD, 2 lines in Geonames)
# ALV-O-7730819^ALV^40.98^0.45^ALV^       (2 lines in OPTD, 2 lines in Geonames)
# ARN-A-2725346^ARN^59.651944^17.918611^STO^ (2 lines in OPTD, split from a
# ARN-R-8335457^ARN^59.649463^17.929^STO^     combined line, 1 line in Geonames)
# IES-CA-2846939^IES^51.3^13.28^IES^(1 combined line in OPTD,1 line in Geonames)
# IEV-A-6300960^IEV^50.401694^30.449697^IEV^(2 lines in OPTD, split from a
# IEV-C-703448^IEV^50.401694^30.449697^IEV^  combined line, 2 lines in Geonames)
# KBP-A-6300952^KBP^50.345^30.894722^IEV^   (1 line in OPTD, 1 line in Geonames)
# LHR-A-2647216^LHR^51.4775^-0.461389^LON^  (1 line in OPTD, 1 line in Geonames)
# LON-C-2643743^LON^51.5^-0.1667^LON^       (1 line in OPTD, 1 line in Geonames)
# NCE-CA-0^NCE^43.658411^7.215872^NCE^      (1 combined line in OPTD
#                                             2 lines in Geonames)
# ZZZ-A-8531905^ZZZ^-0.94238^114.8942^ZZZ^
#
/^[A-Z]{3}-[A-Z]{1,2}-[0-9]{1,15}\^[A-Z]{3}\^[0-9.+-]{0,16}\^[0-9.+-]{0,16}\^([A-Z]{3},?)+\^([0-9]{4}-[0-9]{2}-[0-9]{2}|)$/ {
    # Store the full line
    full_line = $0

    # Primary key (combination of IATA code, location type and Geonames ID)
    pk = $1

    # IATA code of the POR (it should be the same as the one of the primary key)
    iata_code2 = $2

	# Geographical coordinates
	por_lat = $3
	por_lon = $4

	# City code (list)
	srvd_city_code_list = $5

	# Beginning date
	beg_date = $6

    # Register the POR
	registerOPTDLine(pk, iata_code2, por_lat, por_lon, srvd_city_code_list, \
					 beg_date, full_line)
}

##
# Deprecated (there is no longer any header)
# Header of file of PageRank values (ref_airport_pageranked.csv).
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
# File of country states (optd_country_states.csv)
#
# Sample lines:
# ctry_code^geo_id^adm1_code^adm1_name^abbr
# BR^3455077^18^Paraná^PR
# AU^2147291^06^Tasmania^TAS
# US^5481136^NM^New Mexico^NM
/^[A-Z]{2}\^[0-9]+\^[0-9A-Z]+\^[A-Z].+\^[0-9A-Z]{1,3}$/ {
    # Country code
    country_code = $1

    # Geonames ID
    geo_id = $2

	# Administrative level 1 (adm1)
	adm1_code = $3
	adm1_name = $4

	# Alternate state code (abbreviation)
	state_code = $5

    # Register the relationship between the state code and the adm1 code
    ctry_state_list[country_code][adm1_code] = state_code
}


##
# File of time-zone IDs (optd_tz_light.csv)
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
# File of time-zones for a few POR (optd_por_tz.csv).
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
# File of country-continent mappings (optd_cont.csv).
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
# File of US DOT World Area Codes (WAC)(optd_usdot_wac.csv)
#
# Sample lines:
# WAC^WAC_SEQ_ID2^WAC_NAME^WORLD_AREA_NAME^COUNTRY_SHORT_NAME^COUNTRY_TYPE^CAPITAL^SOVEREIGNTY^COUNTRY_CODE_ISO^STATE_CODE^STATE_NAME^STATE_FIPS^START_DATE^THRU_DATE^COMMENTS^IS_LATEST^
# 1^101^Alaska^United States (Includes territories and possessions)^United States^Independent State in the World^Washington, DC^^US^AK^Alaska^02^1950-01-01^^An organized territory on May 11, 1912 and the 49th state of the U.S. on January 3, 1959.^1^
# 4^401^U.S. Virgin Islands^United States (Includes territories and possessions)^United States^Independent State in the World^Washington, DC^^US^VI^U.S. Virgin Islands^78^1990-01-01^^The U.S. took possession of the islands on March 31, 1917 and the territory was renamed the Virgin Islands of the United States^1^
# 427^42701^France^Europe^France^Independent State in the World^Paris^^FR^^^^1950-01-01^^Includes Corsica^1^
# 802^80201^Australia^Australasia and Oceania^Australia^Independent State in the World^Canberra^^AU^^^^1950-01-01^^Includes: Norfolk Island and Tasmania^1^
# 906^90601^British Columbia^Canada and Greenland^Canada^Independent State in the World^Ottawa^^CA^BC^British Columbia^^1950-01-01^^^1^
/^[0-9.]{1,3}\^[0-9.]{1,5}\^[A-Za-z,.()' \-]+\^[A-Za-z,.()' \-]+\^[A-Za-z,.()' \-]+\^(Dependency and Area of Special Sovereignty|Independent State in the World)\^[A-Za-z,.()' \-]*\^[A-Za-z0-9,.()' \-]*\^[A-Z]{0,2}\^[A-Z]{0,2}\^/ {
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
function generateAltNameSection(myAltNameSection) {
	# Returned string
	__pansString = ""

    # Archive the full line and the separator
    full_line = $0
    fs_org = FS

    # Change the separator in order to parse the section of alternate names
    FS = "|"
    $0 = myAltNameSection

    # Print the alternate names
	__pansString = __pansString "^"
    for (fld = 1; fld <= NF; fld++) {
		__pansString = __pansString $fld

		# Separate the details of a given alternate name with the equal (=) sign
		# and the alternate name blocks with the pipe (|) sign.
		if (fld != NF) {

			idx = fld % 3
			if (idx == 0) {
				__pansString = __pansString "="

			} else {
				__pansString = __pansString "|"
			}
		}
    }

    # Restore the initial separator (and full line, if needed)
    FS = fs_org
	#$0 = full_line

	# Return the string
	return __pansString
}


##
# Geonames-derived data dump (dump_from_geonames.csv)
#
# Sample input lines (truncated):
#
# iata_code^icao_code^faac_code^geonameid^name^asciiname^latitude^longitude^country_code^cc2^country_name^continent_name^fclass^fcode^adm1_code^adm1_name_utf^adm1_name_ascii^adm2_code^adm2_name_utf^adm2_name_ascii^adm3^adm4^population^elevation^gtopo30^timezone^GMT_offset^DST_offset^raw_offset^moddate^alternatenames^wiki_link^altname_section^unlc_list
# CHI^^^4887398^Chicago^Chicago^41.85003^-87.65005^US^^United States^North America^P^PPLA2^IL^Illinois^Illinois^031^Cook County^Cook County^^^2695598^179^180^America/Chicago^-6.0^-5.0^-6.0^2014-10-27^Chicago^http://en.wikipedia.org/wiki/Chicago^en|Chicago|p|es|Chicago|^USCHI|
# NCE^LFMN^^6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.66272^7.20787^FR^^France^Europe^S^AIRP^93^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^5^Europe/Paris^1.0^2.0^1.0^2016-02-18^Aéroport de Nice Côte d'Azur^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^en|Nice Côte d'Azur International Airport|p|es|Niza Aeropuerto|ps^FRNCE|
# ORD^KORD^ORD^4887479^Chicago O'Hare International Airport^Chicago O'Hare International Airport^41.97959^-87.90446^US^^United States^North America^S^AIRP^IL^Illinois^Illinois^031^Cook County^Cook County^^^0^201^202^America/Chicago^-6.0^-5.0^-6.0^2016-02-28^Aéroport international O'Hare de Chicago^http://en.wikipedia.org/wiki/O%27Hare_International_Airport^en|Chicago O'Hare International Airport|^USORD|
#
/^[A-Z]{3}\^([A-Z0-9]{4}|)\^[A-Z0-9]{0,4}\^[0-9]{1,15}\^.*\^[0-9.+-]{0,16}\^[0-9.+-]{0,16}\^[A-Z]{2}\^.*\^([0-9]{4}-[0-9]{2}-[0-9]{2}|)\^/ {
    #
    nb_of_geo_por++

	# Full line
	full_line = $0

	# The output format should be the one for OPTD, not Geonames' one
	geonames_format_flag = 0

	# Parse and dump the full details
	registerGeonamesLine(full_line, nb_of_geo_por, geonames_format_flag)
}

##
#
ENDFILE {
    # Finalisation of the Geo library
    finalizeFileGeoAwkLib()

    # DEBUG
    if (nb_of_geo_por == 0) {
		# displayLists()
    }
}

##
#
END {
    # Finalisation of the Geo library
    finalizeGeoAwkLib()

    # DEBUG
    # print ("Generated: " pr_date_generation ", valid from: " pr_date_from \
    #	   " to " pr_date_to) > error_stream
}
