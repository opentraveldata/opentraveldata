#!/usr/bin/env python

import getopt, sys, gzip, re
import numpy as np
import networkx as nx
from scipy.sparse import csc_matrix

# Index increment
k_idx_inc = 100000

#------------------------------------------------------------------------------	
def pageRank(G, s = .85, maxerr = .001):
    """
    Computes the PageRank for each of the n states.

    Used in Web page ranking and text summarization using unweighted
    or weighted transitions respectively.


    Args
    ----------
    G: matrix representing state transitions
       Gij can be a boolean or non negative real number representing the
       transition weight from state i to j.

    Kwargs
    ----------
    s: probability of following a transition. 1-s probability of teleporting
       to another state. Defaults to 0.85

    maxerr: if the sum of pageranks between iterations is bellow this we will
            have converged. Defaults to 0.001
    """
    n = G.shape[0]

    # Transform G into Markov matrix M
    M = csc_matrix (G, dtype=np.float)
    rsums = np.array (M.sum(1))[:,0]
    ri, ci = M.nonzero()
    M.data /= rsums[ri]

    # bool array of sink states
    sink = rsums==0

    # Save the Numpy error settings
    old_settings = np.seterr(all='raise')

    # DEBUG
    print ("Shape: " + str(n))
    # print (M)

    # Compute PageRank r until we converge
    ro, r = np.zeros(n), np.ones(n)
    while np.sum(np.abs(r-ro)) > maxerr:
        # DEBUG
        print ("r: " + str(r))
        print ("ro: "+ str(ro))
        
        #
        ro = r.copy()
        # Calculate each PageRank at a time
        for i in xrange(0,n):
            # inlinks of state i
            Ii = np.array(M[:,i].todense())[:,0]
            # account for sink states
            Si = sink / float(n)
            # account for teleportation to state i
            Ti = np.ones(n) / float(n)

            r[i] = ro.dot( Ii*s + Si*s + Ti*(1-s) )

    # Restore the Numpy error settings
    np.seterr(**old_settings)

    # Return normalized PageRank
    return r/sum(r)


#------------------------------------------------------------------------------	
def usage():
    """
    Display the usage.
    """

    print ()
    print ()
    print ("-h, --help                : outputs help and quits")
    print ("-o <path>                 : path to output file (if blank, stdout)")
    print ("<path>                    : input file (if blank, stdin)")
    print ()
	

#------------------------------------------------------------------------------	
def handle_opt():
    """
    Handle the command-line options
    """

    try:
        opts, args = getopt.getopt(sys.argv[1:], "h:o:", ["help", "output"])

    except getopt.GetoptError as err:
        # will print something like "option -a not recognized"
        print (f"{err}")
        usage()
        sys.exit(2)
	
    # Default options
    input_filename = ''
    output_filename = ''
    input_file = sys.stdin #'/dev/stdin'
    output_file = sys.stdout #'/dev/stdout'

    # Input stream/file
    if len (args) != 0:
        input_filename = args[0]

    # Handling
    for o, a in opts:
        if o in ("-h", "--help"):
            usage()
            sys.exit()
        elif o == "-o":
            output_filename = a
        else:
            assert False, "Unhandled option"

    # Input file. That file may be compressed with GNU Zip (gzip)
    if (input_filename != ''):
        flag_gz = True
        if len (input_filename) < 2:
            flag_gz = False
        elif input_filename[-2:] != 'gz':
            flag_gz = False
        if flag_gz:
            input_file = gzip.open (input_filename, 'rb')
        else:
            input_file = open (input_filename, 'r')

    if (output_filename != ''):
        output_file = open (output_filename, 'w')


    print (f"Input stream/file: '{input_filename}'")
    print (f"Output stream/file: '{output_filename}'")
    return (input_file, output_file)


