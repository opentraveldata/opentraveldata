##
# That AWK script converts a CSV file with quoted string into a hat-separated one
#
# Sample input lines:
#,"AD",,".ANDORRA",,,,,,,,
#,"AD","ALV","Andorra la Vella","Andorra la Vella",,"--34-6--","AI","0601",,"4230N 00131E",""
#"+","AE","HIL","Hail","Hail","AZ","------7-","RL","1801",,"3500N 03330E",
#"=","AE","","Ruwais = Ar Ruways","Ruwais = Ar Ruways","",,"",,"","",""
#,"VN",,".VIET NAM",,,,,,,,
#,"VN","AGG","An Giang","An Giang","44","--3-----","RQ","0901",,,
#,"VN","ANP","An Phú","An Phu","44","--3-----","RL","1401",,"1051N 10505E",
#
# Sample output lines:
#unlc^country_code^unlc_short^name_utf8^name_ascii^state_code^is_port^is_railterm^is_roadterm^is_apt^is_postoff^is_icd^is_fxtpt^is_brdxing^is_unkwn^status^date^iata_code^lat^lon^comments^change_code
#ADALV^AD^ALV^Andorra la Vella^Andorra la Vella^^^^1^1^^1^^^AI^2006-01-01^^^4230N^00131E^^
#

##
# Helper functions
@include "awklib/geo_lib.awk"

##
#
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "prepare_unlc_dump_file.awk"
    fileIdx = 0

    # Log level
    if (!log_level) {
	log_level = 3
    }
	
    # Initialisation of the Geo library
    initGeoAwkLib(awk_file, error_stream, log_level)

    # Global lists
    delete optd_por_unlc_list

    # Description of fields: either anything but a comma,
    # or double-quoted strings
    # Reference: http://www.gnu.org/software/gawk/manual/html_node/Splitting-By-Content.html
    FPAT="[^,]*|\"[^\"]*\""
    #FPAT="[^,\"]*|\"([^\"]|\"\")*\""
    
    # Header
    header_line = "unlc^country_code^unlc_short^name_utf8^name_ascii^state_code^is_port^is_railterm^is_roadterm^is_apt^is_postoff^is_icd^is_fxtpt^is_brdxing^is_unkwn^status^date^iata_code^lat^lon^comments^change_code"
    print (header_line)
}

##
#
BEGINFILE {
    fileIdx++
}

# Extract the name on the left hand side of the sentence
function getLeftName(__tString) {
    split (__tString, __tArray, "=")
    return righttrim(__tArray[1])
}

# Extract the name on the right hand side of the sentence
function getRightName(__tString) {
    split (__tString, __tArray, "=")
    return lefttrim(__tArray[2])
}

# Extract the latitude
# 4230N 00131E
function getLat(__tString) {
    __tString = unquote(__tString)
    if (__tString == "") {
	return ""
    }
    
    split (__tString, __tArray, " ")
    __tCoord = __tArray[1]
    __len = length(__tCoord)
    __tLatInt = substr (__tCoord, 1, 2)
    __tLatDec = "0." substr (__tCoord, 3, __len-3)
    __tLatSign = substr (__tCoord, __len, 1)
    if (__tLatSign == "N") {
	__tLatSign = 1.0

    } else if (__tLatSign == "S") {
	__tLatSign = -1.0

    } else {
	print ("[" awk_file "] Unknown hemisphere. Int: " __tLatInt ", Dec: " \
	       __tLatDec ", +/-: " __tLatSign ", full line: " $0) > error_stream
    }

    __tLat = (__tLatInt + __tLatDec) * __tLatSign
    return __tLat
}

# Extract the longitude
# 4230N 00131E
function getLon(__tString) {
    __tString = unquote(__tString)
    if (__tString == "") {
	return ""
    }
    
    split (__tString, __tArray, " ")
    __tCoord = __tArray[2]
    __len = length(__tCoord)
    __tLonInt = substr (__tCoord, 1, 3)
    __tLonDec = "0." substr (__tCoord, 4, __len-4)
    __tLonSign = substr (__tCoord, __len, 1)
    if (__tLonSign == "E") {
	__tLonSign = 1.0

    } else if (__tLonSign == "W") {
	__tLonSign = -1.0

    } else {
	# Report
	print ("[" awk_file "] Unknown hemisphere. Int: " __tLonInt ", Dec: " \
	       __tLonDec ", +/-: " __tLonSign ", full line: " $0) > error_stream
    }

    __tLon = (__tLonInt + __tLonDec) * __tLonSign
    return __tLon
}

