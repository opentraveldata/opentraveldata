##
#

##
# Function to be called during the BEGIN section
function initGeoAwkLib(__igalParamAWKFile, __igalParamErrorStream, \
		       __igalParamLogLevel) {
    # Global variables
    __glGlobalAWKFile = __igalParamAWKFile
    __glGlobalErrorStream = __igalParamErrorStream
    __glGlobalLogLevel = __igalParamLogLevel
    __glGlobalIsForGeonames = 0
    __glGlobalIsForREF = 0
    __glGlobalIsForInnovata = 0
    __glGlobalPI = 4 * atan2(1,1)
    __glGlobalRTOD = 180.0 / __glGlobalPI
    __glGlobalDTOR = __glGlobalPI / 180.0
    __glGlobalNM = 1852

    # Debugging support
    __glGlobalDebugIataCode = ""
    #__glGlobalDebugIataCode = "AAE"
    #__glGlobalDebugIataCode = "RDU"

    # Initialise the OPTD-derived lists
    resetOPTDLineList()

	# Initialise the US DOT-derived lists
	resetDOTLineList()

    # Initialise the PageRank-derived lists
    resetPageRankList()
}

##
# Various simple mathematics functions
function Abs(x)    { return x < 0 ? -x : x }
function Floor(x)  { return x < 0 ? int(x) - 1 : int(x) }
function Mod(x,y)  { return x - y * Floor(x/y) }
function Sin(x)    { return sin(x * __glGlobalDTOR) }
function Cos(x)    { return cos(x * __glGlobalDTOR) }
function Tan(x)    { return Sin(x)/Cos(x) }
function ASin(x)   { return atan2(x,sqrt(1 - x * x))*__glGlobalRTOD }
function ACos(x)   { return atan2(sqrt(1 - x * x),x)*__glGlobalRTOD }
function ATan2(y,x){ return atan2(y,x)*__glGlobalRTOD }

##
# Function to be called during the BEGINFILE section
function initFileGeoAwkLib() {
    # Initialise the Geonames-derived lists
    resetGeonamesLineList()
    # Initialise the reference data lists
    resetREFLineList()
    # Initialise the Innovata-derived lists
    resetInnovataLineList()
}

##
# Function to be called during the ENDFILE section
function finalizeFileGeoAwkLib() {
}

##
# Function to be called during the END section
function finalizeGeoAwkLib() {
    # Display the last Geonames POR entries, if appropriate
    if (__glGlobalIsForGeonames == 1) {
	displayGeonamesPOREntries()
    }

    # Display the last reference data POR entries
    if (__glGlobalIsForREF == 1) {
	displayREFPOREntries()
    }

    # Display the last Innovata POR entries
    if (__glGlobalIsForInnovata == 1) {
	displayInnovataPOREntries()
    }
}

##
# Display the header of the OPTD POR public data file
function displayOPTDPorPublicHeader(__dopphFullLine) {
    # Just add the 'pk' (meaning primary key) word
    print ("pk^" __dopphFullLine)
}

##
# Display a list
function displayList(__paramListType, __paramList) {
    if (length(__paramList) == 0) {
		return
    }

    print (__paramListType ":")
    for (myIdx in __paramList) {
		print (myIdx " => " __paramList[myIdx])
    }
}

##
# Display a 2-dimensional list
function display2dList(__paramListType, __paramList) {
    if (length(__paramList) == 0) {
		return
    }

    print (__paramListType ":")
    for (myCombIdx in __paramList) {
		split (myCombIdx, myIdxArray, SUBSEP)
		myIdx1 = myIdxArray[1]; myIdx2 = myIdxArray[2]
		print ("[" __paramListType "] " myIdx1 ", " myIdx2 " => "	\
			   __paramList[myIdx1, myIdx2])
    }
}

##
# Display all the geographical-related lists:
# cities, airports, heliports, railway stations, bus stations, ground stations,
# maritime ports and off-line points.
function displayLists() {
    #
    displayList("Cities", city_list)
    displayList("Airports", airport_list)
    displayList("Heliports", heliport_list)
    displayList("Railway stations", rail_list)
    displayList("Bus stations", bus_list)
    displayList("Metro stations", metro_list)
    displayList("Ground stations", ground_list)
    displayList("Ports", port_list)
    displayList("Off-line points", offpoint_list)
	displayList("DOT country POR lists", dot_ctry_por_list)

    # OpenTravelData
    display2dList("OPTD POR indices", optd_por_idx_list)
    display2dList("OPTD POR latitude", optd_por_lat_list)
    display2dList("OPTD POR longitude", optd_por_lon_list)
    display2dList("OPTD POR city list", optd_por_cty_list)
	display2dList("OPTD POR list per airline", optd_por_air_list)
    display2dList("OPTD POR beginning date list", optd_por_bdate_list)

	# US DOT
	display2dList("DOT country indices", dot_ctry_idx_list)
	display2dList("DOT country indices", dot_por_name_list)
	display2dList("DOT country indices", dot_por_area_list)
}

##
# Support function to capitalise all the words of a given string
function capitaliseWords(__cwInStr) {
    # Current string
    __cwRmgStr = __cwInStr

    # Target string
    __cwGenStr = ""

    # Loop until there is no more match (on words)
    while (__cwIdx = match (__cwRmgStr, /(\/?[[:alnum:]]+)/)) {

	# Extract a single-character prefix, if any
	__cwPrefixChar = substr (__cwRmgStr, __cwIdx, 1)

	# When the word is prefixed by a slash ('/'), it is most probably
	# a country or state code. In that latter case, it should not be
	# capitalised.
	__cwMatchLen = RLENGTH
	if (__cwPrefixChar == "/") {
	    __cwIdx++
	    __cwMatchLen--
	}

	# Extract the (matched) word
	__cwWordStr = substr (__cwRmgStr, __cwIdx, __cwMatchLen)

	# Insulate the first letter
	__cwFirstLetter = substr (__cwWordStr, 1, 1)

	# Insulate the remaining letters, if any
	if (__cwMatchLen >= 2) {
	    __cwRmgLetters = substr (__cwWordStr, 2)
	} else {
	    __cwRmgLetters = ""
	}

	# DEBUG
	# print ("idx=" __cwIdx ", pfx=" __cwPrefixChar ", fl=" __cwFirstLetter \
	#	   ", rmg=" __cwRmgLetters ", rlen=" __cwMatchLen ", word=" __cwWordStr)

	if (__cwPrefixChar != "/") {
	    # Capitalise the word
	    __cwFirstLetter = toupper (__cwFirstLetter)
	    __cwRmgLetters = tolower (__cwRmgLetters)
	}

	# Re-aggregate the (now capitalised) word
	__cwWordStr = __cwFirstLetter __cwRmgLetters

	# Add the separator (white space here)
	if (__cwGenStr != "") {
	    __cwGenStr = __cwGenStr " "
	}

	# Add the capitalised work to the target string
	__cwGenStr = __cwGenStr __cwWordStr

	# Remove the match from the current string
	__cwRmgStr = substr (__cwRmgStr, __cwIdx + __cwMatchLen)
    }

    return __cwGenStr
}

##
# State whether the POR is (matches with) a city
function isLocTypeCity(__iltcParamLocationType) {
    __resultIsCity = match (__iltcParamLocationType, "[CO]")
    return __resultIsCity
}

##
# State whether the POR is an airport
function isLocTypeAirport(__ilttrParamLocationType) {
    __resultIsAirport = match (__ilttrParamLocationType, "[A]")
    return __resultIsAirport
}

##
# State whether the POR is travel-related
function isLocTypeTvlRtd(__ilttrParamLocationType) {
    __isAirport = isLocTypeAirport(__ilttrParamLocationType)
    __isHeliport = match (__ilttrParamLocationType, "[H]")
    __isRail = match (__ilttrParamLocationType, "[R]")
    __isBus = match (__ilttrParamLocationType, "[B]")
    __isGround = match (__ilttrParamLocationType, "[G]")
    __isPort = match (__ilttrParamLocationType, "[P]")
    __isOffpoint = match (__ilttrParamLocationType, "[O]")

    # Aggregation
    __resultIsTravelRelated = __isAirport + __isHeliport + __isRail + __isBus \
	+ __isGround + __isPort + __isOffpoint

    return __resultIsTravelRelated
}

##
# State whether the POR is (matches with) a city
function isFeatCodeCity(__ifccParamFeatureCode) {
    # City, populated place, administrative locality, political entity, island
    __resultIsCity  = match (__ifccParamFeatureCode, "^PPL")
    __resultIsCity += match (__ifccParamFeatureCode, "^ADM")
    __resultIsCity += match (__ifccParamFeatureCode, "^LCTY")
    __resultIsCity += match (__ifccParamFeatureCode, "^PCL")
    __resultIsCity += match (__ifccParamFeatureCode, "^RGN")
    __resultIsCity += match (__ifccParamFeatureCode, "^AREA")
    __resultIsCity += match (__ifccParamFeatureCode, "^HMSD")
    __resultIsCity += match (__ifccParamFeatureCode, "^ISL")
    __resultIsCity += match (__ifccParamFeatureCode, "^ATOL")
    __resultIsCity += match (__ifccParamFeatureCode, "^LK")
    __resultIsCity += match (__ifccParamFeatureCode, "^RSV")
    __resultIsCity += match (__ifccParamFeatureCode, "^BAY")
    __resultIsCity += match (__ifccParamFeatureCode, "^HBR")
    __resultIsCity += match (__ifccParamFeatureCode, "^CHN")
    __resultIsCity += match (__ifccParamFeatureCode, "^DAM")
    __resultIsCity += match (__ifccParamFeatureCode, "^PAN")
    __resultIsCity += match (__ifccParamFeatureCode, "^OAS")
    __resultIsCity += match (__ifccParamFeatureCode, "^CMP")
    __resultIsCity += match (__ifccParamFeatureCode, "^PRK")
    __resultIsCity += match (__ifccParamFeatureCode, "^RES")
    __resultIsCity += match (__ifccParamFeatureCode, "^AMUS")
    __resultIsCity += match (__ifccParamFeatureCode, "^CAPE")
    __resultIsCity += match (__ifccParamFeatureCode, "^PT")
    __resultIsCity += match (__ifccParamFeatureCode, "^PLAT")
    __resultIsCity += match (__ifccParamFeatureCode, "^VLC")
    __resultIsCity += match (__ifccParamFeatureCode, "^MT")
    __resultIsCity += match (__ifccParamFeatureCode, "^RK")
    __resultIsCity += match (__ifccParamFeatureCode, "^CNYN")
    __resultIsCity += match (__ifccParamFeatureCode, "^MN")
    __resultIsCity += match (__ifccParamFeatureCode, "^INSM")

    return __resultIsCity
}

