##
# That AWK script:
#  1. Adds the name, in both UTF8 and ASCII encodings, of the served cities.
#  2. Adds the list of travel-related POR IATA codes.
# The optd_por_public.csv data file is parsed twice:
#  * once to store, in memory, the city names,
#  * the second time to write the corresponding fields in that very same
#    optd_por_public.csv file, which is therefore amended.
#
# As of March 2015 (see also the "Fields" part in the BEGIN{} section):
#  * The POR IATA code is the field #1
#  * The POR Geonames ID is the field #5
#  * The POR UTF8 name is the field #7
#  * The POR ASCII name is the field #8
#  * The (list of) city code(s) is the field #37
#  * The (list of) city UTF8 name(s) is the field #38
#  * The (list of) city ASCII name(s) is the field #39
#  * The list of travel-related POR IATA codes is the field #40
#  * The location type is the field #42
#
# * Samples of relevant input POR entries, as manually curated
#   in the optd_por_best_known_so_far.csv data file:
#   - IEV-A-6300960^...^IEV^
#   - IEV-C-703448^...^IEV^
#   - RDU-A-4487056^...^RDU^
#   - RDU-C-4464368^...^RDU^
#   - RDU-C-4487042^...^RDU^
#   - BDL-A-5282636^...^BDL,HFD,SFY^
#   - BDL-C-4845926^...^BDL^
#   - HFD-A-4835842^...^HFD^
#   - HFD-C-4835797^...^HFD^
#   - SFY-C-4951788^...^SFY^
#
# * Samples of output list of city UTF8 names,
#   with their corresponding travel-related POR entry:
#   - [IEV-A-6300960] Kiev
#   - [RDU-A-4487056] Durham=Raleigh
#   - [BDL-A-5282636] Windsor Locks=Hartford=Springfield
#
# * Samples of output list of city details (IATA code, Geonames ID, 
#   UTF8 and ASCII names),
#   with their corresponding travel-related POR entry:
#   - [IEV-A-6300960] IEV|703448|Kiev|Kiev
#   - [RDU-A-4487056] RDU|4464368|Durham|Durham=RDU|4487042|Raleigh|Raleigh
#   - [BDL-A-5282636] BDL|4845926|Windsor Locks|Windsor Locks=HFD|4835797|Hartford|Hartford=SFY|4951788|Springfield|Springfield
#

##
# Helper functions
@include "awklib/geo_lib.awk"


##
#
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "add_city_name.awk"

    # Fields
    K_POR_CDE = 1
    K_POR_GID = 5
    K_NME_UTF = 7
    K_NME_ASC = 8
    K_SVD_CTY_LST = 37
    K_CTY_UTF_LST = 38
    K_CTY_ASC_LST = 39
    K_TVL_LST = 40
    K_LOC_TYP = 42

    # Separators
    K_1ST_SEP = "^"
    K_2ND_SEP = "="
    K_3RD_SEP = "|"

    #
    idx_file = 0
}


##
#
BEGINFILE {
    #
    idx_file++

    # Sanity check
    if (idx_file >=3) {
	print ("[" awk_file "] !!!! Error - The '" FILENAME "' data file " \
	       "should not be parsed more than twice" ) > error_stream
    }
}

##
# First parsing - extraction of the city lists
#
function extractAndStoreCityNames(porIataCode, porLocType, porGeonamesID, \
				  porUtfName, porAsciiName) {
    # Parse the location type
    is_city = isLocTypeCity(porLocType)
    # is_tvl = isLocTypeTvlRtd(porLocType)

    # When it is a city:
    # 1. Store the UTF8 name.
    # 2. Store the details (IATA code, Geonames ID, UTF8 and ASCII names) 
    #    of the point of reference (POR).
    if (is_city != 0) {
	##
	# 1. UTF8 name only
	# Retrieve previous UTF8 names, if any
	cty_list_tmp = cty_list_names[porIataCode]
	if (cty_list_tmp) {
	    cty_list_tmp = cty_list_tmp K_2ND_SEP
	}

	# Add the current city details to the previous ones, if any
	cty_list_tmp = cty_list_tmp porUtfName

	# Register the full list of city UTF8 names
	cty_list_names[porIataCode] = cty_list_tmp

	##
	# 2. Full details
	# Retrieve previous details, if any
	cty_list_tmp = cty_list_details[porIataCode]
	if (cty_list_tmp) {
	    cty_list_tmp = cty_list_tmp K_2ND_SEP
	}

	# Serialise the current city details.
	cty_details = porIataCode K_3RD_SEP porGeonamesID \
	    K_3RD_SEP porUtfName K_3RD_SEP porAsciiName

	# Add the current city details to the previous ones, if any.
	cty_list_tmp = cty_list_tmp cty_details

	# Register the full list of city details
	cty_list_details[porIataCode] = cty_list_tmp
    }
}