#------------------------------------------------------------------------------	
def extract_dict (input_file):
    """
    Extract from the given input file:
     - the dictionary of POR (points of reference, e.g., airports, cities)
     - the dictionary of legs
     - the maximum index, which also corresponds to the number of POR

    Sample input:
     * Only airports (7 fields):
       - ALL^BSL^NCE^357^357^296^521 
     * Airports and cities (9 fields):
       - ALL^EAP^C^NCE^CA^494^494^384^110
       - ALL^NCE^CA^EAP^C^494^494^110^384
    """

    # Initialise the dictionaries
    por_dict = dict()
    schedule_dict = dict()

    # Maximum of the indices (i.e., the number of POR)
    idx_max = 1

    # Browse the input file (may be stdin)
    for line in input_file:
        # Split the line along the separator ('^')
        contentList = line.split('^')

        # Check how many fields/columns are present in the input file.
        # The input file with only the airports has got 7 fields/columns,
        # where as the input file with both the airports and cities
        # has got 9 fields/columns.
        # Note: the index of the first field is 0.
        nbOfFields = len (contentList)

        # Extract the origin and destination codes
        por_orig = ''
        por_dest = ''
        if (nbOfFields == 7):
            por_orig = contentList[1]
            por_dest = contentList[2]
        elif (nbOfFields == 9):
            por_orig = contentList[1] + '-' + contentList[2] + \
                '^' + contentList[1]
            por_dest = contentList[3] + '-' + contentList[4] + \
                '^' + contentList[3]
        else:
            err_msg = f"The number of fields ({nbOfFields}) of the following " \
                " line is not compliant (should either be 7 or 9): {line}"
            raise ValueError (err_msg)

        # Extract the indices for the origin and the destination
        idx_orig = 0
        idx_dest = 0
        if nbOfFields == 7:
            idx_orig = int (contentList[5])
            idx_dest = int (contentList[6])
        elif nbOfFields == 9:
            idx_orig = int (contentList[7])
            idx_dest = int (contentList[8])
        else:
            err_msg = f"The number of fields ({nbOfFields}) of the following " \
                " line is not compliant (should either be 7 or 9): {line}"
            raise ValueError (err_msg)


        # Register the indices into the por dictionary
        if not idx_orig in por_dict:
            por_dict[idx_orig] = por_orig
        if not idx_dest in por_dict:
            por_dict[idx_dest] = por_dest

        # Adjust the maximum, if needed
        if idx_orig > idx_max: idx_max = idx_orig
        if idx_dest > idx_max: idx_max = idx_dest

        # Convert the two indices into a single one
        idx = k_idx_inc * idx_orig + idx_dest

        # Extract the frequency
        freq = 0
        if nbOfFields == 7:
            freq = int (contentList[4])
        elif nbOfFields == 9:
            freq = int (contentList[6])
        else:
            err_msg = f"The number of fields ({nbOfFields}) of the following" \
                " line is not compliant (should either be 7 or 9): {line}"
            raise ValueError (err_msg)

        # Store the frequency
        schedule_dict[idx] = freq

        # DEBUG
        # print (f"[DBG][({idx_orig}, {idx_dest}) => {idx}] {por_orig}^{por_dest}^{freq}")

    return (por_dict, schedule_dict, idx_max)


#------------------------------------------------------------------------------	
def convert_to_array (schedule_dict, idx_max):
    """
    Convert the dictionary of POR into a NumPy array
    """

    # Specify the array
    schedule_matrix = np.array([0])
    schedule_matrix.resize (idx_max, idx_max)

    #
    for idx in schedule_dict:
        # Extract the frequency
        freq = schedule_dict[idx]
        idx_orig = idx / k_idx_inc
        idx_dest = idx - idx_orig * k_idx_inc

        schedule_matrix[idx_orig-1, idx_dest-1] = freq

    return schedule_matrix

#------------------------------------------------------------------------------	
def convert_to_digraph (schedule_dict):
    """
    Convert the dictionary of POR into a NetworkX DiGraph (directed graph)
    """

    # Specify the array
    schedule_digraph = nx.DiGraph()

    #
    for idx, freq in schedule_dict.items():
        idx_orig = int (idx / k_idx_inc)
        idx_dest = idx - idx_orig * k_idx_inc

        schedule_digraph.add_edge (idx_orig-1, idx_dest-1, weight=freq)

        # DEBUG
        #print (f"[DiGraph][{idx_orig}, {idx_dest}] {idx_orig-1}, {idx_dest-1}, {freq}")

    return schedule_digraph


#------------------------------------------------------------------------------	
def dump_page_ranked_por (por_dict, paged_ranked_por, output_file):
    """
    Write the vector of ranks into a CSV file, re-adding the corresponding POR
    for every line.
    """

    # Number of POR (points of reference)
    nb_of_por = len(paged_ranked_por)

    # Maximum rank
    rank_max = 1e-10

    # DEBUG
    # print (f"Nb of legs: {nb_of_por}")

    # Derive the highest PageRank (PR) value
    for page_rank in paged_ranked_por.values():
        # Register the minimum rank, if needed
        if page_rank > rank_max: rank_max = page_rank

    #
    for idx_por_m1, page_rank in paged_ranked_por.items():
        # Normalised (Page) Rank
        normalised_page_rank = page_rank / rank_max

        # Retrieve the POR specifications
        # In the DiGraph (paged_ranked_por dictionary), the index begins at 0,
        # whereas it begins at 1 in the pod_dict dictionary
        por_code = por_dict[idx_por_m1 + 1]
        
        # Dump the details into the given CSV output file
        rec_str = f"{por_code}^{normalised_page_rank}\n"
        output_file.write (rec_str)

    return


#------------------------------------------------------------------------------	
def main():
    """
    Main
    """

    # Parse command options
    input_file, output_file = handle_opt()

    # Extract the dictionary of frequencies:
    # one frequency per (origin, destination)
    por_dict, schedule_dict, idx_max = extract_dict (input_file)

    # DEBUG
    # print (f"por_dict: {por_dict}")

    # DEBUG
    # print (schedule_dict)

    # Convert the dictionary into a NumPy array
    # schedule_matrix = convert_to_array (schedule_dict, idx_max)

    # DEBUG
    # print (schedule_matrix)

    # Calculate the PageRanked legs
    # paged_ranked_por = pageRank (schedule_matrix, s=.86)

    # Convert the dictionary into a NetworkX DiGraph (directed graph)
    schedule_digraph = convert_to_digraph (schedule_dict)

    # DEBUG
    # print (schedule_digraph)

    # Calculate the PageRanked legs
    paged_ranked_por = nx.pagerank (G=schedule_digraph, alpha=0.86)

    # DEBUG
    #print (f"PR POR list: {paged_ranked_por}")

    # Dump the page ranked legs into the output file
    dump_page_ranked_por (por_dict, paged_ranked_por, output_file)


#-------------------------------------------------------------------------------
if __name__ == "__main__":
    main()

