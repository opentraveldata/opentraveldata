
##
# Helper functions
#@include "awklib/geo_lib.awk"


##
#
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "extract_por_unlc.awk"

    # Header
    hdr_line = "unlc^latitude^longitude"
    #print (hdr_line)

    #
    today_date = mktime ("YYYY-MM-DD")
    nb_of_geo_por = 0
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

    # Coordinates
    geo_lat = $7
    geo_lon = $8
    
    # UN/LOCODE
    unlc_list = $34

    if (unlc_list != "") {
	# Browse the list of UN/LOCODE codes
	delete unlc_array
	split (unlc_list, unlc_array, "=")
	for (unlc_idx in unlc_array) {
	    unlc_str = unlc_array[unlc_idx]
	    unlc = substr (unlc_str, 1, 5)
	    print (unlc FS geo_lat FS geo_lon)
	}
    }
}

