##
# That AWK script detects when a same Geoname ID appears for several
# distinct POR, just for information (no further action is performed).
# It takes as input the ../ORI/optd_por_best_known_so_far.csv file.
# Examples:
#  * Geonames ID=3451668: REZ and QRZ
#  ** QRZ-O-3451668^QRZ^-22.46889^-44.44667^QRZ^
#  ** REZ-C-3451668^REZ^-22.46889^-44.44667^REZ^
#  * Geonames ID=3578420: SFG and CCE
#  ** CCE-A-3578420^CCE^18.10019^-63.04755^SFG^
#  ** SFG-A-3578420^SFG^18.10019^-63.04755^SFG^
#  * Geonames ID=4368301: LTW and XSM
#  ** XSM-A-4368301^XSM^38.3142^-76.55094^XSM^
#  ** LTW-A-4368301^LTW^38.3142^-76.55094^LTW^
#  * Geonames ID=5568159: RKC and ROF
#  ** RKC-A-5568159^RKC^41.73044^-122.54355^RKC^
#  ** ROF-A-5568159^ROF^41.73044^-122.54355^SIY^
#  * Geonames ID=6297031: HAH and YVA
#  ** HAH-A-6297031^HAH^-11.53591^43.2742^YVA^
#  ** YVA-A-6297031^YVA^-11.53591^43.2742^YVA^2012-01-01
#  * Geonames ID=6299466: MLH and BSL
#  ** BSL-A-6299466^BSL^47.58958^7.52991^EAP^
#  ** MLH-A-6299466^MLH^47.58958^7.52991^EAP^
#  * Geonames ID=7730274: DNM and MJK
#  ** DNM-A-7730274^DNM^-25.88937^113.57554^DNM^
#  ** MJK-A-7730274^MJK^-25.88937^113.57554^MJK^
#  * Geonames ID=3394605: MTE and QGD
#  ** MTE-C-3394605^MTE^-2.00082^-54.08102^MTE^
#  ** QGD-C-3394605^QGD^-2.00082^-54.08102^QGD^
#  * Geonames ID=3572604: COX and TZN
#  ** COX-A-3572604^COX^24.15745^-77.58356^COX^
#  ** TZN-A-3572604^TZN^24.15745^-77.58356^TZN^
#  * Geonames ID=6299819: ENQ and XPL
#  ** ENQ-A-6299819^ENQ^14.38237^-87.62116^XPL^
#  ** XPL-A-6299819^XPL^14.38237^-87.62116^XPL^
#


##
# Import the AWK Geo library
@include "awklib/geo_lib.awk"

##
#
BEGINFILE {
	# Global variables
	error_stream = "/dev/stderr"
	awk_file = "spot_dup_geonameid.awk"

	#
	nb_of_por = 0
}

##
# Header line
/^pk\^iata_code/ {
	print ($1 "^" $12 "^" $13 "^" $14 "^" $15 "^" $16)
}

##
# Sample input files:
# BSL-A-6299466^BSL^47.58958^7.52991^EAP^
# MLH-A-6299466^MLH^47.58958^7.52991^EAP^
#
/^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,9})\^/ {
	#
	nb_of_por++

	# Full line
	full_line = $0

	# Primary key
	pk = $1

	# IATA code
	iata_code = $2

	# Geographical coordinates from the ORI-maintained POR file
	optd_lat = $3
	optd_lon = $4

	# City codes
	cty_codes = $5

	# Validity beginning date
	date_from = $6

	# Extract the primary key details (IATA code, location type and Geonames ID)
	extractPrimaryKeyDetails(pk)

	# IATA code (first field of the primary key)
	if (epkdIataCode != iata_code) {
		print ("[" awk_file "] !!!! Error for the POR #" FNR			\
			   ", with IATA code=" iata_code ", different from primary key: " \
			   epkdIataCode " (extracted from '" pk "')\n" full_line)	\
			> error_stream
	}

	# Check whether there is already an entry for that Geonames ID
	por_entry_iata = por_list_iata[epkdGeonamesID]

	if (epkdGeonamesID == "0" || por_entry_iata == "") {
		# No previous entry was registered for that Geonames ID; register it.
		por_list_full[epkdGeonamesID] = full_line
		por_list_iata[epkdGeonamesID] = iata_code

	} else {
		# Get the previous full line
		por_entry_full = por_list_full[epkdGeonamesID]

		# Display both the previous and the current POR entries
		print ("Two POR entries have been detected for Geoname ID=" \
			   epkdGeonamesID ": " por_entry_iata " and " iata_code)
	}

}
