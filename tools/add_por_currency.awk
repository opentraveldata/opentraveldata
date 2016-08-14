##
# That AWK script is intended to be run just once, and adds the currency code
# to the no longer valid POR.
# It uses two sources:
#  * No longer valid POR:  optd_por_no_longer_valid.csv
#  * Country details:      optd_countries.csv
#
# Sample output lines:
# UNS^^^Y^8298981^1^Umnak Island Airport^Umnak Island Airport^53.38277^-167.88946^S^AIRP^^^1948-01-01^Air base closed after WWII, in 1947^US^^United States^North America^AK^Alska^Alaska^016^Aleutians West Census Area^Aleutians West Census Area^^^^^^America/Adak^-10.0^-9.0^-10.0^-1^UMB^Umnak Island^UMB|5877180|Umnak Island|Umnak Island^^AK^A^http://en.wikipedia.org/wiki/Cape_Field_at_Fort_Glenn^^1^Alaska^USD
#

##
# Helper functions
@include "awklib/geo_lib.awk"


##
#
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "add_por_currency.awk"

    # Lists
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
	hdr_line = hdr_line "^wac^wac_name^ccy_code"

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
# OPTD-maintained list of no longer valid POR (optd_por_no_longer_valid.csv)
#
# UNS^^^Y^8298981^1^Umnak Island Airport^Umnak Island Airport^53.38277^-167.88946^S^AIRP^^^1948-01-01^Air base closed after WWII, in 1947^US^^United States^North America^AK^Alska^Alaska^016^Aleutians West Census Area^Aleutians West Census Area^^^^^^America/Adak^-10.0^-9.0^-10.0^-1^UMB^Umnak Island^UMB|5877180|Umnak Island|Umnak Island^^AK^A^http://en.wikipedia.org/wiki/Cape_Field_at_Fort_Glenn^^1^Alaska^USD
#
/^(TODO:|)[A-Z]{3}\^/ {
    # Country code
    ctry_code = $17

	# Currency code
	ccy_code = ctry_ccy_list[ctry_code]

	# Add the currency code to the line
	print ($0 "^" ccy_code)
}


##
#
END {
    # DEBUG
}