##
# State whether the POR is an airport (or air field/base or sea plane base)
function isFeatCodeAirport(__ifcaParamFeatureCode) {
    # Airport (AIRP)
    __resultIsAirport  = match (__ifcaParamFeatureCode, "AIRP")
    # Airfield (AIRF)
    __resultIsAirport += match (__ifcaParamFeatureCode, "AIRF")
    # Airbase (AIRB)
    __resultIsAirport += match (__ifcaParamFeatureCode, "AIRB")
    # Sea plane base (AIRS), a.k.a. SPB
    __resultIsAirport += match (__ifcaParamFeatureCode, "AIRS")
    # Abandonned airport (AIRQ)
    __resultIsAirport += match (__ifcaParamFeatureCode, "AIRQ")

    return __resultIsAirport
}

##
# State whether the POR is an heliport
function isFeatCodeHeliport(__ifchParamFeatureCode) {
    # Heliport
    __resultIsHeliport = match (__ifchParamFeatureCode, "AIRH")

    return __resultIsHeliport
}

##
# State whether the POR is a railway station
function isFeatCodeRail(__ifcrParamFeatureCode) {
    # Railway station
    __resultIsRail = match (__ifcrParamFeatureCode, "RSTN")

    return __resultIsRail
}

##
# State whether the POR is a bus station or stop
function isFeatCodeBus(__ifcbParamFeatureCode) {
    # Bus station (BUSTN) or bus stop (BUSTP)
    __resultIsBus = match (__ifcbParamFeatureCode, "BUST")

    return __resultIsBus
}

##
# State whether the POR is a metro station
function isFeatCodeMetro(__ifcmParamFeatureCode) {
    # Metro station
    __resultIsMetro = match (__ifcmParamFeatureCode, "MTRO")

    return __resultIsMetro
}

##
# State whether the POR is a maritime port or ferry or naval base
function isFeatCodePort(__ifcpParamFeatureCode) {
    # Naval base (NVB), maritime port (PRT), ferry (FY)
    __resultIsPort  = match (__ifcpParamFeatureCode, "NVB")
    __resultIsPort += match (__ifcpParamFeatureCode, "PRT")
    __resultIsPort += match (__ifcpParamFeatureCode, "FY")

    return __resultIsPort
}

##
# State whether the POR is travel-related
function isFeatCodeTvlRtd(__ifctrParamFeatureCode) {
    # Airbase (AIRB), airport (AIRP), airfield (AIRF), sea plane base (AIRS)
    __isAirport  = isFeatCodeAirport(__ifctrParamFeatureCode)

    # Heliport
    __isHeliport = isFeatCodeHeliport(__ifctrParamFeatureCode)

    # Railway station
    __isRail = isFeatCodeRail(__ifctrParamFeatureCode)

    # Bus station or bus stop
    __isBus = isFeatCodeBus(__ifctrParamFeatureCode)

    # Metro station
    __isMetro = isFeatCodeMetro(__ifctrParamFeatureCode)

    # Naval base, maritime port or ferry
    __isPort  = isFeatCodePort(__ifctrParamFeatureCode)


    # Aggregation
    __resultIsTravelRelated = __isAirport + __isHeliport + __isRail \
		+ __isBus + __isMetro + __isPort

    return __resultIsTravelRelated
}

##
# Derive the Geonames feature class.
# See also http://www.geonames.org/export/codes.html
function getFeatureClass(__gfcParamLocationType) {
    __resultFeatureClass = "NA"

    switch (__gfcParamLocationType) {
    case "C": case "O":
		__resultFeatureClass = "P"
		break
    case "A": case "H": case "R": case "B": case "P": case "G": \
		__resultFeatureClass = "S"
		break
    }

    return __resultFeatureClass
}

##
# Derive the Geonames feature code.
# See also http://www.geonames.org/export/codes.html
function getFeatureCode(__gfcParamLocationType) {
    __resultFeatureCode = "NA"

    switch (__gfcParamLocationType) {
    case "C": case "O":
		__resultFeatureCode = "PPL"
		break
    case "A":
		__resultFeatureCode = "AIRP"
		break
    case "H":
		__resultFeatureCode = "AIRH"
		break
    case "R":
		__resultFeatureCode = "RSTN"
		break
    case "B":
		__resultFeatureCode = "BUSTN"
		break
    case "G":
		__resultFeatureCode = "RSTN"
		break
    case "P":
		__resultFeatureCode = "FY"
		break
    }

    return __resultFeatureCode
}

##
# Derive the OPTD/IATA location type.
# See also http://www.geonames.org/export/codes.html
function getLocTypeFromFeatCode(__gltParamFeatureCode) {
    __resultLocationType = "NA"

    if (isFeatCodeCity(__gltParamFeatureCode)) {
		# City
		__resultLocationType = "C"

    } else if (isFeatCodeAirport(__gltParamFeatureCode)) {
		# Airport
		__resultLocationType = "A"

    } else if (isFeatCodeHeliport(__gltParamFeatureCode)) {
		# Heliport
		__resultLocationType = "H"

    } else if (isFeatCodeRail(__gltParamFeatureCode)) {
		# Railway station
		__resultLocationType = "R"

    } else if (isFeatCodeBus(__gltParamFeatureCode)			\
			   || isFeatCodeMetro(__gltParamFeatureCode)) {
		# Bus station/stop or metro station
		__resultLocationType = "B"

    } else if (isFeatCodePort(__gltParamFeatureCode)) {
		# Maritime port, ferry, naval base
		__resultLocationType = "P"
    }

    return __resultLocationType
}

##
# Convert the geographical coordinates (latitude) from the Innovata format
# into the standard ones
function convertLatToStd(__cgcLat) {
    # Specification of the latitude format
    lat_regexp = "^([0-9]{2})([0-9]{2})([0-9]{2})(S|N)$"

    # Sign (+ for North, - for South)
    cgcStdLatSgn = gensub (lat_regexp, "\\4", "g", __cgcLat)

    # Degrees, minutes, seconds
    cgcStdLatDeg = gensub (lat_regexp, "\\1", "g", __cgcLat)
    cgcStdLatMin = gensub (lat_regexp, "\\2", "g", __cgcLat)
    cgcStdLatSec = gensub (lat_regexp, "\\3", "g", __cgcLat)

    cgcStdLat = cgcStdLatDeg
    cgcStdLat += (cgcStdLatMin / 60.0)
    cgcStdLat += (cgcStdLatSec / 6000.0)

    if (cgcStdLatSgn == "S") {
	cgcStdLat = -1 * cgcStdLat
    }
    return cgcStdLat
}

##
# Convert the geographical coordinates (longitude) from the Innovata format
# into the standard ones
function convertLonToStd(__cgcLon) {
    # Specification of the longitude format
    lon_regexp = "^([0-9]{3})([0-9]{2})([0-9]{2})(W|E)$"

    # Sign (+ for West, - for East)
    cgcStdLonSgn = gensub (lon_regexp, "\\4", "g", __cgcLon)

    # Degrees, minutes, seconds
    cgcStdLonDeg = gensub (lon_regexp, "\\1", "g", __cgcLon)
    cgcStdLonMin = gensub (lon_regexp, "\\2", "g", __cgcLon)
    cgcStdLonSec = gensub (lon_regexp, "\\3", "g", __cgcLon)

    cgcStdLon = cgcStdLonDeg
    cgcStdLon += (cgcStdLonMin / 60.0)
    cgcStdLon += (cgcStdLonSec / 6000.0)

    if (cgcStdLonSgn == "W") {
	cgcStdLon = -1 * cgcStdLon
    }
    return cgcStdLon
}

##
# Extract the details of the primary key:
# 1. The IATA code
# 2. The OPTD-maintained location type
# 3. The OPTD-maintained Geonames ID
function extractPrimaryKeyDetails(__epkdParamPK) {
    # Specification of the primary key format
    pk_regexp = "^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,15})$"

    # IATA code (first field of the primary key)
    epkdIataCode = gensub (pk_regexp, "\\1", "g", __epkdParamPK)

    # Location type (second field of the primary key)
    epkdLocationType = gensub (pk_regexp, "\\2", "g", __epkdParamPK)

    # Geonames ID (third field of the primary key)
    epkdGeonamesID = gensub (pk_regexp, "\\3", "g", __epkdParamPK)
}

##
# Extract the primary key fields as an array.
# Note that, with AWK, the array index begins with 1 (not 0).
# Hence, the IATA code will be __resultPKArray[1]
function getPrimaryKeyAsArray(__gpkaaParamPK, __resultPKArray) {
    __resultNbOfFields = split (__gpkaaParamPK, __resultPKArray, "-")
    return __resultNbOfFields
}

