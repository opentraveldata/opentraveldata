#!/usr/bin/env python

import getopt, sys, re, csv
import networkx as nx
from operator import add
from collections import OrderedDict, Mapping
from itertools import chain

#
# Default file-paths for input and output data files
#
def_por_airline_filepath = '../opentraveldata/optd_airline_por_rcld.csv'
def_por_filepath = '../opentraveldata/optd_por_public.csv'
def_airline_bestknown_filepath = '../opentraveldata/optd_airline_best_known_so_far.csv'
def_pr_out_filepath = '../opentraveldata/ref_airport_pageranked.csv'
def_freq_out_filepath = '../opentraveldata/ref_airline_nb_of_flights.csv'

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
    print ("  -s, --airline-por <airline POR file-path> :")
    print ("\tInput data file of airline flights")
    print ("\tDefault: '" + def_por_airline_filepath + "'")
    print ("  -b, --por <OPTD POR file-path> :")
    print ("\tInput data file of POR details")
    print ("\tDefault: '" + def_por_filepath + "'")
    print ("  -a, --best-known-airline <OPTD best known airlines file-path> :")
    print ("\tInput data file of best known airline details")
    print ("\tDefault: '" + def_airline_bestknown_filepath + "'")
    print ("  -p, --pr-out <PageRank file-path> :")
    print ("\tOutput data file of PageRank values")
    print ("\tDefault: '" + def_pr_out_filepath + "'")
    print ("  -f, --freq-out <Flight frequency file-path> :")
    print ("\tOutput data file of flight frequency values")
    print ("\tDefault: '" + def_freq_out_filepath + "'")
    print ("")  

#
# Command-line arguments
#
def handle_opt():
    """
    Handle the command-line options
    """

    try:
        opts, args = getopt.getopt (sys.argv[1:], "hv:s:b:a:p:f:",
                                    ["help", "verbose", "airline-por", 
                                     "por", "best-known-airline",
                                     "pr-out", "freq-out"])

    except (getopt.GetoptError, err):
        # Print help information and exit. It will print something like
        # "option -d not recognized"
        print (str (err))
        usage (sys.argv[0], usage_doc)
        sys.exit(2)
    
    # Options
    verboseFlag = False
    por_airline_filepath = def_por_airline_filepath
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
        elif o in ("-s", "--airline-por"):
            por_airline_filepath = a
        elif o in ("-b", "--por"):
            por_filepath = a
        elif o in ("-a", "--best-known-airline"):
            airline_bestknown_filepath = a
        elif o in ("-p", "--pr-out"):
            pr_out_filepath = a
        elif o in ("-f", "--freq-out"):
            freq_out_filepath = a
        else:
            assert False, "Unhandled option"

    # Report the configuration
    print ("Input data file of airline flights: '" + por_airline_filepath + "'")
    print ("Input data file of POR details: '" + por_filepath + "'")
    print ("Input data file of best known airline details: '" + airline_bestknown_filepath + "'")
    print ("Output data file of PageRank values: '" + pr_out_filepath + "'")
    print ("Output data file of flight frequency values: '" + freq_out_filepath + "'")
    return (verboseFlag, por_airline_filepath, por_filepath, airline_bestknown_filepath, pr_out_filepath, freq_out_filepath)

#
# Flatten any dictionary
# See also: http://stackoverflow.com/questions/6027558/flatten-nested-python-dictionaries-compressing-keys
#
def flattenDict (d, join = add, lift = lambda x: x):
    results = []
    def visit (subdict, results, partialKey):
        for k,v in subdict.items():
            newKey = lift(k) if partialKey==_FLAG_FIRST else join(partialKey, lift(k))
            if isinstance (v,Mapping):
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
    if (por_type == 'C'): isTravel = False

    # The POR is at least city-related, it can be as well travel-related
    if ('C' in por_type or 'O' in por_type): isCity = True

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
    # The POR is only city-related, it is not travel-related
    if (por_type == 'C'):
        isTravel = False
    else:
        isTravel = True
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

    # The POR is only city-related, it is not travel-related
    if (por_type == 'C'):
        isCityOnly = True
    else:
        isCityOnly = False
    return isCityOnly

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
# Extract the IATA POR code (eg, 'EWR')
# from the primary key (eg, 'EWR-A-5101809')
#
def getIataCodeFromPK (por_pk):
    # Regular expression for the primary key (pk): (IATA code, type, Geonames ID)
    pk_regexp = re.compile ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,20})$")
    pk_match = pk_regexp.match (por_pk)
    por_code = pk_match.group (1)
    return por_code

