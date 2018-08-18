##
# That AWK script adds the list of no longer valid IATA POR (points of
# reference) to the optd_por_public.csv file. The input files are:
#  * Already re-formatted list of POR: optd_por_public.csv.wonoiata (temporary)
#  * Non longer valid POR:             optd_por_no_longer_valid.csv
#
# See also the make_optd_por_public.awk AWK script for details on the format.
#
# Sample output lines:
# IEV^UKKK^^Y^6300960^^Kyiv Zhuliany International Airport^Kyiv Zhuliany International Airport^50.401694^30.449697^S^AIRP^0.0240196752049^^^^UA^^Ukraine^Europe^^^^^^^^^0^178^174^Europe/Kiev^2.0^3.0^2.0^2012-06-03^IEV^^^^A^http://en.wikipedia.org/wiki/Kyiv_Zhuliany_International_Airport^en|Kyiv Zhuliany International Airport|=en|Kyiv International Airport|=en|Kyiv Airport|s=en|Kiev International Airport|=uk|Міжнародний аеропорт «Київ» (Жуляни)|=ru|Аэропорт «Киев» (Жуляны)|=ru|Международный аеропорт «Киев» (Жуляни)|^488^Ukraine^HRV^
# NCE^LFMN^^Y^6299418^^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.658411^7.215872^S^AIRP^0.157408761216^^^^FR^^France^Europe^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^NCE^^^^CA^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de|Flughafen Nizza|=en|Nice Côte d'Azur International Airport|=es|Niza Aeropuerto|ps=fr|Aéroport de Nice Côte d'Azur|=en|Nice Airport|s^427^France^EUR^FRNCE|
# UNS^ZZZZ^^Y^8298981^1^Umnak Island Airport^Umnak Island Airport^53.38277^-167.88946^S^AIRP^^^1948-01-01^Air base closed after WWII, in 1947^US^^United States^North America^^^^^^^^^^^^America/USA^^^^-1^UMB^Umnak Island^UMB|5877180|Umnak Island|Umnak Island^^AK^A^http://en.wikipedia.org/wiki/Cape_Field_at_Fort_Glenn^^1^Alaska^USD^
#

##
# Helper functions
@include "awklib/geo_lib.awk"


##
#
BEGIN {
	# Global variables
	error_stream = "/dev/stderr"
	awk_file = "add_noiata_por.awk"

	#
	today_date = mktime ("YYYY-MM-DD")
}

##
# List of:
# * Re-formatted list of POR: optd_por_public.csv.wonoiata (temporary)
# * No longer valid POR: optd_por_no_longer_valid.csv file
# Those files have the exact same format as the output of optd_por_public.csv
#
# Sample input lines:
# UNS^^^Y^8298981^1^Umnak Island Airport^Umnak Island Airport^53.38277^-167.88946^S^AIRP^^^1948-01-01^Air base closed after WWII, in 1947^US^^United States^North America^AK^Alaska^Alaska^016^Aleutians West Census Area^Aleutians West Census Area^^^^^^America/Adak^-10.0^-9.0^-10.0^-1^UMB^Umnak Island^UMB|5877180|Umnak Island|Umnak Island^^AK^A^http://en.wikipedia.org/wiki/Cape_Field_at_Fort_Glenn^^1^Alaska^USD^
#
/^([A-Z]{3}|)\^([A-Z]{4}|)\^([0-9A-Z]{3,4}|)\^(Y|N)\^[0-9]{1,12}\^([0-9]{1,10}|)\^/ {
	if (NF == 48) {
		print ($0)

	} else {
		print ("[" awk_file "] !!!! Error for row #" FNR ", having " NF \
			   " fields: " $0) > error_stream
	}
}


END {
}
