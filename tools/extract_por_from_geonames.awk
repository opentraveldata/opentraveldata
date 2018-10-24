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
# the way to generate the 'allCountries_w_alt.txt' file from Geonames
# original data dump files.
#
# The format of the allCountries_w_alt.txt file is already good and needs
# no further change.
#
# As explained by the README.md of this directory, most of the POR have
# no IATA code. However, it is still useful to have them in
# OpenTravelData (OPTD), as they may appear in some flight schedules and,
# for those being referenced by UN/LOCODE, in many transport-related systems.
# As OPTD was originally based on exclusively IATA-referenced POR,
# a few downstream utilities still need a IATA code. That is why,
# at some point back in time, the 'ZZZ' special IATA code was used
# for those POR not referenced by IATA. 'ZZZ' was chosen because it is reserved,
# and therefore no transport-/travel-related POR can have that code.
# From August 2018 onwards, the IATA code is now being left empty
# when the POR has no such code.
# The airport details (e.g., ICAO or UN/LOCODE code, names, time-zones)
# then come from Geonames. It means that Geonames has got the gold/master
# records for those POR. As a reminder, for IATA-referenced POR,
# OPTD has got the gold/master record (in the optd_por_best_known_so_far.csv
# file) for the geographical location and city to transport-related POR
# relationship.
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
#
# Main input data file: <OPTD root dir>/data/geonames/data/por/data/allCountries_w_alt.txt (itself a generated file)
#
# Sample lines:
# -------------
# * With IATA code (NCE here):
# NCE^LFMN^^6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.66272^7.20787^FR^^France^Europe^S^AIRP^93^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Alpes-Maritimes^Alpes-Maritimes^062^06088^0^3^5^Europe/Paris^1.0^2.0^1.0^2012-06-30^Aeroport de Nice Cote d'Azur,Aéroport de Nice Côte d'Azur,Flughafen Nizza,LFMN,NCE,Nice Airport,Nice Cote d'Azur International Airport,Nice Côte d'Azur International Airport,Niza Aeropuerto^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de|Flughafen Nizza||en|Nice Côte d'Azur International Airport||es|Niza Aeropuerto|ps|fr|Aéroport de Nice Côte d'Azur||en|Nice Airport|s^FRNCE|
# * With ICAO code (WAOM here) and no IATA code:
# ^WAOM^^8531905^Muara Teweh Beringin Airport^Muara Teweh Beringin Airport^-0.94238^114.8942^ID^^Indonesia^Asia^S^AIRP^13^Central Kalimantan^Central Kalimantan^^^^^^0^^29^Asia/Pontianak^7.0^7.0^7.0^2013-05-20^Bandar Udara Beringin,WAOM^http://en.wikipedia.org/wiki/Beringin_Airport^id|Bandar Udara Beringin|^IDMUW|
# * With UN/LOCODE code (MAZSB here) and no IATA code:
# ^^^2562055^Skhirate^Skhirate^33.8527^-7.03171^MA^^Morocco^Africa^P^PPLA3^04^Rabat-Salé-Kénitra^Rabat-Sale-Kenitra^501^Skhirate-Temara^Skhirate-Temara^1050101051^^44850^^51^Africa/Casablanca^0.0^1.0^0.0^2016-11-29^Ac Ckhirat,Aç Çkhirat,Kasba Skira,Minaret de Skhirat,Skhirat,Skhirate^http://en.wikipedia.org/wiki/Skhirat^|Aç Çkhirat|||Skhirate|||Kasba Skira|||Minaret de Skhirat|||Skhirat|^MAZSB|
#
# Input format:
# -------------
# A few examples of Geonames feature codes
# (field #14 here; see also http://www.geonames.org/export/codes.html):
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
#  * MILB:  Military base (e.g., Canadian Forces Station Alert)
#  * CHN:   Channel/sound (e.g., Greenway sound)
#  * PRK:   Park (e.g., Serengeti National Park)
#  * RESx:  Reserve (e.g., Maasai-Mara National Reserve)
#  * AMUS:  Amusement Park (e.g., Disneyland Park Paris)
#  * CAPE:  Cape (e.g., Cape Eleuthera)
#  * PT:    Point (e.g., Long Point)
#  * PLATx: Plateau (e.g., Truscott-Mungalalu Plateau)
#  * VLC:   Volcano (e.g., Arenal Volcano)
#  * PASS:  Pass (e.g., Macmillan Pass)
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
# --------------
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
# List of (Language ISO code, alternate name, flags) tuples
# WAC (World Area Code), WAC name
# Currency code
# UN/LOCODE list (there is usually a single UN/LOCODE, but there may be several)


