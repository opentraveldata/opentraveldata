#
# Start from the list of airline details with a 2-char/3-char primary key.
# As that list duplicates all the entries having got the two variants of
# the codes, another primary key has to be invented. The airline name
# seems a good candidate for that.
#

# Derive a primary key from the name
function createPK (cpkName) {
	__cpkName = gensub (" ", "-", "g", tolower (cpkName))
	__cpkName = "air-" __cpkName
	return __cpkName
}

BEGIN {
	# Header
	header = "pk^"
	header = header "env_id^validity_from^validity_to^"
	header = header "2char_code^3char_code^num_code^name^name2^"
	header = header "alliance_code^alliance_status^type(Cargo;Pax scheduled;Dummy;Gds;charTer;Ferry;Rail)"
	print (header)

	# Initialisation
	delete aln_full
	delete aln_name
	delete aln_2char
	delete aln_3char
}

/^([A-Z0-9\*]{2,3})\^/ {
	# Full line
	full_line = $0

	# Unified code
	code_unified = $1

	# 2-char (IATA) code
	code_2char = $2

	# 3-char (ICAO) code
	code_3char = $3

	# Ticketing code
	code_tkt = $4

	# Name
	name = $5

	# Name2
	name2 = $6

	# Alliance code
	alc_code = $7

	# Alliance status
	alc_status = $8

	# Alliance type
	alc_type = $9

	# Validity from
	valid_from = $10

	# Validity to
	valid_to = $11

	# Check whether the airline has already been registered
	last_code_2char = aln_2char[code_unified]
	last_code_3char = aln_3char[code_unified]
	last_name = aln_name[code_unified]
	if (code_2char == last_code_2char || code_3char == last_code_3char) {
		if (code_2char && code_2char == last_code_2char) {
			# print ("+++++++++++ 2char (" code_2char ")^" $0)
		}
		if (code_3char && code_3char == last_code_3char) {
			# print ("+++++++++++ 3char (" code_3char ")^" $0)
		}
	}

	if (code_2char == last_code_2char && code_3char == last_code_3char	\
		&& name == last_name) {
		# That airline has already been registered. So, we just discard it
		# print ("--------- " $0)

	} else if (!name) {
		# The airline has no name. So, we just discard it.
		# print ("--------- " $0)

	} else {
		# That airline is new

		# Derive a primary key, from its name, for that airline
		pk = createPK(name)

		# Register the airline
		if (code_2char) {
			aln_full[code_2char] = full_line
			aln_2char[code_2char] = code_2char
			aln_3char[code_2char] = code_3char
			aln_name[code_2char] = name
		}
		if (code_3char) {
			aln_full[code_3char] = full_line
			aln_2char[code_3char] = code_2char
			aln_3char[code_3char] = code_3char
			aln_name[code_3char] = name
		}

		# Print it
		print (pk "^" env_id "^" valid_from "^" valid_to				\
			   "^" code_2char "^" code_3char "^" code_tkt				\
			   "^" name "^" name2 "^" alc_code "^" alc_status "^" alc_type)
	}
}