# Check whether the function is known
function getUnknwon(__tString) {
    __tFlag = substr (__tString, 1, 1)
    if (__tFlag == "0") {
	__tFlag = 1
    } else {
	__tFlag = 0
    }

    return __tFlag
}

# Extract a flag from the UN/LOCODE function
function getFlag(__tString, __tIdx) {
    __tFlag = substr (__tString, __tIdx, 1)

    if (__tFlag == "-") {
	__tFlag = 0

    } else if (__tFlag == __tIdx) {
	__tFlag = 1

    } else {
	# Report
	print ("[" awk_file "] Unknown flag. String: " __tString ", Idx: " \
	       __tIdx " => flag: " __tFlag ", full line: " $0) > error_stream
    }

    return __tFlag
}

# Check whether the boarder is crossed
function getBoarderXing(__tString) {
    __tFlag = substr (__tString, 8, 1)
    if (__tFlag == "B") {
	__tFlag = 1

    } else if (__tFlag == "-") {
	__tFlag = 0

    } else {
	# Report
	print ("[" awk_file "] Unknown 8th flag. String: " __tString	\
	       " => flag: " __tFlag ", full line: " $0) > error_stream
    }

    return __tFlag
}

# Extract the year and the month
function getDate(__tString) {
    __tString = unquote(__tString)
    __tYear = substr (__tString, 1, 2)
    if (0 + __tYear > 89) {
	__tYear = 1900 + __tYear
    } else {
	__tYear == 2000 + __tYear
    }
    __tMonth = substr (__tString, 3, 2)
    __tDate = __tYear "-" __tMonth "-01"
    return __tDate
}

##
# First read of the UN/LOCODE data file: process the records not tagged
# as duplicates (with change code being "=")
function processRef() {
    # Initialize the output line
    output_line = ""
    
    # Change code
    change_code = unquote($1)

    # Country code
    country_code = unquote($2)

    # Sanity check
    if (!country_code) {
	print ("[" awk_file "] !!! Error - Country code empty. " $0) \
	    > error_stream
    }

    # UN/LOCODE
    unlc_code = unquote($3)
	
    # Primary Key (PK), made of the country code
    # plus the country level UN/LOCODE
    pk = country_code unlc_code
    
    # UTF8 version of the Name
    name_utf8 = unquote($4)

    # ASCII version of the Name
    name_ascii = unquote($5)

    # Process only the unkwown so far records for that UN/LOCODE / name
    if (change_code == "=") {
	# Do nothing at that stage
	# The processing will occur in the second reading of the data file
	
    } else if (unlc_code) {
	# Country subdivision code
	state_code = unquote($6)

	# por_type
	por_type = unquote($7)
	isUnknwon = getUnknwon(por_type)
	isPort = 0
	if (isUnknwon == 0) {
	    isPort = getFlag(por_type, 1)
	}
	isRail = getFlag(por_type, 2)
	isRoad = getFlag(por_type, 3)
	isApt = getFlag(por_type, 4)
	isPost = getFlag(por_type, 5)
	isICD = getFlag(por_type, 6)
	isFx = getFlag(por_type, 7)
	isBrdXing = getBoarderXing(por_type)

	# Status
	status_code = unquote($8)
    
	# Date
	chg_date = getDate($9)

	# Coordinates
	geo_lat = getLat($11)
	geo_lon = getLon($11)
    
	# IATA code
	iata_code = unquote($12)
    
	# Comments
	comments = unquote($13)
    
	# Output line
	SEP = "^"
	output_line = pk SEP country_code SEP unlc_code
	output_line = output_line SEP name_utf8 SEP name_ascii
	output_line = output_line SEP state_code
	output_line = output_line SEP isPort SEP isRail SEP isRoad SEP isApt
	output_line = output_line SEP isPost SEP isICD SEP isFx SEP isBrdXing
	output_line = output_line SEP isUnknwon
	output_line = output_line SEP status_code SEP chg_date
	output_line = output_line SEP iata_code
	output_line = output_line SEP geo_lat SEP geo_lon
	output_line = output_line SEP comments SEP change_code

	#
    	registerLOCODELine(country_code, name_ascii, output_line)

    } else if (country_code == "FR") {
	# A few records are duplicated records, not at POR but at country level
	# For now, just ignore those
	# Report
	if (log_level >= 4) {
	    print ("[" awk_file "] The duplicate rule for France is ignored: " \
		   $0) > error_stream
	}
	
    } else {
	# Sanity check
	firstCtryChar = substr (name_utf8, 1, 1)
	if (firstCtryChar != ".") {
	    # Report
	    print ("[" awk_file "] Not a country: " $0) > error_stream
	}
    }
    
    # Sanity check
    if (country_code) {
	print (output_line)

    } else {
	# Report
	print ("[" awk_file "] !!! Error with country code - " $0) > error_stream
    }
}

