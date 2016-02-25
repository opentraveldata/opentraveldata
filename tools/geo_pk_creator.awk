##
# That AWK script creates and adds a primary key for the Geonames dump file.
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
#  * 'P' for (maritime) port,
#  * 'G' for ground station,
#  * 'O' for off-line point (usually a small city/village or a railway station)
#
# A few examples of Geonames feature codes
# (see http://www.geonames.org/export/codes.html):
#  * PPLx:  Populated place (city)
#  * ADMx:  Administrative division (which may be a city in some cases)
#  * LCTY:  Locality (e.g., Sdom)
#  * PCLx:  Political entity (country, e.g., Bahrain, Monaco)
#  * RGNx:  Region
#  * AREA:  Area (e.g., Bloodvein River area)
#  * HMSD:  Homestead (e.g., Roy Hill Station)
#  * ISLx:  Island (e.g., Dalma Island)
#  * ATOL:  Atoll (e.g., Atoll Tikehau)
#  * LKx:   Lake (e.g., Pinehouse Lake)
#  * RSVx:  Reservoir
#  * BAYx:  Bay (e.g., South Way Bay)
#  * HBRx:  Harbor (e.g., Port Canaveral)
#  * DAM:   Dam (e.g., La Grande-3 Dam)
#  * PANx:  Pan
#  * OAS:   Oasis (e.g., Kufra Oasis)
#  * CMPx:  Camp (e.g., Savuti Rest Camp)
#  * CHN:   Channel/sound (e.g., Greenway sound)
#  * PRK:   Park (e.g., Serengeti National Park)
#  * RESx:  Reserve (e.g., Maasai-Mara National Reserve)
#  * AMUS:  Amusement Park (e.g., Disneyland Park Paris)
#  * CAPE:  Cape (e.g., Cape Eleuthera)
#  * PT:    Point (e.g., Long Point)
#  * PLATx: Plateau (e.g., Truscott-Mungalalu Plateau)
#  * VLC:   Volcano (e.g., Arenal Volcano)
#  * MTx:   Mountain (e.g., Mount Hotham)
#  * RK:    Rock (e.g., Ayers Rock)
#  * CNYN:  Canyon (e.g., Grand Canyon)
#  * MNx:   Mine (e.g., Osborne Mine)
#  * INSM:  Military Installation (e.g., Bellows Air Force Station)
#  * AIRB:  Air base; AIRF: Air field; AIRP: Airport; AIRS: Seaplane landing
#           field
#  * AIRQ:  Abandoned air field
#  * AIRH:  Heliport
#  * FY:    Ferry port
#  * PRT:   Maritime port
#  * RSTN:  Railway station
#  * BUSTN: Bus station; BUSTP: Bus stop
#  * MTRO:  Metro station
#

##
# Helper functions
@include "awklib/geo_lib.awk"


##
#
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "geo_pk_creator.awk"

    # Initialisation of the Geo library
    initGeoAwkLib(awk_file, error_stream, log_level)

    # Number of last registered Geonames POR entries
    nb_of_geo_por = 0
}

##
#
BEGINFILE {
    # Initialisation of the Geo library
    initFileGeoAwkLib()
}

