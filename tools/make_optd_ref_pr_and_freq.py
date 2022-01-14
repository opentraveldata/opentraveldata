#!/usr/bin/env python3

import getopt, sys, re, csv
import networkx as nx
from operator import add
import collections
from itertools import chain

#
# Default file-paths for input and output data files
#
def_optd_dir = "../opentraveldata"
def_w_seats = False
def_por_airline_filepath = f"{def_optd_dir}/optd_airline_por.csv"
def_por_airline_w_seats_filepath = f"{def_optd_dir}/optd_airline_por_rcld.csv"
def_por_filepath = f"{def_optd_dir}/optd_por_public_all.csv"
def_airline_bestknown_filepath = \
    f"{def_optd_dir}/optd_airline_best_known_so_far.csv"
def_pr_out_filepath = f"{def_optd_dir}/ref_airport_pageranked.csv"
def_freq_out_filepath = f"{def_optd_dir}/ref_airline_nb_of_flights.csv"

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
    print ("That script derives both PageRank values for POR " \
           "and flight frequencies for airlines")
    print ("")
    print ("Options:")
    print ("  -h, --help                 : outputs this help and exits")
    print ("  -v, --verbose              : verbose output (debugging)")
    print ("  -s, --with-seats           : input file contains nb of seats too")
    print ("  -a, --airline-por <airline POR file-path> :")
    print ("\tInput data file of airline flights")
    print (f"\tDefault:")
    print (f"\t\tWith frequencies only:    '{def_por_airline_filepath}'")
    print (f"\t\tWith number of seats too: '{def_por_airline_w_seats_filepath}'")
    print ("  -p, --por <OPTD POR file-path> :")
    print ("\tInput data file of POR details")
    print (f"\tDefault: '{def_por_filepath}'")
    print ("  -b, --best-known-airline <OPTD best known airlines file-path> :")
    print ("\tInput data file of best known airline details")
    print (f"\tDefault: '{def_airline_bestknown_filepath}'")
    print ("  -r, --pr-out <PageRank file-path> :")
    print ("\tOutput data file of PageRank values")
    print (f"\tDefault: '{def_pr_out_filepath}'")
    print ("  -f, --freq-out <Flight frequency file-path> :")
    print ("\tOutput data file of flight frequency values")
    print (f"\tDefault: '{def_freq_out_filepath}'")
    print ("")  

#
# Command-line arguments
#
def handle_opt():
    """
    Handle the command-line options
    """

    try:
        opts, args = getopt.getopt (sys.argv[1:], "hvsa:p:b:r:f:",
                                    ["help", "verbose", "with-seats",
                                     "airline-por", "por", "best-known-airline",
                                     "pr-out", "freq-out"])

    except (getopt.GetoptError, err):
        # Print help information and exit. It will print something like
        # "option -d not recognized"
        print (str (err))
        usage (sys.argv[0], usage_doc)
        sys.exit(2)
    
    # Options
    verboseFlag = False
    w_seats = def_w_seats
    por_airline_filepath = None
    por_filepath = def_por_filepath
    airline_bestknown_filepath = def_airline_bestknown_filepath
    pr_out_filepath = def_pr_out_filepath
    freq_out_filepath = def_freq_out_filepath

    # Handling
    for o, a in opts:
        if o in ("-h", "--help"):
            usage (sys.argv[0])
            sys.exit()
        elif o in ("-v", "--verbose"):
            verboseFlag = True
        elif o in ("-s", "--with-seats"):
            w_seats = True
        elif o in ("-a", "--airline-por"):
            por_airline_filepath = a
        elif o in ("-p", "--por"):
            por_filepath = a
        elif o in ("-b", "--best-known-airline"):
            airline_bestknown_filepath = a
        elif o in ("-r", "--pr-out"):
            pr_out_filepath = a
        elif o in ("-f", "--freq-out"):
            freq_out_filepath = a
        else:
            assert False, "Unhandled option"

    # Derive the file-path of the airline POR file, only when not set
    # by a a command-line parameter/option
    if not por_airline_filepath:
        if w_seats:
            por_airline_filepath = def_por_airline_w_seats_filepath
        else:
            por_airline_filepath = def_por_airline_filepath
    
    # Report the configuration
    print (f"Input data file of airline flights (wiht nb of seats? {w_seats}):" \
           f" '{por_airline_filepath}'")
    print (f"Input data file of POR details: '{por_filepath}'")
    print ("Input data file of best known airline details: " \
           f"'{airline_bestknown_filepath}'")
    print (f"Output data file of PageRank values: '{pr_out_filepath}'")
    print (f"Output data file of flight frequency values: '{freq_out_filepath}'")
    return (verboseFlag, w_seats, por_airline_filepath, por_filepath,
            airline_bestknown_filepath, pr_out_filepath, freq_out_filepath)

