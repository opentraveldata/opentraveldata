#! /usr/bin/python

from math import asin, acos, pi, sqrt, sin, cos
import sys, re

def load_db(filename):
  re_line = re.compile('([A-Z]{3}),([\-\.0-9]+),([\-\.0-9]+)')
  coord = {}
  f = open(filename, 'r')
  for line in f:
    m = re_line.match(line)
    if not m is None: coord[m.group(1)] = {'lon': float(m.group(2)), 'lat': float(m.group(3))}
  f.close()
  return coord

coord = load_db('airport_db.txt')
apt_list = coord.keys()

def great_circle_distance(lat1, lon1, lat2, lon2, degrees=True):
  if degrees: lat1, lon1, lat2, lon2 = lat1/180.0*pi, lon1/180.0*pi, lat2/180.0*pi, lon2/180.0*pi
  return 12756.0*asin(sqrt((sin((lat2-lat1)/2.0))**2.0+cos(lat1)*cos(lat2)*(sin((lon2-lon1)/2.0))**2.0))
  #colat1, colat2 = pi/2.0-lat1, pi/2.0-lat2
  #return 6378.0*acos(cos(colat1)*cos(colat2)*cos(lon1-lon2)+sin(colat1)*sin(colat2))

def great_circle_distance_acos(lat1, lon1, lat2, lon2, degrees=True):
  if degrees: lat1, lon1, lat2, lon2 = lat1/180.0*pi, lon1/180.0*pi, lat2/180.0*pi, lon2/180.0*pi
  return 6378.0*acos(cos(lat1)*cos(lon1)*cos(lat2)*cos(lon2)+cos(lat1)*sin(lon1)*cos(lat2)*sin(lon2)+sin(lat1)*sin(lat2))
  #colat1, colat2 = pi/2.0-lat1, pi/2.0-lat2
  #return 6378.0*acos(cos(colat1)*cos(colat2)*cos(lon1-lon2)+sin(colat1)*sin(colat2))
  
def two_airport_search(coord, apt_list):
  for i in range(100):
    od = raw_input('OD (e.g., NCEBOS) or 0 to quit: ')
    if od == '0': break
    o, d = od[0:3].upper(), od[3:6].upper()
    if not (o in apt_list and d in apt_list):
      if not o in apt_list: print '%s not in db' % o
      if not d in apt_list: print '%s not in db' % d
    else:
      dist = great_circle_distance(coord[o]['lat'], coord[o]['lon'], coord[d]['lat'], coord[d]['lon'])
      print '%.0f km   %.0f mi   %.0f nm' % (dist, dist/1.609, dist/1.852)
    print

def dist_two_airports(apt1, apt2, coord=coord, apt_list=apt_list):
  unknown = []
  if not (apt1 in apt_list and apt2 in apt_list):
    if not apt1 in apt_list: unknown.append(apt1)
    if not apt2 in apt_list: unknown.append(apt2)
    dist = -1
  else:
    dist = great_circle_distance(coord[apt1]['lat'], coord[apt1]['lon'], coord[apt2]['lat'], coord[apt2]['lon'])
  return {'km': dist, 'mi':dist/1.609, 'nm': dist/1.852, 'unknown': unknown}
    
def pods_search(coord, apt_list):
  lat_msp, lon_msp, lat_dfw, lon_dfw = coord['MSP']['lat'], coord['MSP']['lon'], coord['DFW']['lat'], coord['DFW']['lon']
  for i in range(100):
    a = raw_input('airport, or 0 to quit: ')
    if a == '0': break
    d = a[0:3].upper()
    if not d in apt_list:
      print '%s not in db' % d
    else:
      dist_msp = great_circle_distance(lat_msp, lon_msp, coord[d]['lat'], coord[d]['lon'])
      dist_dfw = great_circle_distance(lat_dfw, lon_dfw, coord[d]['lat'], coord[d]['lon'])
      print 'msp: %.0f mi   dfw: %.0f mi' % (dist_msp/1.609, dist_dfw/1.609)
    print

def main():
  
  pods_search(coord, apt_list)

if __name__ == "__main__":
    main()