##
# Process the duplicated records.
# That comes at the second reading of the data file, as some referenced records
# (by the duplicated records) appear after the duplicated ones.
# So, the data file has to be read once, so that all the referenced records
# be known.
#
function processDuplicates() {
    # Country code
    country_code = unquote($2)

    # Sanity check
    if (!country_code) {
	print ("[" awk_file "] !!! Error - Country code empty. " $0) \
	    > error_stream
    }

    # UTF8 version of the Name
    name_utf8 = unquote($4)

    # ASCII version of the Name
    name_ascii = unquote($5)

    # Extract the reference names
    name_utf8_ref = getRightName(name_utf8)
    name_ascii_ref = getRightName(name_ascii)

    # Extract the new names
    name_utf8_new = getLeftName(name_utf8)
    name_ascii_new = getLeftName(name_ascii)
	
    output_line = getNewLOCODELine(country_code, name_ascii_ref,	\
				   name_utf8_new, name_ascii_new)

    # DEBUG
    #print ("[" awk_file "] Duplicate name. Ref UTF8 name: " name_utf8_ref \
    #      ", ref ASCII name: " name_ascii_ref ". New UTF8 name: "	\
    #      name_utf8_new ", new ASCII name: " name_ascii_new		\
    #      ". New record: " output_line ", full line: " $0) > error_stream

    # Sanity check
    if (country_code) {
	print (output_line)

    } else {
	# Report
	print ("[" awk_file "] !!! Error with country code - " $0) > error_stream
    }
}

#
# all:  110,362
# POR:  109,907
# diff: 455

##
# Countries
#,"AD",,".ANDORRA",,,,,,,,
#

##
# Alternate names for POR
#"=","AE","","Ruwais = Ar Ruways","Ruwais = Ar Ruways","",,"",,"","",""
#

##
# Alternate names for countries (only FR, apparently)
#
#,"FR",,"Basse-Terre = GP BBR","Basse-Terre = GP BBR",,"1---5---","AF","9506",,,
#,"FR",,"Cayenne = GF CAY","Cayenne = GF CAY",,"---45---","AF","9506",,,
#,"FR",,"Fort-de-France = MQ FDF","Fort-de-France = MQ FDF",,"1--45---","AF","9506",,,
#,"FR",,"Kourou = GF QKR","Kourou = GF QKR",,"1---5---","AF","9506",,,
#,"FR",,"Le Port = RE LPT","Le Port = RE LPT",,"1---5---","AF","9506",,,
#,"FR",,"Pointe-a-Pitre = GP PTP","Pointe-a-Pitre = GP PTP",,"1--45---","AF","9506",,,
#,"FR",,"Saint-Denis = RERUN","Saint-Denis = RERUN",,"---45---","AF","1101",,,
#,"FR",,"Saint-Laurent-du-Maroni = GF SLM","Saint-Laurent-du-Maroni = GF SLM",,"1---5---","AF","1101",,,
#,"FR",,"Saint-Pierre = PM FSP","Saint-Pierre = PM FSP",,"1---5---","AF","1101",,,
#
/^(|""),"[A-Z]{2}",(|""),".+=.+"/ {
}

##
#
#,"AD","ALV","Andorra la Vella","Andorra la Vella",,"--34-6--","AI","0601",,"4230N 00131E",""
#"+","AE","HIL","Hail","Hail","AZ","------7-","RL","1801",,"3500N 03330E",
#"=","AE","","Ruwais = Ar Ruways","Ruwais = Ar Ruways","",,"",,"","",""
#
# Sample output lines:
#unlc^country_code^unlc_short^name_utf8^name_ascii^state_code^is_port^is_railterm^is_roadterm^is_apt^is_postoff^is_icd^is_fxtpt^is_brdxing^is_unkwn^status^date^iata_code^lat^lon^comments^change_code
#
# Change codes: "", "!", "#", "+", "=", "X", "¦"
# /^(|"[#!+=X¦]"|""),"[A-Z]{2}","[0-9A-Z]{3}"/
// {
    if (fileIdx == 1) {
	processRef()

    } else if (fileIdx == 2) {
	# Change code
	change_code = unquote($1)

	# Duplicates
	if (change_code == "=") {
	    processDuplicates()
	}
	
    } else {
	# Report
    }
}

// {
    #print ($0)
}

##
#
END {
}