##
# First parsing - collection of the travel-related points serving a given city
#
function collectTravelPoints(porIataCodePk, porIataCodeServedList, porLocType) {
    # Store the names of the point of reference (POR) when it is not only a city
    if (porLocType != "C") {

	# Split the list of cities
	# Note: most of the time, that list contains a single IATA code
	split (porIataCodeServedList, porIataCodeServedArray, ",")
	for (porIataCodeServedIdx in porIataCodeServedArray) {
	    porIataCodeServed = porIataCodeServedArray[porIataCodeServedIdx]

	    tvl_por_list = travel_por_list_array[porIataCodeServed]
	    if (tvl_por_list == "") {
		travel_por_list_array[porIataCodeServed] = porIataCodePk

	    } else {
		# Add the POR IATA code
		tvl_por_list_tmp = tvl_por_list "," porIataCodePk
		# Sort the list of POR IATA codes
		travel_por_list_array[porIataCodeServed] =	\
		    sortListStringAplha(tvl_por_list_tmp, ",")
	    }
	}
    }
}

##
# Second parsing - writing of the city lists.
#
function writeCityLists(porIataCode, porLocType, porIataCodeServedList, \
			porUtfName, porAsciiName) {
    # Output separator
    OFS = FS

    # Global list with the UTF8 names of all the served cities.
    porCtyListNames = ""

    # Global list with the full details of all the served cities
    porCtyListDetails = ""

    # Browse the list of city code(s)
    # Note: most of the time, that list contains a single IATA code.
    split (porIataCodeServedList, porIataCodeServedArray, ",")
    for (porIataCodeServedIdx in porIataCodeServedArray) {
	porIataCodeServed = porIataCodeServedArray[porIataCodeServedIdx]

	##
	# 1. City UTF8 names
	# Retrieve the list of city UTF8 names for that IATA code
	ctyListTmp = cty_list_names[porIataCodeServed]

	# If the global list is not empty, just add the current UTF8 name to it
	if (porCtyListNames) {
	    porCtyListNames = porCtyListNames K_2ND_SEP
	}

	# Add the current UTF8 name to the global list
	porCtyListNames = porCtyListNames ctyListTmp

	##
	# 2. City details
	# Retrieve the list of city details for that IATA code
	ctyListTmp = cty_list_details[porIataCodeServed]

	# If the global list is not empty, just add the current details to it
	if (porCtyListDetails) {
	    porCtyListDetails = porCtyListDetails K_2ND_SEP
	}

	# Add the current details to the global list
	porCtyListDetails = porCtyListDetails ctyListTmp
    }

    # Write the city lists on the POR file row/line
    $K_CTY_UTF_LST = porCtyListNames
    $K_CTY_ASC_LST = porCtyListDetails
}

##
# Second parsing - writing of the travel-related points serving a given city
function writeTravelPORList(porIataCode, porLocType, porIataCodeServedList) {
    # Parse the location type
    is_city = isLocTypeCity(porLocType)

    if (is_city != 0) {
	# Output separator
	OFS = FS

	# A city can not serve several other cities. So, the list should be
	# limited to a single element
	split (porIataCodeServedList, porIataCodeServedArray, ",")

	# Sanity check
	if (length (porIataCodeServedArray) != 1) {
	    print ("[" awk_file "][" FNR "] !!!! Error - "				\
		   "The list of city codes for " porIataCode "-" porLocType	\
		   " does not contain a single element: '"				\
		   porIataCodeServedList "'" ) > error_stream
	}

	# Now that the list contains for sure a single element, get it
	porIataCodeServed = porIataCodeServedArray[1]

	# Travel-related POR list
	tvl_por_list = travel_por_list_array[porIataCodeServed]
	$K_TVL_LST = tvl_por_list
    }
}

##
# Header
/^iata_code\^/ {
    if (idx_file == 2) {
	print ($0)
    }
}

