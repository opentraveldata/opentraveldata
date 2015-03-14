##
# That AWK script derives the list of active POR (point of reference) entries
# for any given date, from the OPTD-maintained data file of POR
# (i.e., ../opentraveldata/optd_por_public.csv).
#

##
# Helper functions
@include "awklib/geo_lib.awk"

##
#
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "extract_por_for_a_date.awk"

    # Fields
    K_POR_CDE = 1
    K_POR_GID = 5
    K_NME_UTF = 7
    K_NME_ASC = 8
    K_SVD_CTY_LST = 37
    K_CTY_UTF_LST = 38
    K_CTY_ASC_LST = 39
    K_TVL_LST = 40
    K_LOC_TYP = 44

    # Separators
    K_1ST_SEP = "^"
    K_2ND_SEP = "="
    K_3RD_SEP = "|"

    # Header
    hdr_line = "iata_code^icao_code^faa_code^is_geonames^geoname_id^envelope_id"
    hdr_line = hdr_line "^name^asciiname^latitude^longitude"
    hdr_line = hdr_line "^fclass^fcode^page_rank^date_from^date_until^comment"
    hdr_line = hdr_line "^country_code^cc2^country_name^continent_name"
    hdr_line = hdr_line "^adm1_code^adm1_name_utf^adm1_name_ascii"
    hdr_line = hdr_line "^adm2_code^adm2_name_utf^adm2_name_ascii"
    hdr_line = hdr_line "^adm3_code^adm4_code"
    hdr_line = hdr_line "^population^elevation^gtopo30"
    hdr_line = hdr_line "^timezone^gmt_offset^dst_offset^raw_offset^moddate"
    hdr_line = hdr_line "^city_code_list^city_name_list^city_detail_list"
    hdr_line = hdr_line	"^tvl_por_list"
    hdr_line = hdr_line	"^state_code^wac^wac_name^location_type"
    hdr_line = hdr_line "^wiki_link^alt_name_section"

    print (hdr_line)
}

##
# OPTD-maintained list of POR
#
# Sample input and output lines:
# iata_code^icao_code^faa_code^is_geonames^geoname_id^valid_id^name^asciiname^latitude^longitude^fclass^fcode^page_rank^date_from^date_until^comment^country_code^cc2^country_name^continent_name^adm1_code^adm1_name_utf^adm1_name_ascii^adm2_code^adm2_name_utf^adm2_name_ascii^adm3_code^adm4_code^population^elevation^gtopo30^timezone^gmt_offset^dst_offset^raw_offset^moddate^city_code^city_name_utf^city_name_ascii^tvl_por_list^state_code^wac^wac_name^location_type^wiki_link^alt_name_section
#
# IEV^UKKK^^Y^6300960^^Kyiv Zhuliany International Airport^Kyiv Zhuliany International Airport^50.401694^30.449697^S^AIRP^0.0240196752049^^^^UA^^Ukraine^Europe^^^^^^^^^0^178^174^Europe/Kiev^2.0^3.0^2.0^2012-06-03^IEV^^^^^488^Ukraine^A^http://en.wikipedia.org/wiki/Kyiv_Zhuliany_International_Airport^en|Kyiv Zhuliany International Airport|=en|Kyiv International Airport|=en|Kyiv Airport|s=en|Kiev International Airport|=uk|Міжнародний аеропорт «Київ» (Жуляни)|=ru|Аэропорт «Киев» (Жуляны)|=ru|Международный аеропорт «Киев» (Жуляни)|
#
# NCE^LFMN^^Y^6299418^^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.658411^7.215872^S^AIRP^0.157408761216^^^^FR^^France^Europe^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^NCE^^^^^427^France^CA^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de|Flughafen Nizza|=en|Nice Côte d'Azur International Airport|=es|Niza Aeropuerto|ps=fr|Aéroport de Nice Côte d'Azur|=en|Nice Airport|s
#
# RDU^KRDU^^Y^4487056^^Raleigh-Durham International Airport^Raleigh-Durham International Airport^35.87946^-78.7871^S^AIRP^0.0818187017848^^^^US^^United States^North America^NC^North Carolina^North Carolina^183^Wake County^Wake County^^^0^126^124^America/New_York^-5.0^-4.0^-5.0^2011-12-11^RDU|C|4464368=RDU|C|4487042^Durham=Raleigh^Durham=Raleigh^^NC^36^North Carolina^A^http://en.wikipedia.org/wiki/Raleigh%E2%80%93Durham_International_Airport^
#
/^([A-Z0-9]{3})\^([A-Z0-9]{0,4})\^([A-Z0-9]{0,4})\^/{
    # IATA code of the point of reference (POR) itself
    iata_code = $K_POR_CDE

    # Geonames ID
    geoname_id = $K_POR_GID

    # IATA location type
    location_type = $K_LOC_TYP

    # UTF8 name of the POR itself
    name_utf = $K_NME_UTF

    # ASCII name of the POR itself
    name_ascii = $K_NME_ASC

    # Served city IATA code
    served_city_code_list = $K_SVD_CTY_LST

    # IATA code of the city served by that POR
    city_iata_code_list = $K_SVD_CTY_LST

    # DEBUG
    print $0
}

#
ENDFILE {
    # DEBUG
    #displayLists()
}

