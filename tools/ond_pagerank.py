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
# Derive the (isTravel, isCity) flag pair from the location type
#
def getTravelCityFlags (por_type):
    """
    The location type comes from the IATA specification:
    - City-related:
      - C for a populated place (usually a city, "metropolitan area",
      in IATA parlance)
      - O for an off-line point (usually both a populated place and a
      travel-related POR)
    - Travel-related:
      - A for airport
      - H for heliport
      - R for railway station
      - B for bus station
      - P for ferry port
    - Combination of a city (C) and travel-related: CA, CH, CR, CB, CP

    OpenTravelData (http://github.com/opentraveldata/opentraveldata) tries to
    distinguish between city- and travel-related POR, but there is still
    a significant backlog of POR "to split" (see for instance
    http://github.com/opentraveldata/opentraveldata/pull/42)

    """
    isTravel = True
    isCity = False

    # The POR is only city-related, it is not travel-related
    if (por_type == 'C'): isTravel = False

    # The POR is at least city-related, it can be as well travel-related
    if ('C' in por_type or 'O' in por_type): isCity = True

    return (isTravel, isCity)

#
# State whether the POR is travel-related.
#
def isTravel (por_type):
    """
    The location type comes from the IATA specification:
    - City-related:
      - C for a populated place (usually a city, "metropolitan area",
      in IATA parlance)
      - O for an off-line point (usually both a populated place and a
      travel-related POR)
    - Travel-related:
      - A for airport
      - H for heliport
      - R for railway station
      - B for bus station
      - P for ferry port
    - Combination of a city (C) and travel-related: CA, CH, CR, CB, CP
    """
    # The POR is only city-related, it is not travel-related
    if (por_type == 'C'):
        isTravel = False
    else:
        isTravel = True
    return isTravel

#
# State whether the POR is city-related.
#
def isCity (por_type):
    """
    The location type comes from the IATA specification:
    - City-related:
      - C for a populated place (usually a city, "metropolitan area",
      in IATA parlance)
      - O for an off-line point (usually both a populated place and a
      travel-related POR)
    - Travel-related:
      - A for airport
      - H for heliport
      - R for railway station
      - B for bus station
      - P for ferry port
    - Combination of a city (C) and travel-related: CA, CH, CR, CB, CP
    """
    # The POR is only city-related, it is not travel-related
    if ('C' in por_type or por_type == 'O'):
        isCity = True
    else:
        isCity = False
    return isCity

#
# Extract the location type (eg, 'CA', 'A') from the primary key (eg,
# 'EWR-A-5101809')
#
def getTypeFromPK (por_pk):
    # Regular expression for the primary key (pk): (IATA code, type, Geonames ID)
    pk_re = re.compile ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,20})$")
    pk_match = pk_re.match (por_pk)
    por_type = pk_match.group (2)
    return por_type

#
# Extract the POR code (eg, 'EWR') from the primary key (eg, 'EWR-A-5101809')
#
def getCodeFromPK (por_pk):
    # Regular expression for the primary key (pk): (IATA code, type, Geonames ID)
    pk_regexp = re.compile ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,20})$")
    pk_match = pk_regexp.match (por_pk)
    por_code = pk_match.group (1)
    return por_code

#
# State whether the location type is merged (eg, 'CA', 'CR', or 'O';
# as opposed to, eg, 'C', 'A', 'R').
#
def isMerged (por_dict_list):
    if (len (por_dict_list) == 1):
        isMerged = True
    else:
        isMerged = False
    return isMerged

#
# Retrieve the pair of travel- and city-related POR. There is always a
# travel-related POR, and a city-related POR; however, both may be merged.
# If the location type is merged (eg, 'CA', 'CR', or 'O'), then there is
# no distinct city-related POR (ie, 'C'): both types are merged within
# a single POR.
#
def getTravelPOR (por_dict_list):
    por_tvl = None
    por_cty = None
    
    for (por_pk, por_dict) in por_dict_list.items():
        (isTravel, isCity) = getTravelCityFlags (por_type)
        if (isTravel == True): por_tvl = por_dict
        if (isCity == True): por_cty = por_dict

    return (por_tvl, por_cty)

#
# Build the primary key (IATA code, location type, Geonames ID)
#
def buildPK (por_code, por_type, por_geoid):
    try:
        por_pk = por_code + '-' + por_type + '-' + por_geoid
    except:
        print (str(por_code) + '-' + str(por_type) + '-' + str(por_geoid))
        raise
    return por_pk

#
# Extract the list of primary keys from the dictionary of POR
#
def getPKList (por_dict_list):
    por_pk_list = list(por_dict_list.keys())
    return por_pk_list

#
# Extract the primary key of the travel-related POR.
# There can only be one such POR.
#
def getTravelPK (por_dict_list):
    por_tvl_pk = None
    for por_pk in por_dict_list:
        por_type = getTypeFromPK (por_pk)
        is_travel = isTravel (por_type)
        if (is_travel == True):
            por_tvl_pk = por_pk
            break

    return por_tvl_pk

