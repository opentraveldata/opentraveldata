import re
import urllib2

unlink = re.compile(r'\[\[(?:[^|\]]*\|)?([^\]]+)\]\]')
url = 'http://en.wikipedia.org/w/api.php?format=txt&action=query&titles=IATA_aircraft_type_designator&prop=revisions&rvprop=content'
f = open('../ORI/ori_aircraft.csv', 'w')
print('Fetching aircraft information from wikipedia..')
i=0
f.write("iata_code^manufacturer^model\n")
for line in urllib2.urlopen(url):
  if line.startswith("| "):
    fields = line[1:].split("||");
    if len(fields) == 4:
      f.write(fields[0].strip() + "^" + unlink.sub(r'\1',fields[1].strip()) + "^" + unlink.sub(r'\1',fields[2].strip()) + "\n")
      i+=1
print('Wrote ' + str(i) + ' lines to ' + f.name)
f.close()