##
# Generate the primary key from the corresponding fields.
function getPrimaryKey(__gpkParamIataCode, __gpkParamLocationType, \
					   __gpkParamGeonamesID) {
    __resultPK =														\
		__gpkParamIataCode "-" __gpkParamLocationType "-" __gpkParamGeonamesID
    return __resultPK
}

##
# The given string is a list. Sort it.
#
function sortListStringAplha(__slsParamListString, __slsParamSep) {
    __resultNbOfFields = split (__slsParamListString, __resultArray, \
								__slsParamSep)
	#
	asort(__resultArray)

	# Browse the list of travel-related POR IATA codes
	__resultListString = ""
	delete __resultUniqArray
	for (idx in __resultArray) {
		__TvlCode = __resultArray[idx]

		__isAlreadyInArray = __resultUniqArray[__TvlCode]
		if (__isAlreadyInArray) {
			# When the travel-related POR already appears in the list,
			# do not add it again
			continue

		} else {
			# Register that that travel-related POR is in the list
			__resultUniqArray[__TvlCode] = 1
		}

		# Add the separator when needed
		if (int(idx) >= 2) {
			__resultListString = __resultListString __slsParamSep
		}

		# Add the travel-related POR IATA code to the dedicated list
		__resultListString = __resultListString __TvlCode
	}
	return __resultListString
}

##
# Add the given field content to the given dedicated list. The field content
# and the list correspond to the file of best known coordinates.
#
function addFieldToList(__aftlParamIataCode, __aftlParamList, __aftlParamField) {
    myTmpString = __aftlParamList[__aftlParamIataCode]
    if (myTmpString) {
		myTmpString = myTmpString ","
    }
    myTmpString = myTmpString __aftlParamField
    __aftlParamList[__aftlParamIataCode] = myTmpString
}

##
# Add the given location type to the given dedicated OPTD list. The location type
# and the list correspond to the file of best known coordinates.
#
function addLocTypeToOPTDList(__alttolParamIataCode, __alttolParamLocationType, \
							  __alttolParamOPTDList) {
    myTmpString = __alttolParamOPTDList[__alttolParamIataCode]

    # If the location type is already listed, do not add it again.
    # Note that the OPTD-derived location types may be combined. For instance,
    # 'CA' is a typical OPTD-derived location type. So, let us assume that the
    # list of the OPTD-derived location types is {'CA'} and that 'C' is to be
    # added. If the AWK match() is used in that case, it will return a positive
    # match (as 'C' is part of 'CA'), but 'C' is different from 'CA'.
    # That is why the list of OPTD-derived location types must be split before
    # checking each of them one by one.
    # See also the addLocTypeToAllGeoList() function below.
    split (myTmpString, alttolOPTDLocTypeArray, ",")
    for (alttolOPTDLocTypeIdx in alttolOPTDLocTypeArray) {
		alttolOPTDLocType = alttolOPTDLocTypeArray[alttolOPTDLocTypeIdx]
		if (alttolOPTDLocType == __alttolParamLocationType) {
			# DEBUG
			#print ("[" __alttolParamIataCode "-" __alttolParamLocationType \
			#	   "] already exists. Indeed, the OPTD loc_type list is: " \
			#	   myTmpString) > __glGlobalErrorStream
			return
		}
    }

    # By construction, we are now sure that the given location type
    # is not already listed
    if (myTmpString) {
		myTmpString = myTmpString ","
    }

    # Add the given location type
    myTmpString = myTmpString __alttolParamLocationType
    __alttolParamOPTDList[__alttolParamIataCode] = myTmpString
}

##
# Add the given Geonames ID to the given dedicated OPTD list. The Geonames ID
# and the list correspond to the file of best known coordinates.
#
function addGeoIDToOPTDList(__agitolParamIataCode, __agitolParamLocationType, \
							__agitolParamGeonamesID, __agitolParamOPTDList) {
    myTmpString = \
	__agitolParamOPTDList[__agitolParamIataCode, __agitolParamLocationType]
    if (myTmpString) {
		myTmpString = myTmpString ","
    }
    myTmpString = myTmpString __agitolParamGeonamesID
    __agitolParamOPTDList[__agitolParamIataCode, __agitolParamLocationType] = \
		myTmpString
}

##
# Add the given Geonames ID to the given dedicated Geonames list.
# The Geonames ID and the list correspond to the Geonames data dump.
#
function addGeoIDToGeoList(__agitolParamLocationType, __agitolParamGeonamesID, \
						   __agitolParamGeoList) {
    myTmpString = __agitolParamGeoList[__agitolParamLocationType]
    if (myTmpString) {
		myTmpString = myTmpString ","
    }
    myTmpString = myTmpString __agitolParamGeonamesID
    __agitolParamGeoList[__agitolParamLocationType] = myTmpString
}

##
# Add the given location type to the given dedicated Geonames list.
# The Geonames ID and the list correspond to the Geonames data dump.
#
function addLocTypeToGeoList(__alttglParamGeonamesID,	\
							 __alttglParamLocationType, \
							 __alttglParamGeoList) {
    myTmpString = __alttglParamGeoList[__alttglParamGeonamesID]
    if (myTmpString) {
		myTmpString = myTmpString ","
    }
    myTmpString = myTmpString __alttglParamLocationType
    __alttglParamGeoList[__alttglParamGeonamesID] = myTmpString
}

##
# Add the given location type to the given dedicated Geonames
# or reference data list.
#
function addLocTypeToAllGeoList(__alttglParamLocationType,	\
								__alttglParamGeoString) {
    __resultGeoString = __alttglParamGeoString

    # If the location type is already listed, do not add it again.
    # Note that, contrary to what may happen with OPTD-derived location types
    # (see the addLocTypeToOPTDList() function above),
    # the Geonames-derived location types are not combined. For instance,
    # 'CA' is a typical OPTD-derived location type. In Geonames, by construction,
    # there would be two POR entries with non-combined location types,
    # 'C' and 'A' in that example. Hence, the AWK match() function is enough
    # to check that the location type does not already exist.
    if (match (__alttglParamGeoString, __alttglParamLocationType)) {
	return __resultGeoString
    }

    # Register the location type
    if (__resultGeoString) {
		__resultGeoString = __resultGeoString ","
    }
    __resultGeoString = __resultGeoString __alttglParamLocationType
    return __resultGeoString
}

##
# Add the given Geonames ID to the given dedicated Geonames list.
# The Geonames ID and the list correspond to the Geonames data dump.
#
function addGeoIDToAllGeoList(__alttaglParamGeonamesID,__alttaglParamGeoString) {
    __resultGeoString = __alttaglParamGeoString

    # If the Geonames ID is already listed, notify the user
    if (match (__alttaglParamGeoString, __alttaglParamGeonamesID)) {
		print ("[" __glGlobalAWKFile "] !!!! Error at line #" FNR		\
			   ", the Geonames ID (" __alttaglParamGeonamesID			\
			   ") already exists ('" __alttaglParamGeoString			\
			   "'): it is a duplicate. Check the Geonames data dump. By " \
			   "construction, that should not happen!")					\
			> __glGlobalErrorStream
		return __resultGeoString
    }

    # Register the location type
    if (__resultGeoString) {
		__resultGeoString = __resultGeoString ","
    }
    __resultGeoString = __resultGeoString __alttaglParamGeonamesID
    return __resultGeoString
}

##
# Add the given IATA code to the given US DOT list of area codes.
#
function addDOTFieldToList(__adftlParamIataCode, __adftlParamDOTList, \
						   __adftlParamDOTAreaCode) {
    # Register the details of the US DOT-maintained POR entry for the given field
    myTmpString = __adftlParamDOTList[__adftlParamDOTAreaCode]
    if (myTmpString) {
		myTmpString = myTmpString ","
    }
    myTmpString = myTmpString __adftlParamIataCode
    __adftlParamDOTList[__adftlParamDOTAreaCode] = myTmpString
}

##
# Add a given field to the given dedicated OPTD list. The field and the list
# correspond to the file of best known coordinates and, therefore, are one
# of the following:
# * Latitude
# * Longitude
# * Served city IATA code(s)
# * Beginning date of the validity range
#
function addOPTDFieldToList(__aoftlParamIataCode, __aoftlParamLocationType, \
							__aoftlParamOPTDList, __aoftlParamOPTDField) {
    # Register the details of the OPTD-maintained POR entry for the given field
    myTmpString = \
		__aoftlParamOPTDList[__aoftlParamIataCode, __aoftlParamLocationType]
    if (myTmpString) {
		myTmpString = myTmpString ","
    }
    myTmpString = myTmpString __aoftlParamOPTDField
    __aoftlParamOPTDList[__aoftlParamIataCode, __aoftlParamLocationType] = \
		myTmpString
}