#
# Retrieve the POR code (eg, 'EWR', 'WRLM') thanks to the primary key
# (eg, respecively 'EWR-A-5101809', 'ZZZ-A-8531915').
# When the IATA code is 'ZZZ', the POR code is the ICAO code,
# and has to be retrieved from the por_all_dict dictionary.
#
def getCodeFromPK (por_all_dict, por_pk_4_zzz_dict, por_pk):
    # First, retrieve the IATA code, first element of the primary key
    por_code = getIataCodeFromPK (por_pk)

    # When the POR has no IATA code, retrieve ICAO code instead
    if (por_code == "ZZZ"):
        try:
            por_code = por_pk_4_zzz_dict[por_pk]
        except:
            print ("No entry can be found in the POR dictionary for '" + str(por_pk) + "'; key_list: " + str(key_list))
            raise KeyError

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

        try:
            por_cty_full_dict = por_all_dict[cty_code]
        except KeyError:
            print ("[Error] Code: " + por_code + "; PK: " + por_pk + "; cty_code_list: " + str(cty_code_list) + "; idx/cty_code: " + cty_code)
            print ("[Error] Usually, it comes from the fact that the Geonames ID in optd_por_best_known_so_far.csv is not the right one (see optd_por_public.csv for the right Geonames ID)")
            raise KeyError

        for por_cty_pk in por_cty_full_dict:
            # Filter out the already known primary keys
            if por_pk == por_cty_pk or por_cty_pk == 'notified': continue

            # Keep the POR, which are cities only (ie, 'C')
            isCityOnly = isCityOnlyFromPK (por_cty_pk)
            if (isCityOnly == True):
                por_cty_pk_list.append (por_cty_pk)
    return por_cty_pk_list

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
# Extract the details of POR from the OpenTravelData CSV file
#
# iata_code^icao_code^geoname_id^envelope_id^city_code_list^location_type
#
def extractPOR (por_all_dict, por_pk_4_zzz_dict, por_filepath, verboseFlag):
    """
    Derive a dictionary of all the POR referenced within the OpenTravelData
    project as public POR (Points Of Reference)
    """
    # Browse the input file.
    # Regular expression for the primary key (pk): (IATA code, type, Geonames ID)
    pk_re = re.compile ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,20})$")
    with open (por_filepath, newline='') as csvfile:
        file_reader = csv.DictReader (csvfile, delimiter='^')
        for line in file_reader:

            # Filter out the no longer valid POR
            por_env_id = line['envelope_id']
            if (por_env_id != ""): continue

            # Retrieve the POR details
            por_iata_code = line['iata_code']
            por_icao_code = line['icao_code']
            por_type = line['location_type']
            por_geo_id = line['geoname_id']

            # Derive a unique code.
            # If there is no IATA code, then pick the ICAO code, and register
            # that mapping; for instance, 'ZZZ-A-8531884' maps to 'WRLE'.
            por_code = por_iata_code
            if (por_code == "ZZZ"):
                por_code = por_icao_code
                por_pk = buildPK (por_iata_code, por_type, por_geo_id)
                por_pk_4_zzz_dict[por_pk] = por_code
      
            # Extract the list of city codes
            por_city_code_list_str = line['city_code_list']
            por_city_code_list = por_city_code_list_str.split (',')

            # Store the POR
            storePOR (por_all_dict, por_code, por_iata_code, por_type, por_geo_id, por_city_code_list)

    return (por_all_dict)

#
# Store the flight leg edges into both directional graphs
#
def storeEdge (por_org_pk, por_dst_pk, nb_seats, nb_freq, dg_seats, dg_freq):
    # Store/add the weights for the corresponding flight legs
    isEdgeExisting = dg_seats.has_edge (por_org_pk, por_dst_pk)
    if (isEdgeExisting == False):
        dg_seats.add_edge (por_org_pk, por_dst_pk, weight = float(nb_seats))
        dg_freq.add_edge (por_org_pk, por_dst_pk, weight = float(nb_freq))
    else:
        dg_seats[por_org_pk][por_dst_pk]['weight'] += float(nb_seats)
        dg_freq[por_org_pk][por_dst_pk]['weight'] += float(nb_freq)
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
def analyzeAirlinePOR (por_all_dict, por_pk_4_zzz_dict,
                       airline_all_dict, airline_por_filepath, verboseFlag):
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
            errorMsg = "Warning: POR in flight schedule, but not in OpenTravelData list of POR: "
            if not (apt_org in por_all_dict):
                por_all_dict[apt_org] = dict()
                por_all_dict[apt_org]['notified'] = True
                sys.stderr.write (errorMsg + apt_org + "\n")
                continue
            if not (apt_dst in por_all_dict):
                por_all_dict[apt_dst] = dict()
                por_all_dict[apt_dst]['notified'] = True
                sys.stderr.write (errorMsg + apt_dst + "\n")
                continue

            # The POR cannot be found in OpenTravelData, but the error has
            # already been reported
            if por_all_dict[apt_org]['notified'] == True or por_all_dict[apt_dst]['notified'] == True:
                continue
            
            # Extract the average number of seats
            nb_seats = int(round(float((line['seats_mtly_avg']))))

            # Extract the average frequency
            nb_freq = int(round(float(line['freq_mtly_avg'])))


            ##
            # Airlines
            ##
            if airline_code in airline_all_dict:
                airline_dict = airline_all_dict[airline_code]
                hasBeenNotified = airline_all_dict[airline_code]['notified']
                if hasBeenNotified == False:
                    airline_all_dict[airline_code]['flt_freq'] += nb_freq
                    airline_all_dict[airline_code]['nb_seats'] += nb_seats
            else:
                airline_all_dict[airline_code] = dict()
                airline_all_dict[airline_code]['notified'] = True
                errorMsg = "Warning: airline in flight schedule, but not in OpenTravelData list of best known airlines: "
                sys.stderr.write (errorMsg + airline_code + "\n")

            
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

            # Extract the corresponding IATA codes. Most of the time,
            # the POR code is the IATA code. When the IATA is "ZZZ",
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
                    storeEdge (apt_org_pk, apt_dst_pk, nb_seats, nb_freq,
                               dg_seats, dg_freq)

    return (dg_seats, dg_freq)

