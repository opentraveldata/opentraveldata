##
# That AWK script extracts information from the 'allCountries_w_alt.txt'
# Geonames-derived data file:
# - For all the transport-related points of reference (POR,
#   i.e., mainly airports, airbases, airfields, heliports).
# - For all the populated places (i.e., cities) and administrative
#   divisions (e.g., municipalities) having got a IATA code (e.g., 'LON' for
#   London, UK, 'PAR' for Paris, France and 'SFO' for San Francisco, CA, USA).
#
# See ../geonames/data/por/admin/aggregateGeonamesPor.sh for more details on
# the way to derive that file from Geonames original data files.
#
# The format of allCountries_w_alt.txt file corresponds to what is expected.
# So, no further processing has to be done on the format here.
# However, most of the POR having no IATA code is filtered out.
# Hence, the remaining of the Shell/AWK scripts, then, can be left untouched.
#
# A few airports have no IATA code (see for instance
# http://github.com/opentraveldata/opentraveldata/issues/15). However,
# some are used by airlines to be published in schedules. So, a work around
# to have them in OpenTravelData (in the optd_por_public.csv file) is to use
# the 'ZZZ' special IATA code, which cannot be used for airports (it is
# reserved), meaning that that airport has no IATA code. The airport details
# (e.g., ICAO or FAA code, names, time-zones) then come from Geonames.
# Sample line from the optd_por_best_known_so_far.csv file.
# ZZZ-A-8531905^ZZZ^-0.94238^114.8942^ZZZ^
#
# Input data files:
# * <OPTD root dir>/data/geonames/data/por/data/allCountries_w_alt.txt (generated file)
# * <OPTD root dir>/opentraveldata/optd_por_best_known_so_far.csv
#
# Input format:
# -------------
# Sample lines for the allCountries_w_alt.txt file:
# NCE^LFMN^^6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.66272^7.20787^FR^^France^Europe^S^AIRP^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^Aeroport de Nice Cote d'Azur,Aéroport de Nice Côte d'Azur,Flughafen Nizza,LFMN,NCE,Nice Airport,Nice Cote d'Azur International Airport,Nice Côte d'Azur International Airport,Niza Aeropuerto^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de|Flughafen Nizza||en|Nice Côte d'Azur International Airport||es|Niza Aeropuerto|ps|fr|Aéroport de Nice Côte d'Azur||en|Nice Airport|s
# ^WAOM^^8531905^Beringin Airport^Beringin Airport^-0.94238^114.8942^ID^^Indonesia^Asia^S^AIRP^13^Central Kalimantan^Central Kalimantan^^^^^^0^^29^Asia/Pontianak^7.0^7.0^7.0^2013-05-20^Bandar Udara Beringin,WAOM^http://en.wikipedia.org/wiki/Beringin_Airport^id|Bandar Udara Beringin|
#
# Sample lines for the optd_por_best_known_so_far.csv file:
# ZZZ-A-8531905^ZZZ^-0.94238^114.8942^ZZZ^
#
# A few examples of Geonames feature codes
# (field #11 here; see also http://www.geonames.org/export/codes.html):
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
#  * RSRT:  Resort (e.g., Sun City Resort)
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
# Output format:
# IATA code, ICAO code, FAA code,
# Geoname ID, Name, ASCII name, Latitude, Longitude,
# Country 2-char code, Extra country code, Country name, Continent name,
# Feature class, Feature code,
# Admin. level 1 code, Admin. level 1 UTF8 name, Admin. level 1 ASCII name,
# Admin. level 2 code, Admin. level 2 UTF8 name, Admin. level 2 ASCII name,
# Administrative level 3 code, Administrative level 4 code, 
# Population, Elevation, Topo 30,
# Time zone, GMT_offset, DST_offset, raw_offset,
# Modification date, List of all the alternate names without details,
# English Wikipedia link,
# (Language ISO code, alternate name, flags)*


##
# Helper functions
@include "awklib/geo_lib.awk"

##
# Initialisation
BEGIN {
	# Global variables
	error_stream = "/dev/stderr"
	awk_file = "extract_por_with_iata_icao.awk"

	#
	por_lines = 0
	delete optd_no_iata_list

	# Output files
	if (iata_file == "") {
		iata_file = "/dev/stdout"
	}
	if (noiata_file == "") {
		noiata_file = "/dev/stdout"
	}
}

##
# Header
#
/^iata_code\^/ {
	# Extract the header
	hdr_line = $0

	# Print the header
	print (hdr_line) > iata_file
	print (hdr_line) > noiata_file
}


