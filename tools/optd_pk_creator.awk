##
# That AWK script creates and adds a primary key for the OPTD-maintained list
# of POR (points of reference).
# It uses the following input files:
#  * Geonames dump data file:
#      dump_from_geonames.csv
#  * OPTD-maintained list of best known coordinates:
#      optd_por_best_known_so_far.csv
#
# The primary key is made of:
#  * The IATA code
#  * The location type
#  * The Geonames ID, when existing, or 0 otherwise
# For instance:
#  * ARN-A-2725346 means the Arlanda airport in Stockholm, Sweden
#  * ARN-R-8335457 means the Arlanda railway station in Stockholm, Sweden
#  * CDG-A-6269554 means the Charles de Gaulle airport in Paris, France
#  * PAR-C-2988507 means the city of Paris, France
#  * NCE-CA-0 means Nice, France, indifferentiating the airport from the city
#  * SFO-A-5391989 means the San Francisco airport, California, USA
#  * SFO-C-5391959 means the city of San Francisco, California, USA
#
# A few examples of IATA location types:
#  * 'C' for city
#  * 'A' for airport
#  * 'CA' for a combination of both
#  * 'H' for heliport
#  * 'R' for railway station
#  * 'B' for bus station,
#  * 'P' for maritime port
#  * 'G' for ground station
#  * 'O' for off-line point (usually small airports or railway stations)
#
# That script relies on the OPTD-maintained list of POR (points of reference),
# provided by the OpenTravelData project (http://github.com/opentraveldata/optd).
# Issue the 'bash prepare_optd_public.sh --ori' command to see more detailed
# instructions.
#
# All the work has indeed already been done by OPTD and integrated within the
# OPTD-maintained list of POR file, namely 'optd_por_public.csv'. Hence, the
# primary key is just the concatenation of the IATA code and location type.
# No more work to do at that stage.
#

##
# Header
/^iata_code/ {
    print ("pk^" $0)
}

##
# Regular 'optd_por_public.csv' line
# Details of the fields:
# iata_code^icao_code^faa_code^is_geonames^geoname_id^envelope_id
# ^name^asciiname^latitude^longitude^fclass^fcode
# ^page_rank^date_from^date_until^comment
# ^country_code^cc2^country_name^continent_name
# ^adm1_code^adm1_name_utf^adm1_name_ascii
# ^adm2_code^adm2_name_utf^adm2_name_ascii
# ^adm3_code^adm4_code
# ^population^elevation^gtopo30
# ^timezone^gmt_offset^dst_offset^raw_offset^moddate
# ^city_code_list^city_name_list^city_detail_list^tvl_por_list
# ^state_code^location_type
# ^wiki_link
# ^alt_name_section
#
# Sample lines:
# ARN^ESSA^^Y^2725346^^Stockholm-Arlanda Airport^Stockholm-Arlanda Airport^59.651944^17.918611^S^AIRP^0.256292269082^^^^SE^^Sweden^Europe^26^Stockholm^Stockholm^0191^Sigtuna Kommun^Sigtuna Kommun^^^0^41^42^Europe/Stockholm^1.0^2.0^1.0^2012-07-01^STO^Stockholm^STO|2673730|Stockholm|Stockholm^^^A^http://en.wikipedia.org/wiki/Stockholm-Arlanda_Airport^en|Stockholm-Arlanda Airport|
# ARN^ZZZZ^^Y^8335457^^Arlanda Central Station^Arlanda Central Station^59.649463^17.929^S^RSTN^0.256292269082^^^^SE^^Sweden^Europe^26^Stockholm^Stockholm^0191^Sigtuna Kommun^Sigtuna Kommun^019106^0032^0^^27^Europe/Stockholm^1.0^2.0^1.0^2012-07-01^STO^Stockholm^STO|2673730|Stockholm|Stockholm^^^R^http://en.wikipedia.org/wiki/Arlanda_North_Station^en|Arlanda Central Station|
# IEV^UKKK^^Y^6300960^^Kyiv Zhuliany International Airport^Kyiv Zhuliany International Airport^50.401694^30.449697^S^AIRP^0.0250500878161^^^^UA^^Ukraine^Europe^^^^^^^^^0^178^174^Europe/Kiev^2.0^3.0^2.0^2012-06-03^IEV^Kiev^IEV|703448|Kiev|Kiev^^^A^http://en.wikipedia.org/wiki/Kyiv_Zhuliany_International_Airport^en|Kyiv Zhuliany International Airport|=ru|Аэропорт «Киев» (Жуляны)|
# IEV^ZZZZ^^Y^703448^^Kiev^Kiev^50.401694^30.449697^P^PPLC^0.10867536938^^^^UA^^Ukraine^Europe^12^Kyiv City^Kyiv City^^^^^^2514227^^187^Europe/Kiev^2.0^3.0^2.0^2012-10-23^IEV^Kiev^IEV|703448|Kiev|Kiev^IEV,KBP,QOF,QOH^^C^http://en.wikipedia.org/wiki/Kiev^en|Kiev|h=ru|Киев|
# NCE^LFMN^^Y^6299418^^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.658411^7.215872^S^AIRP^0.148589178303^^^^FR^^France^Europe^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^NCE^Nice^NCE|2990440|Nice|Nice^^^A^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^en|Nice Côte d'Azur International Airport|=fr|Aéroport de Nice Côte d'Azur|=en|Nice Airport|s
# RDU^KRDU^^Y^4487056^^Raleigh-Durham International Airport^Raleigh-Durham International Airport^35.87946^-78.7871^S^AIRP^0.0818187017848^^^^US^^United States^North America^NC^North Carolina^North Carolina^183^Wake County^Wake County^^^0^126^124^America/New_York^-5.0^-4.0^-5.0^2011-12-11^RDU^Durham=Raleigh^RDU|4464368|Durham|Durham=RDU|4487042|Raleigh|Raleigh^^NC^A^http://en.wikipedia.org/wiki/Raleigh%E2%80%93Durham_International_Airport^

#
/^([A-Z]{3})\^([A-Z0-9]{0,4})\^([A-Z0-9]{0,4})\^([YN])/ {
    # IATA code
    iata_code = $1

    # Location type
    location_type = $42

    # Geonames ID
    geonames_id = $5

    # Primary key (IATA code - location type)
    pk = iata_code "-" location_type "-" geonames_id

    #
    print (pk "^" $0)
}

