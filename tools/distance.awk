#
# AWK script to calculate the distance between geographical points
# of several sources:
#  * OPTD-maintained list of best known coordinates:
#      optd_por_best_known_so_far.csv
#  * Geonames dump data file:
#      dump_from_geonames.csv
#

##
# Helper functions
@include "awklib/geo_lib.awk"

##
#
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "distance.awk"

    # Initialisation of the Geo library
    initGeoAwkLib(awk_file, error_stream, log_level)
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
# Main
#  * POR in both the list of best known coordinates and Geonames,
#    with a PageRank:
#    - (11) NCE-CA-6299418^NCE^43.658411^7.215872^NCE^^NCE^43.66272^7.20787^NCE^0.158985215433
#  * POR in both the list of best known coordinates and Geonames,
#    without a PageRank:
#    -  (9) AAC-CA-6297289^AAC^31.073333^33.835833^AAC^^AAC^31.07333^33.83583
#  * POR only in the list of best known coordinates, with a PageRank
#    -  (8) AJL-CA-0^AJL^23.746603^92.802767^AJL^^AJL^0.00868396886294
#  * POR only in the list of best known coordinates, without a PageRank
#    -  (6) XIT-R-0^XIT^51.42^12.42^LEJ^
#
  /^[A-Z]{3}-[A-Z]{0,2}-[0-9]{1,10}\^[A-Z]{3}\^[0-9.+-]{0,12}\^/ {

	  # Primary key (IATA code, location type and Geonames ID)
	  pk = $1

	  # Location type (extracted from the primary key)
	  location_type = gensub ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})$",	\
							  "\\2", "g", pk)

	  # Geonames ID
	  geonames_id = gensub ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})$",	\
							"\\3",	"g", pk)

	  # IATA code
	  iata_code = $2
	
	  # PageRank value
	  page_rank = getPageRankFromCodeAndLocType(iata_code, location_type)

	  # Best known geographical coordinates (fields #3 and #4)
	  if (NF >= 8) {
		  lat1 = $3
		  lon1 = $4
	  } else {
		  lat1 = 0
		  lon1 = 0
	  }

	  # Geonames geographical coordinates, when existing (fields #8 and #9)
	  if (NF == 11 || NF == 9) {
		  lat2 = $8
		  lon2 = $9
	  } else {
		  lat2 = 0
		  lon2 = 0
	  }

	  # For now, calculate the distance only when the POR exists in both
	  # input files
	  if (NF == 11 || NF == 9) {
		  # Delegate the distance calculation
		  distance = geoDistance(lat1, lon1, lat2, lon2)

		  # IATA code
		  printf ("%s", iata_code "-")

		  # Location type
		  printf ("%2s", location_type)

		  # Distance, in km
		  printf ("^%6.0f", distance/1000.0)
		
		  # PageRank (the maximum being 100%, i.e., 1.0, usually for ORD/Chicago)
		  printf ("^%21.20f", page_rank)

		  # Popularity, in number of passengers
		  # printf ("^%9.0f", pagerank)

		  # Distance x PageRank
		  printf ("^%8.0f", page_rank*distance)

		  # Distance x popularity
		  # printf ("^%8.0f", popularity*distance/1000000.0)

		  # End-of-line
		  printf ("%s", "\n")

	  } else if (NF == 8 || NF == 6) {
		  # The POR (point of reference) is not known from Geonames.
		  # So, there is no difference to calculate: do nothing else here.

	  } else if (NF == 4) {
		  # It corresponds to the ref_airport_pageranked.csv file (because
		  # the beginning of the line is the same). As that file has already
		  # been analysed above, nothing more has to be done here

	  } else {
		  # Do nothing
		  print ("!!!! For " FNR " record, there are " NF \
				 " fields, whereas 6, 8, 9 or 11 are expected: " $0) \
			  > "/dev/stderr"
	  }

  }
