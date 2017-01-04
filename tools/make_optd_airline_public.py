#!/usr/bin/python3

import getopt, sys, re, csv
from operator import add
from collections import OrderedDict, Mapping

#
# Default file-paths for input and output data files
#
def_airline_bestknown_filepath = '../opentraveldata/optd_airline_best_known_so_far.csv'
def_airline_no_longer_valid_filepath = '../opentraveldata/optd_airline_no_longer_valid.csv'
def_airline_alliance_filepath = '../opentraveldata/optd_airline_alliance_membership.csv'
def_freq_filepath = '../opentraveldata/ref_airline_nb_of_flights.csv'
def_airline_filepath = '../opentraveldata/optd_airlines.csv'

#
# Usage
#
def usage (script_name):
    """
    Display the usage.
    """

    print ("")
    print ("Usage: %s [options]" % script_name)
    print ("")
    print ("That script derives both PageRank values for POR and flight frequencies for airlines")
    print ("")
    print ("Options:")
    print ("  -h, --help                 : outputs this help and exits")
    print ("  -v, --verbose              : verbose output (debugging)")
    print ("  -b, --best-known-airline <OPTD best known airlines file-path> :")
    print ("\tInput data file of best known airline details")
    print ("\tDefault: '" + def_airline_bestknown_filepath + "'")
    print ("  -n, --no-longer-valid-airline <OPTD no longer valid airlines file-path> :")
    print ("\tInput data file of no longer valid airline details")
    print ("\tDefault: '" + def_airline_no_longer_valid_filepath + "'")
    print ("  -l, --alliance <OPTD airline alliance file-path> :")
    print ("\tInput data file of airline alliance details")
    print ("\tDefault: '" + def_airline_alliance_filepath + "'")
    print ("  -f, --freq <Flight frequency file-path> :")
    print ("\tInput data file of flight frequency values")
    print ("\tDefault: '" + def_freq_filepath + "'")
    print ("  -a, --airline <OPTD airline file-path> :")
    print ("\tOutput data file of airline details")
    print ("\tDefault: '" + def_airline_filepath + "'")
    print ("")  

#
# Command-line arguments
#
def handle_opt():
    """
    Handle the command-line options
    """

    try:
        opts, args = getopt.getopt (sys.argv[1:], "hv:p:a:b:n:l:f:",
                                    ["help", "verbose", "airline-por", 
                                     "airline", "best-known-airline",
                                     "no-longer-valid-airline", "alliance",
                                     "freq"])

    except (getopt.GetoptError, err):
        # Print help information and exit. It will print something like
        # "option -d not recognized"
        print (str (err))
        usage (sys.argv[0], usage_doc)
        sys.exit(2)
    
    # Options
    verboseFlag = False
    airline_bestknown_filepath = def_airline_bestknown_filepath
    airline_no_longer_valid_filepath = def_airline_no_longer_valid_filepath
    airline_alliance_filepath = def_airline_alliance_filepath
    freq_filepath = def_freq_filepath
    airline_filepath = def_airline_filepath

    # Handling
    for o, a in opts:
        if o in ("-h", "--help"):
            usage (sys.argv[0])
            sys.exit()
        elif o in ("-v", "--verbose"):
            verboseFlag = True
        elif o in ("-b", "--best-known-airline"):
            airline_bestknown_filepath = a
        elif o in ("-n", "--no-longer-valid-airline"):
            airline_no_longer_valid_filepath = a
        elif o in ("-l", "--alliance"):
            airline_alliance_filepath = a
        elif o in ("-f", "--freq"):
            freq_filepath = a
        elif o in ("-a", "--airline"):
            airline_filepath = a
        else:
            assert False, "Unhandled option"

    # Report the configuration
    print ("Input data file of best known airline details: '" + airline_bestknown_filepath + "'")
    print ("Input data file of no longer valid airline details: '" + airline_no_longer_valid_filepath + "'")
    print ("Input data file of flight frequency values: '" + freq_filepath + "'")
    print ("Output data file of airline details: '" + airline_filepath + "'")
    return (verboseFlag, airline_bestknown_filepath,
            airline_no_longer_valid_filepath, airline_alliance_filepath,
            freq_filepath, airline_filepath)

#
# Extract the details of airlines from the OpenTravelData CSV files
#
# pk^env_id^validity_from^validity_to^3char_code^2char_code^num_code^name^name2^alliance_code^alliance_status^type^wiki_link^alt_names^bases^key^version^parent_pk_list
#
def extractAirlineDetails (airline_all_dict, airline_filepath, verboseFlag):
    """
    Derive a dictionary of all the airlines referenced within the OpenTravelData
    project as 'best known so far' (bksf)
    """
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
            alliance_code = ""
            alliance_status = ""
            air_type = row['type']
            wiki_link = row['wiki_link']
            alt_names = row['alt_names']
            bases = row['bases']
            air_key = row['key']
            air_version = row['version']
            parent_pk_list = row['parent_pk_list']

            # Register the airline, if not already registered
            air_code = iata_code + "^" + icao_code
            if not (air_code in airline_all_dict):
                airline_all_dict[air_code] = {'pk': pk, 'key': air_key,
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
                                              'flt_freq': 0}

    return

#
# Extract the route frequencies from the OpenTravelData CSV file
#
# iata_code^icao_code^nb_seats^flight_freq
#
def extractFrequencies (airline_all_dict, freq_filepath, verboseFlag):
    """
    Complete the airline details with the flight route frequencies
    """
    with open (freq_filepath, newline='') as csvfile:
        file_reader = csv.DictReader (csvfile, delimiter='^')
        for row in file_reader:
            iata_code = row['iata_code']
            icao_code = row['icao_code']
            if (icao_code == "ZZZ"): icao_code = ""
            flt_freq = int(row['flight_freq'])

            air_code = iata_code + "^" + icao_code
            if not (air_code in airline_all_dict):
                print ("The airline '" + iata_code + "/" + icao_code
                       + "' cannot be found in the OPTD airline data files ('"
                       + def_airline_bestknown_filepath + "' and '"
                       + def_airline_no_longer_valid_filepath + "')")
                raise KeyError
            else:
                airline_all_dict[air_code]['flt_freq'] = flt_freq

    return

#
# Derive the successors (eg, "merged into" or "rebranded as")
#
def calculateSuccessors (airline_all_dict, verboseFlag):
    """
    Derive the successors (eg, 'merged into' or 'rebranded as')
    """
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
def dump_airlines (airline_all_dict, output_filepath, verboseFlag):
    """
    Generate a CSV data file with the details of all the airlines
    """

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

    # Parse command options
    (verboseFlag, airline_bestknown_filepath, airline_no_longer_valid_filepath, airline_alliance_filepath, freq_filepath, airline_filepath) = handle_opt()

    # Extract the airline details from OpenTravelData (both from the file
    # of best known details and from the file of no longer valid airlines)
    airline_all_dict = dict()
    extractAirlineDetails (airline_all_dict, airline_bestknown_filepath,
                           verboseFlag)
    extractAirlineDetails (airline_all_dict, airline_no_longer_valid_filepath,
                           verboseFlag)

    # Add the flight frequencies
    extractFrequencies (airline_all_dict, freq_filepath, verboseFlag)

    # DEBUG
    # from pprint import pprint as pp
    # pp (airline_all_dict)

    # Derive the successors (eg, "merged into" or "rebranded as")
    calculateSuccessors (airline_all_dict, verboseFlag)

    # Dump the airline details into the output file
    dump_airlines (airline_all_dict, airline_filepath, verboseFlag)


#
# Main, when launched from a library
#
if __name__ == "__main__":
    main()
