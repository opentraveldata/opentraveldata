#!/usr/bin/python3

import getopt, sys, csv
import networkx as nx

#
# Usage
#
def usage (script_name, usage_doc):
    """
    Display the usage.
    """

    print ("")
    print ("Usage: %s [options]" % script_name)
    print ("")
    print (usage_doc)
    print ("")
    print ("Options:")
    print ("  -h, --help    : outputs this help and exits")
    print ("  -v, --verbose : verbose output (debugging)")
    print ("  -o <path>     : path to output file (if blank, stdout)")
    print ("  <path>        : input file (if blank, stdin)")
    print ("")
	

#
# Command-line arguments
#
def handle_opt (usage_doc):
    """
    Handle the command-line options
    """

    try:
        opts, args = getopt.getopt (sys.argv[1:], "hv:o:",
                                    ["help", "verbose", "output"])

    except (getopt.GetoptError, err):
        # Print help information and exit. It will print something like
        # "option -a not recognized"
        print (str (err))
        usage (sys.argv[0], usage_doc)
        sys.exit(2)
	
    # Options
    verboseFlag = False
    input_filename = ''
    output_filename = ''
    output_file = sys.stdout #'/dev/stdout'

    # Input stream/file
    if len (args) != 0:
        input_filename = args[0]

    # Handling
    for o, a in opts:
        if o in ("-h", "--help"):
            usage (sys.argv[0], usage_doc)
            sys.exit()
        elif o in ("-v", "--verbose"):
            verboseFlag = True
        elif o in ("-o", "--output"):
            output_filename = a
        else:
            assert False, "Unhandled option"

    # Output file
    if (output_filename != ''):
        output_file = open (output_filename, 'w')

    # 
    print ("Input stream/file: '" + input_filename + "'")
    print ("Output stream/file: '" + output_filename + "'")
    return (verboseFlag, input_filename, output_file)


#
# Generate a directional graph from the CSV file
#
def deriveGraph (optd_airline_por_filename, verboseFlag):
    """
    Derive two NetworkX directional graphs from the given input file:
     - One with, as weight, the monthly average number of seats
     - One with, as weight, the monthly flight frequency
    """

    # Initialize the dictionary of POR
    por_dict = dict()
    
    # Initialise the NetworkX directional graphs (DiGraph)
    dg_seats = nx.DiGraph(); dg_freq = nx.DiGraph()

    # Browse the input file (may be stdin)
    with open (optd_airline_por_filename, newline='') as csvfile:
        file_reader = csv.DictReader (csvfile, delimiter='^')
        for line in file_reader:
            # Extract the origin and destination POR
            apt_org = line['apt_org']
            apt_dst = line['apt_dst']

            # Store the POR
            if not (apt_org in por_dict):
                por_dict[apt_org] = dict()
            if not (apt_dst in por_dict):
                por_dict[apt_dst] = dict()

            # Extract the average number of seats
            seats = line['seats_mtly_avg']

            # Extract the average frequency
            freq = line['freq_mtly_avg']

            # Store the weights into the corresponding schedules
            dg_seats.add_edge (apt_org, apt_dst, weight = float(seats))
            dg_freq.add_edge (apt_org, apt_dst, weight = float(freq))

    return (por_dict, dg_seats, dg_freq)


#
# Normalize the PageRank values, and store them into the global POR dictionary
#
def normalizePR (por_dict, prTypeStr, prdict, verboseFlag):
    """
    Store the PageRank values into the global POR dictionary
    """

    # Number of POR (points of reference)
    nb_of_por = len(prdict)

    # Maximum rank
    rank_max = 1e-10

    # DEBUG
    # print ('Nb of legs: ' + str(nb_of_por))

    # Derive the maximum PageRank value
    for (idx_por, page_rank) in prdict.items():
        # Update the maximum rank, if needed
        if page_rank > rank_max: rank_max = page_rank

    # DEBUG
    # print ('Max PageRank value: ' + str(rank_max))

    # Store the PageRank values into the global POR
    for (idx_por, page_rank) in prdict.items():
        # Normalise the PageRank value
        normalised_page_rank = page_rank / rank_max

        # Store the normalized PageRank value
        por_dict[idx_por][prTypeStr] = normalised_page_rank

    return

#
# Print the PageRank values into the given file
#
def dump_page_ranked_por (por_dict, prdict_seats, prdict_freq, output_file, verboseFlag):
    """
    Generate a CSV data file with, for every POR, two PageRank values:
     - One based on the monthly average number of seats
     - The other one based on the monthly average flight frequency
    """

    # Normalize the PageRank values, and store them in the global POR
    # dictionary ('por_dict')
    normalizePR (por_dict, "pr_seats", prdict_seats, verboseFlag)
    normalizePR (por_dict, "pr_freq", prdict_freq, verboseFlag)

    # Write the header
    headerStr = "iata_code^pr_seats^pr_freq"
    output_file.write (headerStr + '\n')

    # Dump the PageRank values
    for (idx_por, pr_dict) in por_dict.items():
        # Extract the seats-based PageRank value
        pr_seats = pr_dict['pr_seats']
        pr_freq = pr_dict['pr_freq']

        # Dump the details into the given CSV output file
        por_output_str = str(idx_por) + '^' + str(pr_seats) + '^' + str(pr_freq)
        output_file.write (por_output_str + '\n')

    return


#
# Main
#
def main():
    """
    Main
    """

    # Parse command options
    usageStr = "That script derives the PageRank values for a flight schedule"
    verboseFlag, input_file, output_file = handle_opt (usageStr)

    # Build directional graphs from the file of flight schedule:
    # - One with, as weight, the monthly average number of seats
    # - One with, as weight, the monthly flight frequency
    (por_dict, dict_seats, dict_freq) = deriveGraph (input_file, verboseFlag)

    # Derive the PageRank values
    prdict_seats = nx.pagerank (dict_seats)
    prdict_freq = nx.pagerank (dict_freq)

    # DEBUG
    # print (prdict_seats)
    # print (prdict_freq)

    # Dump the page ranked POR into the output file
    dump_page_ranked_por (por_dict, prdict_seats, prdict_freq,
                          output_file, verboseFlag)


#
# Main, when launched from a library
#
if __name__ == "__main__":
    main()

