#!/usr/bin/env python3

import getopt, sys, re, csv
from operator import add
from collections import OrderedDict, Mapping

#
# Default file-paths for input and output data files
#
airline_bestknown_filepath = '../../opentraveldata/optd_airline_best_known_so_far.csv'
airline_alliance_filepath = '../../opentraveldata/optd_airline_alliance_membership.csv'
new_airline_alliance_filepath = '../../opentraveldata/optd_airline_alliance_membership_new.csv'

#
# Initialize the airline-related dictionaries
#
def initializeAirlineDictionaries ():
    global_dict = dict()

    # Add the dictionary holding all the details for every airline
    global_dict['airlines'] = dict()

    # Add the dictionary holding, for every IATA code, the corresponding list
    # of airlines. Usually, there is a single active airline corresponding to
    # a given IATA code. However, there are some so-called IATA commercial
    # duplicates, always operating in distinct geographical regions. And,
    # more commonly, a given IATA code may have been given to quite a few
    # (now deprecated) airlines during the history.
    # The cargo version of some airlines may also be a distinct airline
    # with the same IATA code though. For instance, both Lufthansa and
    # Lufthansa Cargo share LH as IATA code, but have different ICAO codes
    # (DLH and GEC respectively).
    global_dict['airline-code-by-iata'] = dict()
    global_dict['airline-pk-by-code'] = dict()
    
    # Add the dictionary holding all the details for every alliance
    global_dict['alliances'] = dict()
    
    return global_dict

#
# Extract the details of airlines from the OpenTravelData CSV files
#
# pk^env_id^validity_from^validity_to^3char_code^2char_code^num_code^name^name2^alliance_code^alliance_status^type^wiki_link^alt_names^bases^key^version^parent_pk_list
#
def extractAirlineDetails (global_dict, airline_filepath, verboseFlag):
    """
    Derive a dictionary of all the airlines referenced within the OpenTravelData
    project
    """

    # Extract a handler on the airline-dedicated directory
    airline_all_dict = global_dict['airlines']
    airline_code_list_by_iata = global_dict['airline-code-by-iata']
    airline_pk_list_by_code = global_dict['airline-pk-by-code']
    
    # Parse the OPTD data file
    with open (airline_filepath, newline='') as csvfile:
        file_reader = csv.DictReader (csvfile, delimiter='^')
        for row in file_reader:
            pk = row['pk']
            env_id = row['env_id']
            validity_from = row['validity_from']
            validity_to = row['validity_to']
            iata_code = row['2char_code']
            icao_code = row['3char_code']
            num_code = row['num_code']
            air_name_utf8 = row['name']
            air_name_asc = row['name2']
            alliance_code = row['alliance_code']
            alliance_status = row['alliance_status']
            air_type = row['type']
            wiki_link = row['wiki_link']
            alt_names = row['alt_names']
            bases = row['bases']
            air_key = row['key']
            air_version = row['version']
            parent_pk_list = row['parent_pk_list']

            # Derive the airline aggregated code (ie, IATA and ICAO)
            air_code = iata_code + "^" + icao_code

            # Register the airline aggregated code in the list indexed
            # by IATA codes
            if not (iata_code in airline_code_list_by_iata):
                airline_code_list_by_iata[iata_code] = []

            airline_air_code_list = airline_code_list_by_iata[iata_code]
            airline_air_code_list.append (air_code)

            # Register the airline pk in the list indexed by aggregated codes
            if not (air_code in airline_pk_list_by_code):
                airline_pk_list_by_code[air_code] = []

            airline_pk_list = airline_pk_list_by_code[air_code]
            airline_pk_list.append (pk)
                
            # Register all the airline details in the list indexed by pk
            if not (air_code in airline_all_dict):
                airline_all_dict[pk] = {'pk': pk, 'key': air_key,
                                        'version': air_version,
                                        'env_id': env_id,
                                        'validity_from': validity_from,
                                        'validity_to': validity_to,
                                        '2char_code': iata_code,
                                        '3char_code': icao_code,
                                        'num_code': num_code,
                                        'type': air_type,
                                        'name': air_name_utf8,
                                        'name2': air_name_asc,
                                        'alliance_code': alliance_code,
                                        'alliance_status': alliance_status,
                                        'wiki_link': wiki_link,
                                        'alt_names': alt_names,
                                        'bases': bases,
                                        'parent_pk_list': parent_pk_list,
                                        'successor_pk_list': "",
                                        'flt_freq': ""}

    return

