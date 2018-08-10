#!/usr/bin/env python3

import getopt, sys, io
import pandas as pd

#
# Usage
#
def usage (script_name):
    """
    Display the usage.
    """

    print ("")
    print ("Usage: {} [options]".format(script_name))
    print ("")
    print ("That script transforms and filter a fix width data file into a hat symbol separated CSV one")
    print ("")
    print ("Options:")
    print ("  -h, --help                 : outputs this help and exits")
    print ("  -v, --verbose              : verbose output (debugging)")
    print ("  -i, --input <input data file-path>")
    print ("  -o, --output <output data file-path>")
    print ("")  

#
# Command-line arguments
#
def handle_opt():
    """
    Handle the command-line options
    """

    try:
        opts, args = getopt.getopt (sys.argv[1:], "hv:i:o:",
                                    ["help", "verbose", "input", "output"])

    except (getopt.GetoptError, err):
        # Print help information and exit. It will print something like
        # "option -d not recognized"
        print (str (err))
        usage (sys.argv[0], usage_doc)
        sys.exit(2)
    
    # Options
    verboseFlag = False
    airline_input_filepath = ''
    airline_output_filepath = ''
    airline_input_file = sys.stdin # '/dev/stdin'
    airline_output_file = sys.stdout # '/dev/stdout'
    
    # Input stream/file
    if len (args) != 0:
        airline_input_filepath = args[0]

    # Handling
    for o, a in opts:
        if o in ("-h", "--help"):
            usage (sys.argv[0])
            sys.exit()
        elif o in ("-v", "--verbose"):
            verboseFlag = True
        elif o in ("-i", "--input"):
            airline_input_filepath = a
        elif o in ("-o", "--output"):
            airline_output_filepath = a
        else:
            raise ValueError ("That option ({}) is unknown. Rerun that script with the -h option to see the accepted options".format(o))

    # Input file. That file may be compressed with GNU Zip (gzip)
    if (airline_input_filepath != ''):
        airline_input_file = open (airline_input_filepath, 'rb')
    
    # Output file-path
    if (airline_output_filepath != ''):
        airline_output_file = open (airline_output_filepath, 'w')

    # Report the configuration
    airline_input_filepath_str = airline_input_filepath \
                                 if airline_input_filepath != '' \
                                 else 'Standard input'
    airline_output_filepath_str = airline_output_filepath \
                                  if airline_output_filepath != '' \
                                  else 'Standard output'
    if (airline_output_filepath_str != 'Standard output'):
        print ("Input data file: '{}'".format(airline_input_filepath_str))
        print ("Output data file: '{}'".format(airline_output_filepath_str))

    #
    return (verboseFlag, airline_input_filepath, airline_output_file)

def extract_df (airline_input_filepath):
    """
    Parse a fix width data file containing details
    about IATA referenced airlines, and fill in a Pandas data-frame
    """
    # Using Pandas with column specification
    col_names = ['name', 'num_code', '3char_code', '2char_code',
                 'address_street_1', 'address_street_2', 'address_city_name',
                 'address_state_name', 'address_country_name',
                 'address_postal_code',
                 'flag_1', 'flag_2', 'flag_3', 'flag_4', 'type',
                 'num_code_2']
    col_specs = [(0, 80), (80, 84), (84, 87), (87, 90),
                 (90, 130), (130, 170), (170, 195),
                 (195, 215), (215, 259),
                 (259, 373),
                 (373, 374), (374, 375), (375, 376), (376, 377), (377, 379),
                 (379, 385)]
    col_converters = {
        'num_code': lambda x: str(int(x)),
        'num_code_2': lambda x: str(int(x))}
    airline_df = pd.read_fwf(airline_input_filepath,
                             colspecs = col_specs, header = None,
                             names = col_names, converters = col_converters)

    # Leave empty fields empty (otherwise, Pandas specifies NaN)
    airline_df.fillna (value = '', method = None, inplace = True)

    # Merge num_code and num_code2
    airline_df['num_code'] = airline_df \
    .apply(lambda r: r['num_code'] if r['num_code'] != '' else r['num_code_2'],
                     axis = 1)
    
    # DEBUG
    #print (str(airline_df.head()))
    #print (str(airline_df.dtypes))

    #
    return (airline_df)

def dump_to_csv (airline_df, airline_output_file):
    """
    Dump a sub-set of the the Pandas data-frame into a CSV file.
    The field delimiter is the hat symbol ('^').
    """
    subcol_names = ['2char_code', '3char_code', 'num_code', 'name', 'type']
    
    # DEBUG
    #airline_spec_df = airline_df[airline_df['2char_code'] == 'LH'][subcol_names]
    #print (str(airline_spec_df))

    # Sort by IATA and ICAO codes
    airline_df.sort_values(['2char_code', '3char_code', 'num_code', 'name'],
                           ascending = True, inplace = True)
    
    # Dump the data-frame into a CSV file
    airline_df.to_csv (airline_output_file, sep = '^', columns = subcol_names,
                       header = True, index = False, doublequote = False,
                       quotechar = '|')
    

#
# Main
#
def main():
    """
    Main
    """

    # Parse command options
    (verboseFlag, airline_input_filepath, airline_output_file) = handle_opt()

    # DEBUG
    #print ("Type of file: '{}'".format(type(airline_input_filepath)))

    # Parse the fixed width data file of airline details
    airline_df = extract_df (airline_input_filepath)

    # Dump the Pandas data-frame into a CSV file
    dump_to_csv (airline_df, airline_output_file)

#
# Main, when launched from a library
#
if __name__ == "__main__":
    main()
