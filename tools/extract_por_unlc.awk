
##
# Helper functions
#@include "awklib/geo_lib.awk"


##
#
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "extract_por_unlc.awk"

    # Lists
    delete ctry_iso31662code_list
    delete ctry_iso31662name_list
    delete ctry_state_list

    # Header (the master header is in the extract_por_unlc.sh script)
    hdr_line = "unlocode^latitude^longitude^geonames_id"
    hdr_line = hdr_line "^iso31662_code^iso31662_name"
    hdr_line = hdr_line "^feat_class^feat_code"
    #print (hdr_line)

    #
    today_date = mktime ("YYYY-MM-DD")
    nb_of_geo_por = 0
}


##
# File of country subdivisions (optd_country_states.csv)
#
# As Geonames have their own country subdivision encoding (sometimes, FIPS,
# sometimes ISO 3166-2), OPTD have to maintain a mapping between those
# Geonames country subdivion codes and ISO 3166-2 codes. Those mappings
# are manually curated in the optd_country_states.csv (subsidiary) input file.
# Sample lines:
# ctry_code^geo_id^adm1_code^name_en^iso31662^abbr
# BR^3455077^18^Paraná^PR^PR
# AU^2147291^06^Tasmania^TAS^TAS
# US^5481136^NM^New Mexico^NM^NM
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
# Geonames-derived data dump (dump_from_geonames.csv)
#
# Sample input lines (truncated):
#
# iata_code^icao_code^faac_code^geonameid^name^asciiname^latitude^longitude^country_code^cc2^country_name^continent_name^fclass^fcode^adm1_code^adm1_name_utf^adm1_name_ascii^adm2_code^adm2_name_utf^adm2_name_ascii^adm3^adm4^population^elevation^gtopo30^timezone^GMT_offset^DST_offset^raw_offset^moddate^alternatenames^wiki_link^altname_section^unlc_list
# ^^^3039181^Santa Coloma^Santa Coloma^42.49454^1.49897^AD^^Andorra^Europe^P^PPL^07^Andorra la Vella^Andorra la Vella^^^^^^0^^978^Europe/Andorra^1.0^2.0^1.0^2014-11-05^Santa Coloma^http://en.wikipedia.org/wiki/Santa_Coloma_d%27Andorra^|Santa Coloma|^ADSCO|
#
#/^([_A-Z]{3,4}|)\^([A-Z0-9]{4}|)\^[A-Z0-9]{0,4}\^[0-9]{1,15}\^.*\^[0-9.+-]{0,16}\^[0-9.+-]{0,16}\^[A-Z]{2}\^.*\^([0-9]{4}-[0-9]{2}-[0-9]{2}|)\^/ {
/^([_A-Z0-9]{3,4}|)\^/ {
    #
    nb_of_geo_por++

    # Geonames ID
    geonames_id = $4
    
    # Coordinates
    geo_lat = $7
    geo_lon = $8
    
    # Geonames feature class and code
    feat_class = $13
    feat_code = $14

    # Country code
    country_code = $9

    # Administrative level 1 code
    adm1_code = $15

    # Country subdivision details
    iso31662_code = ctry_iso31662code_list[country_code][adm1_code]
    iso31662_name = ctry_iso31662name_list[country_code][adm1_code]

    # UN/LOCODE
    unlc_list = $34

    # DEBUG
    unlc_dbg = "" # "VNOCL"
    if (unlc_dbg != "" && match(unlc_list, unlc_dbg)) {
	print ("[" awk_file "][" unlc_dbg "] geoid=" geonames_id	\
	       ", feat=" feat_class "-" feat_code ", ctry=" country_code \
	       ", adm1=" adm1_code ", iso3166=" iso31662_code "/" iso31662_name \
	       ", unlc_list=" unlc_list) > error_stream
    }

    if (unlc_list != "") {
	# Browse the list of UN/LOCODE codes
	delete unlc_array
	split (unlc_list, unlc_array, "=")
	for (unlc_idx in unlc_array) {
	    # Extract the UN/LOCODE
	    unlc_str = unlc_array[unlc_idx]
	    unlc = substr (unlc_str, 1, 5)

	    # Assemble the output line
	    output_line = unlc FS geo_lat FS geo_lon FS geonames_id
	    output_line = output_line FS iso31662_code FS iso31662_name
	    output_line = output_line FS feat_class FS feat_code
	    
	    #
	    print (output_line)
	}
    }
}

