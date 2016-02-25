##
# That script is used by two distinct use case:
#  * 1a. In order to replace the geographical coordinates, only when
#        known by Geonames.
#  * 1b. In order to replace the geographical coordinates, only when
#        known by reference data.
#  * 2.  In order to fix the geographical coordinates of the pristine
#        OPTD-maintained list of best known POR coordinates.

{

    if (NF == 24) {
	# First use case (a). The POR is known by Geonames.

	# IATA code
	printf ("%s", $1)

	# The geographical coordinates are fields #6 and #7
	printf ("%s", "^" $6 "^" $7)

	#
	printf ("%s", "\n")

    } else if (NF == 18) {
	if ($14 != "" && $15 != "" \
	    && int($14 * 1000)/1000 != 0 && int($15 * 1000)/1000 != 0) {
	    # First use case (b). The POR is known by reference data.

	    # IATA code
	    printf ("%s", $1)

	    # The geographical coordinates are fields #14 and #15
	    printf ("%s", "^" $14 "^" $15)

	    #
	    printf ("%s", "\n")
	}

    } else if (NF == 3 || NF == 5) {
	# Second use case. The coordinates have been fixed.

	# IATA code
	printf ("%s", $1)

	# The geographical coordinates are fields #2 and #3
	printf ("%s", "^" $2 "^" $3)

	#
	printf ("%s", "\n")

    } else if (NF == 1) {
	# First use case. The POR is known neither by Geonames nor by reference data.

    } else {
	# Error
	print ("!!!! Error !!!! The line contains " NF " fields: " $0) \
	    > "/dev/stderr"
    }

}