#
# Store the POR details
#
def storePOR (por_all_dict, por_code, por_type, por_geoid, por_cty_code_list):
    # Initialize the per-POR dictionary when needed
    if (not por_code in por_all_dict):
        por_all_dict[por_code] = dict()

    por_pk = buildPK (por_code, por_type, por_geoid)
    por_all_dict[por_code][por_pk] = {'iata_code': por_code,
                                      'location_type': por_type,
                                      'geoname_id': por_geoid,
                                      'city_code_list': por_cty_code_list}
    
    return

#
# Extract the best known details of POR from the OpenTravelData CSV file
#
def extractBksfPOR (por_all_dict, optd_por_bestknown_filename, verboseFlag):
    """
    Derive a dictionary of all the POR referenced within the OpenTravelData
    project as 'best known so far' (bksf)
    """
    # Browse the input file.
    # Regular expression for the primary key (pk): (IATA code, type, Geonames ID)
    pk_re = re.compile ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,20})$")
    with open (optd_por_bestknown_filename, newline='') as csvfile:
        file_reader = csv.DictReader (csvfile, delimiter='^')
        for line in file_reader:
            # Extract the POR type from the primary key
            por_pk = line['pk']
            match = pk_re.match (por_pk)
            por_type = match.group (2)
            por_geoid = match.group (3)

            # Extract the IATA code
            por_code = line['iata_code']

            # Extract the list of city codes
            ctyCodeListStr = line['city_code']
            por_cty_code_list = ctyCodeListStr.split (',')

            # Store the POR
            storePOR (por_all_dict, por_code, por_type, por_geoid, por_cty_code_list)

    return (por_all_dict)

#
# Store the flight leg edges into both directional graphs
#
def storeEdge (por_org_pk, por_dst_pk, nb_seats, nb_freq, dg_seats, dg_freq):
    # Store the weights for the corresponding flight legs
    dg_seats.add_edge (por_org_pk, por_dst_pk, weight = float(nb_seats))
    dg_freq.add_edge (por_org_pk, por_dst_pk, weight = float(nb_freq))
    return

