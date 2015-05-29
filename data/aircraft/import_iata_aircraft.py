from update_optd_aircraft import *

iata_file = "../IATA/iata_aircraft_type_2012_03.csv"
iata_cols = ['iata_code',
             'iata_group',
             'model',
             'iata_category',
             'icao_code']

# runned only once to build the initial file, may be usefull for updated iata table
def read_iata(filename):
    with open(filename, 'r') as fin:
        data = {}
        # skip header
        fin.next()
        for row in fin:
            items = row.strip().split(sep)
            iata = items[0]
            content = [(col,items[i]) for i, col in enumerate(iata_cols) if (len(items)>i and items[i])]
            data[iata] = dict(content)
    return data


def main():
    # get new ones from urls, currently just one implemented
    iata = read_iata(iata_file)
    # read the existing table
    existing = read_existing(target_file)
    # update list of aircrafts
    update_aircrafts(iata, existing)
    # write back to file
    write(target_file, iata)


if __name__ == '__main__':
    main()