#
# Flatten any dictionary
# See also: http://stackoverflow.com/questions/6027558/flatten-nested-python-dictionaries-compressing-keys
#
def flattenDict (d, join = add, lift = lambda x: x):
    results = []
    def visit (subdict, results, partialKey):
        for k,v in subdict.items():
            newKey = lift(k) \
                if partialKey == _FLAG_FIRST \
                else join (partialKey, lift(k))
            if isinstance (v, collections.Mapping):
                visit (v, results, newKey)
            else:
                results.append ((newKey, v))
    visit (d, results, _FLAG_FIRST)
    return results

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
    if por_type == 'C':
        isTravel = False

    # The POR is at least city-related, it can be as well travel-related
    if 'C' in por_type or 'O' in por_type:
        isCity = True

    return (isTravel, isCity)

#
# State whether the POR is travel-related
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
    isTravel = True
    
    if por_type == 'C':
        # The POR is only city-related, it is not travel-related
        isTravel = False

    #
    return isTravel

#
# State whether the POR is city-only-related
#
def isCityOnlyFromPK (por_pk):
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
    # Regular expression for the primary key (pk): (IATA code, type, Geonames ID)
    pk_re = re.compile ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,20})$")
    pk_match = pk_re.match (por_pk)
    por_type = pk_match.group (2)
    isCityOnly = False

    if por_type == 'C':
        # The POR is only city-related, it is not travel-related
        isCityOnly = True

    #
    return isCityOnly

#
# Extract the location type (eg, 'CA', 'A') from the primary key (eg,
# 'EWR-A-5101809')
#
def getTypeFromPK (por_pk):
    # Regular expression for the primary key (pk): (IATA code, type, Geonames ID)
    pk_re = re.compile ("^(|[A-Z]{3})-([A-Z]{1,2})-([0-9]{1,20})$")
    pk_match = pk_re.match (por_pk)
    por_type = None
    
    try:
        
        por_type = pk_match.group (2)
        
    except:
        err_msg = f"Error - No location type in the primary key {por_pk}"
        raise KeyError (err_msg)

    return por_type

#
# Extract the IATA POR code (eg, 'EWR')
# from the primary key (eg, 'EWR-A-5101809')
#
def getIataCodeFromPK (por_pk):
    # Regular expression for the primary key (pk): (IATA code, type, Geonames ID)
    pk_regexp = re.compile ("^(|[A-Z]{3})-([A-Z]{1,2})-([0-9]{1,20})$")
    pk_match = pk_regexp.match (por_pk)
    por_code = None
    
    try:
        
        por_code = pk_match.group (1)
        
    except:
        err_msg = f"Error - No IATA code in the primary key {por_pk}"
        raise KeyError (err_msg)
    
    return por_code

#
# Retrieve the POR code (eg, 'EWR', 'WRLM') thanks to the primary key
# (eg, respecively 'EWR-A-5101809', '-A-8533855').
# When the IATA code is empty, the POR code is the ICAO code,
# and has to be retrieved from the por_all_dict dictionary.
#
def getCodeFromPK (por_all_dict, por_pk_noiata_dict, por_pk):
    # First, retrieve the IATA code, first element of the primary key
    por_code = getIataCodeFromPK (por_pk)

    # When the POR has no IATA code, retrieve ICAO code instead
    if not por_code:
        try:
            por_code = por_pk_noiata_dict[por_pk]
        except:
            err_msg = "Error - No entry can be found in the POR dictionary " \
                f"for '{por_pk}'; key_list: {key_list}"
            raise KeyError (err_msg)

    return por_code

