#!/usr/bin/env python3

import csv

import requests

successes = 0
failures = 0
with open('../opentraveldata/optd_airlines_websites.csv', newline='') as csvfile:
    rows = csv.reader(csvfile, delimiter='^')
    for row in rows:
        iata_code = row[1]
        website = row[3]
        if iata_code and website:
            url = "https://logo.clearbit.com/"+website
            try:
                logo = requests.get(url)
                print('Connecting to:\n', url, '\n...')
                if logo.status_code == 200:
                    print('Success\n')
                    filename = '../opentraveldata/optd_airlines_websites_logos/' + iata_code+'.png'
                    open(filename, 'wb').write(logo.content)
                successes += 1
            except:
                print('Attempt failed:', url, '\n')
                failures += 1


print(successes, 'Successes,', failures, 'failures')
