#!/usr/bin/python3

import getopt, sys, re, csv
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
    print ("  -h, --help                 : outputs this help and exits")
    print ("  -v, --verbose              : verbose output (debugging)")
    print ("  -o, --output <path>        : path to output file")
    print ("  -a, --airline-por <airline POR file-path> : File of best known POR details")
    print ("  -b, --best-known-por <OPTD best known POR file-path> : File of best known POR details")
    print ("")
	

#
# Command-line arguments
#
def handle_opt (usage_doc):
    """
    Handle the command-line options
    """

    try:
        opts, args = getopt.getopt (sys.argv[1:], "hv:o:a:b:",
                                    ["help", "verbose", "output",
                                     "airline-por", "best-known-por"])

    except (getopt.GetoptError, err):
        # Print help information and exit. It will print something like
        # "option -d not recognized"
        print (str (err))
        usage (sys.argv[0], usage_doc)
        sys.exit(2)
	
    # Options
    verboseFlag = False
    por_airline_filename = '../opentraveldata/optd_airline_por_rcld.csv'
    por_bestknown_filename = '../opentraveldata/optd_por_best_known_so_far.csv'
    output_filename = '../opentraveldata/ref_airport_pageranked_new.csv'

    # Handling
    for o, a in opts:
        if o in ("-h", "--help"):
            usage (sys.argv[0], usage_doc)
            sys.exit()
        elif o in ("-v", "--verbose"):
            verboseFlag = True
        elif o in ("-a", "--airline-por"):
            por_airline_filename = a
        elif o in ("-b", "--best-known-por"):
            por_bestknown_filename = a
        elif o in ("-o", "--output"):
            output_filename = a
        else:
            assert False, "Unhandled option"

    # 
    print ("Stream/file of best known POR details: '" + por_airline_filename + "'")
    print ("Stream/file of airline flights: '" + por_bestknown_filename + "'")
    print ("Output stream/file: '" + output_filename + "'")
    return (verboseFlag, por_airline_filename, por_bestknown_filename, output_filename)

#
# Store the POR details
#
def storePOR (por_dict, por_code, por_type, por_cty_code_list):
    if not (por_code in por_dict):
        por_dict[por_code] = dict()
        por_dict[por_code][por_type] = {'iata_code': por_code,
                                        'loc_type': por_type,
                                        'cty_code_list': por_cty_code_list}
    
    return
#
# Extract the best known details of POR from the OpenTravelData CSV file
#
def extractBksfPOR (optd_por_bestknown_filename, verboseFlag):
    """
    Derive a dictionary of all the POR referenced within the OpenTravelData
    project as 'best known so far' (bksf)
    """

    # Initialize the dictionary of POR
    por_dict = dict()
    
    # Browse the input file
    # Regular expression for the primary key (pk): (IATA code, type, Geonames ID)
    pk_re = re.compile ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,20})$")
    with open (optd_por_bestknown_filename, newline='') as csvfile:
        file_reader = csv.DictReader (csvfile, delimiter='^')
        for line in file_reader:
            # Extract the POR type from the primary key
            por_pk = line['pk']
            match = pk_re.match (por_pk)
            por_type = match.group (2)

            # Extract the IATA code
            por_code = line['iata_code']

            # Extract the list of city codes
            ctyCodeListStr = line['city_code']
            por_cty_code_list = ctyCodeListStr.join (',')
            
            # Store the POR
            storePOR (por_dict, por_code, por_type, por_cty_code_list)

    return (por_dict)