#
# State whether the location type is merged (eg, 'CA', 'CR', or 'O';
# as opposed to, eg, 'C', 'A', 'R')
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
# Serialize the primary key (IATA code, location type, Geonames ID)
#
def buildPK (por_code, por_type, por_geoid):
    por_pk = f"{por_code}-{por_type}-{por_geoid}"
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
        # Filter out the records not appearing in the schedule
        if por_pk == 'notified': continue

        #
        por_type = getTypeFromPK (por_pk)
        is_travel = isTravel (por_type)
        if (is_travel == True):
            por_tvl_pk = por_pk
            break

    return por_tvl_pk

#
# Get all the POR primary keys corresponding to a given IATA code
#
def getPORPKList (por_all_dict, por_code):
    por_dict = por_all_dict[por_code]
    por_pk_list = []
    for por_pk in por_pk_list:
        # Filter out the records not appearing in the schedule
        if por_pk == 'notified': continue

        #
        por_pk_list.append (por_pk)
    return por_pk_list

#
# Get the list of primary keys for the city-only POR
#
def getCityPKList (por_all_dict, por_code, por_pk):
    por_dict = por_all_dict[por_code][por_pk]
    cty_code_list = por_dict['city_code_list']
    por_cty_pk_list = []
    for cty_code in cty_code_list:

        por_cty_full_dict = None
        try:
            
            por_cty_full_dict = por_all_dict[cty_code]
            
        except KeyError as err:
            err_msg = f"[Error] {err} - Code: {por_code}; PK: {por_pk}; " \
                f"cty_code_list: {cty_code_list}; idx/cty_code: {cty_code}. " \
                "Usually, it comes from the fact that the Geonames ID " \
                "in optd_por_best_known_so_far.csv is not the right one " \
                "(see optd_por_public.csv for the right Geonames ID)"
            raise KeyError (err_msg)

        for por_cty_pk in por_cty_full_dict:
            # Filter out the already known primary keys
            if por_pk == por_cty_pk or por_cty_pk == 'notified': continue

            # Keep the POR, which are cities only (ie, 'C')
            isCityOnly = isCityOnlyFromPK (por_cty_pk)
            if (isCityOnly == True):
                por_cty_pk_list.append (por_cty_pk)

    #
    return por_cty_pk_list

#
# Store the POR details
#
def storePOR (por_all_dict, por_code, por_iata_code, por_type, por_geoid, \
              por_cty_code_list):
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
# Extract the details of POR from the OpenTravelData CSV file
#
# iata_code^icao_code^faa_code^is_geonames^geoname_id^envelope_id^...^latitude^longitude^...^date_from^...^city_code_list^...^location_type^...
#
def extractPOR (por_all_dict, por_pk_noiata_dict, por_filepath, verboseFlag):
    """
    Derive a dictionary of all the POR referenced within the OpenTravelData
    project as public POR (Points Of Reference)
    """
    # Browse the input file.
    # Regular expression for the primary key (pk): (IATA code, type, Geonames ID)
    with open (por_filepath, newline='') as csvfile:
        file_reader = csv.DictReader (csvfile, delimiter='^')
        for row in file_reader:

            # Filter out the no longer valid POR
            por_env_id = row['envelope_id']
            if (por_env_id != ""): continue

            # Retrieve the IATA and ICAO codes
            por_iata_code = row['iata_code']
            por_icao_code = row['icao_code']

            # Filter out the POR having no IATA nor ICAO code
            if (por_iata_code == "" and por_icao_code == ""): continue
                        
            # Retrieve the POR details
            por_type = row['location_type']
            por_geo_id = row['geoname_id']
            por_coord_lat = row['latitude']
            por_coord_lon = row['longitude']
            por_date_from = row['date_from']
            por_city_code_list_str = row['city_code_list']

            # Derive a unique code, to be either IATA or ICAO
            por_code = por_iata_code
            if (por_code == ""):
                por_code = por_icao_code
                por_pk = buildPK (por_iata_code, por_type, por_geo_id)
                por_pk_noiata_dict[por_pk] = por_code
                
                # Normally, the list of cities is empty too.
                # For the PageRank algorithm, an entry for cities is needed,
                # so it is set to the ICAO code too
                if (por_city_code_list_str == ""):
                    por_city_code_list_str = por_icao_code

            # Extract the list of city codes
            por_city_code_list = por_city_code_list_str.split (',')

            # Store the POR
            storePOR (por_all_dict, por_code, por_iata_code, por_type,
                      por_geo_id, por_city_code_list)

    return (por_all_dict)

