##
# That AWK script spots the empty coordinates from the
# ../ORI/ori_por_best_known_so_far.csv file, and fixes them thanks to the
# Innovata dump file.
#

##
#
BEGINFILE {
	# Global variables
	error_stream = "/dev/stderr"
	awk_file = "fix_ori_por_best_known_from_innovata.awk"

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
# BBL-CA-7730745^BBL^36.65^52.67^BBL^
# NCE-A-6299418^NCE^NCE^Cote D'Azur Airport^Nice^^FR^43.6583^-7.21717^0^A^NCE^43.658411^7.215872^NCE^
# NCE-C-2990440^NCE^NCE^Cote D'Azur Airport^Nice^^FR^43.6583^-7.21717^0^C^NCE^43.70313^7.26608^NCE^
#
/^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,9})\^/ {
	#
	nb_of_por++

	# Primary key
	pk = $1

	#
	if (NF == 16) {
		# The POR exists in both ORI POR and Innovata

		# IATA code
		iata_code = $12

		# Geographical coordinates from the Innovata file
		inn_lat = $8
		inn_lon = $9

		# Geographical coordinates from the ORI-maintained POR file
		ori_lat = $13
		ori_lon = $14

		# City code
		cty_code = $15

		# Validity beginning date
		date_from = $16

		#
		if (ori_lat == "" && ori_lon == "") {
			# Replace the geographical coordinates
			print (pk "^" iata_code "^" inn_lat "^" inn_lon \
				   "^" cty_code "^" date_from)

		} else {
			# Original line from the ORI-maintained POR file
			print (pk "^" iata_code "^" ori_lat "^" ori_lon \
				   "^" cty_code "^" date_from)
		}

	} else if (NF == 6) {
		# The POR exists only in ORI POR
		print ($0)

	} else {
		# Anomaly
		print ("[" nb_of_por "] Unknown format for: " $0) > error_stream
	}
}
