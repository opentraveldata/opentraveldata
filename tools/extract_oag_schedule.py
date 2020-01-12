#!/usr/bin/env python3

import sys, os, re, datetime, getopt
import numpy as np

separator = '^'
subseparator = '~'
comment = "#"
mon_dict = {
  'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4, 'MAY': 5, 'JUN': 6,
  'JUL': 7, 'AUG': 8, 'SEP': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12
}
dow_vector = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']

#
#
# WARNING: Line starts at 1 in IATA document. line<n>_fields_IATA matches this,
# and line<n>_fields is converted so that the line starts at 0
#
#
line_2_fields_IATA = {'valid_from': [15,21], 'valid_to': [22,28]}
line_3_fields_IATA = {
  'marketing_carrier': [3,5],
  'flight_number': [6,9],
  'itinerary_number': [10,11],
  'leg_sequence_number': [12,13],
  'service_type': [14,14],
  'first_date': [15,21],
  'last_date': [22,28],
  'dow': [29,35],
  'frequency_rate': [36,36],
  'origin': [37,39],
  'STD': [44,47],
  'origin_offset': [48,52],
  'origin_terminal': [53,54],
  'destination': [55,57],
  'STA': [58,61],
  'destination_offset': [66,70],
  'destination_terminal': [71,72],
  'aircraft_type': [73,75],
  'pax_reservation_booking_designator': [76,95],
  'pax_reservation_booking_modifier': [96,100],
  'meal_service': [101,110],
  'joint_operation': [111,119],
  'departure_min_connecting_time_status': [120,120],
  'arrival_min_connecting_time_status': [121,121],
  'itinerary_number_overflow': [128,128],
  'aircraft_owner': [129,131],
  'cockpit_crew_employer': [132,134],
  'cabin_crew_employer': [135,137],
  'onward_flight_airline': [138,140],
  'onward_flight_number': [141,144],
  'onward_flight_aircraft_rotation_layover': [145,145],
  'onward_flight_operational_suffix': [146,146],
  'flight_transit_layover': [148,148],
  'code_sharing': [149,149],
  'traffic_restriction': [150,160],
  'traffic_restriction_overflow_indicator': [161,161],
  'aircraft_configuration': [173,192],
  'date_variation': [193,194]
}

# first number: position of first character, starting from 1
# second number: position of last character, starting from 1
line_4_fields_IATA = {
  'origin_indicator': [29,29],
  'destination_indicator': [30,30],
  'data_element_identifier': [31,33],
  'data': [40,194]
}

def format_time(t): # (-)HHMM
  return t
	
def format_date(d): # YYMMDD
  return d.strftime('%y%m%d')

def get_date(str_yymmdd): # YYMMDD
  try:
    yy = int(str_yymmdd[0:2])
    mm = int(str_yymmdd[2:4])
    dd = int(str_yymmdd[4:6])
    return datetime.date(2000+yy, mm, dd)
  except (Exception, e):
    print ("str_yyyymmdd:---{}---".format (str_yymmdd))
    return 0

def ddMMMyy_to_date (ddMMMyy, date_variation=0, mon_dict=mon_dict):
  # from SSIM, e.g. 02JUN09
  dd, MMM, yy = int(ddMMMyy[0:2]), ddMMMyy[2:5], int(ddMMMyy[5:7])
  if MMM == 'XXX': return None
  if date_variation == 0:
    return datetime.date (2000+yy, mon_dict[MMM], dd)
  
  return datetime.date (2000+yy, mon_dict[MMM], dd) \
    + datetime.timedelta(days=date_variation)

def determine_date_from_filename(filename):
  """
  Schedule file name can contain dates that are useful for parsing.
  V[YYMMDD] is validity date indicated inside of the file,
            which should preside if indicated
  D[YYMMDD] is publciation date of the file
  """ 
  re_date_v = re.compile ('V(\w{6})')
  re_date_d = re.compile ('D(\w{6})')
  v = re_date_v.search (filename)
  d = re_date_d.search (filename)
  m = ''
  if v is not None:
    m = v
  elif d is not None:
    m = d
  else:
    return None

  try:

    d = m.group(1)
    return datetime.date (2000+int(d[0:2]), int(d[2:4]), int(d[4:6]))

  except (Exception, e):
    return None