##
# Register the details of the OPTD-maintained POR entry. Those details are:
# 1. The primary key:
# 1.1. The IATA code
# 1.2. The OPTD-maintained location type
# 1.3. The OPTD-maintained Geonames ID
# 2. The IATA code of the POR itself
# 3. The geographical coordinates (latitude and longitude)
# 4. The IATA code (list) of the served cit(y)(ies)
# 5. The beginning date of the validity range.
#    When blank, it has always been valid.
#
# Note 1: the location type is either individual (e.g., 'C', 'A', 'H', 'R', 'B',
#         'P', 'G', 'O') or combined (e.g., 'CA', 'CH', 'CR', 'CB', 'CP')
#
function registerOPTDLine(__rolParamPK, __rolParamIataCode2,	\
						  __rolParamLatitude, __rolParamLongitude,	\
						  __rolParamServedCityCode, __rolParamBeginDate, \
						  __rolParamFullLine) {
    # Extract the primary key fields
    getPrimaryKeyAsArray(__rolParamPK, myPKArray)
    rolIataCode = myPKArray[1]
    rolLocationType = myPKArray[2]
    rolGeonamesID = myPKArray[3]

    # Analyse the location type
    myIsCity = isLocTypeCity(rolLocationType)
    myIsTravel = isLocTypeTvlRtd(rolLocationType)

    # DEBUG
    # print ("PK=" __rolParamPK ", IATA code=" rolIataCode ", loc_type=" \
    #	   rolLocationType ", GeoID=" rolGeonamesID ", srvd city="		\
    #	   __rolParamServedCityCode ", beg date=" __rolParamBeginDate ", awk=" \
    #	   awk_file ", err=" __glGlobalErrorStream)

    # Sanity check: the IATA codes of the primary key and of the dedicated field
    #               should be equal.
    if (rolIataCode != __rolParamIataCode2) {
		print ("[" __glGlobalAWKFile "] !!!! Error at line #" FNR	 \
			   ", the IATA code ('" rolIataCode "') of the primary key " \
			   "is not the same as the one of the dedicated field ('"	\
			   __rolParamIataCode2 "') - Full line: " __rolParamFullLine) \
			> __glGlobalErrorStream
    }

    # Sanity check: when the location type is a combined type, one of those
    #               types should be a travel-related POR.
    if (length(rolLocationType) >= 2 && myIsTravel == 0) {
		print ("[" __glGlobalAWKFile "] !!!! Error at line #" FNR	\
			   ", the location type ('"	rolLocationType				\
			   "') is unknown - Full line: " __rolParamFullLine)	\
			> __glGlobalErrorStream
    }

    # Add the location type to the dedicated list for that IATA code
    addLocTypeToOPTDList(rolIataCode, rolLocationType, optd_por_loctype_list)

    # Add the Geonames ID to the dedicated list for that (IATA code, location
    # type)
    addGeoIDToOPTDList(rolIataCode, rolLocationType, rolGeonamesID,	\
					   optd_por_geoid_list)

    # Calculate the index for that IATA code
    optd_por_idx_list[rolIataCode, rolLocationType]++
    optd_por_idx = optd_por_idx_list[rolIataCode, rolLocationType]

    # Register the details of the OPTD-maintained POR entry for the latitude
    addOPTDFieldToList(rolIataCode, rolLocationType,			\
					   optd_por_lat_list, __rolParamLatitude)

    # Register the details of the OPTD-maintained POR entry for the longitude
    addOPTDFieldToList(rolIataCode, rolLocationType,			\
					   optd_por_lon_list, __rolParamLongitude)

    # Register the details of the OPTD-maintained POR entry for the (list of)
    # served cit(y)(ies)
    addOPTDFieldToList(rolIataCode, rolLocationType,				\
					   optd_por_cty_list, __rolParamServedCityCode)

    # Register the details of the OPTD-maintained POR entry for the beg. date
    addOPTDFieldToList(rolIataCode, rolLocationType,				\
					   optd_por_bdate_list, __rolParamBeginDate)
}

##
# Get the field for the given (list, POR IATA code) pair
function getOPTDFieldFromList(__gofflIataCode, __gofflLocType, __gofflList) {
	return __gofflList[__gofflIataCode, __gofflLocType]
}

##
# Get the geographical latitude for the given POR IATA code
function getOPTDPorLatitude(__goplIataCode, __goplLocType) {
	return getOPTDFieldFromList(__goplIataCode, __goplLocType, optd_por_lat_list)
}

##
# Get the geographical longitude for the given POR IATA code
function getOPTDPorLongitude(__goplIataCode, __goplLocType) {
	return getOPTDFieldFromList(__goplIataCode, __goplLocType, optd_por_lon_list)
}

##
# Get the city code (list) for the given POR IATA code
function getOPTDPorCityCodeList(__goplIataCode, __gopcclLocType) {
	return getOPTDFieldFromList(__goplIataCode, __gopcclLocType,	\
								optd_por_cty_list)
}

##
# Get the beginning date for the given POR IATA code
function getOPTDPorBegDate(__goplIataCode, __gopbdLocType) {
	return getOPTDFieldFromList(__goplIataCode, __gopbdLocType, \
								optd_por_bdate_list)
}

##
# Register the flight frequency for a given (origin, destination) POR pair,
# for a given airline. The input parameters are:
# 1. The airline 2-char ISO code
# 2. The origin POR
# 3. The destination POR
# 4. The number of flights (flight frequency) for that (origin, destination) pair
#
function registerPORAirlineLine(__rpalAirline, __rpalPOROrg,	\
								__rpalPORDst, __rpalFltFreq) {
    # DEBUG
    # print ("Airline code=" __rpalAirline ", origin=" __rpalPOROrg		\
    #	   ", destination=" __rpalPORDst ", flight frquency=" __rpalFltFreq	\
	#      "awk=" awk_file ", err=" __glGlobalErrorStream)

	# Register the US DOT-maintained POR name and area code
	optd_por_air_list[__rpalAirline, __rpalPOROrg] += __rpalFltFreq
	optd_por_air_list[__rpalAirline, __rpalPORDst] += __rpalFltFreq
}

##
# Retrieve the flight frequency for a given (airline, POR) combination.
# The input parameters are:
# 1. The airline 2-char ISO code
# 2. The POR IATA code
# The function returns the accumulated number of flights (flight frequency)
# for that (airline, POR) combination
#
function getAirlinePORFltFreq(__gapffAirline, __gapffPOR) {
	outputFltFreq = optd_por_air_list[__gapffAirline, __gapffPOR]
	return outputFltFreq
}

##
# Register the details of the US DOT-maintained POR entry. Those details are:
# 1. The IATA code
# 2. The DOT-maintained location name
# 3. The DOT-maintained area (country) code
#
function registerDOTLine(__rdlParamIataCode, __rdlParamName, \
						 __rdlParamAreaCode, __rdlParamFullLine) {
    # DEBUG
    # print ("IATA code=" __rdlParamIataCode ", loc_name="				\
    #	   __rdlParamName ", AreaCode=" __rdlParamAreaCode ", awk="		\
    #	   awk_file ", err=" __glGlobalErrorStream)

	# Register the US DOT-maintained POR name and area code
    dot_por_name_list[__rdlParamIataCode] = __rdlParamName
    dot_por_area_list[__rdlParamIataCode] = __rdlParamAreaCode
 
    # Calculate the index for that IATA code
    dot_ctry_idx_list[__rdlParamAreaCode]++
    dot_ctry_idx = dot_ctry_idx_list[__rdlParamAreaCode]

    # Register the US DOT-maintained area code for that POR entry
    addDOTFieldToList(__rdlParamAreaCode, dot_ctry_por_list, __rdlParamIataCode)
}

##
# Reset the list of the OPTD-maintained POR entries
function resetOPTDLineList() {
    delete optd_por_loctype_list
    delete optd_por_geoid_list
    delete optd_por_idx_list
    delete optd_por_lat_list
    delete optd_por_lon_list
    delete optd_por_cty_list
    delete optd_por_bdate_list
	delete optd_por_air_list
}

##
# Reset the list of the US DOT-maintained POR entries
function resetDOTLineList() {
    delete dot_ctry_idx_list
    delete dot_ctry_por_list
    delete dot_por_name_list
    delete dot_por_area_list
}

##
# Reset the list of last Geonames POR entries
function resetGeonamesLineList() {
    delete geo_line_list
    delete geo_line_loctype_list
    delete geo_line_geoid_list
    geo_line_loctype_all_list = ""
    geo_line_geoid_all_list = ""
}

##
# Reset the list of last reference data POR entries
function resetREFLineList() {
    ref_last_full_line = ""
}

##
# Reset the list of last Innoavata POR entries
function resetInnovataLineList() {
    inn_last_full_line = ""
}

##
# Reset the list of the OPTD-maintained PageRank entries
function resetPageRankList() {
    delete optd_pr_city_list
    delete optd_pr_tvl_list
}

##
# Suggest a next step for the user: add the given POR entry
function displayNextStepAdd(__dnsaParamIataCode, __dnsaParamLocationType, \
							__dnsaParamGeonamesID) {
    # Calculate the primary key
    dnsaPK = getPrimaryKey(__dnsaParamIataCode, __dnsaParamLocationType, \
						   __dnsaParamGeonamesID)

    #
    print ("[" __glGlobalAWKFile "] Next step: add an entry in the OPTD " \
		   "file of best known coordinates for the " dnsaPK " primary key") \
		> __glGlobalErrorStream
}

##
# Suggest a next step for the user: fix the location type of the given POR entry
function displayNextStepFixLocType(__dnsfltParamIataCode,		\
								   __dnsfltParamLocationType,	\
								   __dnsfltParamGeonamesID) {
    # Calculate the primary key
    dnsfPK = getPrimaryKey(__dnsfltParamIataCode, __dnsfltParamLocationType, \
						   __dnsfltParamGeonamesID)

    #
    print ("[" __glGlobalAWKFile "] Next step: fix the entry in the OPTD " \
		   "file of best known coordinates for the " dnsfPK " primary key") \
		> __glGlobalErrorStream
}

##
# Suggest a next step for the user: fix the Geonames ID of the given POR entry
function displayNextStepFixID(__dnsfiParamIataCode, __dnsfiParamLocationType, \
							  __dnsfiParamGeonamesID) {
    # Calculate the primary key
    dnsfPK = getPrimaryKey(__dnsfiParamIataCode, __dnsfiParamLocationType, \
						   __dnsfiParamGeonamesID)

    #
    print ("[" __glGlobalAWKFile "] Next step: fix the entry in the OPTD " \
		   "file of best known coordinates for the " dnsfPK " primary key") \
		> __glGlobalErrorStream
}


