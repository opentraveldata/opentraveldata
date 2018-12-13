#!/usr/bin/env python

from bs4 import BeautifulSoup
import requests


target_file = "../../opentraveldata/optd_aircraft.csv"
sep = '^'
header = ['iata_code',
          'manufacturer',
          'model',
          'iata_group',
          'iata_category',
          'icao_code',
          'nb_engines',
          'aircraft_type']


def read_from_flugzeuginfo():
    url = "http://www.flugzeuginfo.net/table_accodes_iata_en.php"
    r = requests.get(url)
    soup = BeautifulSoup(r.text, "html.parser")

    data = []
    tables = soup.find_all('table')

    for table in tables:
        for row in table.find_all('tr'):
            cols = row.find_all('td')
            cols = [ele.text.strip() for ele in cols]
            data.append([ele for ele in cols if ele])

    res = {}
    for d in data:
        if len(d) == 4:
            iata = d[0]
            manufacturer = d[1]
            model = d[2]
            res[iata] = {'iata_code':iata, 'manufacturer':manufacturer, 'model':model}
    return res
    
    
def read_existing(filename):
    with open(filename, 'r') as fin:
        data = {}
        # skip header
        fin.next()
        for row in fin:
            items = row.strip().split(sep)
            iata = items[0]
            content = [(col,items[i]) for i, col in enumerate(header) if (len(items)>i and items[i])]
            data[iata] = dict(content)
    return data


def update_aircrafts (target, update):
   for iata, aircraft in update.iteritems():
    target_a = target.get(iata,{})
    target_a.update(aircraft)
    target[iata] = target_a


def write(filename, data):
    with open(filename, 'w') as fout:
        print >> fout, sep.join(header)
        for iata, aircraft in sorted(data.iteritems()):
            print >> fout, sep.join([aircraft.get(col,'') for col in header])


def main():
    # get new ones from urls, currently just one implemented
    new = read_from_flugzeuginfo()
    # read the existing table
    existing = read_existing(target_file)
    # update list of aircrafts
    update_aircrafts(new, existing)
    # write back to file
    write(target_file, new)
    

if __name__ == '__main__':
    main()