import datetime, bz2, gzip, re

class myException(Exception): pass

re_blank=re.compile('\ +')

def is_gz(filename):
  if len(filename)<2: return False
  if filename[-2:] != 'gz': return False
  return True

def is_bz2 (filename):
  if len (filename) < 3:
    return False
  if filename[-3:] != 'bz2':
    return False
  return True

def flex_open (filename, option):
  flag_gz = is_gz (filename)
  flag_bz2 = is_bz2 (filename)
  if flag_gz:
    return gzip.open (filename, option)
  elif flag_bz2:
    return bz2.BZ2File (filename, option)
  else:
    return open (filename, option)

def get_field_names_and_numbers (header_line, separator, comment):
  flag_ok = True
  line = header_line.rstrip('\n')
  if len (line) == 0:
    raise myException ("problem with input ssim file (no line)")
  if line[0] != comment:
    raise myException ("problem with input ssim file (no line on top " \
                       "with field names)")
  field_names = line.lstrip(comment).split(separator)
  field_nbs = {}
  for i in range(len(field_names)):
    field_nbs[field_names[i]] = i
  return field_names, field_nbs

def get_date_range (start, end, step=datetime.timedelta(days=1)):
  myrange = []
  tmp = start
  while tmp < end:
    myrange.append(tmp)
    tmp += step
  return myrange

def log (str_text, f=sys.stdout):
  today_date = datetime.datetime.now()
  f.write ("%s:%s:%s\n".format (sys.argv[0],
                                today_date.strftime ('%Y-%m-%d %H:%H:%S'),
                                str_text))

def import_field_from_line_2 (line, field_name,
                              line_2_fields_IATA = line_2_fields_IATA):
  res = line[line_2_fields_IATA[field_name][0]-1:line_2_fields_IATA[field_name][1]]
  # (position of first character starting from 0) = (position of first character starting from 1 - as in IATA) - 1
  # (position of one-after-last character starting from 0) = (position of last character starting from 1 - as in IATA)
  return res

def import_field_from_line_3 (line, field_name,
                              line_3_fields_IATA = line_3_fields_IATA,
                              remove_blank = False):
  res = line[line_3_fields_IATA[field_name][0]-1:line_3_fields_IATA[field_name][1]]
  # (position of first character starting from 0) = (position of first character starting from 1 - as in IATA) - 1
  # (position of one-after-last character starting from 0) = (position of last character starting from 1 - as in IATA)
  if remove_blank: res = res.strip()
  return res

def import_field_from_line_4 (line, field_name,
                              line_4_fields_IATA = line_4_fields_IATA,
                              remove_blank = False,
                              re_blank = re_blank):
  res = line[line_4_fields_IATA[field_name][0]-1:line_4_fields_IATA[field_name][1]]
  # (position of first character starting from 0) = (position of first character starting from 1 - as in IATA) - 1
  # (position of one-after-last character starting from 0) = (position of last character starting from 1 - as in IATA)
  if remove_blank:
    res = res.strip()
    res = re.sub(re_blank, '', res)
  return res

def instantiate_dates (first_date, last_date, dow):
  # dow[i] is i if service on day i, ' ' otherwise (0=Monday)
  # d.weekday() is 0 for Monday, 6 for Sunday, so it corresponds to dow vector
  date_range = get_date_range (first_date, last_date+datetime.timedelta(days=1))
  return [x for x in date_range if dow[x.weekday()] != ' ']

def best_known_date_variation (date_var_1digit):
  """
  Best known date variation usaged by airline (often not specified
  in the IATA guideline
  """
  if date_var_1digit in ['A', 'J']: 
    return -1
  
  elif date_var_1digit in ['1', '2']: 
    return int (date_var_1digit)
  
  else:
    return 0