##
# Calculate an alternate location type
function getAltLocTypeFromGeo(__galtfgParamLocationType) {
    if (isLocTypeTvlRtd(__galtfgParamLocationType)) {
		__resultLocationType = "C" __galtfgParamLocationType

    } else if (isLocTypeCity(__galtfgParamLocationType)) {
		__resultLocationType = "O"
    }
    return __resultLocationType
}

##
# Get the Geonames location type, if any, which is the most similar to the
# OPTD-derived given one.
# Typically, The OPTD location type may be combined (e.g., 'CA', 'CH', 'CR',
# 'CB', 'CP') or correspond to an off-line point (i.e., 'O'), while the
# Geonames-derived location types are individual (i.e., either 'C' or
# travel-related such 'A', 'H', 'R', 'B', 'P').
# In all the cases, with the algorithm used here, there is a single OPTD-derived
# location type (which may be combined) and potentially several in Geonames.
# If they are similar enough, the Geonames-derived location type is returned.
#
# OPTD samples:
# CRK-A-6300472
# CRK-C-1704703
# CRK-C-1730737
# TNK-CA-5876829
# TVX-C-1790942
# TVX-R-8411019
# Geonames samples:
# CRK^...^6300472^AIRP
# CRK^...^1704703^PPLA3
# CRK^...^1730737^PPL
# TNK^...^5876833^AIRP  (should match, but with less weight than the following)
# TNK^...^5876829^PPL   (should match with OPTD-derived TNK-CA-5876829)
# TVX^...^1790942^PPLA3 (should match with OPTD-derived TVX-C-1790942)
# TVX^...^8411019^AIRP  (should match with OPTD-derived TVX-R-8411019 and notify
#                        the user as there is a location type mismatch)
function getMostSimilarLocType(__gmsltParamOPTDLocType, __gmsltParamOPTDGeoID, \
							   __gmsltParamGeoLocTypeListString,		\
							   __gmsltParamGeoGeoIDListString) {
    __resultMostSimilarLocType = ""

    # First, check whether the OPTD-derived Geonames ID is to be found in the
    # Geonames data dump
    isGeoIDKnownToGeonames = match (__gmsltParamGeoGeoIDListString, \
									__gmsltParamOPTDGeoID)
    if (isGeoIDKnownToGeonames) {
		# Retrieve the Geonames-derived location type corresponding to that
		# Geonames-derived Geonames ID. That Geonames-derived location type
		# will allow to retrieve the right Geonames ID later on.
		gmsltGeoLocType = geo_line_loctype_list[__gmsltParamOPTDGeoID]
		__resultMostSimilarLocType = gmsltGeoLocType
		return __resultMostSimilarLocType
    }

    split (__gmsltParamGeoLocTypeListString, gmsltGeoLocTypeArray, ",")
    for (gmsltGeoLocTypeIdx in gmsltGeoLocTypeArray) {
		gmsltGeoLocType = gmsltGeoLocTypeArray[gmsltGeoLocTypeIdx]

		if (isLocTypeTvlRtd(__gmsltParamOPTDLocType)	\
			&& isLocTypeTvlRtd(gmsltGeoLocType)) {
			__resultMostSimilarLocType = gmsltGeoLocType
			break
		}

		if ((isLocTypeCity(__gmsltParamOPTDLocType)			\
			 || match (__gmsltParamOPTDLocType, "O")) &&	\
			(isLocTypeCity(gmsltGeoLocType)					\
			 || match (gmsltGeoLocType, "O"))) {
			__resultMostSimilarLocType = gmsltGeoLocType
			break
		}
    }

    return __resultMostSimilarLocType
}

##
# More explicit name for the power function
function pow(__powBase, __powPower) {
    return __powBase^__powPower
}

##
# Calculate the azimuth, giving the relative direction, from the first POR (point
# of reference) to the second one
function geoAzim(__gaLat1, __gaLon1, __gaLat2, __gaLon2) {
    latdif = __gaLat1 - __gaLat2
    londif = __gaLon1 - __gaLon2
    meanlat = (__gaLat1 + __gaLat2) / 2
	
    __gaA = 2 * atan2 (londif * ((prcurt/mrcurt) * (cos(meanlat))), latdif)
    __gaB = londif * (sin(meanlat))
    __gaAz = (__gaA - __gaB) / 2
    if (londif > 0 && latdif < 0) __gaAz += __glGlobalPI
    if (londif < 0 && latdif < 0) __gaAz += __glGlobalPI
    if (londif < 0 && latdif > 0) __gaAz += 2*__glGlobalPI
	
    return __gaAz * __glGlobalRTOD
}

##
# Calculate the geographical (great circle) distance
function geoDistance(__gdLat1, __gdLon1, __gdLat2, __gdLon2) {
    __gdLatDif = __gdLat1 - __gdLat2
    __gdLonDif = __gdLon1 - __gdLon2
    __gdXProj = Sin(__gdLonDif / 2)
    __gdYProj = Sin(__gdLatDif / 2)
    __gdXMult = Cos(__gdLat1) * Cos(__gdLat2)
    __gdDProj = sqrt(__gdYProj^2 + __gdXMult * __gdXProj^2)
    __gdDistance = __glGlobalNM * 120.0 * ASin(__gdDProj)

    return __gdDistance
}

##
# Retrieve the PageRank value for that POR
function getPageRank(__gprParamIataCode, __gprParamLocType) {
    # Check whether it is a city
    is_city = isLocTypeCity(__gprParamLocType)

    # Check whether it is travel-related
    is_tvl = isLocTypeTvlRtd(__gprParamLocType)
	
    if (is_city != 0) {
		__gprPR = optd_pr_city_list[__gprParamIataCode]
	
    } else if (is_tvl != 0) {
		__gprPR = optd_pr_tvl_list[__gprParamIataCode]

    } else {
		__gprPR = 0.001
    }

    return __gprPR
}

##
# Register the PageRank value for the given POR, specified by a
# (IATA code, pseudo location type) combination.
# The location type is a pseudo one, because it originally comes from
# the analysis of schedule files; hence, one can distinguish only between
# a city and a travel-related POR.
function registerPageRankValue(__rprlParamIataCode, __rprlParamLocType, \
							   __rprlParamFullLine, __rprlParamNbOfPOR, \
							   __rprlParamPRValue) {
    # Check whether it is a city
    is_city = isLocTypeCity(__rprlParamLocType)

    # Check whether it is travel-related
    is_tvl = isLocTypeTvlRtd(__rprlParamLocType)

    # Store the PageRank value for that POR
    if (is_city != 0) {
		addFieldToList(__rprlParamIataCode, optd_pr_city_list,	\
					   __rprlParamPRValue)
    }
    if (is_tvl != 0) {
		addFieldToList(__rprlParamIataCode, optd_pr_tvl_list, __rprlParamPRValue)
    }

}

##
# Register the full Geonames POR entry details for the given primary key:
# 1. The IATA code
# 2. The OPTD-maintained location type
# 3. The OPTD-maintained Geonames ID
function registerGeonamesLine(__rglParamIataCode, __rglParamFeatureCode, \
							  __rglParamGeonamesID, __rglParamFullLine,	\
							  __rglParamNbOfPOR) {
    # Register the fact that the AWK script runs on the Geonames data dump
    # (most probably called from the geo_pk_creator.awk file)
    __glGlobalIsForGeonames = 1

    # Derive the location type from the feature code.
    # Note: by design of a Geonames POR entry, its location type is individual.
    #       However, the POR entry may have been registered in the OPTD list as
    #       combined. In that latter case, a 'C' has to be added in front of
    #       the travel-related location type. For instance, 'A' => 'CA'.
    rglLocationType = getLocTypeFromFeatCode(__rglParamFeatureCode)

    # Sanity check: the location type should be known
    if (rglLocationType == "NA") {
		print ("[" __glGlobalAWKFile "] !!!! Error at line #" __rglParamNbOfPOR \
			   ", the POR with that IATA code ('" __rglParamIataCode	\
			   "') has an unknown feature code ('" __rglParamFeatureCode \
			   "') - Full line: " __rglParamFullLine) > __glGlobalErrorStream
		return
    }

    # Display the last read POR entry, when:
    # 1. The current POR entry is not the first one (as the last POR entry
    #    then is not defined).
    # 2. The current POR entry has got a (IATA code, location type) combination
    #    distinct from the last POR entry.
    if (__rglParamIataCode == geo_iata_code || __rglParamNbOfPOR == 1) {
		
    } else {
		# Display the last Geonames POR entries
		displayGeonamesPOREntries()
    }

    # Register the Geonames POR entry in the list of last entries
    # for that IATA code
    geo_iata_code = __rglParamIataCode

    # DEBUG
    #print ("[" __glGlobalAWKFile "][" __rglParamNbOfPOR "] iata_code="	\
    #	   __rglParamIataCode ", feat_code=" __rglParamFeatureCode	\
    #	   ", geo_loc_type=" rglLocationType ", GeoID=" __rglParamGeonamesID) \
    #	> __glGlobalErrorStream

    # Add the location type to the dedicated list
    geo_line_loctype_all_list =											\
		addLocTypeToAllGeoList(rglLocationType,	geo_line_loctype_all_list)

    # Add the location type to the dedicated list for that Geonames ID
    addLocTypeToGeoList(__rglParamGeonamesID, rglLocationType,	\
						geo_line_loctype_list)

    # Add the Geonames ID to the dedicated list
    geo_line_geoid_all_list =											\
		addGeoIDToAllGeoList(__rglParamGeonamesID, geo_line_geoid_all_list)

    # Add the Geonames ID to the dedicated list for that location type
    addGeoIDToGeoList(rglLocationType, __rglParamGeonamesID, geo_line_geoid_list)

    # Store the full details of the Geonames POR entry
    geo_line_list[__rglParamGeonamesID] = __rglParamFullLine
}