#
# Sort the dictionary according to the values (weights, here)
# Does not work for now
def sortPORDict (unsorted_dict):

    def sort_function(t):
        try: 
            k, v = t
            return v['pr_seats']
        except KeyError:
            return 0
    
    sorted_dict = OrderedDict (sorted (unsorted_dict.items(),
                                       key=sort_function, reverse=True))
    return sorted_dict

#
# Sort the dictionary according to the values (flt_freq, here)
# Does not work for now
def sortAirlineDict (unsorted_dict):
    
    def sort_function(t):
        try: 
            k, v = t
            return v['nb_seats']
        except KeyError:
            return 0
    
    sorted_dict = OrderedDict (sorted (unsorted_dict.items(), key = sort_function, reverse=True))

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
def filterOutPORFields (pr_dict, fieldnames):
    # Retrieve the IATA code
    assert (fieldnames[1] == 'por_code'), "The second field is not 'por_code'!"
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
# Filter in only the fields to be dumped into the CSV file
# ['iata_code', 'icao_code', 'nb_seats', 'flight_freq']
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
# Normalize the PageRank values, and store them into the global POR dictionary
#
def normalizePR (por_all_dict, por_pk_4_zzz_dict, prTypeStr, pr_dict,
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
        idx_por = getCodeFromPK (por_all_dict, por_pk_4_zzz_dict, idx_por_pk)
        por_all_dict[idx_por][idx_por_pk][prTypeStr] = normalised_page_rank

    return

#
# Print the PageRank values into the given file
#
def dump_page_ranked_por (por_all_dict, por_pk_4_zzz_dict,
                          prdict_seats, prdict_freq,
                          output_filepath, verboseFlag):
    """
    Generate a CSV data file with, for every POR, two PageRank values:
     - One based on the monthly average number of seats
     - The other one based on the monthly average flight frequency
    """
    
    # Normalize the PageRank values, and store them in the global POR
    # dictionary ('por_all_dict')
    normalizePR (por_all_dict, por_pk_4_zzz_dict, "pr_seats", prdict_seats,
                 verboseFlag)
    normalizePR (por_all_dict, por_pk_4_zzz_dict, "pr_freq", prdict_freq,
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
    por_all_dict_sorted = sortPORDict (flattened_dict)

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
            if 'pr_seats' in pr_dict:
                # Filter out the fields not to be dumped into the CSV file
                pr_dict_fltd = filterOutPORFields (pr_dict, fieldnames)
                fileWriter.writerow (pr_dict_fltd)

    return

#
# Print the flight frequencies into the given file
#
def dump_freq_airline (airline_all_dict, output_filepath, verboseFlag):
    """
    Generate a CSV data file with, for every airline, the flight frequency
    """

    # Sort the dictionary by the average number of seats
    airline_all_dict_sorted = sortAirlineDict (airline_all_dict)

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
    (verboseFlag, por_airline_filepath, por_filepath, airline_bestknown_filepath, pr_out_filepath, freq_out_filepath) = handle_opt()

    # Extract the POR details from OpenTravelData
    por_all_dict = dict()
    por_pk_4_zzz_dict = dict()
    extractPOR (por_all_dict, por_pk_4_zzz_dict, por_filepath, verboseFlag)

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
    (dict_seats, dict_freq) = analyzeAirlinePOR (por_all_dict, por_pk_4_zzz_dict,
                                                 airline_all_dict,
                                                 por_airline_filepath,
                                                 verboseFlag)

    # DEBUG
    # dump_digraph (dict_seats, "../opentraveldata/optd_airline_por_cumulated.csv", verboseFlag)
    # dump_digraph (dict_freq, pr_out_filepath, verboseFlag)
    
    # Derive the PageRank values
    prdict_seats = nx.pagerank (dict_seats)
    prdict_freq = nx.pagerank (dict_freq)

    # DEBUG
    # print (str(prdict_seats))
    # print (str(prdict_freq))

    # Dump the PageRank values for POR into the output file
    dump_page_ranked_por (por_all_dict, por_pk_4_zzz_dict,
                          prdict_seats, prdict_freq,
                          pr_out_filepath, verboseFlag)

    # Dump the flight frequencies for airlines into the output file
    dump_freq_airline (airline_all_dict, freq_out_filepath, verboseFlag)


#
# Main, when launched from a library
#
if __name__ == "__main__":
    main()
