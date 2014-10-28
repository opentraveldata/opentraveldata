##
# That AWK script has been run once (July 2012), and is not intended to be
# processed that often. It is left here, just as a sample.
#
# The script takes a list of POR for which the location type is "combined":
# most of the time, it is "CA" (meaning city and airport), but it can also be
# something like "AR" (meaning airport and railway station).
#
# Typical sequence of commands to issue in order to use that script:
# awk -F'^' -f ori_split_best.awk best_to_split.csv ori_por_best_known_so_far.csv > ori_por_best_known_so_far.csv.new
# sort -t'^' -k1,1 ori_por_best_known_so_far.csv.new > ori_por_best_known_so_far.csv.new2
# \mv ori_por_best_known_so_far.csv.new2 ori_por_best_known_so_far.csv.new
# Check with:
# comm -3 ori_por_best_known_so_far.csv ori_por_best_known_so_far.csv.new | less
# Then:
# \mv ori_por_best_known_so_far.csv.new ori_por_best_known_so_far.csv
# git add ori_por_best_known_so_far.csv
#

##
# List of POR to be split (e.g., 'best_to_split.csv')
# Sample lines:
# AAH-CA
/^([A-Z]{3})-([A-Z]{1,2})$/ {
	# Parse the line
	pk = $1
	iata_code = substr (pk, 1, 3)
	location_type = substr (pk, 5)

	# Register the IATA code for which the line must be split
	por_list[iata_code] = location_type
}

##
# ORI-maintained list of POR (normally, 'ori_por_best_known_so_far.csv')
# Sample lines:
# AAH-CA^AAH^50.75^6.133^AAH
/^([A-Z]{3})-([A-Z]{1,2})\^([A-Z]{3})\^/ {
	# Parse the line
	pk = $1
	iata_code = $2
	location_type = substr (pk, 5)

	if (iata_code in por_list) {
		# The POR line must be split
		OFS = FS
		location_type_size = length (location_type)
		for (idx = 1; idx <= location_type_size; idx++) {
			$1 = iata_code "-" substr (location_type, idx, 1)
			print ($0)
		}

	} else {
		# The POR can be kept as is
		print ($0)
	}
}
