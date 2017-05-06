##
# That AWK script extracts the POR codes, with their state details,
# for a given country.
# It uses the following data sources:
#  * OPTD-maintained lists of:
#    * POR:             optd_por_public.csv
#    * Country states:  optd_country_states.csv (that file has then to be modified)
#
# The state codes are referenced by the ISO 3166 standard
# (http://en.wikipedia.org/wiki/ISO_3166-2):
# * United States:
#  * http://en.wikipedia.org/wiki/ISO_3166-2:US
#  * http://en.wikipedia.org/wiki/List_of_states_and_territories_of_the_United_States
#  * http://en.wikipedia.org/wiki/List_of_U.S._state_abbreviations
# * Argentina:
#  * http://en.wikipedia.org/wiki/ISO_3166-2:AR
#  * http://en.wikipedia.org/wiki/Provinces_of_Argentina
# * Australia:
#  * http://en.wikipedia.org/wiki/ISO_3166-2:AU
#  * http://en.wikipedia.org/wiki/States_and_territories_of_Australia
# * Brazil:
#  * http://en.wikipedia.org/wiki/ISO_3166-2:BR
#  * http://en.wikipedia.org/wiki/States_of_Brazil
# * Canada:
#  * http://en.wikipedia.org/wiki/ISO_3166-2:CA
#  * http://en.wikipedia.org/wiki/Provinces_and_territories_of_Canada
# * India:
#  * http://en.wikipedia.org/wiki/ISO_3166-2:IN
#  * http://en.wikipedia.org/wiki/States_and_union_territories_of_India
#
# Sample output lines:
# AR^3430657^14^Misiones Province^MN
# US^5332921^CA^California^CA

##
# Helper functions
@include "awklib/geo_lib.awk"


##
#
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "extract_state_details.awk"

	# Lists
	delete ctry_state_list

    #
    today_date = mktime ("YYYY-MM-DD")
    unknown_idx = 1

	# Country code
	if (!tgt_ctry_code) {
		tgt_ctry_code = "AR"
	}
	
	# Log level
	if (!log_level) {
		log_level = 3
	}
	
    # Fields
	K_IATA_CODE = 1
	K_GEO_ID = 5
    K_CTRY_CODE = 17
    K_ADM1_CODE = 21
    K_ADM1_NAME = 22
    K_STATE_CODE = 41
    K_LOC_TYPE = 42

    # Separators
    K_1ST_SEP = "^"
    K_2ND_SEP = "="
    K_3RD_SEP = "|"

	# Header
	hdr_line = "ctry_code^geo_id^adm1_code^adm1_name^abbr"
	print (hdr_line)
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
# OPTD-maintained list of POR
#
# Sample input and output lines:
# iata_code^icao_code^faa_code^is_geonames^geoname_id^valid_id^name^asciiname^latitude^longitude^fclass^fcode^page_rank^date_from^date_until^comment^country_code^cc2^country_name^continent_name^adm1_code^adm1_name_utf^adm1_name_ascii^adm2_code^adm2_name_utf^adm2_name_ascii^adm3_code^adm4_code^population^elevation^gtopo30^timezone^gmt_offset^dst_offset^raw_offset^moddate^city_code^city_name_utf^city_name_ascii^tvl_por_list^state_code^location_type^wiki_link^alt_name_section^wac^wac_name
#
# IEV^UKKK^^Y^6300960^^Kyiv Zhuliany International Airport^Kyiv Zhuliany International Airport^50.401694^30.449697^S^AIRP^0.0240196752049^^^^UA^^Ukraine^Europe^^^^^^^^^0^178^174^Europe/Kiev^2.0^3.0^2.0^2012-06-03^IEV^^^^^488^Ukraine^A^http://en.wikipedia.org/wiki/Kyiv_Zhuliany_International_Airport^en|Kyiv Zhuliany International Airport|=en|Kyiv International Airport|=en|Kyiv Airport|s=en|Kiev International Airport|=uk|Міжнародний аеропорт «Київ» (Жуляни)|=ru|Аэропорт «Киев» (Жуляны)|=ru|Международный аеропорт «Киев» (Жуляни)|
#
# NCE^LFMN^^Y^6299418^^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.658411^7.215872^S^AIRP^0.157408761216^^^^FR^^France^Europe^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^NCE^^^^^427^France^CA^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de|Flughafen Nizza|=en|Nice Côte d'Azur International Airport|=es|Niza Aeropuerto|ps=fr|Aéroport de Nice Côte d'Azur|=en|Nice Airport|s
#
# RDU^KRDU^^Y^4487056^^Raleigh-Durham International Airport^Raleigh-Durham International Airport^35.87946^-78.7871^S^AIRP^0.0818187017848^^^^US^^United States^North America^NC^North Carolina^North Carolina^183^Wake County^Wake County^^^0^126^124^America/New_York^-5.0^-4.0^-5.0^2011-12-11^RDU|C|4464368=RDU|C|4487042^Durham=Raleigh^Durham=Raleigh^^NC^36^North Carolina^A^http://en.wikipedia.org/wiki/Raleigh%E2%80%93Durham_International_Airport^
#
/^[A-Z0-9]{3}\^[A-Z0-9]{0,4}\^[A-Z0-9]{0,4}\^/{
    # ISO 2-character code
    por_ctry_code = $K_CTRY_CODE
	if (por_ctry_code == tgt_ctry_code) {

		# IATA code
		iata_code = $K_IATA_CODE

		# Location type
		loc_type = $K_LOC_TYPE
	
		# Geonames ID
		geo_id = $K_GEO_ID
	
		# Administrative level 1 code
		adm1_code = $K_ADM1_CODE

		# Administrative level 1 name
		adm1_utf_name = $K_ADM1_NAME

		# State code
		state_code = $K_STATE_CODE

		#
		result_line = por_ctry_code "^" iata_code "^" loc_type "^" geo_id
		result_line = result_line  "^" adm1_code "^" adm1_utf_name "^" state_code

		#
		print (result_line)
	}
}


##
#
ENDFILE {
    #
}

##
#
END {
    #
}