##
# Helper functions
@include "awklib/geo_lib.awk"

##
# Initialisation
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "extract_por_from_geonames.awk"

    #
    intorg_por_lines = 0

    # Lists
    delete ctry_iso31662code_list
    delete ctry_iso31662name_list
    delete ctry_state_list

    # Output files
    if (intorg_file == "") {
		intorg_file = "/dev/stdout"
    }
    if (all_file == "") {
		all_file = "/dev/stdout"
    }
}

##
# Progress report
function displayProgress() {
    print ("[" awk_file "] " FNR " POR have been processed, "		\
	   "including " intorg_por_lines " IATA-referenced POR")	\
	> error_stream
}

##
# Header
#
/^iata_code\^/ {
    # Extract the header
    hdr_line = $0

    # Print the header
    print (hdr_line) > intorg_file
    print (hdr_line) > all_file
}


##
# File of country subdivisions (optd_country_states.csv)
#
# Sample lines:
# ctry_code^geo_id^adm1_code^name_en^iso31662^abbr
# BR^3455077^18^Paraná^PR^PR
# AU^2147291^06^Tasmania^TAS^TAS
# US^5481136^NM^New Mexico^NM^NM
/^[A-Z]{2}\^[0-9]+\^[0-9A-Z]+\^[A-Z].+\^[0-9A-Z]{1,3}\^[0-9A-Z]{1,3}$/ {
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
# POR entries having no IATA code (vast majority of the POR).
#
#
# Samples:
# ========
#
# No IATA code
# ------------
# ^^^3022309^Cros-de-Cagnes^Cros-de-Cagnes^43.66405^7.1722^FR^^France^Europe^P^PPL^93^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Alpes-Maritimes^Alpes-Maritimes^061^06027^0^2^19^Europe/Paris^1.0^2.0^1.0^2016-02-18^Cros-de-Cagnes^^|Cros-de-Cagnes|^
#
# Historical (no longer referenced by IATA)
# -----------------------------------------
# _TRT^^^5783768^Tremonton^Tremonton^41.71187^-112.16551^US^^United States^North America^P^PPL^UT^Utah^Utah^003^Box Elder County^Box Elder County^^^8227^1318^1318^America/Denver^-7.0^-6.0^-7.0^2017-12-10^TRT,Tremonton,Trimuntun,te li meng dun,trmwntwn  ywta,trymwntwn,Тремонтон,Тримънтън,ترمونتون، یوتا,تريمونتون,特里蒙顿^http://en.wikipedia.org/wiki/Tremonton%2C_Utah^post|84337||ar|تريمونتون||bg|Тримънтън||fa|ترمونتون، یوتا||sr|Тремонтон||zh|特里蒙顿||en|Tremonton|^USTRT|
#
# ICAO code
# ---------
# ^VYCI^^11258616^Coco Island Airport^Coco Island Airport^14.13518^93.36731^MM^^Myanmar^Asia^S^AIRP^17^Rangoon^Rangoon^MMR013D003^Yangon South District^Yangon South District^MMR013032^^0^^4^Asia/Yangon^6.5^6.5^6.5^2017-07-20^Coco Island Airport,VYCI^http://en.wikipedia.org/wiki/Coco_Island_Airport^en|Coco Island Airport|^
# ^WAOM^^8531905^Muara Teweh Beringin Airport^Muara Teweh Beringin Airport^-0.94238^114.8942^ID^^Indonesia^Asia^S^AIRP^13^Central Kalimantan^Central Kalimantan^^^^^^0^^29^Asia/Pontianak^7.0^7.0^7.0^2013-05-20^Bandar Udara Beringin,WAOM^http://en.wikipedia.org/wiki/Beringin_Airport^id|Bandar Udara Beringin|^IDMUW|
#
# UN/LOCODE code
# --------------
# ^^^291068^Port Rashid^Port Rashid^25.26769^55.2825^AE^^United Arab Emirates^Asia^L^PRT^03^Dubai^Dubai^^^^^^0^^-9999^Asia/Dubai^4.0^4.0^4.0^2013-03-05^Mina' Rashid,Mīnā’ Rāshid,Port Rashed,Port Rashid,Rachid Port^http://en.wikipedia.org/wiki/Port_Rashid^|Port Rashid|||Rachid Port||ar|Mīnā’ Rāshid||||Port Rashed|^AEMRP|=AEPRA|
#
/^(|_[A-Z0-9]{3})\^([A-Z0-9]{4}|)\^([A-Z0-9]{0,4})\^([0-9]{1,15})\^.*\^([0-9]{4}-[0-9]{2}-[0-9]{2})/ {
	# Progress report
	if (FNR % 1e6 == 0) {
		displayProgress()
	}
	
    # IATA code
    iata_code = $1

	# ICAO code
	icao_code = $2

    # Geonames ID
    geo_id = $4

    # Feature code
    fcode = $14

    # UN/LOCODE code
    unlc_list = $34

    # When the POR is relevant (ie, transport or city related):
    # * Dump the line into the non-IATA POR
    # * Dump the line into the curated list of POR (named "IATA POR"
    #   for historical reasons, though they are not referenced by IATA)
    if (isFeatCodeTvlRtd(fcode) >= 1 || isFeatCodeCity(fcode) >= 1) {
		print ($0) > all_file

		# In the following cases, the POR is added to the file of POR
		# being referenced by an international organization (such as,
		# for instance, IATA, ICAO or UN/LOCODE). That allows to get
		# non-IATA POR in OpenTravelData:
		# * The POR is referenced by ICAO
		# * The POR is referenced by UN/LOCODE
		if (icao_code || unlc_list) {
			print ($0) > intorg_file
		}
    }
}

##
# The format of allCountries_w_alt.txt file corresponds to what is expected
# by downstream data processing programs, such as ./make_optd_por_public.sh.
# So, no processing has to be done here.
# The data file is split in two, so as to keep compatibility with
# the MySQL-based generation process; that process is no longer supported,
# some people may find an interest in re-initiating it back to life
# in the future.
#
# NCE^LFMN^^6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.66272^7.20787^FR^^France^Europe^S^AIRP^93^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Alpes-Maritimes^Alpes-Maritimes^062^06088^0^3^5^Europe/Paris^1.0^2.0^1.0^2012-06-30^Aeroport de Nice Cote d'Azur,Aéroport de Nice Côte d'Azur,Flughafen Nizza,LFMN,NCE,Nice Airport,Nice Cote d'Azur International Airport,Nice Côte d'Azur International Airport,Niza Aeropuerto^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de|Flughafen Nizza||en|Nice Côte d'Azur International Airport||es|Niza Aeropuerto|ps|fr|Aéroport de Nice Côte d'Azur||en|Nice Airport|s^FRNCE|
#
/^[A-Z0-9]{3}\^([A-Z0-9]{4}|)\^[A-Z0-9]{0,4}\^[0-9]{1,15}\^.*\^[0-9]{4}-[0-9]{2}-[0-9]{2}\^/ {
	# Progress report
	if (FNR % 1e6 == 0) {
		displayProgress()
	}
	
    #
    intorg_por_lines++

    #
    print ($0) > intorg_file
}


##
#
END {
	displayProgress()
}
