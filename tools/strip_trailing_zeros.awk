##
# That AWK script strips the trailing zeros (0) from the geographical coordinates
# of various files. It is intended to be used once on a file. If some other
# scripts produce trailing zeros, then it is better to fix it.
#
# Typical use cases:
# awk -F'^' -f strip_trailing_zeros.awk -v add_hdr=1 por_all_iata_20120708.csv > por_all_iata_20120708.csv2
# kdiff3 por_all_iata_20120708.csv por_all_iata_20120708.csv2
# \mv -f por_all_iata_20120708.csv2 por_all_iata_20120708.csv
#
# awk -F'^' -f strip_trailing_zeros.awk ../ORI/optd_por_best_known_so_far.csv > ../ORI/optd_por_best_known_so_far.csv
# kdiff3 ../ORI/optd_por_best_known_so_far.csv2 ../ORI/optd_por_best_known_so_far.csv
# \mv -f ../ORI/optd_por_best_known_so_far.csv2 ../ORI/optd_por_best_known_so_far.csv
#

##
#
BEGIN {
	hdr_line = "iata_code^icao_code^geonameid^name^asciiname^latitude^longitude^country^cc2^fclass^fcode^admin1^admin2^admin3^admin4^population^elevation^gtopo30^timezone^GMT_offset^DST_offset^raw_offset^moddate^alternatenames^wiki_link^altname_iso^altname_text"

	if (add_hdr == "1") {
		print (hdr_line)
	}
}

#
# ORI-maintained list of best known coordinates
#
# Sample line:
# NCE-CA^NCE^43.658411^7.215872^NCE
#
/^([A-Z0-9]{3}-[A-Z]{1,2})\^([A-Z0-9]{3})\^.*\^.*\^([A-Z0-9]{3})$/ {
	# Retrieve the coordinates as numbers
	lat = 0 + $3
	lon = 0 + $4

	# Convert the coordinates into strings
	lat_str = "" lat
	lon_str = "" lon

	# Alter the coordinates only when different
	if (lat_str != $3) {
		lat_new = sprintf ("%.10g", lat)
		OFS = FS
		$3 = lat_new
	}
	if (lon_str != $4) {
		lon_new = sprintf ("%.10g", lon)
		OFS = FS
		$4 = lon_new
	}

	#
	print ($0)
}

#
# Typical ORI-formatted file of POR
# Sample line:
# AAA^NTGA^6947726^Anaa Airport^Anaa Airport^-17.3490800^-145.5122900^PF^^S^AIRP^^^^^0^0^8^Pacific/Tahiti^-10.0^-10.0^-10.0^2012-04-29^AAA,Anaa,NTGA,Анаа^http://en.wikipedia.org/wiki/Anaa_Airport^ru^Анаа
#
/^([A-Z0-9]{3})\^([A-Z0-9]{4}|)\^([0-9]{1,9})\^.*\^([0-9]{4}-[0-9]{2}-[0-9]{2})/ {
	# Retrieve the coordinates as numbers
	lat = 0 + $6
	lon = 0 + $7

	# Retrieve the elevation
	elevation = $17

	# Convert the coordinates into strings
	lat_str = "" lat
	lon_str = "" lon

	# Alter the coordinates only when different
	if (lat_str != $6) {
		lat_new = sprintf ("%.10g", lat)
		OFS = FS
		$6 = lat_new
	}
	if (lon_str != $7) {
		lon_new = sprintf ("%.10g", lon)
		OFS = FS
		$7 = lon_new
	}

	# Alter the elevation when null
	if (elevation == 0) {
		$17 = ""
	}

	#
	print ($0)
}
