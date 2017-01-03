#!/usr/bin/python3

import getopt, sys, re, csv
import networkx as nx
from operator import add
from collections import OrderedDict, Mapping
from itertools import chain

#
# Default file-paths for input and output data files
#
def_airline_bestknown_filepath = '../opentraveldata/optd_airline_best_known_so_far.csv'
def_airline_no_longer_valid_filepath = '../opentraveldata/optd_airline_no_longer_valid.csv'
def_freq_filepath = '../opentraveldata/ref_airline_nb_of_flights.csv'
def_airline_filepath = '../opentraveldata/optd_airlines.csv'

#
_FLAG_FIRST = object()

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
    print ("  -f, --freq <Flight frequency file-path> :")
    print ("\tInput data file of flight frequency values")
    print ("\tDefault: '" + def_freq_out_filepath + "'")
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
        opts, args = getopt.getopt (sys.argv[1:], "hv:p:a:b:n:f:",
                                    ["help", "verbose", "airline-por", 
                                     "airline", "best-known-airline",
                                     "no-longer-valid-airline",
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
    return (verboseFlag, airline_bestknown_filepath, airline_no_longer_valid_filepath, freq_filepath, airline_filepath)

#
# Store the POR details
#
def storePOR (por_all_dict, por_code, por_iata_code, por_type, por_geoid, por_cty_code_list):
    # Initialize the per-POR dictionary when needed
    if (not por_code in por_all_dict):
        por_all_dict[por_code] = dict()

    por_pk = buildPK (por_iata_code, por_type, por_geoid)
    por_dict = {'iata_code': por_iata_code, 'por_code': por_code,
                'location_type': por_type,
                'geoname_id': por_geoid, 'city_code_list': por_cty_code_list}
    por_all_dict[por_code][por_pk] = por_dict
    por_all_dict[por_code]['notified'] = False

    return

#
# Extract the best known details of airlines from the OpenTravelData CSV file
#
# pk^env_id^validity_from^validity_to^3char_code^2char_code^num_code^name^name2^alliance_code^alliance_status^type^wiki_link^flt_freq^alt_names^bases^key^version^parent_pk_list
#
def extractBksfAirline (airline_all_dict, airline_bestknown_filepath,
                        verboseFlag):
    """
    Derive a dictionary of all the airlines referenced within the OpenTravelData
    project as 'best known so far' (bksf)
    """
    with open (airline_bestknown_filepath, newline='') as csvfile:
        file_reader = csv.DictReader (csvfile, delimiter='^')
        for row in file_reader:
            #pk = row['pk']
            iata_code = row['2char_code']
            icao_code = row['3char_code']
            airline_code = iata_code
            if icao_code == "": icao_code = "ZZZ"
            if airline_code == "": airline_code = icao_code
            env_id = row['env_id']
            airline_name = row['name']

            # Register the airline, if active and not already registered
            if not (airline_code in airline_all_dict) and env_id == '':
                airline_all_dict[airline_code] = dict()

            if env_id == '':
                airline_all_dict[airline_code] = {'iata_code': iata_code,
                                                  'icao_code': icao_code,
                                                  'nb_seats': 0,
                                                  'flt_freq': 0,
                                                  'notified': False}

    return

#
# Extract the details of both valid and no longer valid airlines,
# from the two corresponding OpenTravelData CSV files
#
def extractAirlines (airline_all_dict, airline_bestknown_filepath,
                     airline_no_longer_valid_filepath, verboseFlag):
    """
    Derive a dictionary of all the airlines referenced within the OpenTravelData
    project as 'best known so far' (bksf)
    """
    
    return

#
# Add the flight frequencies
#
def addFrequencies (airline_all_dict, freq_filepath, verboseFlag):
    """
    Add the flight frequencies
    """
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
                                       key = sort_function, reverse=True))

    # DEBUG
    # from pprint import pprint as pp
    # pp (sorted_dict)
    
    return sorted_dict

#
# Filter in only the fields to be dumped into the CSV file
# ['pk', 'env_id', 'validity_from', 'validity_to', '3char_code',
# '2char_code', 'num_code', 'name', 'name2', 'alliance_code',
# 'alliance_status', 'type', 'wiki_link', 'flt_freq',
# 'alt_names', 'bases', 'key', 'version', 'parent_pk_list',
# 'successor_pk_list']
#
def filterOutAirlineFields (airline_dict, fieldnames):
    # Retrieve the IATA code
    assert (fieldnames[0] == 'iata_code'), "The first field is not 'iata_code'!"
    iata_code = airline_dict[fieldnames[0]]

    # Retrieve the ICAO code
    assert (fieldnames[1] == 'icao_code'), "The second field is not 'icao_code'!"
    icao_code = airline_dict[fieldnames[1]]

    # Retrieve the number of seats
    assert (fieldnames[2] == 'nb_seats'), "The third field is not 'nb_seats'!"
    nb_seats = airline_dict[fieldnames[2]]

    # Retrieve the flight frequency
    assert (fieldnames[3] == 'flight_freq'), "The fourth field is not 'flight_freq'!"
    flt_freq = airline_dict['flt_freq']

    #
    airline_dict_fltd = {fieldnames[0]: iata_code, fieldnames[1]: icao_code,
                         fieldnames[2]: nb_seats, fieldnames[3]: flt_freq}
    return airline_dict_fltd

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
            # Filter out the fields not to be dumped into the CSV file
            airline_dict_fltd = filterOutAirlineFields (airline_dict, fieldnames)
            fileWriter.writerow (airline_dict_fltd)

    return

#
# Main
#
def main():
    """
    Main
    """

    # Parse command options
    (verboseFlag, airline_bestknown_filepath, airline_no_longer_valid_filepath, freq_filepath, airline_filepath) = handle_opt()

    # Extract the airline details from OpenTravelData (both from the file
    # of best known details and from the file of no longer valid airlines)
    airline_all_dict = dict()
    extractAirlines (airline_all_dict, airline_bestknown_filepath,
                     airline_no_longer_valid_filepath, verboseFlag)

    # Add the flight frequencies
    addFrequencies (airline_all_dict, freq_filepath, verboseFlag)

    # Derive the successors (eg, "merged into" or "rebranded as")
    calculateSuccessors (airline_all_dict, verboseFlag)

    # Dump the airline details into the output file
    #dump_airlines (airline_all_dict, airline_filepath, verboseFlag)


#
# Main, when launched from a library
#
if __name__ == "__main__":
    main()