#
# Extract the details of alliances from the OpenTravelData CSV file
#
# alliance_name^alliance_type^airline_iata_code_2c^airline_name^from_date^to_date^env_id
#
def extractAllianceDetails (global_dict, alliance_filepath, verboseFlag):
    """
    Complete the airline details with the alliance details
    """

    # Extract handlers on the airline-dedicated directories
    airline_all_dict = global_dict['airlines']
    airline_code_list_dict = global_dict['airline-code-by-iata']
    airline_pk_list_dict = global_dict['airline-pk-by-code']
    
    # Extract a handler on the alliance-dedicated directory
    alliance_dict = global_dict['alliances']
    
    with open (alliance_filepath, newline='') as csvfile:
        file_reader = csv.DictReader (csvfile, delimiter='^')
        for row in file_reader:
            alliance_name = row['alliance_name']
            alliance_type = row['alliance_type']
            air_iata_code = row['airline_iata_code_2c']
            air_name = row['airline_name']
            alliance_env_id = row['env_id']

            # When the rule is no longer valid, just discard it for now
            if (alliance_env_id != ""): continue
            
            # Browse all the airlines corresponding to that IATA code
            air_code_list = airline_code_list_dict[air_iata_code]
            for air_code in air_code_list:
                pk_list = airline_pk_list_dict[air_code]
                for pk in pk_list:
                    # Retrieve the dictionary with all the airline details
                    airline_dict = airline_all_dict[pk]

                    # Filter out the non active airlines
                    air_env_id = airline_dict['env_id']
                    if (air_env_id != ""): continue

                    # Sanity check on the name
                    air_name_org = airline_dict['name']
                    if (air_name_org != air_name):
                        print ("[Error] The airline '" + air_iata_code
                               + "' has different names in the best known and alliance files, resp. '"
                               + air_name_org + "' and '" + air_name + "'")
                        raise Exception

                    # Set the alliance name and status
                    airline_dict['alliance_code'] = alliance_name
                    airline_dict['alliance_status'] = alliance_type

    return

#
# Extract the route frequencies from the OpenTravelData CSV file
#
# iata_code^icao_code^nb_seats^flight_freq
#
def extractFrequencies (global_dict, freq_filepath, verboseFlag):
    """
    Complete the airline details with the flight route frequencies
    """

    # Extract handlers on the airline-dedicated directories
    airline_all_dict = global_dict['airlines']
    airline_code_list_dict = global_dict['airline-code-by-iata']
    airline_pk_list_dict = global_dict['airline-pk-by-code']

    #
    with open (freq_filepath, newline='') as csvfile:
        file_reader = csv.DictReader (csvfile, delimiter='^')
        for row in file_reader:
            iata_code = row['iata_code']
            icao_code = row['icao_code']
            if (icao_code == "ZZZ"): icao_code = ""
            flt_freq = int(row['flight_freq'])

            # Derive the aggregated airline code (IATA and ICAO codes)
            air_code = iata_code + "^" + icao_code
            if not (air_code in airline_pk_list_dict):
                if (iata_code in airline_code_list_dict):
                    air_code_list = airline_code_list_dict[iata_code]
                    print ("[Error] The airline '" + iata_code + "/" + icao_code
                           +"' cannot be found in the OPTD airline data files ('"
                           + def_airline_bestknown_filepath + "' and '"
                           + def_airline_no_longer_valid_filepath + "'). "
                           + "Referenced airline(s) for that IATA code: "
                           + str(air_code_list)
                           + ". You may to re-run make_optd_ref_pr_and_freq.py")
                else:
                    print ("[Error] The airline '" + iata_code + "/" + icao_code
                           + "' cannot be found in the OPTD airline data files ('"
                           + def_airline_bestknown_filepath + "' and '"
                           + def_airline_no_longer_valid_filepath + "'). "
                           + "There is no airline with that IATA code."
                           + ". You may to re-run make_optd_ref_pr_and_freq.py")
                raise KeyError
            else:
                # Retrieve only the active airline
                pk_list = airline_pk_list_dict[air_code]
                activeAirlinePK = ""
                nbOfActiveAirlines = 0
                for pk in pk_list:
                    airline_dict = airline_all_dict[pk]
                    env_id = airline_dict['env_id']
                    if (env_id != ""): continue
                    else:
                        activeAirlinePK = airline_dict['pk']
                        nbOfActiveAirlines += 1

                # Sanity checks
                if (nbOfActiveAirlines == 0):
                    print ("[Error] The airline '" + iata_code + "/" + icao_code
                           + "' has no active record. List of PK: "
                           + str(pk_list))
                    raise KeyError
                if (nbOfActiveAirlines >= 2):
                    print ("[Warning] The airline '" + iata_code + "/"
                           + icao_code
                           + "' has " + str(nbOfActiveAirlines)
                           + " active records: " + str(pk_list)
                           + ". Only '" + activeAirlinePK + "' is retained here")

                # Set the flight frequency on the retrieved airline record
                airline_all_dict[activeAirlinePK]['flt_freq'] = flt_freq

    return

