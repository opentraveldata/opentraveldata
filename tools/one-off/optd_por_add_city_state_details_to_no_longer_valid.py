#!usr/bin/env python3

# That ad hoc script adds, for every POR, the country code and
# state (ISO3166-2) code of the city served by that POR.
# The input file is the list of POR no longer referenced by IATA.
# That input file is curated fully manually. It is therefore assumed
# that the country (code) and state (code) of the served city(ies)
# are the same as the POR's ones. It may not be fully exact but, again,
# if any error is introduced, it will be fixed the next time some humnan
# being will have a deeper look at those records. And since those records
# are no longer active/referenced, it is not so much of an issue to get
# some potential inaccuracies for the country/state (codes) of the served
# city(ies).

import csv

# Input
optd_por_file = '../opentraveldata/optd_por_no_longer_valid.csv'

# Output
optd_por_out_file = '../opentraveldata/optd_por_no_longer_valid.csv.new'

# Standard header for the OPTD POR data files (e.g., optd_por_public_all.csv)
k_optd_std_hdr = ('iata_code', 'icao_code', 'faa_code',
                  'is_geonames', 'geoname_id', 'envelope_id',
                  'name', 'asciiname', 'latitude', 'longitude',
                  'fclass', 'fcode', 'page_rank', 'date_from', 'date_until',
                  'comment', 'country_code', 'cc2', 'country_name',
                  'continent_name',
                  'adm1_code', 'adm1_name_utf', 'adm1_name_ascii',
                  'adm2_code', 'adm2_name_utf', 'adm2_name_ascii',
                  'adm3_code', 'adm4_code', 'population', 'elevation', 'gtopo30',
                  'timezone', 'gmt_offset', 'dst_offset', 'raw_offset',
                  'moddate',
                  'city_code_list', 'city_name_list', 'city_detail_list',
                  'tvl_por_list', 'iso31662', 'location_type', 'wiki_link',
                  'alt_name_section', 'wac', 'wac_name', 'ccy_code',
                  'unlc_list', 'uic_list', 'geoname_lat', 'geoname_lon')

# Browse the input file
optd_por_list = []
with open (optd_por_file, newline='') as csvfile:

    file_reader = csv.reader (csvfile, delimiter='^')
    for row in file_reader:
        # IATA code of the POR
        iata_code = row[0]

        # Some rows are still work-in-progress, labelled as 'TODO'.
        # The number of fields for those rows is well below 42.
        if len(row) >= 42:
            # Location type
            loc_type = row[41]

            # Country code of the POR
            country_code = row[16]

            # State (ISO3166-2) code of the POR
            state_code = row[40]

            # String with the details (IATA code, Geonames ID, UTF8 name,
            # ASCII name) of the served cities. The city detail strings
            # are separated by an equal sign ('=').
            # For a given city, the details are separated by the pipe
            # sign ('|')
            city_detail_list_str = row[38]
            city_detail_list = city_detail_list_str.split ('=')

            # Browse the list of cities
            city_detail_list2 = []
            for city_details_str in city_detail_list:
                city_details = city_details_str.split ('|')

                # Append the country code
                city_details.append (country_code)

                # Append the state (ISO3166-2) code
                city_details.append (state_code)

                # Shape back into a string
                city_details_str2 = '|'.join (city_details)

                # Add the details for that city to the current list
                city_detail_list2.append (city_details_str2)

            # Shape back into a string
            city_detail_list_str2 = '='.join (city_detail_list2)

            # DEBUG
            #print (f"{iata_code}-{loc_type}: {city_detail_list_str2}")

            # Update the city details for the POR record in place
            row[38] = city_detail_list_str2

        # Add the POR row to the list of POR
        optd_por_list.append (row)

# DEBUG
#nb_rec = len(optd_por_list)
#print (f"Nb of records: {nb_rec}")

# Write the output file
with open (optd_por_out_file, 'w', newline ='') as csvfile:
    file_writer = csv.writer (csvfile, delimiter='^', lineterminator='\n')
    for record in optd_por_list:
        file_writer.writerow (record)
        