##
# Sample input and output lines:
# iata_code^icao_code^faa_code^is_geonames^geoname_id^valid_id^name^asciiname^latitude^longitude^fclass^fcode^page_rank^date_from^date_until^comment^country_code^cc2^country_name^continent_name^adm1_code^adm1_name_utf^adm1_name_ascii^adm2_code^adm2_name_utf^adm2_name_ascii^adm3_code^adm4_code^population^elevation^gtopo30^timezone^gmt_offset^dst_offset^raw_offset^moddate^city_code^city_name_utf^city_name_ascii^tvl_por_list^state_code^location_type^wiki_link^alt_name_section^wac^wac_name^ccy_code^unlc_list
#
# IEV^UKKK^^Y^6300960^^Kyiv Zhuliany International Airport^Kyiv Zhuliany International Airport^50.401694^30.449697^S^AIRP^0.0240196752049^^^^UA^^Ukraine^Europe^^^^^^^^^0^178^174^Europe/Kiev^2.0^3.0^2.0^2012-06-03^IEV^^^^A^http://en.wikipedia.org/wiki/Kyiv_Zhuliany_International_Airport^en|Kyiv Zhuliany International Airport|=en|Kyiv International Airport|=en|Kyiv Airport|s=en|Kiev International Airport|=uk|Міжнародний аеропорт «Київ» (Жуляни)|=ru|Аэропорт «Киев» (Жуляны)|=ru|Международный аеропорт «Киев» (Жуляни)|^488^Ukraine^HRV^
#
# NCE^LFMN^^Y^6299418^^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.658411^7.215872^S^AIRP^0.157408761216^^^^FR^^France^Europe^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^NCE^^^^CA^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de|Flughafen Nizza|=en|Nice Côte d'Azur International Airport|=es|Niza Aeropuerto|ps=fr|Aéroport de Nice Côte d'Azur|=en|Nice Airport|s^427^France^EUR^FRNCE|
#
# RDU^KRDU^^Y^4487056^^Raleigh-Durham International Airport^Raleigh-Durham International Airport^35.87946^-78.7871^S^AIRP^0.0818187017848^^^^US^^United States^North America^NC^North Carolina^North Carolina^183^Wake County^Wake County^^^0^126^124^America/New_York^-5.0^-4.0^-5.0^2011-12-11^RDU|C|4464368=RDU|C|4487042^Durham=Raleigh^Durham=Raleigh^^NC^A^http://en.wikipedia.org/wiki/Raleigh%E2%80%93Durham_International_Airport^^36^North Carolina^USD^USRDU|
#
/^[A-Z0-9]{3}\^[A-Z0-9]{0,4}\^[A-Z0-9]{0,4}\^/{

    if (idx_file == 1) {
	##
	# First parsing

	# IATA code of the point of reference (POR) itself
	iata_code = $K_POR_CDE

	# Geonames ID
	geoname_id = $K_POR_GID

	# UTF8 name of the POR itself
	name_utf = $K_NME_UTF

	# ASCII name of the POR itself
	name_ascii = $K_NME_ASC

	# Served city IATA code
	served_city_code_list = $K_SVD_CTY_LST

	# IATA location type
	location_type = $K_LOC_TYP

	# Store the POR names for the POR IATA code
	extractAndStoreCityNames(iata_code, location_type, geoname_id, \
				 name_utf, name_ascii)

	# Collect the travel-related POR IATA code
	collectTravelPoints(iata_code, served_city_code_list, location_type)

    } else if (idx_file == 2) {
	##
	# Second parsing

	# IATA code of the point of reference (POR) itself
	iata_code = $K_POR_CDE

	# Geonames ID
	geoname_id = $K_POR_GID

	# UTF8 name of the POR itself
	name_utf = $K_NME_UTF

	# ASCII name of the POR itself
	name_ascii = $K_NME_ASC

	# IATA code of the city served by that POR
	city_iata_code_list = $K_SVD_CTY_LST

	# IATA location type
	location_type = $K_LOC_TYP

	# Write the city names for that POR
	writeCityLists(iata_code, location_type, city_iata_code_list, \
		       name_utf, name_ascii)

	# Write the travel-related points serving a given city
	writeTravelPORList(iata_code, location_type, city_iata_code_list)

	# Write the full line, amended by the call to the writeCityLists()
	# function
	print ($0)

    } else {
	# Sanity check
	print ("[" awk_file "] !!!! Error - The '" FILENAME "' data file " \
	       "should not be parsed more than twice" ) > error_stream
    }
}