##
# Display the full details of the Geonames POR entry, prefixed by the
# corresponding primary key (IATA code, location type, Geonames ID).
#
function displayGeonamesPORWithPK(__dpwpParamIataCode, __dpwpParamOPTDLocType, \
				  __dpwpParamOPTDGeoID, \
				  __dpwpParamGeonamesGeoID) {
    # Notification
    if (__dpwpParamGeonamesGeoID != __dpwpParamOPTDGeoID && \
	__glGlobalLogLevel >= 4) {
	print("[" __glGlobalAWKFile "] !!!! Warning at line #" FNR	\
	      ", the OPTD-derived POR with that IATA code ('"		\
	      __dpwpParamIataCode "'), location type ('" __dpwpParamOPTDLocType \
	      "') has got a different Geonames ID (" __dpwpParamOPTDGeoID \
	      ") than the Geonames' one (" __dpwpParamGeonamesGeoID	\
	      "). The retained Geonames ID is " __dpwpParamGeonamesGeoID) \
	    > __glGlobalErrorStream
	displayNextStepFixID(__dpwpParamIataCode, __dpwpParamOPTDLocType, \
			     __dpwpParamOPTDGeoID)
    }

    # Build the primary key
    dpwpPK = getPrimaryKey(__dpwpParamIataCode, __dpwpParamOPTDLocType, \
			   __dpwpParamGeonamesGeoID)

    # Retrieve the full details of the Geonames POR entry
    dpwpGeonamesPORLine = geo_line_list[__dpwpParamGeonamesGeoID]

    # Add the primary key as a prefix
    dpwpGeonamesPORPlusPKLine = dpwpPK FS dpwpGeonamesPORLine

    # Dump the full line, prefixed by the primary key
    print (dpwpGeonamesPORPlusPKLine)
}

##
# Display the list of Geonames POR entries.
# Usually, there is no more than one POR entry for a given IATA code
# and location type.
#
# In some rare cases, a travel-related POR serves several cities. For instance,
# RDU-A-4487056 serves both RDU-C-4464368 (Raleigh) and RDU-C-4487042 (Durham)
# in North Carolina, USA. In that case, there are two entries for RDU-C.
#
function displayGeonamesPOREntries() {

    # Calculate the number of the Geonames POR entries corresponding to
    # the last IATA code.
    dgpeNbOfGeoPOR = length(geo_line_list)

    # DEBUG
    if (__glGlobalDebugIataCode != "" && \
	geo_iata_code == __glGlobalDebugIataCode) {
	print("[" __glGlobalDebugIataCode "] " dgpeNbOfGeoPOR		\
	      " Geonames entries, OPTD loc_type_list: "			\
	      optd_por_loctype_list[geo_iata_code] ", Geonames loc_type_list: " \
	      geo_line_loctype_all_list ", Geonames GeoID_list: "	\
	      geo_line_geoid_all_list) > __glGlobalErrorStream
    }

    # Browse all the location types known by OPTD for that IATA code
    dgpeOPTDLocTypeList = optd_por_loctype_list[geo_iata_code]
    split (dgpeOPTDLocTypeList, dgpeOPTDLocTypeArray, ",")
    for (dgpeOPTDLocTypeIdx in dgpeOPTDLocTypeArray) {
	#
	dgpeOPTDLocType = dgpeOPTDLocTypeArray[dgpeOPTDLocTypeIdx]

	# Browse all the Geonames IDs known by OPTD for that
	# (IATA code, location type) combination
	dgpeOPTDGeoIDList = optd_por_geoid_list[geo_iata_code, dgpeOPTDLocType]
	split (dgpeOPTDGeoIDList, dgpeOPTDGeoIDArray, ",")
	for (dgpeOPTDGeoIDIdx in dgpeOPTDGeoIDArray) {
	    #
	    dgpeOPTDGeoID = dgpeOPTDGeoIDArray[dgpeOPTDGeoIDIdx]

	    # Check whether the OPTD-derived location type is to be found
	    # in the Geonames POR entries for that IATA code.
	    # Retrieve the list of Geonames ID, if existing/non empty.
	    dgpeGeoIDList = geo_line_geoid_list[dgpeOPTDLocType]
	    if (dgpeGeoIDList != "") {

		# DEBUG
		if (__glGlobalDebugIataCode != "" &&		\
		    geo_iata_code == __glGlobalDebugIataCode) {
		    print ("[" __glGlobalDebugIataCode "] OPTD-loctype: " \
			   dgpeOPTDLocType ", OPTD GeoID: " dgpeOPTDGeoID \
			   ", Geonames GeoID_list[" dgpeOPTDLocType "]: " \
			   dgpeGeoIDList) > __glGlobalErrorStream
		}

		# Check whether the OPTD-derived Geonames ID exists in the
		# Geonames data dump. If yes, rely on it. If not, take the
		# first one of the Geonames-derived list.
		dgpeIsOPTDGeoIDInGeonames = match (dgpeGeoIDList, dgpeOPTDGeoID)
		if (dgpeIsOPTDGeoIDInGeonames) {
		    dgpeGeoID = dgpeOPTDGeoID

		} else {
		    # Extract the first Geonames ID from
		    # the Geonames-derived list
		    split (dgpeGeoIDList, dgpeGeoIDArray, ",")
		    dgpeGeoID = dgpeGeoIDArray[1]
		}

		# DEBUG
		if (__glGlobalDebugIataCode != "" &&		\
		    geo_iata_code == __glGlobalDebugIataCode) {
		    print ("[" __glGlobalDebugIataCode "] Matching loc type: " \
			   dgpeOPTDLocType ", Geonames GeoID list: "	\
			   dgpeGeoIDList ", kept GeoID: " dgpeGeoID)	\
			> __glGlobalErrorStream
		}

		# Display the full details of the Geonames POR entry
		displayGeonamesPORWithPK(geo_iata_code, dgpeOPTDLocType, \
					 dgpeOPTDGeoID, dgpeGeoID)
				
	    } else {
		# The OPTD location type is not found in the list of
		# Geonames-derived location types. Typically, The OPTD location
		# type may be combined (e.g., 'CA', 'CH', 'CR', 'CB', 'CP')
		# or correspond to an off-line point (i.e., 'O'), while the
		# Geonames-derived location types are individual (i.e., either
		# 'C' or travel-related such 'A', 'H', 'R', 'B', 'P').
		# In all the cases, there is a single location type in OPTD
		# and potentially several in Geonames. If they are similar
		# enough, the Geonames-derived location type is replaced by
		# OPTD's one.
		dgpeMostSimilarLocType =				\
		    getMostSimilarLocType(dgpeOPTDLocType, dgpeOPTDGeoID, \
					  geo_line_loctype_all_list,	\
					  geo_line_geoid_all_list)
		if (dgpeMostSimilarLocType != "") {
		    # Retrieve the list of Geonames ID corresponding to that
		    # (Geonames-derived) location type
		    dgpeGeoIDList = geo_line_geoid_list[dgpeMostSimilarLocType]

		    # Extract the first Geonames ID from the Geonames-derived
		    # list
		    split (dgpeGeoIDList, dgpeGeoIDArray, ",")
		    dgpeGeoID = dgpeGeoIDArray[1]

		    # DEBUG
		    if (__glGlobalDebugIataCode != "" &&		\
			geo_iata_code == __glGlobalDebugIataCode) {
			print ("[" __glGlobalDebugIataCode		\
			       "] Matching similar loc type: " dgpeOPTDLocType \
			       ", Geonames GeoID list: " dgpeGeoIDList	\
			       ", kept GeoID: " dgpeGeoID)		\
			    > __glGlobalErrorStream
		    }

		    # Display the full details of the Geonames POR entry
		    displayGeonamesPORWithPK(geo_iata_code, dgpeOPTDLocType, \
					     dgpeOPTDGeoID, dgpeGeoID)
					
		} else {
		    # Notification
		    if ((__glGlobalLogLevel >= 4 && dgpeOPTDGeoID != 0) || \
			(__glGlobalLogLevel >= 5 && dgpeOPTDGeoID == 0)) {
			print ("[" __glGlobalAWKFile "] iata_code="	\
			       geo_iata_code ", OPTD-loctype=" dgpeOPTDLocType \
			       ", OPTD-GeoID=" dgpeOPTDGeoID		\
			       " not found in Geonames. Known Geo ID list: " \
			       geo_line_geoid_all_list) > __glGlobalErrorStream
		    }
		}
	    }
	}
    }

    # Reset the list for the next turn
    resetGeonamesLineList()
}

##
# Register the full reference data POR entry details for the given primary key:
# 1. The IATA code
# 2. The OPTD-maintained location type
function registerREFLine(__rrlParamIataCode, __rrlParamLocType, \
			 __rrlParamFullLine, __rrlParamNbOfPOR) {
    # Register the fact that the AWK script runs on the reference data file
    # (most probably called from the ref_pk_creator.awk file)
    __glGlobalIsForREF = 1

    # Display the last read POR entry, when:
    # 1. The current POR entry is not the first one (as the last POR entry
    #    then is not defined).
    # 2. The current POR entry has got a (IATA code, location type) combination
    #    distinct from the last POR entry.
    if (__rrlParamIataCode == geo_iata_code || __rrlParamNbOfPOR == 1) {
		
    } else {
	# Display the last Geonames POR entries
	displayREFPOREntries()
    }

    # Register the reference data POR entry in the list of last entries
    # for that IATA code
    geo_iata_code = __rrlParamIataCode

    # DEBUG
    #print ("[" __glGlobalAWKFile "][" __rrlParamNbOfPOR "] iata_code="	\
    #	   __rrlParamIataCode ", geo_loc_type=" __rrlParamLocType) \
    #	> __glGlobalErrorStream

    # Store the location type of the reference data POR entry
    ref_last_loctype = __rrlParamLocType

    # Store the full details of the reference data POR entry
    ref_last_full_line = __rrlParamFullLine
}

