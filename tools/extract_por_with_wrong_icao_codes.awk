##
# That AWK script re-formats the full details of POR (points of reference)
# derived from a few sources:
#  * OPTD-maintained lists of:
#    * Country-associated continents:       optd_cont.csv
#    * US DOT World Area Codes (WAC):       optd_usdot_wac.csv
#    * Country details:                     optd_countries.csv
#    * Country states:                      optd_country_states.csv
#  * Geonames:                              dump_from_geonames.csv
#
# Sample output lines (same format as for optd_por_public_all.csv):
#

##
# Helper functions
@include "awklib/geo_lib.awk"

##
#
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "extract_por_with_wrong_icao_codes.awk"

    # Lists
    ctry_name_list["ZZ"] = "Not relevant/available"
    ctry_cont_code_list["ZZ"] = "ZZ"
    ctry_cont_name_list["ZZ"] = "Not relevant/available"
    delete ctry_iso31662code_list
    delete ctry_iso31662name_list
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
    hdr_line = hdr_line "^city_code_list^city_name_list^city_detail_list"
    hdr_line = hdr_line "^tvl_por_list^iso31662"
    hdr_line = hdr_line "^location_type^wiki_link^alt_name_section"
    hdr_line = hdr_line "^wac^wac_name^ccy_code^unlc_list^uic_list"
    hdr_line = hdr_line "^geoname_lat^geoname_lon"

    print (hdr_line)

    #
    today_date = mktime ("YYYY-MM-DD")
    unknown_idx = 1

	# Log level
	if (!log_level) {
		log_level = 3
	}
	
    # Initialisation of the Geo library
    initGeoAwkLib(awk_file, error_stream, log_level)
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
# ctry_code^geo_id^adm1_code^name_en^iso31662^abbr
# BR^3455077^18^Paraná^PR^PR
# AU^2147291^06^Tasmania^TAS^TAS
# US^5481136^NM^New Mexico^NM^NM
/^[A-Z]{2}\^[0-9]+\^[0-9A-Z]+\^[^0-9]+\^[0-9A-Z]{1,3}\^[0-9A-Z]{1,3}$/ {
    # Country code
    country_code = $1

    # Geonames ID
    geo_id = $2

    # Administrative level 1 (adm1)
    adm1_code = $3

    # Country subdivision English name (used on the English Wikipedia)
    name_en = $4

    # ISO 3166-2 code
    iso31662_code = $5

    # Alternate state code (abbreviation)
    state_code = $6

    # Register the relationship between the adm1 code
    # and the country subdivion details (name, ISO 3166-2 code, abbr)
    ctry_iso31662code_list[country_code][adm1_code] = iso31662_code
    ctry_iso31662name_list[country_code][adm1_code] = name_en
    ctry_state_list[country_code][adm1_code] = state_code
}


##
# File of country-continent mappings (optd_cont.csv).
#
# Sample lines:
# country_code^country_name^continent_code^continent_name
# DE^Germany^EU^Europe
# AG^Antigua and Barbuda^NA^North America
# PE^Peru^SA^South America
/^[A-Z]{2}\^[A-Za-z,. \-]+\^[A-Z]{2}\^[A-Za-z ]+$/ {
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
    registerWACLists(world_area_code, through_date,		\
		     country_iso_code, state_code, wac_name)
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
# Geonames-derived data file (por_all_YYYYMMDD.csv)
# with all the POR having some non-IATA code (e.g., ICAO, FAAC, TC/ID,
# UIC, UN/LOCODE)
# iata_code^icao_code^faac_code^geonameid^name^asciiname^latitude^longitude^country_code^cc2^country_name^continent_name^fclass^fcode^adm1_code^adm1_name_utf^adm1_name_ascii^adm2_code^adm2_name_utf^adm2_name_ascii^adm3^adm4^population^elevation^gtopo30^timezone^GMT_offset^DST_offset^raw_offset^moddate^alternatenames^wiki_link^altname_section^unlc_list^uic_list
# ^MYX7^^3571565^Rudder Cut Cay Airport^Rudder Cut Cay Airport^23.88333^-76.25^BS^^Bahamas^North America^S^AIRF^36^Black Point^Black Point^^^^^^0^^7^America/Nassau^-5.0^-4.0^-5.0^2017-10-28^MYX7^https://en.wikipedia.org/wiki/Rudder_Cut_Cay_Airport^^^
#
/^\^[A-Z]{3}[0-9]{1}/ {
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

