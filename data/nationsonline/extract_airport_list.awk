##
#

#
function extract_line() {
	detail_string = $0
	gsub ("<td (valign=\"top\" )?class=\"border1\"([ ])?>([ ])?", "",
		  detail_string)
	gsub (" </td>", "</td>", detail_string)
	nb_rep = gsub ("</td>", "", detail_string)
	gsub ("<td>", "", detail_string)
	gsub ("<tr>", "", detail_string)
	gsub ("</tr>", "", detail_string)
	gsub ("<a href=\"..([A-Za-z_/-]+).htm\">", "", detail_string)
	gsub ("</a>", "", detail_string)
	gsub ("   ", "", detail_string)
	gsub ("  ", "", detail_string)
	gsub ("&uuml;", "ü", detail_string)
	gsub ("&eacute;", "é", detail_string)
	gsub ("&nbsp;", "", detail_string)

	#
	#printf ("[" idx "] " $0 "\n")

	if (nb_rep == 3) {
		# All the details are on a single line
		iata_code = gensub ("([A-Z][a-z]+)([A-Z][a-z]+)([A-Z][A-Z][A-Z])[ ]?",
							"\\3", "g", detail_string)
		airport_name = gensub("([A-Z][a-z]+)([A-Z][a-z]+)([A-Z][A-Z][A-Z])[ ]?",
							  "\\1",  "g", detail_string)
		country_name = gensub("([A-Z][a-z]+)([A-Z][a-z]+)([A-Z][A-Z][A-Z])[ ]?",
							  "\\2",  "g", detail_string)
		alt_name = ""
		state_code = ""
		
		#
		printf (iata_code "^" airport_name "^" alt_name "^")
		printf (state_code "^" country_name "\n")

		#
		idx = 3

	} else if (idx == 1) {
		# Airport name
		# Detect whether a state code is given
		detail_string_tmp = detail_string
		has_state = gsub ("(.+), ([A-Z][A-Z])", "", detail_string_tmp)

		if (has_state == 0) {
			# printf ("No rep => " detail_string "\n")
			airport_name = detail_string
			state_code = ""

		} else {
			# printf ("Rep => '" detail_string "'\n")
			airport_name = gensub ("(.+), ([A-Z][A-Z])", "\\1", "g", detail_string)
			state_code = gensub ("(.+), ([A-Z][A-Z])", "\\2", "g", detail_string)
		}

		# Detect whether an alternate name is given
		detail_string_tmp = detail_string
		has_altname = gsub ("([^-]+) - (.+)", "", detail_string_tmp)

		if (has_altname == 0) {
			# printf ("No alt => " detail_string "\n")
			alt_name = ""
			
		} else {
			# printf ("Alt => " detail_string "\n")
			alt_name = gensub ("([^-]+) - (.+)", "\\2", "g", airport_name)
			airport_name = gensub ("([^-]+) - (.+)", "\\1", "g", airport_name)
			state_code = gensub ("([^-]+) - (.+)", "\\1", "g", state_code)
		}

	} else if (idx == 2) {
		country_name = detail_string

	} else if (idx == 3) {
		iata_code = detail_string

		#
		printf (iata_code "^" airport_name "^" alt_name "^")
		printf (state_code "^" country_name "\n")

	} else {
		printf ("!!!!! Fatal error -- idx (" idx ")>= 4 -- " $0) > "/dev/stderr"
	}
}

#
BEGIN {
	idx = 1
	# Header
	printf ("iata_code^airport_name^alt_name^state_code^country_name\n")
}

## M A I N
/(<tr>)?<td (valign="top" )?class="border1"([ ])?>/ {
	#
	extract_line()

	#
	idx++
	if (idx >= 4) {
		idx = 1
	}
}

/<td>([A-Z ]+)<\/td>(<\/tr>)?/ {
	#
	extract_line()

	#
	idx++
	if (idx >= 4) {
		idx = 1
	}
}
