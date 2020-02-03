##
# That AWK script extracts all the (operating) legs, for all the airlines,
# from a CSV-ified schedule data file.
#
# The fields of that CSV-ified schedule date file are expected to be:
# date^origin^destination^STD^origin_offset^STA^
# destination_offset^arrival_date_variation^
# aircraft_owner^aircraft_type^code_sharing^joint_operation^traffic_restriction^
# marketing_carrier^
# flight_number^itinerary_number^leg_sequence_number^service_type^
# frequency_rate^origin_terminal^destination_terminal^
# pax_reservation_booking_designator^pax_reservation_booking_modifier^
# meal_service^departure_min_connecting_time_status^
# arrival_min_connecting_time_status^itinerary_number_overflow^
# cockpit_crew_employer^cabin_crew_employer^onward_flight_airline^
# onward_flight_number^onward_flight_aircraft_rotation_layover^
# onward_flight_operational_suffix^flight_transit_layover^
# traffic_restriction_overflow_indicator^aircraft_configuration^
# dei010^dei050^line_four_data
#
# Sample input line:
# 131128^JFK^LAX^0900^-0500^1225^-0800^0^AA^762^^^^AA^1^1^1^J^^8^4^
# FAJRDIYBHKMVWNSQLGO^^XX^D^D^^^^^^^^^^^ABAS1979/BA4310/LY8144/QF3100/TN1101^^
# AB011ONEWORLD~AB109BBBBBBFFFFFFFFFFFFF~AB5019OCT13~AB5031/2/4/12/18~AB505ET~
# AB860097/000/N/000/OCT13
#


##
# M A I N
{
	# Origin
	org_apt_code = $2

	# Destination
	dst_apt_code = $3

	# Operating carrier
	op_air_code = $9

	# DEI 010 - Operating information
	# dei10 = $37

	# DEI 050 - Marketing information
	dei50 = $38

	# When the marketing is empty, it means that the leg is operating
	if (dei50 == "") {
		print (op_air_code "^" org_apt_code "^" dst_apt_code)
	}
}