#
# Generate a directional graph from the CSV file
#
def deriveGraph (por_all_dict, optd_airline_por_filename, verboseFlag):
    """
    Derive two NetworkX directional graphs from the given input file:
     - One with, as weight, the monthly average number of seats
     - One with, as weight, the monthly flight frequency

    POR records, as appearing in the file of best known details:

    EWR-A-5101809^NYC,EWR
    EWR-C-5099738^EWR
    EWR-C-5101798^EWR
    CHI-C-4887398^CHI
    ORD-A-4887479^CHI
    IFO-CA-6300962^IFO
    KBP-A-6300952^IEV

    Raw flight leg records, with their weights:
    AA^EWR^ORD^450.0
    PS^IFO^KBP^200.0

    Extrapolated/rebuilt flight leg records:
    AA^NYC-C^EWR-A^450.0
    AA^EWR-C^EWR-A^450.0
    AA^EWR-A^ORD-A^450.0
    AA^ORD-A^CHI-C^450.0
    PS^IFO-CA^KBP-A^200.0
    PS^KBP-A^IEV-C^200.0

    And the derived graph:
    {NYC-C,EWR-C}--450.0--EWR-A--450.0--ORD-A--450.0--CHI-C
    IFO-CA--200.0--KBP-A--200.0--IEV-C
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
            errorMsg = "Warning: POR in flight schedule, but not in OpenTravelData list of best known POR: "
            porExists = True
            if not (apt_org in por_all_dict):
                porExists = False
                sys.stderr.write (errorMsg + apt_org + "\n")
                continue
            if not (apt_dst in por_all_dict):
                porExists = False
                sys.stderr.write (errorMsg + apt_dst + "\n")
                continue

            # Extract the average number of seats
            nb_seats = line['seats_mtly_avg']

            # Extract the average frequency
            nb_freq = line['freq_mtly_avg']

            # Retrieve the POR dictionaries
            apt_org_dict_list = por_all_dict[apt_org]
            apt_dst_dict_list = por_all_dict[apt_dst]

            # Retrieve the primary keys of the travel-related POR
            apt_org_tvl_pk = getTravelPK (apt_org_dict_list)
            apt_dst_tvl_pk = getTravelPK (apt_dst_dict_list)
                
            # Determine whether there is a need for extra edges.
            # Those extra edges are (potentially) between the city-
            # and travel-related origin POR.
            for (apt_org_pk, apt_org_dict) in apt_org_dict_list.items():
                apt_org_type = getTypeFromPK (apt_org_pk)
                is_travel = isTravel (apt_org_type)
                if (is_travel == True):
                    continue
                        
                # Store the extra flight leg edge
                storeEdge (apt_org_pk, apt_org_tvl_pk, nb_seats, nb_freq,
                           dg_seats, dg_freq)

            # Determine whether there is a need for extra edges.
            # Those extra edges are (potentially) between the city-
            # and travel-related origin POR.
            for (apt_dst_pk, apt_dst_dict) in apt_dst_dict_list.items():
                apt_dst_type = getTypeFromPK (apt_dst_pk)
                is_travel = isTravel (apt_dst_type)
                if (is_travel == True):
                    continue
                        
                # Store the extra flight leg edge
                storeEdge (apt_dst_pk, apt_dst_tvl_pk, nb_seats, nb_freq,
                           dg_seats, dg_freq)

            # Store the flight leg edge
            storeEdge (apt_org_tvl_pk, apt_dst_tvl_pk, nb_seats, nb_freq,
                       dg_seats, dg_freq)


    return (dg_seats, dg_freq)

#
# Filter in only the fields to be dumped into the CSV file
# ['pk', 'iata_code', 'pr_seats', 'pr_freq']
#
def filterOutFields (pr_dict, fieldnames):
    # Retrieve the IATA code
    assert (fieldnames[1] == 'iata_code'), "The second field is not 'iata_code'!"
    por_code = pr_dict[fieldnames[1]]

    # Retrieve the location type
    por_type = pr_dict['location_type']
    
    # Retrieve the Geonames ID
    por_geoid = pr_dict['geoname_id']

    # Derive the primary key (IATA code combined with the location  type)
    por_pk = buildPK (por_code, por_type, por_geoid)
    
    # Retrieve the PageRank derived from the average number of seats
    assert (fieldnames[2] == 'pr_seats'), "The third field is not 'pr_seats'!"
    pr_seats = pr_dict[fieldnames[2]]
    
    # Retrieve the PageRank derived from the average flight frequency
    assert (fieldnames[3] == 'pr_freq'), "The third field is not 'pr_freq'!"
    pr_freq = pr_dict[fieldnames[3]]
    
    pr_dict_fltd = {fieldnames[0]: por_pk,
                    fieldnames[1]: por_code,
                    fieldnames[2]: pr_seats,
                    fieldnames[3]: pr_freq}
    return pr_dict_fltd

#
# Normalize the PageRank values, and store them into the global POR dictionary
#
def normalizePR (por_all_dict, prTypeStr, pr_dict, verboseFlag):
    """
    Store the PageRank values into the global POR dictionary
    """

    # Number of POR (points of reference)
    nb_of_por = len (pr_dict)

    # Maximum rank
    rank_max = 1e-10

    # DEBUG
    # print ('Nb of legs: ' + str(nb_of_por))

    # Derive the maximum PageRank value
    for (idx_por_pk, page_rank) in pr_dict.items():
        # Update the maximum rank, if needed
        if page_rank > rank_max: rank_max = page_rank

    # DEBUG
    # print ('Max PageRank value: ' + str(rank_max))

    # Store the PageRank values into the global POR
    for (idx_por_pk, page_rank) in pr_dict.items():
        # Normalise the PageRank value
        normalised_page_rank = page_rank / rank_max

        # Store the normalized PageRank value
        idx_por = getCodeFromPK (idx_por_pk)
        por_all_dict[idx_por][idx_por_pk][prTypeStr] = normalised_page_rank

    return

#
# Print the PageRank values into the given file
#
def dump_page_ranked_por (por_all_dict, prdict_seats, prdict_freq, output_filename, verboseFlag):
    """
    Generate a CSV data file with, for every POR, two PageRank values:
     - One based on the monthly average number of seats
     - The other one based on the monthly average flight frequency
    """

    # Normalize the PageRank values, and store them in the global POR
    # dictionary ('por_all_dict')
    normalizePR (por_all_dict, "pr_seats", prdict_seats, verboseFlag)
    normalizePR (por_all_dict, "pr_freq", prdict_freq, verboseFlag)

    # Dump the details into the given CSV output file
    fieldnames = ['pk', 'iata_code', 'pr_seats', 'pr_freq']
    with open (output_filename, 'w', newline='') as output_csv:
        #
        fileWriter = csv.DictWriter (output_csv, delimiter='^',
                                     fieldnames = fieldnames)

        # Write the header
        fileWriter.writeheader()

        # Browse the POR having a PageRank value and dump the details
        for (idx_por, pr_dict_full) in por_all_dict.items():
            for (idx_por_type, pr_dict) in pr_dict_full.items():
                if 'pr_seats' in pr_dict:
                    # Filter out the fields not to be dumpred into the CSV file
                    pr_dict_fltd = filterOutFields (pr_dict, fieldnames)
                    fileWriter.writerow (pr_dict_fltd)

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
    por_all_dict = dict()
    extractBksfPOR (por_all_dict, por_bestknown_filename, verboseFlag)
    
    # Build directional graphs from the file of flight schedule:
    # - One with, as weight, the monthly average number of seats
    # - One with, as weight, the monthly flight frequency
    (dict_seats, dict_freq) = deriveGraph (por_all_dict, por_airline_filename, verboseFlag)

    # Derive the PageRank values
    prdict_seats = nx.pagerank (dict_seats)
    prdict_freq = nx.pagerank (dict_freq)

    # DEBUG
    # print (prdict_seats)
    # print (prdict_freq)

    # Dump the page ranked POR into the output file
    dump_page_ranked_por (por_all_dict, prdict_seats, prdict_freq,
                          output_filename, verboseFlag)


#
# Main, when launched from a library
#
if __name__ == "__main__":
    main()