#
# Generate a directional graph from the CSV file
#
def deriveGraph (por_dict, optd_airline_por_filename, verboseFlag):
    """
    Derive two NetworkX directional graphs from the given input file:
     - One with, as weight, the monthly average number of seats
     - One with, as weight, the monthly flight frequency
    
    IEV-A^IEV
    IEV-C^IEV
    CHI-C^CHI
    DPA-A^CHI
    MDW-A^CHI
    ORD-A^CHI
    PWK-A^CHI
    RFD-A^CHI,RFD

    
    """

    # Initialise the NetworkX directional graphs (DiGraph)
    dg_seats = nx.DiGraph(); dg_freq = nx.DiGraph()

    # Browse the input file
    with open (optd_airline_por_filename, newline='') as csvfile:
        file_reader = csv.DictReader (csvfile, delimiter='^')
        for line in file_reader:
            # Extract the origin and destination POR
            apt_org = line['apt_org']
            apt_dst = line['apt_dst']

            # Store the POR
            errorMsg = "Error: POR in flight schedule, but not in OpenTravelData list of best known POR: "
            porExists = True
            if not (apt_org in por_dict):
                porExists = False
                sys.stderr.write (errorMsg + apt_org + "\n")
                continue
            if not (apt_dst in por_dict):
                porExists = False
                sys.stderr.write (errorMsg + apt_dst + "\n")
                continue

            # Extract the average number of seats
            seats = line['seats_mtly_avg']

            # Extract the average frequency
            freq = line['freq_mtly_avg']

            # Retrieve the POR dictionaries
            apt_org_dict = por_dict[apt_org]
            apt_dst_dict = por_dict[apt_dst]
                
            # Store the weights for the corresponding flight legs
            for apt_org_type in apt_org_dict:
                apt_org_pk = (apt_org, apt_org_type)
                for apt_dst_type in apt_dst_dict:
                    apt_dst_pk = (apt_dst, apt_dst_type)

                    #
                    dg_seats.add_edge (apt_org_pk, apt_dst_pk,
                                       weight = float(seats))
                    dg_freq.add_edge (apt_org_pk, apt_dst_pk,
                                      weight = float(freq))

    return (dg_seats, dg_freq)


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
    for (idx_por_pk, page_rank) in prdict.items():
        # Update the maximum rank, if needed
        if page_rank > rank_max: rank_max = page_rank

    # DEBUG
    # print ('Max PageRank value: ' + str(rank_max))

    # Store the PageRank values into the global POR
    for (idx_por_pk, page_rank) in prdict.items():
        # Normalise the PageRank value
        normalised_page_rank = page_rank / rank_max

        # Store the normalized PageRank value
        idx_por = idx_por_pk[0]
        idx_por_type = idx_por_pk[1]
        por_dict[idx_por][idx_por_type][prTypeStr] = normalised_page_rank

    return

#
# Print the PageRank values into the given file
#
def dump_page_ranked_por (por_dict, prdict_seats, prdict_freq, output_filename, verboseFlag):
    """
    Generate a CSV data file with, for every POR, two PageRank values:
     - One based on the monthly average number of seats
     - The other one based on the monthly average flight frequency
    """

    # Normalize the PageRank values, and store them in the global POR
    # dictionary ('por_dict')
    normalizePR (por_dict, "pr_seats", prdict_seats, verboseFlag)
    normalizePR (por_dict, "pr_freq", prdict_freq, verboseFlag)

    # Dump the details into the given CSV output file
    fieldnames = ['iata_code', 'loc_type', 'pr_seats', 'pr_freq']
    with open (output_filename, 'w', newline='') as output_csv:
        #
        fileWriter = csv.DictWriter (output_csv, delimiter='^',
                                     fieldnames = fieldnames)

        # Write the header
        fileWriter.writeheader()

        # Browse the POR having a PageRank value and dump the details
        for (idx_por, pr_dict_full) in por_dict.items():
            for (idx_por_type, pr_dict) in pr_dict_full.items():
                if 'pr_seats' in pr_dict:
                    fileWriter.writerow (pr_dict)

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
    (verboseFlag, por_airline_filename, por_bestknown_filename, output_filename) = handle_opt (usageStr)

    # Extract the POR from OpenTravelData best known details
    por_dict = extractBksfPOR (por_bestknown_filename, verboseFlag)
    
    # Build directional graphs from the file of flight schedule:
    # - One with, as weight, the monthly average number of seats
    # - One with, as weight, the monthly flight frequency
    (dict_seats, dict_freq) = deriveGraph (por_dict, por_airline_filename, verboseFlag)

    # Derive the PageRank values
    prdict_seats = nx.pagerank (dict_seats)
    prdict_freq = nx.pagerank (dict_freq)

    # DEBUG
    # print (prdict_seats)
    # print (prdict_freq)

    # Dump the page ranked POR into the output file
    dump_page_ranked_por (por_dict, prdict_seats, prdict_freq,
                          output_filename, verboseFlag)


#
# Main, when launched from a library
#
if __name__ == "__main__":
    main()