def handle_date_variation (date_variation, origin_offset, destination_offset):
  """
  Output: relative_arrival_date_variation is with respect to the departure date.
  These cases are handled directly because they are extremely common (99.5%)
  """
  if date_variation in ['00','  ']:
    return 0, 0

  if date_variation == '01':
    return 0, 1

  if date_variation == '11':
    return 1, 0
  
  # much less common
  departure_date_digit = date_variation[0]
  arrival_date_digit = date_variation[1]
  departure_date_variation = best_known_date_variation (departure_date_digit)
  absolute_arrival_date_variation = best_known_date_variation(arrival_date_digit)
  relative_arrival_date_variation = \
    absolute_arrival_date_variation - departure_date_variation

  # arriving at a date earlier than departure
  if relative_arrival_date_variation == -1:
    if origin_offset == destination_offset:
      relative_arrival_date_variation = 0

  return departure_date_variation, relative_arrival_date_variation
  
def write_header (field_names, f_output, separator = separator,
                  comment = comment):
  fields_str = separator.join (field_names)
  record_str = f'{comment}{separator}{fields_str}\n'
  f_output.write (record_str)

def output_info (info, dates, field_names, f_output, separator):
  for d in dates:
    info['date'] = format_date(d)
    fields_str = separator.join ([info[x] for x in field_names])
    record_str = f'{fields_str}\n'
    f_output.write (record_str)

