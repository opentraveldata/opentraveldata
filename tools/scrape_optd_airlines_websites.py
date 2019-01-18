#!/usr/bin/env python3

import requests 
from lxml import html
import csv

new_rows = [["pk", "2char_code", "name", "website" ]]
successes = 0
failures = 0
with open('../opentraveldata/optd_airline_best_known_so_far.csv', newline='') as csvfile:
    rows = csv.reader(csvfile, delimiter='^')
    for row in rows:
        if row[0].startswith('air') and row[5] and row[7]:
            try:
                page = requests.get(row[12])
                print('Connecting to:\n', row[12], '\n...')
                if page.status_code == 200:
                    print('Success\n')
                tree = html.fromstring(page.content)
                header = tree.xpath('//th[text()="Website"]')
                site = header[0].xpath('..//a')
                url = site[0].attrib['href']
                successes += 1
            except:
                url = ""
                print('Attempt failed:', row[7], '\n')
                failures += 1
            new_rows.append([row[0], row[5], row[7], url])

print(successes, 'Successes,', failures, 'failures')                
with open('../opentraveldata/optd_airlines_websites.csv', 'w') as csvfile:
    writer = csv.writer(csvfile, delimiter='^')
    writer.writerows(new_rows)