##
# OPTD-maintained list of POR (optd_por_best_known_so_far.csv)
#
# AYM-A-10943125^AYM^24.46682^54.6102^AUH,AYM^2014-05-01
# AYM-C-10227711^AYM^24.49784^54.60556^AYM^2014-05-01
# NCE-A-6299418^NCE^43.658411^7.215872^NCE^
# NCE-C-2990440^NCE^43.70313^7.26608^NCE^
# ZZZ-A-8531905^ZZZ^-0.94238^114.8942^ZZZ^
#
/^ZZZ-[A-Z]{1,2}-[0-9]{1,15}\^ZZZ\^[0-9.+-]{0,16}\^[0-9.+-]{0,16}\^ZZZ\^[0-9-]{0,10}$/ {
    # Primary key (IATA code and location pseudo-code)
    pk = $1

	# Geonames ID
	extractPrimaryKeyDetails(pk)
	geo_id = epkdGeonamesID

	# Location type
	por_type = epkdLocationType
	
	# Register the POR
	optd_no_iata_list[geo_id] = por_type
}

##
# POR entries having no IATA code (vast majority of the POR).
#
#
# Samples:
# ========
#
# No code
# -------
# ^^^3022309^Cros-de-Cagnes^Cros-de-Cagnes^43.66405^7.1722^FR^^France^Europe^P^PPL^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^061^06027^0^2^19^Europe/Paris^1.0^2.0^1.0^2012-02-27^Cros-de-Cagnes^^|Cros-de-Cagnes|
#
# ICAO code
# ---------
# ^BGKS^^7730417^Kangersuatsiaq Heliport^Kangersuatsiaq Heliport^72.39667^-55.555^GL^^Greenland^America^S^AIRH^03^^^^^^^^0^^-9999^America/Godthab^-3.0^-2.0^-3.0^2012-02-26^BGKS,KAQ^http://en.wikipedia.org/wiki/Kangersuatsiaq_Heliport
#
/^\^([A-Z0-9]{4}|)\^([A-Z0-9]{0,4})\^([0-9]{1,12})\^.*\^([0-9]{4}-[0-9]{2}-[0-9]{2})/ {
	# Geonames ID
	geo_id = $4

	# Feature code
	fcode = $14

	# Dump the line when the POR is either travel- or city-related
	if (isFeatCodeTvlRtd(fcode) >= 1 || isFeatCodeCity(fcode) >= 1) {
		print ($0) > noiata_file
	}

	# When the POR has no IATA code, but is referenced in
	# optd_por_best_known_so_far.csv, then add it to the list of POR having
	# a IATA code ('ZZZ', here). That allows to get non-IATA POR in
	# OpenTravelData
	if (optd_no_iata_list[geo_id]) {
		OFS = FS
		$1 = "ZZZ"
		print ($0) > iata_file

		# Reset the IATA code field, otherwise, the line will match
		# the next AWK matching rule and action code clause
		$1 = ""
	}
}

##
# The format of allCountries_w_alt.txt file corresponds to what is expected. So,
# no processing has to be done here. The data file is split in two, so as to keep
# compatibility with the MySQL-based generation process.
#
# NCE^LFMN^^6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.66272^7.20787^FR^^France^Europe^S^AIRP^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^Aeroport de Nice Cote d'Azur,Aéroport de Nice Côte d'Azur,Flughafen Nizza,LFMN,NCE,Nice Airport,Nice Cote d'Azur International Airport,Nice Côte d'Azur International Airport,Niza Aeropuerto^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de|Flughafen Nizza||en|Nice Côte d'Azur International Airport||es|Niza Aeropuerto|ps|fr|Aéroport de Nice Côte d'Azur||en|Nice Airport|s
# ^WAOM^^8531905^Beringin Airport^Beringin Airport^-0.94238^114.8942^ID^^Indonesia^Asia^S^AIRP^13^Central Kalimantan^Central Kalimantan^^^^^^0^^29^Asia/Pontianak^7.0^7.0^7.0^2013-05-20^Bandar Udara Beringin,WAOM^http://en.wikipedia.org/wiki/Beringin_Airport^id|Bandar Udara Beringin|
#
/^[A-Z0-9]{3}\^([A-Z0-9]{4}|)\^[A-Z0-9]{0,4}\^[0-9]{1,15}\^.*\^[0-9]{4}-[0-9]{2}-[0-9]{2}\^/ {
	#
	por_lines++

	#
	print ($0) > iata_file
}


##
#
END {
	print ("Number of POR lines: " por_lines)
}