##
# The ../opentraveldata/optd_por_best_known_so_far.csv data file is used,
# in order to specify the POR primary key and its location type.
#
# Sample lines:
#  ALV-C-3041563^ALV^42.50779^1.52109^ALV^ (2 lines in OPTD, 2 lines in Geonames)
#  ALV-O-7730819^ALV^40.98^0.45^ALV^       (2 lines in OPTD, 2 lines in Geonames)
#  ARN-A-2725346^ARN^59.651944^17.918611^STO^ (2 lines in OPTD, split from a
#  ARN-R-8335457^ARN^59.649463^17.929^STO^     combined line, 1 line in Geonames)
#  IES-CA-2846939^IES^51.3^13.28^IES^(1 combined line in OPTD,1 line in Geonames)
#  IEV-A-6300960^IEV^50.401694^30.449697^IEV^(2 lines in OPTD, split from a
#  IEV-C-703448^IEV^50.401694^30.449697^IEV^  combined line, 2 lines in Geonames)
#  KBP-A-6300952^KBP^50.345^30.894722^IEV^   (1 line in OPTD, 1 line in Geonames)
#  LHR-A-2647216^LHR^51.4775^-0.461389^LON^  (1 line in OPTD, 1 line in Geonames)
#  LON-C-2643743^LON^51.5^-0.1667^LON^       (1 line in OPTD, 1 line in Geonames)
#  NCE-CA-0^NCE^43.658411^7.215872^NCE^      (1 combined line in OPTD
#                                             2 lines in Geonames)
#
/^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})\^([A-Z]{3})\^/ {
    # Store the full line
    full_line = $0

    # Primary key (combination of IATA code, location type and Geonames ID)
    pk = $1

    # IATA code of the POR (it should be the same as the one of the primary key)
    iata_code2 = $2

    # Geographical coordinates
    latitude = $3
    longitude = $4

    # IATA code of the served city
    srvd_city_code = $5

    # Beginning date of the validity range
    beg_date = $6

    # Register the OPTD-maintained line
    registerOPTDLine(pk, iata_code2, latitude, longitude,	\
		     srvd_city_code, beg_date, full_line)
}


####
## Geonames dump file

##
# Geonames header line
/^iata_code/ {
    # Retrieve the full line
    full_line = $0

    # Add the primary key keyword ('pk') and print it
    displayOPTDPorPublicHeader(full_line)
}

##
# Geonames regular lines
# Sample lines (truncated):
#  IEV^UKKK^^6300960^Kyiv Zhuliany International Airport^Kyiv Zhuliany International Airport^50.40169^30.4497^UA^^Ukraine^Europe^S^AIRP^^^^^^^^^0^178^174^Europe/Kiev^2.0^3.0^2.0^2012-06-03^Kyiv Airport,...^http://en.wikipedia.org/wiki/Kyiv_Zhuliany_International_Airport^en|Kyiv Zhuliany International Airport|
#  IEV^ZZZZ^^703448^Kiev^Kiev^50.45466^30.5238^UA^^Ukraine^Europe^P^PPLC^12^Kyiv City^Kyiv City^^^^^^2514227^^187^Europe/Kiev^2.0^3.0^2.0^2012-08-18^Kiev,...,Київ^http://en.wikipedia.org/wiki/Kiev^en|Kiev|h|en|Kyiv|p
#  LHR^EGLL^^2647216^London Heathrow Airport^London Heathrow Airport^51.47115^-0.45649^GB^^United Kingdom^Europe^S^AIRP^ENG^England^England^GLA^Greater London^Greater London^F9^^0^^27^Europe/London^0.0^1.0^0.0^2010-08-03^London Heathrow,...,伦敦 海斯楼 飞机场,倫敦希斯路機場,런던 히드로 공항^http://en.wikipedia.org/wiki/London_Heathrow_Airport^en|Heathrow Airport||en|Heathrow|s
#  LON^ZZZZ^^2643743^London^London^51.50853^-0.12574^GB^^United Kingdom^Europe^P^PPLC^ENG^England^England^GLA^Greater London^Greater London^^^7556900^^25^Europe/London^0.0^1.0^0.0^2012-08-19^City of London,...伦敦,倫敦^http://en.wikipedia.org/wiki/London^en|London|p|en|London City|
#  NCE^LFMN^^6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.66272^7.20787^FR^^France^Europe^S^AIRP^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^Nice Airport,...^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^en|Nice Airport|s
#  NCE^ZZZZ^^2990440^Nice^Nice^43.70313^7.26608^FR^^France^Europe^P^PPLA2^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^338620^25^18^Europe/Paris^1.0^2.0^1.0^2011-11-02^Nice,...,Ница,尼斯^http://en.wikipedia.org/wiki/Nice^en|Nice||ru|Ницца|
#
/^([A-Z]{3})\^([A-Z0-9]{0,4})\^([A-Z0-9]{0,4})\^([0-9]{1,10})\^/ {
    #
    nb_of_geo_por++

    # IATA code
    iata_code = $1

    # Geonames ID
    geonames_id = $4

    # Feature code
    fcode = $14

    # Store the full line
    full_line = $0

    # Register the full line
    registerGeonamesLine(iata_code, fcode, geonames_id,	full_line, nb_of_geo_por)
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
}

