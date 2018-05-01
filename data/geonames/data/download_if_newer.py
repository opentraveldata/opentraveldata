#!/usr/bin/env python

import urllib.request, shutil, csv, datetime, re, getopt, sys, os, requests

def usage (script_name, usage_doc):
    """Display the usage for that program."""
    print ("")
    print ("Usage: %s [options] -s <Data file URL> -d <Destination file>" % script_name)
    print ("")
    print (usage_doc)
    print ("")
    print ("Options:")
    print ("  -h, --help                   : outputs this help and exits")
    print ("  -v, --verbose                : verbose output (debugging)")
    print ("  -s, --src <Data file URL>    : URL of the (source) data file")
    print ("  -d, --dst <Destination file> : Local path of the file the source will be copied into")
    print ("")

def handle_opt (usage_doc):
    """Handle the command-line options."""
    try:
        opts, args = getopt.getopt (sys.argv[1:], "hvs:d:",
                                    ["help", "verbose", "src", "dst"])
    except (getopt.GetoptError, err):
        # Print help information and exit. It will print something like
        # "option -a not recognized"
        print (str (err))
        usage (sys.argv[0], usage_doc)
        sys.exit(2)

    # Options
    verboseFlag = False
    src_url = ''
    dst_file = ''
    for o, a in opts:
        if o in ("-h", "--help"):
            usage (sys.argv[0], usage_doc)
            sys.exit()
        elif o in ("-v", "--verbose"):
            verboseFlag = True
        elif o in ("-s", "--src"):
            src_url = a
        elif o in ("-d", "--dst"):
            dst_file = a
        else:
            assert False, "Unhandled option"
    return (verboseFlag, src_url, dst_file)

def getModificationTime (file_url, verbose_flag = False):
    """Extract the modification time (as the EPOCH integer)
       of the Web-hosted data file."""
    #
    url_time_epoch = 0
    
    # Extract the HTTP header for the Web-hosted data file
    url_time_str = ''
    try:
        req = requests.head(file_url)
        url_time_str = req.headers['last-modified']

    except:
        print("The data file ('{}') does not seem to be available"
              .format(file_url))
        return url_time_epoch

    # Parse the modification time of the Web-hosted file
    # The date-time is formatted like 'Tue, 01 May 2018 00:27:57 GMT'
    url_time_epoch = datetime.datetime.strptime(url_time_str,
                                                "%a, %d %b %Y %X %Z").timestamp()

    #
    return url_time_epoch

def downloadFile (file_url, output_file, verbose_flag = False):
    """Download a file from the Web."""
    if verbose_flag:
        print ("Downloading '" + output_file + "' from " + file_url + "...")

    with urllib.request.urlopen (file_url) as response, \
         open (output_file, 'wb') as out_file:
        shutil.copyfileobj (response, out_file)

        # Overwrite the modification time, with the Web-hosted data file's one
        url_time_epoch = getModificationTime (file_url, verbose_flag)
        os.utime (output_file, (url_time_epoch, url_time_epoch))

    # Get the (potentially new) modification time
    file_time_epoch = os.path.getmtime (output_file)
    file_time = datetime.datetime.fromtimestamp(file_time_epoch)

    if verbose_flag:
        print ("... done; (potentially) new modification time of the target file ('{}'): {}"
                   .format(output_file, file_time))

    return

def downloadFileIfNeeded (file_url, output_file, verbose_flag = False):
    """Download a file from the Web, only if newer on that latter."""

    # Get the modification time-stamp of the Web-hosted data file
    url_time_epoch = getModificationTime (file_url, verbose_flag)
    url_time = datetime.datetime.fromtimestamp(url_time_epoch)
    if verbose_flag:
        print ("Time-stamp of the Web-hosted data file ('{}'): {}"
               .format(file_url, url_time))

    try:
    
        # Get the modification time of the target file
        file_time_epoch = 0
        if os.stat (output_file).st_size > 0:
            file_time_epoch = os.path.getmtime (output_file)
            file_time = datetime.datetime.fromtimestamp(file_time_epoch)
            if verbose_flag:
                print ("Time-stamp of the target file ('{}'): {}"
                       .format(output_file, file_time))

        if url_time_epoch > file_time_epoch:
            # Download the file
            downloadFile (file_url, output_file, verbose_flag)

    except OSError:
        downloadFile (file_url, output_file, verbose_flag)

    return

def main(url, dstFile):
    req = requests.head(url)
    url_time_str = req.headers['last-modified']

    # Parse the modification time of the Web-hosted file
    # The date-time is formatted like 'Tue, 01 May 2018 00:27:57 GMT'
    url_time_epoch = datetime.datetime.strptime(url_time_str,
                                                "%a, %d %b %Y %X %Z").timestamp()
    url_time = datetime.datetime.fromtimestamp(url_time_epoch)

    # Get the modification time of the target file
    file_time_epoch = os.path.getmtime(dstFile)
    file_time = datetime.datetime.fromtimestamp(file_time_epoch)
    print ('URL time: {}; URL time epoch: {}; file time epoch: {}'
           .format(url_time, url_time_epoch, file_time_epoch))

    if url_time_epoch <= file_time_epoch:
        # The Web-hosted data file has not been updated
        # since it was locally downloaded
        os.utime (dstFile, (url_time_epoch, url_time_epoch))
        print ('Web-hosted data file modification time ({}) is not newer than local target file ({}), skipping download'.format(url_time, dstFile))
        return
    else:
        do_download(url)
        os.utime (dstFile, (url_time_epoch, url_time_epoch))

    return

# Main
if __name__ == '__main__':
    #
  usageStr = "That script downloads Geonames data files when needed"
  (verboseFlag, srcUrl, dstFile) = handle_opt(usageStr)

  # If the files are not present, or are too old, download them
  downloadFileIfNeeded (srcUrl, dstFile, verboseFlag)

  # Tell the caller that the program was successful
  sys.exit(0)