def parse_ssim7_file_and_output_info (ssim7_file, user_first_date,
                                      user_last_date, field_names,
                                      dei_numbers, f_output,
                                      separator = separator,
                                      subseparator = subseparator):
  # outputs time just for tracking purposes
  #os.system('date && echo %s' % ssim7_file)
  
  # constants
  fields_to_import_first_to_determine_dates = [
    'first_date', 'last_date',
    'origin_offset', 'destination_offset',
    'date_variation'
  ]

  fields_to_import_with_remove_blank = [
    'marketing_carrier', 'flight_number', 'service_type', 'frequency_rate',
    'origin_terminal', 'destination_terminal', 'aircraft_type',
    'pax_reservation_booking_designator', 'pax_reservation_booking_modifier',
    'meal_service', 'joint_operation', 'departure_min_connecting_time_status',
    'arrival_min_connecting_time_status', 'itinerary_number_overflow',
    'aircraft_owner', 'cockpit_crew_employer', 'cabin_crew_employer',
    'onward_flight_airline', 'onward_flight_number',
    'onward_flight_aircraft_rotation_layover',
    'onward_flight_operational_suffix', 'flight_transit_layover',
    'code_sharing', 'traffic_restriction_overflow_indicator',
    'aircraft_configuration'
  ]

  fields_to_import_directly = [
    'itinerary_number', 'leg_sequence_number', 'dow', 'origin', 'STD',
    'destination', 'STA', 'traffic_restriction'
  ]

  fields_to_format_as_time = [
    'STD', 'origin_offset', 'STA', 'destination_offset'
  ]

  fields_to_convert_to_int_before_output = [
    'arrival_date_variation', 'flight_number', 'itinerary_number',
    'leg_sequence_number'
  ]

  fields_from_line_4 = [
    'origin_indicator', 'destination_indicator',
    'data_element_identifier', 'data'
  ]
  
  output_fields_from_line_4 = [
    'line_four_data', 'dei010', 'dei050'
  ]

  # Count the number of lines
  nb_of_rows = 0
  f0 = flex_open (ssim7_file, 'r')
  for line in f0.readlines():
    nb_of_rows += 1
  nb_of_rows_10pc = int (nb_of_rows / 10)
  print ('Number of lines in {}: {} (10%: {})'.format (ssim7_file, nb_of_rows,
                                                       nb_of_rows_10pc))
  
  # read lines from SSIM file
  f = flex_open (ssim7_file, 'r')
  
  # initialize
  info = {}
  dates = []
  skip_leg = False
  idx = 0
  nb_of_empty_rows = 0
  
  # parse lines of SSIM file
  for line in f:
    line = line.decode('ascii').rstrip('\n')

    # Status report
    idx += 1
    if idx % nb_of_rows_10pc == 0:
      cpltd_pc = int (idx / nb_of_rows_10pc) * 10
      print ("{}% - {} / {} - '{}'".format (cpltd_pc, idx, nb_of_rows, line))
    
    if len (line) < 100:
      # Not really a line
      nb_of_empty_rows += 1
      continue
    
    if line[0] == '3':
      #
      # starting new leg, so we need to output the info for the previous leg
      # if it was not to be skipped
      #
      if not skip_leg:
        output_info (info, dates, field_names, f_output, separator)

      #
      # initialize
      #
      info = {}
      dates = []
      skip_leg = False

      #
      # get fields to determine dates, to avoid gathering information
      # that will not be output
      #
      for field_name in fields_to_import_first_to_determine_dates:
        info[field_name] = import_field_from_line_3 (line, field_name)

      #
      # handle date variation
      #
      date_variation = info['date_variation']
      origin_offset = info['origin_offset']
      destination_offset = info['destination_offset']
      departure_date_variation, arrival_date_variation = \
        handle_date_variation (date_variation, origin_offset,
                               destination_offset)
      info['arrival_date_variation'] = arrival_date_variation

      leg_first_date = ddMMMyy_to_date (info['first_date'])
      first_date_to_use = max (leg_first_date, user_and_airline_first_date)

      leg_last_date = ddMMMyy_to_date (info['last_date'])
      if leg_last_date is None:
        last_date_to_use = user_and_airline_last_date
      else:
        last_date_to_use = min (leg_last_date, user_and_airline_last_date)

      if last_date_to_use < first_date_to_use:
        # no need to consider lines until next line 3 (i.e., skip this leg)
        skip_leg = True
        continue

      #
      # get remaining fields
      #
      for field_name in fields_to_import_with_remove_blank:
        info[field_name] = import_field_from_line_3 (line, field_name,
                                                     remove_blank = True)
      for field_name in fields_to_import_directly:
        info[field_name] = import_field_from_line_3 (line, field_name)

      #
      # prepare output info
      #
      # format time
      for field_name in fields_to_format_as_time:
        info[field_name] = format_time (info[field_name])

      # integers
      for field_name in fields_to_convert_to_int_before_output:
        info[field_name] = str (int (info[field_name]))

      # misc
      if info['aircraft_owner'] == '':
        info['aircraft_owner'] = info['marketing_carrier']

      if info['onward_flight_number'] != '':
        info['onward_flight_number'] = str(info['onward_flight_number'])
      
      #
      # instantiate dates
      #
      dates = instantiate_dates(first_date_to_use, last_date_to_use, info['dow'])

      #
      # initialize info from line 4
      #
      for output_field_from_line_4 in output_fields_from_line_4:
        info[output_field_from_line_4] = ''
    
    elif line[0] == '2':

      # dates of validity: taking max of first date of validity
      # and user choice, taking min of last date of validity and user choice
      valid_from = import_field_from_line_2 (line, 'valid_from')
      airline_first_date = ddMMMyy_to_date (valid_from)
      if airline_first_date is None:
        user_and_airline_first_date = user_first_date
        
      else:
        user_and_airline_first_date = max (user_first_date, airline_first_date)
      
      valid_to = import_field_from_line_2 (line, 'valid_to')
      airline_last_date = ddMMMyy_to_date (valid_to)
      if airline_last_date is None:
        user_and_airline_last_date = user_last_date
      else:
        user_and_airline_last_date = min (user_last_date, airline_last_date)
    
    elif skip_leg:
      continue
    
    elif line[0] == '4':
      #
      # prepare output info from line 4
      #
      info_line_four = {}
      for field_name in fields_from_line_4:
        info_line_four [field_name] = import_field_from_line_4 (line,
                                                                field_name,
                                                                remove_blank=True)
      if info_line_four['data_element_identifier'] in dei_numbers:
        info['dei' + info_line_four['data_element_identifier']] = ''.join([info_line_four[x] for x in ['origin_indicator', 'destination_indicator', 'data']])

      else:
        if info['line_four_data'] != '':
          info['line_four_data'] += subseparator
        info['line_four_data'] += ''.join([info_line_four[x] for x in fields_from_line_4])
  
  # output last leg if it was not be skipped
  if not skip_leg:
    output_info (info, dates, field_names, f_output, separator)
  