##
# Display the full details of the reference data POR entry, prefixed by the
# corresponding primary key (IATA code, location type, Geonames ID).
#
function displayREFPORWithPK(__drpwkParamIataCode, __drpwkParamOPTDLocType, \
			     __drpwkParamOPTDGeoID) {
    # Build the primary key
    drpwkPK = getPrimaryKey(__drpwkParamIataCode, __drpwkParamOPTDLocType, \
			    __drpwkParamOPTDGeoID)

    # Re-write, within the reference data full line:
    #  * The location type (field #2)
    #  * The airport flag (field #9)
    #  * The commercial flag (field #18)
    drpwkFullLine = ref_last_full_line

    # Reparse the line
    OFS = FS
    $0 = drpwkFullLine

    # Override the location type
    $2 = __drpwkParamOPTDLocType

    # Override the airport flag when the POR is not an airport
    if (isLocTypeTvlRtd(__drpwkParamOPTDLocType) == 0) {
	$9 = "N"
    }

    # Override the commercial flag when the POR is a city only
    if (__drpwkParamOPTDLocType == "C") {
	$18 = "N"
    }
    drpwkFullLine = $0

    # Add the primary key as a prefix to the full details of
	# the reference data POR entry
    drpwkREFPORPlusPKLine = drpwkPK FS drpwkFullLine

    # Dump the full line, prefixed by the primary key
    print (drpwkREFPORPlusPKLine)
}

##
# Display the list of reference data POR entries.
# Usually, there is no more than one POR entry for a given IATA code
# and location type.
#
# In some rare cases, a travel-related POR serves several cities. For instance,
# RDU-A-4487056 serves both RDU-C-4464368 (Raleigh) and RDU-C-4487042 (Durham)
# in North Carolina, USA. In that case, there are two entries for RDU-C.
#
function displayREFPOREntries() {

    # DEBUG
    if (__glGlobalDebugIataCode != "" && \
	geo_iata_code == __glGlobalDebugIataCode) {
	print ("[" __glGlobalDebugIataCode "] OPTD loc_type list: "    \
	       optd_por_loctype_list[geo_iata_code] ", REF loc_type: " \
	       ref_last_loctype) > __glGlobalErrorStream
    }

    # Browse all the location types known by OPTD for that IATA code
    drpeOPTDLocTypeList = optd_por_loctype_list[geo_iata_code]
    split (drpeOPTDLocTypeList, drpeOPTDLocTypeArray, ",")
    for (drpeOPTDLocTypeIdx in drpeOPTDLocTypeArray) {
	#
	drpeOPTDLocType = drpeOPTDLocTypeArray[drpeOPTDLocTypeIdx]

	# Browse all the Geonames IDs known by OPTD for that
	# (IATA code, location type) combination
	drpeOPTDGeoIDList = optd_por_geoid_list[geo_iata_code, drpeOPTDLocType]
	split (drpeOPTDGeoIDList, drpeOPTDGeoIDArray, ",")
	for (drpeOPTDGeoIDIdx in drpeOPTDGeoIDArray) {
	    #
	    drpeOPTDGeoID = drpeOPTDGeoIDArray[drpeOPTDGeoIDIdx]

	    # Display the full details of the reference data POR entry
	    displayREFPORWithPK(geo_iata_code, drpeOPTDLocType, drpeOPTDGeoID)
		
	    # DEBUG
	    if (__glGlobalDebugIataCode != "" &&		\
		geo_iata_code == __glGlobalDebugIataCode) {
		print ("[" __glGlobalDebugIataCode "] OPTD-loctype: "	\
		       drpeOPTDLocType ", OPTD GeoID: " drpeOPTDGeoID	\
		       ", REF loc_type list: " ref_last_loctype)	\
		    > __glGlobalErrorStream
	    }
	}
    }

    # Reset the list for the next turn
    resetREFLineList()
}

##
# Register the full Innovata POR entry details for the given primary key:
# 1. The IATA code
# 2. The OPTD-maintained location type
function registerInnovataLine(__rilParamIataCode, __rilParamLocType, \
			      __rilParamFullLine, __rilParamNbOfPOR) {
    # Register the fact that the AWK script runs on the Innovata data dump
    # (most probably called from the inn_pk_creator.awk file)
    __glGlobalIsForInnovata = 1

    # Display the last read POR entry, when:
    # 1. The current POR entry is not the first one (as the last POR entry
    #    then is not defined).
    # 2. The current POR entry has got a (IATA code, location type) combination
    #    distinct from the last POR entry.
    if (__rilParamIataCode == geo_iata_code || __rilParamNbOfPOR == 1) {
		
    } else {
	# Display the last Geonames POR entries
	displayInnovataPOREntries()
    }

    # Register the Innovata POR entry in the list of last entries
    # for that IATA code
    geo_iata_code = __rilParamIataCode

    # DEBUG
    #print ("[" __glGlobalAWKFile "][" __rilParamNbOfPOR "] iata_code="	\
    #	   __rilParamIataCode ", geo_loc_type=" __rilParamLocType)		\
    #	> __glGlobalErrorStream

    # Store the location type of the Innovata POR entry
    inn_last_loctype = __rilParamLocType

    # Store the full details of the Innovata POR entry
    inn_last_full_line = __rilParamFullLine
}

##
# Display the list of Innovata POR entries.
# Usually, there is no more than one POR entry for a given IATA code
# and location type.
#
# In some rare cases, a travel-related POR serves several cities. For instance,
# RDU-A-4487056 serves both RDU-C-4464368 (Raleigh) and RDU-C-4487042 (Durham)
# in North Carolina, USA. In that case, there are two entries for RDU-C.
#
function displayInnovataPOREntries() {

    # DEBUG
    if (__glGlobalDebugIataCode != "" && \
	geo_iata_code == __glGlobalDebugIataCode) {
	print ("[" __glGlobalDebugIataCode "] OPTD loc_type list: "	  \
	       optd_por_loctype_list[geo_iata_code] ", Innovata loc_type: " \
	       inn_last_loctype) > __glGlobalErrorStream
    }

    # Browse all the location types known by OPTD for that IATA code
    dipeOPTDLocTypeList = optd_por_loctype_list[geo_iata_code]
    split (dipeOPTDLocTypeList, dipeOPTDLocTypeArray, ",")
    for (dipeOPTDLocTypeIdx in dipeOPTDLocTypeArray) {
	#
	dipeOPTDLocType = dipeOPTDLocTypeArray[dipeOPTDLocTypeIdx]

	# Browse all the Geonames IDs known by OPTD for that
	# (IATA code, location type) combination
	dipeOPTDGeoIDList = optd_por_geoid_list[geo_iata_code, dipeOPTDLocType]
	split (dipeOPTDGeoIDList, dipeOPTDGeoIDArray, ",")
	for (dipeOPTDGeoIDIdx in dipeOPTDGeoIDArray) {
	    #
	    dipeOPTDGeoID = dipeOPTDGeoIDArray[dipeOPTDGeoIDIdx]

	    # Display the full details of the Innovata POR entry
	    displayInnovataPORWithPK(geo_iata_code, dipeOPTDLocType, \
				     dipeOPTDGeoID)
		
	    # DEBUG
	    if (__glGlobalDebugIataCode != "" &&		\
		geo_iata_code == __glGlobalDebugIataCode) {
		print ("[" __glGlobalDebugIataCode "] OPTD-loctype: "	\
		       dipeOPTDLocType ", OPTD GeoID: " dipeOPTDGeoID	\
		       ", Innovata loc_type list: " inn_last_loctype)	\
		    > __glGlobalErrorStream
	    }
	}
    }

    # Reset the list for the next turn
    resetInnovataLineList()
}

##
# Display the full details of the Innovata POR entry, prefixed by the
# corresponding primary key (IATA code, location type, Geonames ID).
#
function displayInnovataPORWithPK(__dipwkParamIataCode,		\
								  __dipwkParamOPTDLocType,	\
								  __dipwkParamOPTDGeoID) {
    # Build the primary key
    dipwkPK = getPrimaryKey(__dipwkParamIataCode, __dipwkParamOPTDLocType, \
			    __dipwkParamOPTDGeoID)

    # Re-write, within the Innovata full line:
    #  * The location type (field #8)
    #  * The geographical coordinates (fields #6 and #7)
    dipwkFullLine = inn_last_full_line

    # Reparse the line
    OFS = "^"
    $0 = dipwkFullLine

    # Override the location type
    $10 = __dipwkParamOPTDLocType

    # Convert and override the latitude
    inn_lat = $7
    std_lat = convertLatToStd(inn_lat)
    $7 = std_lat

    # Convert and override the longitude
    inn_lon = $8
    std_lon = convertLonToStd(inn_lon)
    $8 = std_lon

    # Retrieve the full line
    dipwkFullLine = $0

    # Add the primary key as a prefix to the full details
    # of the Innovata POR entry
    dipwkInnovataPORPlusPKLine = dipwkPK "^" dipwkFullLine

    # Dump the full line, prefixed by the primary key
    print (dipwkInnovataPORPlusPKLine)
}

