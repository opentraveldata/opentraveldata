##
# That AWK script extracts the mapping between every country
# and its corresponding continent.
# For instance, Germany is located in Europe and Peru in South America.
#
# 1. Input data files
# -------------------
# 1.1. Continent information data file
# ------------------------------------
# The continents are referenced by their short code, which can be found in the
# continentCodes.txt file:
# http://github.com/opentraveldata/opentraveldata/blob/master/data/geonames/data/por/data/continentCodes.txt
#
# 1.2. Country information data file
# ----------------------------------
# The input data file is downloaded from Geonames:
# http://download.geonames.org/export/dump/countryInfo.txt
#
#
# 2. Output data file
# -------------------
# The generated data file contains, for every country code, its corresponding
# continent (code and name).
# http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_cont.csv
#
# Sample output lines:
# country_code^country_name^continent_code^continent_name
# DE^Germany^EU^Europe
# PE^Peru^SA^South America
#


##
#
BEGIN {
    # Global variables
    error_stream = "/dev/stderr"
    awk_file = "extract_continent_mapping.awk"

    # Header
    printf ("%s","country_code^country_name^continent_code^continent_name")
    printf ("%s", "\n")

    #
    today_date = mktime ("YYYY-MM-DD")
    cont_line = 0
}

##
# Continent information data file: continentCodes.txt
#
# Sample lines:
# AF Africa 6255146
# AS Asia 6255147
# EU Europe 6255148
# NA North America 6255149
# OC Oceania 6255151
# SA South America 6255150
# AN Antarctica 6255152
#
/^([A-Z]{2})\t([A-Za-z ]+)\t([0-9]{1,9})$/ {
    #
    cont_line++

    # Continent code
    cont_code = $1

    # Continent name
    cont_name = $2

    # Register the continent name
    cont_list[cont_code] = cont_name
}

##
# Country information data file: countryInfo.txt
#
# Sample lines:
# ISO ISO3 ISO-Numeric fips CountryName Capital Area(in sq km) Population Continent tld CurrencyCode CurrencyName Phone Postal Code Format Postal Code Regex Languages geonameid neighbours EquivalentFipsCode
# DE DEU 276 GM Germany Berlin 357021 81802257 EU .de EUR Euro 49 ### ^(\d{5})$ de 2921044 CH,PL,NL,DK,BE,CZ,LU,FR,AT
# FR FRA 250 FR France Paris 547030 64768389 EU .fr EUR Euro 33 ### ^(\d{5})$ fr-FR,frp,br,co,ca,eu,oc 3017382 CH,DE,BE,LU,IT,AD,MC,ES 
# GB GBR 826 UK United Kingdom London 244820 62348447 EU .uk GBP Pound 44 @# #@@|@# #@@|@@# #@@|@@# #@@|@#@ #@@|@@#@ #@@|GIR0AA ^(([A-Z]\d{2}[A-Z]{2})|([A-Z]\d{3}[A-Z]{2})|([A-Z]{2}\d{2}[A-Z]{2})|([A-Z]{2}\d{3}[A-Z]{2})|([A-Z]\d[A-Z]\d[A-Z]{2})|([A-Z]{2}\d[A-Z]\d[A-Z]{2})|(GIR0AA))$ en-GB,cy-GB,gd 2635167 IE
# RU RUS 643 RS Russia Moscow 1.71E+007 140702000 EU .ru RUB Ruble 7 ### ^(\d{6})$ ru,tt,xal,cau,ady,kv,ce,tyv,cv,udm,tut,mns,bua,myv,mdf,chm,ba,inh,tut,kbd,krc,ava,sah,nog 2017370 GE,CN,BY,UA,KZ,LV,PL,EE,LT,FI,MN,NO,AZ,KP 
# US USA 840 US United States Washington 9629091 310232863 NA .us USD Dollar 1 ###-## ^(\d{9})$ en-US,es-US,haw,fr 6252001 CA,MX,CU
#
/^([A-Z]{2})\t([A-Z]{3})\t([0-9]{1,3})\t.*\t([0-9]{1,10})\t.*\t.*$/ {
    # 2-character ISO code
    iso_2char_code = $1

    # (ASCII) Name
    ctry_name = $5

    # Continent code
    cont_code = $9

    # Continent name
    cont_name = cont_list[cont_code]

    # Print the mapping for that country
    print (iso_2char_code "^" ctry_name "^" cont_code "^" cont_name)
}


##
#
END {
    # DEBUG
    # print (cont_line " lines") > error_stream
}