#
# Store the flight leg edges into both directional graphs
#
def storeEdge (w_seats, por_org_pk, por_dst_pk, nb_seats, nb_freq,
               dg_seats, dg_freq):
    
    # Store/add the weights for the corresponding flight legs
    isEdgeExisting = dg_seats.has_edge (por_org_pk, por_dst_pk)
    if not isEdgeExisting:
        dg_freq.add_edge (por_org_pk, por_dst_pk, weight = float(nb_freq))
        if w_seats:
            dg_seats.add_edge (por_org_pk, por_dst_pk, weight = float(nb_seats))
        
    else:
        dg_freq[por_org_pk][por_dst_pk]['weight'] += float(nb_freq)
        if w_seats:
            dg_seats[por_org_pk][por_dst_pk]['weight'] += float(nb_seats)

    #
    return

#
# Extract the best known details of airlines from the OpenTravelData CSV file
#
# pk^env_id^validity_from^validity_to^3char_code^2char_code^num_code^name^name2^alliance_code^alliance_status^type^wiki_link^flt_freq^alt_names^bases^key^version
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

            # TODO: there may be several active airlines for the same IATA code.
            #       Optimally, select the airline based on its base/region.
            #       Quick win: register the flt_freq for all those airlines
            if env_id == '':
                airline_all_dict[airline_code] = {'iata_code': iata_code,
                                                  'icao_code': icao_code,
                                                  'nb_seats': 0,
                                                  'flt_freq': 0,
                                                  'notified': False}

    return