##
# Extract the list of names of a POR in a given language.
#
# Sample lists of alternate name details:
# [AAE] ru|Аэропорт «Аннаба»|=en|Rabah Bitat Annaba Airport|=en|Annaba Airport|s=en|Les Salines Airport|h=en|El Mellah Airport|=en|Rabah Bitat Airport|p
# [PAR] la|Lutetia Parisorum|=fr|Lutèce|h=fr|Ville-Lumière|c=eo|Parizo|=es|París|ps=de|Paris|=en|Paris|p=af|Parys|=als|Paris|=an|París|=ar|باريس|=ast|París|=be|Горад Парыж|=bg|Париж|=ca|París|=cs|Paříž|=cy|Paris|=da|Paris|=el|Παρίσι|=et|Pariis|=eu|Paris|=fa|پاریس|=fi|Pariisi|=fr|Paris|p=ga|Páras|=gl|París|=he|פריז|=hr|Pariz|=hu|Párizs|=id|Paris|=io|Paris|=it|Parigi|=ja|パリ|=ka|პარიზი|=kn|ಪ್ಯಾರಿಸ್|=ko|파리|=ku|Parîs|=kw|Paris|=lb|Paräis|=li|Paries|=lt|Paryžius|=lv|Parīze|=mk|Париз|=ms|Paris|=na|Paris|=nds|Paris|=nl|Parijs|=nn|Paris|=no|Paris|=oc|París|=pl|Paryż|=pt|Paris|=ro|Paris|=ru|Париж|=scn|Pariggi|=sco|Paris|=sl|Pariz|=sq|Paris|=sr|Париз|=sv|Paris|=ta|பாரிஸ்|=th|ปารีส|=tl|Paris|=tr|Paris|=uk|Париж|=vi|Paris|p=zh|巴黎|=ia|Paris|=fy|Parys|=ln|Pari|=os|Париж|=pms|Paris|=sk|Paríž|=sq|Parisi|=sw|Paris|=tl|Lungsod ng Paris|=ug|پارىژ|=fr|Paname|c=fr|Pantruche|c=am|ፓሪስ|=arc|ܦܐܪܝܣ|=br|Pariz|=gd|Paris|=gv|Paarys|=hy|Փարիզ|=ksh|Paris|=lad|Paris|=lmo|Paris|=mg|Paris|=mr|पॅरिस|=tet|París|=tg|Париж|=ty|Paris|=ur|پیرس|=vls|Parys|=is|París|=vi|Pa-ri|=ml|പാരിസ്|=uz|Parij|=rue|Паріж|=ne|पेरिस|=jbo|paris|=mn|Парис|=lij|Pariggi|=vec|Parixe|=yo|Parisi|=yi|פאריז|=mrj|Париж|=hi|पैरिस|=fur|Parîs|=tt|Париж|=szl|Paryż|=mhr|Париж|=te|పారిస్|=tk|Pariž|=bn|প্যারিস|=ha|Pariis|=sah|Париж|=mzn|پاریس|=bo|ཕ་རི།|=haw|Palika|=mi|Parī|=ext|París|=ps|پاريس|=pa|ਪੈਰਿਸ|=ckb|پاریس|=cu|Парижь|=cv|Парис|=co|Parighji|=bs|Pariz|=so|Baariis|=hbs|Pariz|=gu|પૅરિસ|=xmf|პარიზი|=ba|Париж|=pnb|پیرس|=arz|باريس|=la|Lutetia|=kk|Париж|=kv|Париж|=gn|Parĩ|=ky|Париж|=myv|Париж ош|=nap|Parigge|=km|ប៉ារីស|=krc|Париж|=udm|Париж|=wo|Pari|=gan|巴黎|=sc|Parigi|=za|Bahliz|=my|ပါရီမြို့|=post|75000|p=post|75020|=olo|Pariižu|
# Sample output for French ("fr"):
# [PAR] Lutèce|h=Ville-Lumière|c=Paris|p=Paname|c=Pantruche|c
function getPORNameForLang (__gpnflAltNameList, __gpnflLang) {
	outputNameList = ""
	outputMainSep = "="
	outputSecSep = "|"

	# The list of alternate name details is separated by the equal ("=") sign
	split (__gpnflAltNameList, dpnAltNameArray, "=")
    for (dpnAltIdx in dpnAltNameArray) {
		dpnAltNameDetails = dpnAltNameArray[dpnAltIdx]

		# The list of details is separated by the pipe ("|") sign
		split (dpnAltNameDetails, dpnAltNameDetailArray, "|")

		# With AWK, the array created by split() begins with the index of 1:
		# 1. Langauge (e.g., "en", "fa", "ru", "zh")
		# 2. Name for that language
		# 3. Qualifier (e.g., "p" for preferred, "s" for short, "h" for
		#    historical, and "c" for colloquial)
		AltNameLang = dpnAltNameDetailArray[1]
		delete EquivalentLangArray
		EquivalentLangArray[__gpnflLang] = 1
		if (__gpnflLang == "zh") {
			EquivalentLangArray["yue"] = 1
			EquivalentLangArray["wuu"] = 1
			EquivalentLangArray["pny"] = 1
			EquivalentLangArray["zh-CN"] = 1
		}
		if (AltNameLang in EquivalentLangArray) {
			if (outputNameList != "") {
				outputNameList = outputNameList outputMainSep
			}
			outputNameList = outputNameList dpnAltNameDetailArray[2]
			if (dpnAltNameDetailArray[3] != "") {
				outputNameList = outputNameList outputSecSep dpnAltNameDetailArray[3]
			}
		}
	}

	#
	return outputNameList
}

##
# Register a few relationships for the World Area Code (WAC)
function registerWACLists(__rwlWorldAreaCode, __rwlThroughDate,			\
						  __rwlCountryIsoCode, __rwlStateCode, __rwlWACName) {

    # Register the WAC associated to that country (e.g., 401 for 'AL'/Albania)
	if (__rwlThroughDate == "" && __rwlCountryIsoCode) {
		wac_by_ctry_code_list[__rwlCountryIsoCode] = __rwlWorldAreaCode
	}

    # Register the WAC associated to that state (e.g., 51 for 'AL'/Alabama)
	if (__rwlThroughDate == "" && __rwlStateCode) {
		wac_by_state_code_list[__rwlStateCode] = __rwlWorldAreaCode
	}

	# Register the WAC name
	wac_name_list[__rwlWorldAreaCode] = __rwlWACName

	# DEBUG
	# print ("WAC: " __rwlWorldAreaCode "; country_code: " __rwlCountryIsoCode \
	#	   "; state_code: " __rwlStateCode) > error_stream
}

##
# Retrieve the World Area Code (WAC) for a given country or a given state
function getWorldAreaCode(__gwacCountryCode, __gwacStateCode, __gwacCountryCodeAlt) {
	# If there is a WAC registered for the state code (as found in Geonames),
	# then the WAC is specified at the state level (like for US and CA states)
	world_area_code_for_state = wac_by_state_code_list[__gwacStateCode]
	if (world_area_code_for_state) {
		return world_area_code_for_state
	}

	# Then, try to match the country code (as found in Geonames)
	world_area_code_for_ctry = wac_by_ctry_code_list[__gwacCountryCode]
	if (world_area_code_for_ctry) {
		return world_area_code_for_ctry
	}

	# Then, try to match the alternate country code (as found in Geonames)
	world_area_code_for_ctry = wac_by_ctry_code_list[__gwacCountryCodeAlt]
	if (world_area_code_for_ctry) {
		return world_area_code_for_ctry
	}

	# Then, try to match the country code (as found in Geonames)
	# with a WAC state code. For instance, Puerto Rico (PR) is a country
	# for Geonames, but a state (of the USA) for the US DOT WAC.
	world_area_code_for_state = wac_by_state_code_list[__gwacCountryCode]
	if (world_area_code_for_state) {
		return world_area_code_for_state
	}
	
	# Then, try to match the alternate country code (as found in Geonames)
	# with a WAC state code. For instance, Puerto Rico (PR) is a country
	# for Geonames, but a state (of the USA) for the US DOT WAC.
	world_area_code_for_state = wac_by_state_code_list[__gwacCountryCodeAlt]
	if (world_area_code_for_state) {
		return world_area_code_for_state
	}

	# A few specific rules. See for instance the issue #5 on Open Travel Data:
	# http://github.com/opentraveldata/opentraveldata/issues/5
	# The following countries should be mapped onto WAC #005, TT, USA:
	# * American Samoa, referenced under Geonames as AS
	# * Guam, referenced under Geonames as GU
	# * Northern Mariana Islands, referenced under Geonames as MP
	if (__gwacCountryCode == "AS" || __gwacCountryCode == "GU" \
		|| __gwacCountryCode == "MP"){
		world_area_code_for_ctry = 5
		return world_area_code_for_ctry
	}
	# For some reason, the US DOT has got the wrong country code for Kosovo
	# See also https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#XK
	if (__gwacCountryCode == "XK") {
		world_area_code_for_ctry = 494
		return world_area_code_for_ctry
	}

    # There is no WAC registered for either the state or country code
	#print ("[" awk_file "] !!!! Warning !!!! No World Area Code (WAC) can be" \
	#	   " found for either the state code ("	__gwacStateCode				\
	#	   "), the country code (" __gwacCountryCode						\
	#	   ") or the alternate country code (" __gwacCountryCodeAlt			\
	#	   "). Line: " $0) > error_stream
}

##
# Retrieve the World Area Code (WAC) name for a given WAC
function getWorldAreaCodeName(__gwacnWAC) {
	if (__gwacnWAC) {
		wac_name = wac_name_list[__gwacnWAC]
		return wac_name
	}
}
