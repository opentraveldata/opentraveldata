##
# Extraction of the details of countries.
#
# That AWK script extracts the country details
# from the Geonames '../data/geonames/data/por/data/countryInfo.txt' data file.
#

##
# Sample input lines (TAB separated):
# US      USA     840     US      United States   Washington      9629091 310232863       NA      .us     USD     Dollar  1       #####-####      ^\d{5}(-\d{4})?$        en-US,es-US,haw,fr      6252001 CA,MX,CU        
#
# Sample output lines:
# iso_2char_code^iso_3char_code^iso_num_code^fips^name^cptl^area^pop^cont^tld^ccy_code^ccy_name^tel_pfx^zip_fmt^lang_code_list^geo_id^ngbr_ctry_code_list
# US^USA^840^US^United States^Washington^9629091^310232863^NA^.us^USD^Dollar^1^#####-####^en-US=es-US=haw=fr^6252001^CA=MX=CU


##
# Helper functions
@include "awklib/geo_lib.awk"

##
# Initialisation
BEGIN {
	# Global variables
	error_stream = "/dev/stderr"
	awk_file = "make_opt_country.awk"

	# Header
	hdr_line = "iso_2char_code^iso_3char_code^iso_num_code"
	hdr_line = hdr_line "^fips^name^cptl^area^pop^cont_code^tld"
	hdr_line = hdr_line "^ccy_code^ccy_name^tel_pfx^zip_fmt"
	hdr_line = hdr_line "^lang_code_list^geo_id^ngbr_ctry_code_list"
	print (hdr_line)
}


##
# Entries corresponding to country details (TAB-separated; to insert a TAB
# within Emacs, type CTRL-q and TAB; to insert a TAB on the Bash command-line,
# type CTRL-v and TAB):
# US      USA     840     US      United States   Washington      9629091 310232863       NA      .us     USD     Dollar  1       #####-####      ^\d{5}(-\d{4})?$        en-US,es-US,haw,fr      6252001 CA,MX,CU        
#
/^[A-Z]{2}	[A-Z]{3}	[0-9]{1,3}	[A-Z]{0,2}/ {
  # ISO 2-character code
  iso_2char_code = $1

  # ISO 3-character code
  iso_3char_code = $2

  # ISO numeric code
  iso_num_code = $3

  # FIPS code
  fips_code = $4

  # Country name
  ctry_name = $5

  # Capital name
  cptl_name = $6

  # Area (in square kilometers)
  area = $7

  # Population
  population = $8

  # (Geonames) Continent code
  cont_code = $9

  # Internet Top Level Domain (TLD)
  tld = $10

  # Currency code
  ccy_code = $11

  # Currency name
  ccy_name = $12

  # Phone prefix
  tel_pfx = $13

  # Postal code format
  zip_fmt = $14

  # Postal code regex
  zip_regex = $15

  # List of language codes
  lang_code_list = changeSepInList($16, ",", "=")

  # Geonames ID
  geo_id = $17

  # List of neighboring country codes
  ngbr_ctry_code_list = changeSepInList($18, ",", "=")

  # Parse the section of alternate names
  #sep_saved = FS
  OFS = "^"

  #
  output_line = iso_2char_code OFS iso_3char_code OFS iso_num_code OFS fips_code
  output_line = output_line OFS ctry_name OFS cptl_name OFS area OFS population
  output_line = output_line OFS cont_code OFS tld OFS ccy_code OFS ccy_name
  output_line = output_line OFS tel_pfx OFS zip_fmt OFS lang_code_list
  output_line = output_line OFS geo_id OFS ngbr_ctry_code_list

  print (output_line)
}