#
# Analyze the data file of airline POR, and derive two main structures:
#  1. Airline-based flight frequencies, collected within the main airline
#     dictionary (airline_all_dict)
#  2. POR-based number of seats and flight frequencies, collected into
#     two dedicated NetworkX directional graphs (dg_seats and dg_freq)
#
def analyzeAirlinePOR (por_all_dict, por_pk_noiata_dict,
                       airline_all_dict, airline_por_filepath, w_seats,
                       verboseFlag):
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
    IEV-C-703448^IEV
    IFO-CA-6300962^IFO
    KBP-A-6300952^IEV
    NYC-C-5128581^NYC
    TRK-A-6301277^TRK
    TRK-C-1624725^TRK
    ZZZ-A-8533855^ZZZ # WITG
    ZZZ-A-8531915^ZZZ # WRLM

    Raw flight leg records, with their weights:
    AA^EWR^ORD^450.0
    PS^IFO^KBP^200.0
    KD^WRLM^TRK^500.0

    Extrapolated/rebuilt flight leg records:
    AA^NYC-C-5128581^ORD-A-4887479^450.0
    AA^EWR-C-5099738^ORD-A-4887479^450.0
    AA^EWR-C-5101798^ORD-A-4887479^450.0
    AA^EWR-A-5101809^ORD-A-4887479^450.0
    AA^NYC-C-5128581^CHI-C-4887398^450.0
    AA^EWR-C-5099738^CHI-C-4887398^450.0
    AA^EWR-C-5101798^CHI-C-4887398^450.0
    AA^EWR-A-5101809^CHI-C-4887398^450.0
    PS^IFO-CA-6300962^KBP-A-6300952^200.0
    PS^IFO-CA-6300962^IEV-C-703448^200.0
    KD^ZZZ-A-8531915^TRK-A-6301277^500.0
    KD^ZZZ-A-8531915^TRK-C-1624725^500.0

    And the derived graph:
    {(NYC-C-5128581),(EWR-C-5099738),(EWR-C-5101798),(EWR-A-5101809)}--450.0--{(ORD-A-4887479),(CHI-C-4887398)}
    (IFO-CA-6300962)--200.0--{(KBP-A-6300952),(IEV-C-703448)}
    (ZZZ-A-8531915)--500.0--{(TRK-A-6301277),(TRK-C-1624725)}

    Intuitive version, but which does not value the cities enough:
    {(NYC-C-5128581),(EWR-C-5099738),(EWR-C-5101798)}--450.0--(EWR-A-5101809)--450.0--(ORD-A-4887479)--450.0--(CHI-C-4887398)
    (IFO-CA-6300962)--200.0--(KBP-A-6300952)--200.0--(IEV-C-703448)
    (ZZZ-A-8531915)--500.0--(TRK-A-6301277)--500.0--(TRK-C-1624725)
    """

    # Initialise the NetworkX directional graphs (DiGraph)
    dg_seats = nx.DiGraph(); dg_freq = nx.DiGraph()

    # Browse the input file
    with open (airline_por_filepath, newline='') as csvfile:
        file_reader = csv.DictReader (csvfile, delimiter='^')
        for line in file_reader:
            # Extract the airline IATA code
            airline_code = line['airline_code']

            # Extract the origin and destination POR
            apt_org = line['apt_org']
            apt_dst = line['apt_dst']

            # Store the POR
            errorMsg = "Warning: POR in flight schedule, " \
                "but not in OpenTravelData list of POR: "

            if not (apt_org in por_all_dict):
                por_all_dict[apt_org] = dict()
                por_all_dict[apt_org]['notified'] = True
                
                sys.stderr.write (f"{errorMsg}{apt_org}\n")
                
                continue

            if not (apt_dst in por_all_dict):
                por_all_dict[apt_dst] = dict()
                por_all_dict[apt_dst]['notified'] = True
                
                sys.stderr.write (f"{errorMsg}{apt_dst}\n")
                
                continue

            # The POR cannot be found in OpenTravelData, but the error has
            # already been reported
            if por_all_dict[apt_org]['notified'] == True \
               or por_all_dict[apt_dst]['notified'] == True:
                continue
            
            # Extract the average frequency
            nb_freq = 0
            if w_seats:
                nb_freq = line['freq_mtly_avg']
                nb_freq = int(round(float(nb_freq)))
            else:
                nb_freq = line['flt_freq']
                nb_freq = int (nb_freq)


            # Extract the average number of seats
            nb_seats = 0
            if w_seats:
                nb_seats = line['seats_mtly_avg']
                nb_seats = int(round(float((nb_seats))))

            ##
            # Airlines
            ##
            if airline_code in airline_all_dict:
                airline_dict = airline_all_dict[airline_code]
                hasBeenNotified = airline_all_dict[airline_code]['notified']
                
                if hasBeenNotified == False:
                    airline_all_dict[airline_code]['flt_freq'] += nb_freq
                    
                    if w_seats:
                        airline_all_dict[airline_code]['nb_seats'] += nb_seats
                    
            else:
                airline_all_dict[airline_code] = dict()
                airline_all_dict[airline_code]['notified'] = True
                
                errorMsg = "Warning: airline in flight schedule, " \
                    "but not in OpenTravelData list of best known airlines: "
                sys.stderr.write (f"{errorMsg}{airline_code}\n")
            
            ##
            # POR
            ##
            
            # Retrieve the POR dictionaries
            apt_org_dict_list = por_all_dict[apt_org]
            apt_dst_dict_list = por_all_dict[apt_dst]

            # Retrieve the primary key of each of the travel-related POR
            # There should be only one. For instance:
            #  EWR  -> EWR-A-5101809
            #  ORD  -> ORD-A-4887479
            #  IFO  -> IFO-CA-6300962
            #  KBP  -> KBP-A-6300952
            #  WITG -> ZZZ-A-8533855
            #  WRLM -> ZZZ-A-8531915
            apt_org_tvl_pk = getTravelPK (apt_org_dict_list)
            apt_dst_tvl_pk = getTravelPK (apt_dst_dict_list)

            # Happens when location type is C
            if apt_org_tvl_pk is None:
                continue
            if apt_dst_tvl_pk is None:
                continue

            # Extract the corresponding IATA codes. Most of the time,
            # the POR code is the IATA code. When the IATA is empty,
            # the POR code is then the ICAO code instead.
            apt_org_iata_code = getIataCodeFromPK (apt_org_tvl_pk)
            apt_dst_iata_code = getIataCodeFromPK (apt_dst_tvl_pk)

            # Retrieve the (list of primary key of the) cities served
            # by the travel-related POR. For instance:
            #  EWR-A-5101809 -> NYC-C-5128581, EWR-C-5099738, EWR-C-5101798
            #  ORD-A-4887479 -> CHI-C-4887398
            #
            # When the IATA code is ZZZ, the POR is an airport having
            # no IATA code (but having an ICAO code), and there is
            # no served city

            apt_org_pk_list = []
            if (apt_org_iata_code != "ZZZ"):
                apt_org_pk_list = getCityPKList (por_all_dict, apt_org,
                                                 apt_org_tvl_pk)

            apt_dst_pk_list = []
            if (apt_dst_iata_code != "ZZZ"):
                apt_dst_pk_list = getCityPKList (por_all_dict, apt_dst,
                                                 apt_dst_tvl_pk)

            # Add back the travel-related POR (primary key) to the list
            # of POR (primary keys). For instance:
            apt_org_pk_list.append (apt_org_tvl_pk)
            apt_dst_pk_list.append (apt_dst_tvl_pk)

            # Derive all the edge combinations
            for apt_org_pk in apt_org_pk_list:
                for apt_dst_pk in apt_dst_pk_list:
                    # Store the flight leg edge
                    storeEdge (w_seats, apt_org_pk, apt_dst_pk,
                               nb_seats, nb_freq, dg_seats, dg_freq)

    return (dg_seats, dg_freq)

#
# Sort the dictionary according to the values (weights, here)
#
def sortPORDict (w_seats, unsorted_dict):
    #
    sorting_key = 'pr_freq'
    if w_seats:
        sorting_key = 'pr_seats'

    def sort_function(t):
        try: 
            k, v = t
            return v[sorting_key]
        except KeyError:
            return 0
    
    sorted_dict = collections.OrderedDict (sorted (unsorted_dict.items(),
                                                   key = sort_function,
                                                   reverse = True))
    return sorted_dict

#
# Sort the dictionary according to the values (flt_freq, here)
#
def sortAirlineDict (w_seats, unsorted_dict):
    #
    sorting_key = 'flt_freq'
    if w_seats:
        sorting_key = 'nb_seats'
    
    def sort_function(t):
        try: 
            k, v = t
            return v[sorting_key]
        except KeyError:
            return 0
    
    sorted_dict = collections.OrderedDict (sorted (unsorted_dict.items(),
                                                   key = sort_function,
                                                   reverse = True))

    # DEBUG
    # from pprint import pprint as pp
    # pp (sorted_dict)
    
    return sorted_dict

#
# Print the directed graph (DiGraph) into the corresponding CSV file 
#
def dump_digraph (dg, output_filepath, verboseFlag):
    """
    Generate a CSV data file with, for every edge of the DiGraph:
     - The origin POR primary key
     - The destination POR primary key
     - The weight, which is usually either the total capacity
       or the total frequency
    """

    fieldnames = ['org_pk', 'dst_pk', 'weight']
    with open (output_filepath, 'w', newline='') as output_csv:
        #
        fileWriter = csv.DictWriter (output_csv, delimiter='^',
                                     fieldnames = fieldnames)
        # Write the header
        fileWriter.writeheader()

        #
        for (org_pk, dst_pk, edge_data) in dg.edges (data = True):
            edge_weight = edge_data['weight']
            fileWriter.writerow ({'org_pk': org_pk, 'dst_pk': dst_pk,
                                  'weight': edge_weight})
        
    return

#
# Filter in only the fields to be dumped into the CSV file
# ['pk', 'por_code', 'pr_seats', 'pr_freq']
#
def filterOutPORFields (w_seats, pr_dict, fieldnames):
    # Retrieve the IATA code
    assert (fieldnames[1] == 'por_code'), "The second field is not 'por_code'!"
    por_code = pr_dict[fieldnames[1]]

    # Retrieve the location type
    por_type = pr_dict['location_type']
    
    # Retrieve the Geonames ID
    por_geoid = pr_dict['geoname_id']

    # Derive the primary key (IATA code combined with the location  type)
    por_pk = buildPK (por_code, por_type, por_geoid)

    # When relevant, retrieve the PageRank values derived
    # from the average number of seats
    pr_seats = 0
    if w_seats:
        assert (fieldnames[2] == 'pr_seats'), \
            "The third field is not 'pr_seats'!"
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
# Filter in only the fields to be dumped into the CSV file
# ['iata_code', 'icao_code', 'nb_seats', 'flight_freq']
#
def filterOutAirlineFields (w_seats, airline_dict, fieldnames):
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
    assert (fieldnames[3] == 'flight_freq'), \
        "The fourth field is not 'flight_freq'!"
    flt_freq = airline_dict['flt_freq']

    #
    airline_dict_fltd = {fieldnames[0]: iata_code, fieldnames[1]: icao_code,
                         fieldnames[2]: nb_seats, fieldnames[3]: flt_freq}
    return airline_dict_fltd

#
# Normalize the PageRank values, and store them into the global POR dictionary
#
def normalizePR (por_all_dict, por_pk_noiata_dict, prTypeStr, pr_dict,
                 verboseFlag):
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
        idx_por = getCodeFromPK (por_all_dict, por_pk_noiata_dict, idx_por_pk)
        por_all_dict[idx_por][idx_por_pk][prTypeStr] = normalised_page_rank

    return

#
# Print the PageRank values into the given file
#
def dump_page_ranked_por (por_all_dict, por_pk_noiata_dict,
                          prdict_seats, prdict_freq,
                          output_filepath, w_seats, verboseFlag):
    """
    Generate a CSV data file with, for every POR,
    potentially two PageRank values:
     - One based on the monthly average flight frequency
     - When provided, one based on the monthly average number of seats
    """
    
    # Normalize the PageRank values, and store them in the global POR
    # dictionary ('por_all_dict')
    normalizePR (por_all_dict, por_pk_noiata_dict, "pr_freq", prdict_freq,
                 verboseFlag)
    if w_seats:
        normalizePR (por_all_dict, por_pk_noiata_dict, "pr_seats", prdict_seats,
                     verboseFlag)

    def flattenDict(d):
        flattened_dict = {}
        for k1, v1 in d.items():
            for k2, v2 in v1.items():
                if k2 != "notified":
                    flattened_dict[k2] = v2
        return flattened_dict

    flattened_dict = flattenDict(por_all_dict)
    
    # Sort the dictionary by the average number of seats
    por_all_dict_sorted = sortPORDict (w_seats, flattened_dict)

    # Dump the details into the given CSV output file
    fieldnames = ['pk', 'por_code', 'pr_seats', 'pr_freq']
    with open (output_filepath, 'w', newline='') as output_csv:
        #
        fileWriter = csv.DictWriter (output_csv, delimiter='^',
                                     fieldnames = fieldnames,
                                     dialect = 'unix', quoting = csv.QUOTE_NONE)

        # Write the header
        fileWriter.writeheader()

        # Browse the POR having a PageRank value and dump the details
        for (idx_por_type, pr_dict) in por_all_dict_sorted.items():
            if 'pr_freq' in pr_dict:
                # Filter out the fields not to be dumped into the CSV file
                pr_dict_fltd = filterOutPORFields (w_seats, pr_dict, fieldnames)
                fileWriter.writerow (pr_dict_fltd)

    return

#
# Print the flight frequencies into the given file
#
def dump_freq_airline (airline_all_dict, output_filepath, w_seats, verboseFlag):
    """
    Generate a CSV data file with, for every airline, the flight frequency
    """

    # Sort the dictionary by the average number of seats
    airline_all_dict_sorted = sortAirlineDict (w_seats, airline_all_dict)

    # Dump the details into the given CSV output file
    fieldnames = ['iata_code', 'icao_code', 'nb_seats', 'flight_freq']
    with open (output_filepath, 'w', newline='') as output_csv:
        #
        fileWriter = csv.DictWriter (output_csv, delimiter='^',
                                     fieldnames = fieldnames,
                                     dialect = 'unix', quoting = csv.QUOTE_NONE)

        # Write the header
        fileWriter.writeheader()

        # Browse the POR having a PageRank value and dump the details
        for (idx_airline, airline_dict) in airline_all_dict_sorted.items():
            # Filter out part of the records not appearing in schedule
            if not 'flt_freq' in airline_dict: continue

            # Retrieve the flight frequency
            flt_freq = airline_dict['flt_freq']

            # Filter out the remaining of the records not appearing in schedule
            if flt_freq == 0.0: continue
            
            # Filter out the fields not to be dumped into the CSV file
            airline_dict_fltd = filterOutAirlineFields (w_seats, airline_dict,
                                                        fieldnames)
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
    (verboseFlag, w_seats, por_airline_filepath, por_filepath, \
     airline_bestknown_filepath, pr_out_filepath, \
     freq_out_filepath) = handle_opt()

    # Extract the POR details from OpenTravelData
    por_all_dict = dict()
    por_pk_noiata_dict = dict()
    extractPOR (por_all_dict, por_pk_noiata_dict, por_filepath, verboseFlag)

    # DEBUG
    # from pprint import pprint as pp
    # pp (por_all_dict)

    # Extract the airlines from OpenTravelData best known details
    airline_all_dict = dict()
    extractBksfAirline (airline_all_dict, airline_bestknown_filepath,
                        verboseFlag)    

    # DEBUG
    # from pprint import pprint as pp
    # pp (airline_all_dict)

    # Build directional graphs from the file of flight schedule:
    # - One with, as weight, the monthly average number of seats
    # - One with, as weight, the monthly flight frequency
    (dict_seats, dict_freq) = analyzeAirlinePOR (por_all_dict,
                                                 por_pk_noiata_dict,
                                                 airline_all_dict,
                                                 por_airline_filepath, w_seats,
                                                 verboseFlag)

    # DEBUG
    # dump_digraph (dict_seats, "../opentraveldata/optd_airline_por_cumulated.csv", verboseFlag)
    # dump_digraph (dict_freq, pr_out_filepath, verboseFlag)
    
    # Derive the PageRank values by frequencies
    prdict_freq = nx.pagerank (dict_freq)
    
    # Derive the PageRank values by seats, when existing
    prdict_seats = None
    if w_seats:
        prdict_seats = nx.pagerank (dict_seats)

    # DEBUG
    # print (f"{prdict_freq}")
    # if w_seats: print (f"{prdict_seats}")

    # Dump the PageRank values for POR into the output file
    dump_page_ranked_por (por_all_dict, por_pk_noiata_dict,
                          prdict_seats, prdict_freq,
                          pr_out_filepath, w_seats, verboseFlag)

    # Dump the flight frequencies for airlines into the output file
    dump_freq_airline (airline_all_dict, freq_out_filepath, w_seats, verboseFlag)


#
# Main, when launched from a library
#
if __name__ == "__main__":
    main()
