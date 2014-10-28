##
# That AWK script parses the UNWTO specification document of world regions.
# It outputs the details in a standard and open format, which is then published
# on the OpenTravelData project, in the refdata/ORI sub-directory.
#
# Sample input:
# Americas	Caribbean	Anguilla	1310	21AI	Anguilla
# 	Central America	Belize	1210	22BZ	Belize
#		Nicaragua	1260	22NI	Nicaragua
#		Panama	1270	22PA	Panama
#		Other Central America	1290	22OT	Other Central America
# 	North America	Canada	1010	23CA	Canada
#		Greenland	1110	23GL	Greenland
#		St. Pierre & Miquelon	1120	23PM	St. Pierre & Miquelon
#		USA	1030	23US	USA
#		Other North America	1180	23OT	Other North America
#
# Sample output:
# UNWTO^Americas^Caribbean^Anguilla^1310^21AI^AI
# UNWTO^Americas^Central America^Belize^1210^22BZ^BZ
# UNWTO^Americas^Central America^Nicaragua^1260^22NI^NI
# UNWTO^Americas^Central America^Panama^1270^22PA^PA
# UNWTO^Americas^Central America^Other Central America^1290^22OT^OT
# UNWTO^Americas^North America^Canada^1010^23CA^CA
# UNWTO^Americas^North America^Greenland^1110^23GL^GL
# UNWTO^Americas^North America^St. Pierre & Miquelon^1120^23PM^PM
# UNWTO^Americas^North America^USA^1030^23US^US
# UNWTO^Americas^North America^Other North America^1180^23OT^OT


##
#
BEGIN {
	#
	rg_name = ""
	subrg_name = ""
	#
	cnt_map["UK"] = "GB"
	#
	rg_map["NO"] = "NA"
	rg_map["SO"] = "SA"
}

##
# Generation of the refdata/ori_regions.csv file
# Sample input:
# North America
#
/^([A-Za-z]{1,20})$/ {
	# Extract the region name
	rg_name = $1
	# Derive the region code, usually the first two letters transformed
	# into uppercase letters.
	rg_code = toupper(substr(rg_name, 1, 2))

	# Convert the region code, if needed (for instance, SO/NO -> SA/NA)
	if (rg_code in rg_map) {
		rg_code = rg_map[rg_code]
	}
	print "UNWTO^" rg_code "^" rg_name "^"
}

##
# Generation of the refdata/ori_region_details.csv file
# Sample input:
# Americas	Caribbean	Anguilla	1310	21AI	Anguilla
#
/^([A-Za-z]{1,20})\t/ {
	rg_name = $1
}

##
# Generation of the refdata/ori_region_details.csv file
# Sample input:
# Americas	Caribbean	Anguilla	1310	21AI	Anguilla
# 	Central America	Belize	1210	22BZ	Belize
#
/^([A-Za-z]{1,20}|)\t([A-Za-z.,"& \-]{1,60})\t/ {
	subrg_name = $2
	# print rg_name " / " subrg_name " for " $0
}


##
# Generation of the refdata/ori_region_details.csv file
# Sample input:
# Region	Sub-region	Destination	Old Code	Code	Destination
# Americas	Caribbean	Anguilla	1310	21AI	Anguilla
# 	Central America	Belize	1210	22BZ	Belize
#		USA	1030	23US	USA
#
/^([A-Za-z]{1,20}|)\t([A-Za-z.,"& \-]{1,60}|)\t([A-Za-z.,"& \-\(\)]{1,60})\t/ {
	# Get rid of the header
	if (NF >= 3 && $3 != "Destination") {
		rg_code = toupper(substr(rg_name, 1, 2))
		rg_id = ""
		subrg_code = ""
		cnt_name = $3
		cnt_code_1 = $4
		cnt_code_2 = $5
		# The 2-character ISO country code is extracted from the full
		# country code, e.g., 'ML' (Mali) is extracted from '15ML'
		cnt_code_iso2_idx = length(cnt_code_2) - 1
		if (cnt_code_iso2_idx < 0) {
			cnt_code_iso2_idx = 0
			print "[" FNR "] Error with the country code ('" cnt_code_2 \
					"'). Full line: " $0 > "/dev/stderr" 
		}

		# Remove the quotes, if existing
		if (match (cnt_name, "^\"(.*)\"$")) {
			cnt_name = gensub("^\"(.*)\"$", "\\1", "g", cnt_name)
		}

		# Extract the 2-character ISO code
		cnt_code_iso2 = substr(cnt_code_2, cnt_code_iso2_idx)

		# Convert the country code, if needed (for instance, UK -> GB)
		if (cnt_code_iso2 in cnt_map) {
			cnt_code_iso2 = cnt_map[cnt_code_iso2]
		}

		# print rg_name "," subrg_name "," cnt_name "," cnt_code_1 "," \
		# cnt_code_2 " for " $0

		print "UNWTO^" rg_code "^" rg_name "^" rg_id					\
			"^" subrg_code "^" subrg_name								\
			"^" cnt_name "^" cnt_code_1 "^" cnt_code_2 "^" cnt_code_iso2
	}
}

