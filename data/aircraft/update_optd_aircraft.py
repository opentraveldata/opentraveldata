from bs4 import BeautifulSoup
import requests


target_file = "../../opentraveldata/optd_aircraft.csv"
sep = '^'
header = ['iata_code', 'manufacturer', 'model']


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
            res[iata] = (manufacturer, model)
    return res
    
    
def read_existing(filename):
    with open(filename, 'r') as fin:
        data = {}
        # skip header
        fin.next()
        for row in fin:
            items = row.strip().split(sep)
            iata = items[0]
            manufacturer = items[1]
            model = items[2]
            data[iata] = (manufacturer, model)
    return data


def write(filename, data):
    with open(filename, 'w') as fout:
        print >> fout, sep.join(header)
        for iata, (manufacturer, model) in sorted(data.iteritems()):
            print >> fout, sep.join([iata, manufacturer, model])


def main():
    # read the existing table
    existing = read_existing(target_file)
    # get new ones from urls, currently just one implemented
    new = read_from_flugzeuginfo(url)
    # update list of aircrafts
    existing.update(new)
    # write back to file
    write(target_file, existing)
    

if __name__ == '__main__':
    main()