def parse_several_ssim7_files_and_output_info (ssim7_files, ssim7_file_dates,
                                               field_names, dei_numbers,
                                               f_output,
                                               separator = separator):
  # sort ssim7 files by order of dates
  ind = np.array (ssim7_file_dates).argsort()
  sorted_ssim7_files = np.array (ssim7_files).take(ind)
  sorted_ssim7_file_dates = np.array (ssim7_file_dates).take(ind)
  
  # parse ssim7 files from first to one-before-last
  for i in range (len (ssim7_files)-1):
    ssim7_file = sorted_ssim7_files[i]
    first_date = sorted_ssim7_file_dates[i]
    last_date = sorted_ssim7_file_dates[i+1] - datetime.timedelta(days=1)
    parse_ssim7_file_and_output_info(ssim7_file, first_date, last_date,
                                     field_names, dei_numbers, f_output)
  
  # parse last ssim7 file
  ssim7_file = sorted_ssim7_files[-1]
  first_date = sorted_ssim7_file_dates[-1]
  last_date = first_date + datetime.timedelta(days=365)
  parse_ssim7_file_and_output_info(ssim7_file, first_date, last_date,
                                   field_names, dei_numbers, f_output)
  
  # output time (tracking)
  #os.system('date')

def output_old_data_from_old_catalog (old_catalog, ssim7_first_date,
                                      field_names, f_output,
                                      separator = separator,
                                      comment = comment):
  # open old catalog
  f = flex_open (old_catalog, 'r')
  
  # check that field_names are the same in old catalog and for new catalog
  header_line = f.readline()
  if header_line == '':
    sys.stderr.write ("warning: old catalog is empty\n")
    return
  
  field_names_from_old_catalog, field_nbs = \
    get_field_names_and_numbers (header_line, separator, comment)
  for (field_name, field_name_from_old_catalog) in zip (field_names,
                                                        field_names_from_old_catalog):
    if field_name != field_name_from_old_catalog:
      raise myException ("field names from old catalog are not the same " \
                         "as those for new catalog")
  
  # copy lines from old catalog that are earlier than first date of ssim7
  int_ssim7_first_date = int (format_date(ssim7_first_date))
  for line in f:
    fields = line.rstrip('\n').split(separator)
    int_date_from_old_catalog = int(fields[field_nbs['date']])
    if int_date_from_old_catalog < int_ssim7_first_date:
      f_output.write(line)
  
  # close old catalog
  f.close()

def usage():
  sys.stderr.write('\n') 
  sys.stderr.write('\n') 
  sys.stderr.write("-h, --help                        : outputs help and quits\n")
  sys.stderr.write('\n') 
  sys.stderr.write("Mandatory arguments:\n")
  sys.stderr.write("--ssim7-files=<path1,path2,...>   : comma-separated list of ssim7 files to consider\n")
  sys.stderr.write("                                    (the order matters, since overwriting will take place).\n")
  sys.stderr.write("--output-csv=<path>               : text or gz output file.\n")
  sys.stderr.write('\n') 
  sys.stderr.write("Optional argument:\n")
  sys.stderr.write("--old-catalog=<path>              : text or gz file containing a catalog to be updated\n")
  sys.stderr.write('\n') 
  