#
# Derive the successors (eg, "merged into" or "rebranded as")
#
def calculateSuccessors (global_dict, verboseFlag):
    """
    Derive the successors (eg, 'merged into' or 'rebranded as')
    """

    # Extract a handler on the airline-dedicated directory
    airline_all_dict = global_dict['airlines']

    # Browse all the airlines
    for (idx_airline, airline_dict) in airline_all_dict.items():
        # Retrieve the primary key
        pk = airline_dict['pk']
        iata_code = airline_dict['2char_code']
        icao_code = airline_dict['3char_code']

        # Retrieve the list of parents
        parent_pk_list_str = airline_dict['parent_pk_list']
        parent_pk_tuple_list = parent_pk_list_str.split("=")

        # Filter out the records having no specified parent (most of the cases)
        if len(parent_pk_list_str) == 0: continue

        # Browse the list of parent types and primary keys
        for parent_tuple_str in parent_pk_tuple_list:
            parent_tuple = parent_tuple_str.split("|")
            parent_type = parent_tuple[0]
            parent_pk = parent_tuple[1]
            
            # Retrieve the parent airline corresponding to the PK
            parent_airline_dict = airline_all_dict[parent_pk]
            parent_airline_successor_list_str = parent_airline_dict['successor_pk_list']

            # Set the successor (back link) in that parent airline
            successor_tuple_str = parent_type + "|" + pk
            if (parent_airline_successor_list_str != ""):
                parent_airline_dict['successor_pk_list'] += "="
            parent_airline_dict['successor_pk_list'] += successor_tuple_str

    return

#
# Sort the dictionary according to the values (pk, here)
#
def sortAirlineDict (unsorted_dict):
    
    def sort_function(t):
        try: 
            k, v = t
            return v['pk']
        except KeyError:
            return ""
    
    sorted_dict = OrderedDict (sorted (unsorted_dict.items(),
                                       key = sort_function, reverse=False))

    # DEBUG
    # from pprint import pprint as pp
    # pp (sorted_dict)
    
    return sorted_dict

#
# Dump the details of all the airlines into the given file
#
def dump_airlines (global_dict, output_filepath, verboseFlag):
    """
    Generate a CSV data file with the details of all the airlines
    """

    # Extract a handler on the airline-dedicated directory
    airline_all_dict = global_dict['airlines']

    # Sort the dictionary by the average number of seats
    airline_all_dict_sorted = sortAirlineDict (airline_all_dict)

    # Dump the details into the given CSV output file
    fieldnames = ['pk', 'env_id', 'validity_from', 'validity_to', '3char_code',
                  '2char_code', 'num_code', 'name', 'name2', 'alliance_code',
                  'alliance_status', 'type', 'wiki_link', 'flt_freq',
                  'alt_names', 'bases', 'key', 'version', 'parent_pk_list',
                  'successor_pk_list']

    with open (output_filepath, 'w', newline='') as output_csv:
        #
        fileWriter = csv.DictWriter (output_csv, delimiter='^',
                                     fieldnames = fieldnames,
                                     dialect = 'unix', quoting = csv.QUOTE_NONE)

        # Write the header
        fileWriter.writeheader()

        # Browse the POR having a PageRank value and dump the details
        for (idx_airline, airline_dict) in airline_all_dict_sorted.items():
            try:
                fileWriter.writerow (airline_dict)
            except:
                print ("Faulty row: " + str(airline_dict))

    return

#
# Main
#
def main():
    """
    Main
    """

    # Initialize the airline-related dictionaries
    global_dict = initializeAirlineDictionaries()

    # Extract the airline details from OpenTravelData (both from the file
    # of best known details and from the file of no longer valid airlines)
    extractAirlineDetails (global_dict, airline_bestknown_filepath, True)

    # Add the alliance details
    extractAllianceDetails (global_dict, airline_alliance_filepath, True)
    
    # DEBUG
    # from pprint import pprint as pp
    # pp (global_dict)

    # Dump the airline details into the output file
    dump_airlines (global_dict, new_airline_alliance_filepath, verboseFlag)

#
# Main, when launched from a library
#
if __name__ == "__main__":
    main()
