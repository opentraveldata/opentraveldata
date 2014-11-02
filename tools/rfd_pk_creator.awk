##
# That AWK script creates and adds a primary key for the Amadeus RFD dump file.
# It uses the following input files:
#  * Amadeus RFD dump data file:
#      dump_from_crb_city.csv
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
# That script relies on the OPTD-maintained list of POR (points of reference),
# provided by the OpenTravelData project (http://github.com/opentraveldata/optd).
# Issue the 'prepare_rfd_dump_file.sh --geonames' command to see more detailed
# instructions.
#

##
# Helper functions
@include "awklib/geo_lib.awk"


##
#
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "rfd_pk_creator.awk"

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
## Amadeus RFD dump file

##
# Amadeus RFD header line
/^iata_code/ {
    # Retrieve the full line
    full_line = $0

    # Add the primary key keyword ('pk') and print it
    displayOPTDPorPublicHeader(full_line)
}

##
# Amadeus RFD regular lines
#
# Sample input lines (truncated):
#  BFJ^^BA^BUCKLEY ANGB^BA^BA/FJ:BA^BA^BFJ^Y^^FJ^AUSTL^ITC3^FJ169^^^^N
#  IEV^CA^KIEV ZHULIANY INT^ZHULIANY INTL^KIEV ZHULIANY I^KIEV/UA:ZHULIANY INTL
#    ^KIEV^IEV^Y^^UA^EURAS^ITC2^UA127^50.4^30.4667^2082^Y
#  KBP^A^KIEV BORYSPIL^BORYSPIL INTL^KIEV BORYSPIL^KIEV/UA:BORYSPIL INTL
#    ^KIEV^IEV^Y^^UA^EURAS^ITC2^UA127^50.35^30.9167^2384^Y
#  LHR^A^LONDON LHR^HEATHROW^LONDON LHR^LONDON/GB:HEATHROW
#    ^LONDON^LON^Y^^GB^EUROP^ITC2^GB053^51.4761^-0.63222^2794^Y
#  LON^C^LONDON^^LONDON^LONDON/GB
#    ^LONDON^LON^N^^GB^EUROP^ITC2^GB053^51.5^-0.16667^^N
#  NCE^CA^NICE^COTE D AZUR^NICE^NICE/FR:COTE D AZUR
#    ^NICE^NCE^Y^^FR^EUROP^ITC2^FR052^43.6653^7.215^^Y
#
/^([A-Z]{3})\^([A-Z]*)\^/ {
    #
    nb_of_geo_por++

    # IATA code
    iata_code = $1

    # Feature code
    rfd_loc_type = $2

    # Store the full line
    full_line = $0

    # Register the full line
    registerRFDLine(iata_code, rfd_loc_type, full_line, nb_of_geo_por)

    # DEBUG
    #if (FNR >= 16) { exit }
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