def handle_opt():
  try:
    opts, args = getopt.getopt (sys.argv[1:], "h",
                                ["help", "ssim7-files=", "old-catalog=",
                                 "output-csv="])
  except (getopt.GetoptError, err):
    # will print something like "option -a not recognized"
    sys.stderr.write(str(err) + '\n')
    usage()
    sys.exit(2)
  
  # mandatory
  ssim7_files = None
  output_file = None
  
  # optional
  old_catalog = None
  
  # handling
  for o, a in opts:
    if o in ("-h", "--help"):
      usage()
      sys.exit()
    elif o == "--ssim7-files":
      ssim7_files = a.split(',')
    elif o == "--old-catalog":
      old_catalog = a
    elif o == "--output-csv":
      output_file = a
    else:
      assert False, "unhandled option"
  
  if ssim7_files is None or output_file is None:
    usage()
    sys.stderr.write('\n') 
    sys.stderr.write("*** ERROR *** Missing arguments!\n")
    sys.stderr.write('\n')
    sys.exit()
  return ssim7_files, output_file, old_catalog
  
def main():
  ssim7_files, output_file, old_catalog = handle_opt()
  
  # constants
  dei_numbers = ['010', '050']
  field_names = [
    'date', 'origin', 'destination', 'STD', 'origin_offset', 'STA',
    'destination_offset', 'arrival_date_variation', 'aircraft_owner',
    'aircraft_type', 'code_sharing', 'joint_operation', 'traffic_restriction',
    'marketing_carrier', 'flight_number', 'itinerary_number',
    'leg_sequence_number', 'service_type', 'frequency_rate',
    'origin_terminal', 'destination_terminal',
    'pax_reservation_booking_designator',
    'pax_reservation_booking_modifier', 'meal_service',
    'departure_min_connecting_time_status',
    'arrival_min_connecting_time_status',
    'itinerary_number_overflow', 'cockpit_crew_employer',
    'cabin_crew_employer', 'onward_flight_airline',
    'onward_flight_number', 'onward_flight_aircraft_rotation_layover',
    'onward_flight_operational_suffix', 'flight_transit_layover',
    'traffic_restriction_overflow_indicator',
    'aircraft_configuration', 'dei010', 'dei050',
    'line_four_data'
  ]
  
  #
  # CHECKS before doing all the work
  #
  # determine dates for each file
  ssim7_file_dates = []
  for ssim7_file in ssim7_files:
    d = determine_date_from_filename (ssim7_file)
    if d is None:
      raise myException ("date could not be determined from file name " \
                         "{}".format (ssim7_file))
    ssim7_file_dates.append (d)

  # open output file
  #flag_gz_output = is_gz(output_file)
  #txt_output_file = output_file
  #if flag_gz_output: txt_output_file = output_file[:-2]
  try:
    f_output = flex_open (output_file, 'w')
  except (Exception, e):
    raise myException ("output file %s could not be created".format(output_file))
  
  # write header
  write_header (field_names, f_output)
  
  # if old catalog provided, keep only data that is earlier
  # than min(ssim7_file_dates)
  if not old_catalog is None:
    if old_catalog == output_file:
      raise myException ("error: old catalog and output csv file are the same. Exiting...")
    output_old_data_from_old_catalog (old_catalog, min (ssim7_file_dates),
                                      field_names, f_output)
  
  # parse all ssim7 files
  parse_several_ssim7_files_and_output_info (ssim7_files, ssim7_file_dates,
                                             field_names, dei_numbers, f_output)

if __name__ == "__main__":
    main()
    
#3 KL 91492402J30OCT1030OCT10     6  ATL17201720-0400S CDG06550655+01002E767JCIZSBMHQKLTV                               II       DL                  L A           M         C0M                 01931197
#3 KL 12240501J28MAR1030OCT101234567 CDG09400940+02002FAMS11001100+0200  737JCIZDXSBMKHLQTENVW       XX                 II                                        M          C0M                 00856740

