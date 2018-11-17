# Overview
The [original of that documentation file](http://github.com/opentraveldata/opentraveldata/blob/master/tools/README.md)
is maintained on the [OpenTravelData project](http://github.com/opentraveldata/opentraveldata),
within the [``tools`` directory](http://github.com/opentraveldata/opentraveldata/blob/master/tools).

# POR (points of reference)

## Data sources
The two main sources for the geographical points of reference (POR) are:
* The [OpenTravelData (OPTD) project itself](http://github.com/opentraveldata/opentraveldata),
  with its manually curated
  [list of POR (namely ``opentraveldata/optd_por_best_known_so_far.csv``)](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_best_known_so_far.csv).
* The [Geonames project](http://geonames.org), from which a POR data file is
  derived, namely ``tools/dump_from_geonames.csv``.
  See the [section below dedicated to getting data from Geonames](#update-from-geonames)
  for more details.

Various other smaller data sources are used, and maintained by OPTD, such as
details for time-zones, administrative levels of countries, countries,
continents, currencies and codes from organisms such as UN/LOCODE or US WAC.
Those data sources are detailed in
[dedicated section below](#input-files-for-the-main-optd-maintained-por-data-file-processor).

## IATA referencing
All the [POR referenced by IATA](http://github.com/opentraveldata/opentraveldata/blob/master/data/IATA/archives)
are also maintained by OPTD. That is, there should not be any POR referenced
by IATA which is not also curated by OPTD. If that is not the case, that is,
if a IATA-referenced POR is missing from OPTD, then please
[open a bug](http://github.com/opentraveldata/opentraveldata/issues/new).

Very regularly, updates from IATA are reported back into OPTD (those changes
are usually captured through screen snapshots on various Web sites),
so that OPTD reflects at least the up-to-date state of IATA. On top of this,
OPTD brings many quality improvements, in particular with respect to travel
and city code assignments.

## OPTD-generated POR data file
The main deliverable of the
[OpenTravelData project](http://github.com/opentraveldata/opentraveldata)
is the POR "public" file, namely
[``opentraveldata/optd_por_public.csv``](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_public.csv).
The "public" qualifier hints that anyone is able to add, on top of that
POR reference file, his/her own private information.

## OPTD-maintained POR file

### Rationale
The main curated POR file of the
[OpenTravelData project](http://github.com/opentraveldata/opentraveldata)
is the list of "best known details", namely
[``opentraveldata/optd_por_best_known_so_far.csv``](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_best_known_so_far.csv).
It originated (around 2010) from a colection of screen scraped content from
various Web sites.
The OPTD people began to spend significant amount of time curating the list
of POR on various free platforms such as [Geonames](http://geonames.org) and
[Wikipedia](http://wikipedia.org), and that initial knowledge was then fixed
in that ``opentraveldata/optd_por_best_known_so_far.csv``, which has been
continuously curated since then.

### Relationship between a city and its serving POR
For most of the IATA referenced POR, the same IATA code is used to reference
both the travel-/transport-related record as well as the city one.
For instance, San Francisco, California (CA), United States (US):
```csv
SFO-A-5391989^SFO^37.618972^-122.374889^SFO^
SFO-C-5391959^SFO^37.77493^-122.41942^SFO^
```

Some big travel-/transport-related POR, such as the airports of Chicago,
London, Paris or Moscow, have their own IATA code, distinct from the one
of the city they serve. Following is the example for Chicago, Illinois (IL),
United States (US), and its transport-serving POR:
```csv
CHI-C-4887398^CHI^41.85003^-87.65005^CHI^
DPA-A-4890214^DPA^41.90642^-88.24841^CHI^
MDW-A-4887472^MDW^41.785972^-87.752417^CHI^
ORD-A-4887479^ORD^41.978603^-87.904842^CHI^ 
RFD-A-4894553^RFD^42.20164^-89.09567^CHI,RFD^
RFD-C-4907959^RFD^42.27113^-89.094^RFD^2016-01-01
ZUN-R-4914391^ZUN^41.87864^-87.64033^CHI^
```

Moreover, there is usually no more than one POR entry for a given pair of
IATA code and location type. In some rare cases though, a travel-related POR
serves several cities. For instance,
[``RDU-A-4487056``](http://geonames.org/4487056) serves both
[``RDU-C-4464368``](http://geonames.org/4464368) (Raleigh, NC, US) and
[``RDU-C-4487042``](http://geonames.org/4487042) (Durham, NC, US)
in North Carolina (NC), United States (US).
In that case, there are two entries for ``RDU-C``. The corresponding entries
in the [``optd_por_best_known_so_far.csv`` file](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_best_known_so_far.csv)
are:
```csv
RDU-A-4487056^RDU^35.87946^-78.7871^RDU^
RDU-C-4464368^RDU^35.99403^-78.89862^RDU^
RDU-C-4487042^RDU^35.7721^-78.63861^RDU^
```

As of July 2018, there are over 20,000 POR referenced by a IATA code.
Again, the same IATA code is usually referenced by at least a city
and a travel-related POR. So, overall, there are many less distinct
IATA codes. At of July 2018, OPTD is aware of exactly 11,270 distinct
IATA codes. To get that number, one can run for instance the following
command (and subtract 1 to the result, for the header):
```bash
$ cut -d'^' -f1,1 ../opentraveldata/optd_por_best_known_so_far.csv | cut -d'-' -f1,1 | uniq | wc -l
```

### Non-IATA-referenced POR
On the other hand, there are in OPTD many POR not referenced by IATA.
Those POR are extracted from Geonames and end up into OPTD if they have
an ICAO or UN/LOCODE code.

Examples of non-IATA-referenced POR, which end up in OPTD:
* [Yei Airport, South Sudan (SS)](http://geonames.org/8131475),
  referenced by ICAO as ``HSYE``
* [Coco Island Airport, Myanmar (MM)](http://geonames.org/11258616),
  referenced by ICAO as ``VYCI``
* [Migori Airport, Kenya (KE)](http://geonames.org/11395447),
  referenced by ICAO as ``HKMM``

As of July 2018, there are over 90,000 POR having at least an ICAO or
UN/LOCODE code, and which are not referenced by IATA. So, adding them all
to the ``optd_por_best_known_so_far.csv`` file is not so practical.
And it is not very usefull too; especially now that Geonames has become
the master (provider of so called gold records) for all the new POR.
Hence, all the non-IATA-referenced ICAO- or UN/LOCODE-referenced POR
can be added to the ``optd_por_public.csv`` file, without them to be curated
one by one in the ``optd_por_best_known_so_far.csv`` file first.
In any case, those POR are present in the ``dump_from_geonames.csv`` file.
Command to see the different Geonames feature codes for those
non-IATA-referenced POR:
```bash
$ grep '^\^' dump_from_geonames.csv | cut -d'^' -f14,14 | sort | uniq -c | sort -nr | less
```

## Geonames-derived POR file
The [Geonames project](http://geonames.org) dumps every morning the content
of their production database. The corresponding snapshot data files can be
downloaded from their [export site](http://download.geonames.org/export/dump/).

OPTD maintains a few scripts to download those Geonames dump data files,
and to generate in several steps the so-called Geonames data source,
namely ``dump_from_geonames.csv``.

### Download of the Geonames snapshot data files
The [``data/geonames/data/getDataFromGeonamesWebsite.sh`` Shell script](http://github.com/opentraveldata/opentraveldata/blob/master/data/geonames/data/getDataFromGeonamesWebsite.sh)
downloads all the Geonames dump/snapshot data files,
including among other things:
* [``allCountries.zip`` (around 350 MB)](http://download.geonames.org/export/dump/allCountries.zip),
  becoming ``allCountries.txt`` once unzipped, and listing the main details of
  every single POR known from Geonames (over 12 millions of POR).
* [``alternateNames.zip`` (around 140 MB)](http://download.geonames.org/export/dump/alternateNames.zip),
  becoming ``alternateNames.txt`` once unzipped, and listing the alternate
  names of those POR. Note that the codes (e.g., IATA, ICAO, FAA, TCID,
  UN/LOCODE, Wikipedia and Wikidata) links are alternate names
  in Geonames parlance.

### Generation of the aggregated Geonames snapshot data file
The [``data/geonames/data/por/admin/aggregateGeonamesPor.awk`` AWK script](http://github.com/opentraveldata/opentraveldata/blob/master/data/geonames/data/por/admin/aggregateGeonamesPor.awk),
from the two above-mentioned Geonames snapshot/dump data files,
generates a combined data file, named ``allCountries_w_alt.txt``, in the
[``data/geonames/data/por/data`` directory](http://github.com/opentraveldata/opentraveldata/blob/master/data/geonames/data/por/data),
next to the downloaded Geonames data files.

### Generation of the main OPTD-used Geonames data file
The [``tools/extract_por_with_iata_icao.awk`` AWK script](http://github.com/opentraveldata/opentraveldata/blob/master/tools/extract_por_with_iata_icao.awk),
from the above-mentioned combined Geonames data file, generates the main
Geonames POR data file then used by OPTD, namely ``dump_from_geonames.csv``,
in the
[``tools`` directory](http://github.com/opentraveldata/opentraveldata/blob/master/tools).

### Examples of records in the main OPTD-used Geoanmes data file
Examples of records in the ``dump_from_geonames.csv`` data file, echoing
the examples shown in the
[OPTD-maintained POR file section above](#optd-maintained-por-file).

#### Regular relationship between a city and its transport-related POR
Following the [city of San Francisco](http://geonames.org/5391959) and its
[main airport](http://geonames.org/5391989):
```csv
SFO^^^5391959^San Francisco^San Francisco^37.77493^-122.41942^US^^United States^North America^P^PPLA2^CA^California^California^075^City and County of San Francisco^City and County of San Francisco^^^864816^16^28^America/Los_Angeles^-8.0^-7.0^-8.0^2017-06-15^San Francisco^http://en.wikipedia.org/wiki/San_Francisco^en|San Francisco|p|ru|Сан-Франциско||abbr|SF|^USSFO|
SFO^KSFO^SFO^5391989^San Francisco International Airport^San Francisco International Airport^37.61882^-122.3758^US^^United States^North America^S^AIRP^CA^California^California^081^San Mateo County^San Mateo County^^^0^5^-2^America/Los_Angeles^-8.0^-7.0^-8.0^2014-07-29^San Francisco International Airport^http://en.wikipedia.org/wiki/San_Francisco_International_Airport^en|San Francisco International Airport|^USSFO|
```

#### A transport-related POR serving several cities
Following the [Raleigh-Durham International Airport](http://geonames.org/4487056)
serving the cities of [Durham](http://geonames.org/4464368) and
[Raleigh](http://geonames.org/4487042) in North Carolina (NC) in
the United States (US):
```csv
RDU^^^4464368^Durham^Durham^35.99403^-78.89862^US^^United States^North America^P^PPLA2^NC^North Carolina^North Carolina^063^Durham County^Durham County^90932^^257636^123^121^America/New_York^-5.0^-4.0^-5.0^2017-05-23^Durham,RDU^http://en.wikipedia.org/wiki/Durham%2C_North_Carolina^de|Durham||en|Durham|p^USDUR|
RDU^^^4487042^Raleigh^Raleigh^35.7721^-78.63861^US^^United States^North America^P^PPLA^NC^North Carolina^North Carolina^183^Wake County^Wake County^92612^^451066^96^99^America/New_York^-5.0^-4.0^-5.0^2017-05-23^RDU,Raleigh^http://en.wikipedia.org/wiki/Raleigh%2C_North_Carolina^en|Raleigh|p^USRAG|
RDU^KRDU^^4487056^Raleigh-Durham International Airport^Raleigh-Durham International Airport^35.87946^-78.7871^US^^United States^North America^S^AIRP^NC^North Carolina^North Carolina^183^Wake County^Wake County^90576^^0^126^124^America/New_York^-5.0^-4.0^-5.0^2017-05-23^KRDU,RDU,Raleigh-Durham International Airport^http://en.wikipedia.org/wiki/Raleigh%E2%80%93Durham_International_Airport^en|Raleigh–Durham International Airport|p^USRDU|
```

#### Non-IATA-referenced OPTD-known POR
The following transport-related POR are not referenced by IATA, and also
not known from (or maintained by) OPTD. They are normally referenced by another
organism such as ICAO or UN/LOCODE:
```csv
^^^11085^Bīsheh Kolā^Bisheh Kola^36.18604^53.16789^IR^^Iran^Asia^P^PPL^35^Māzandarān^Mazandaran^^^^^^0^^1168^Asia/Tehran^3.5^4.5^3.5^2012-01-16^Bisheh Kola^^fa|Bīsheh Kolā|^IRBSM|
^^^54392^Malable^Malable^2.17338^45.58548^SO^^Somalia^Africa^L^PRT^13^Middle Shabele^Middle Shabele^^^^^^0^^1^Africa/Mogadishu^3.0^3.0^3.0^2012-01-16^Malable^^|Malable|^SOELM|
^^^531191^Mal’chevskaya^Mal'chevskaya^49.0565^40.36541^RU^^Russia^Europe^S^RSTN^61^Rostov^Rostov^^^^^^0^^199^Europe/Moscow^3.0^3.0^3.0^2017-10-03^Mal’chevskaya^^en|Mal’chevskaya|^RUMAA|
```

## Use cases

### Generate the OPTD-maintained POR (points of reference) file
```bash
$ cd <OPTD_ROOT_DIR>/tools
$ ./make_optd_por_public.sh && ./make_optd_por_public.sh --clean
$ git add ../opentraveldata/optd_por_public.csv
$ git diff --cached optd_por_public.csv
$ git ci -m "[POR] Integrated the latest updates from Geonames."
```

### Update from Geonames
The Geonames data may be updated, i.e., new Geonames data files are
downloaded and the ```allCountries_w_alt.txt``` data file is recomputed:
```bash
$ cd <OPTD_ROOT_DIR>/data/geonames/data
$ time ./getDataFromGeonamesWebsite.sh
$ cd por/data
$ \rm -f *~ ../../zip/*~
$ cd -
$ cd por/admin
$ ./aggregateGeonamesPor.sh
$ cd -
$ ls -laFh --color por/data/al*
```

* Back in OPTD, generate two ``por_*intorg_YYYYMMDD.csv`` data files:
  * ``por_intorg_YYYYMMDD.csv`` references all the POR having a IATA code in Geonames
  * ``por_nointorg_YYYYMMDD.csv`` references all the POR having no IATA code (but
 which could have one in Geonames)
```bash
$ cd <OPTD_ROOT_DIR>/tools
$ ./extract_por_from_geonames.sh && ./extract_por_from_geonames.sh --clean
```

* Copy the generated ``por_intorg_YYYYMMDD.csv`` file
into ``dump_from_geonames.csv``
```bash
$ cp -f por_iata_YYYYMMDD.csv dump_from_geonames.csv
```

Note that the ``por_noiata_YYYYMMDD.csv`` has usually a size of around 1.5 GB.

### Add state (administrative level) codes for a given country
See [OpenTravelData Issue #78](https://github.com/opentraveldata/opentraveldata/issues/78)
for an example on how to add Russian region/state codes.

As many other big countries (e.g., United States, Australia, Brazil),
Russia has got regions (administrative level 1), which are assigned
standard (ISO 3166-2) codes: http://en.wikipedia.org/wiki/ISO_3166-2:RU
Those codes are to be added to the ``optd_por_public.csv`` file.

The region codes have first to be added to the
[``opentraveldata/optd_country_states.csv`` CSV file](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_country_states.csv).
They can be derived from the
[Geonames ADM1 codes](http://download.geonames.org/export/dump/admin1CodesASCII.txt).

And, then, the
[``opentraveldata/optd_state_exceptions.csv`` CSV file](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_state_exceptions.csv)
must be amended with the new Russian region codes, in order to reflect that
IATA does not reference those regions correctly.

A way to extract the state (administrative level 1) details from the file
in order to add them into the file:
```bash
$ # To be performed once
$ mkdir -p ~/dev/geo
$ cd ~/dev/geo
$ git clone https://github.com/opentraveldata/opentraveldata.git
$ #
$ cd ~/dev/geo/opentraveldata/data/geonames/data/por/data
$ wget http://download.geonames.org/export/dump/admin1CodesASCII.txt
$ awk -F '\t' '/^RU/ {state_code = substr ($1, 0, 2); adm1_code = substr ($1, 4); print (state_code "^" $4 "^" adm1_code "^" $2 "^") }' admin1CodesASCII.txt | sort -t'^' -k2,2
RU^468898^88^Jaroslavl^
RU^472039^86^Voronezj^
RU^472454^85^Vologda^
...
RU^2125072^92^Kamtsjatka^
RU^2126099^15^Chukotka^
RU^7779061^93^Transbaikal Territory^
```

Just for information, the relevant AWK scripts are:
* [``tools/awklib/geo_lib.awk``](http://github.com/opentraveldata/opentraveldata/blob/master/tools/awklib/geo_lib.awk#function-addctrysubdivdetails)
* [``tools/make_optd_por_public.awk``](http://github.com/opentraveldata/opentraveldata/blob/master/tools/make_optd_por_public.awk#L239)

### Add a field in Geonames dumps
Following is the list of scripts to change when a field is added to the Geonames
dump files (generated by the [``data/geonames/data/por/admin/aggregateGeonamesPor.awk`` AWK script](http://github.com/opentraveldata/opentraveldata/blob/master/data/geonames/data/por/admin/aggregateGeonamesPor.awk)):
* [``tools/add_city_name.awk``](http://github.com/opentraveldata/opentraveldata/blob/master/tools/add_city_name.awk)
* [``tools/add_noiata_por.awk``](http://github.com/opentraveldata/opentraveldata/blob/master/tools/add_noiata_por.awk)
* [``tools/add_por_ref_no_geonames.awk``](http://github.com/opentraveldata/opentraveldata/blob/master/tools/add_por_ref_no_geonames.awk)
* [``tools/extract_non_geonames_por.awk``](http://github.com/opentraveldata/opentraveldata/blob/master/tools/extract_non_geonames_por.awk)
* [``tools/awklib/geo_lib.awk``](http://github.com/opentraveldata/opentraveldata/blob/master/tools/awklib/geo_lib.awk)

* The data file of no-longer-IATA POR
  ([``opentraveldata/optd_por_no_longer_valid.csv``)](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_no_longer_valid.csv)
  should be updated as well (it is manually curated).
  The following AWK-based command may help:
```bash
$ awk -F'^' '{print $0 "^"}' ../opentraveldata/optd_por_no_longer_valid.csv > optd_por_no_longer_valid2.csv && mv optd_por_no_longer_valid2.csv ../opentraveldata/optd_por_no_longer_valid.csv
```

* The data file of POR not (yet) in Geonames
  ([opentraveldata/optd_por_no_geonames.csv](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_no_geonames.csv))
  should be updated as well, by launching the
  [``tools/prepare_por_no_geonames.sh`` script](http://github.com/opentraveldata/opentraveldata/blob/master/tools/prepare_por_no_geonames.sh)

### Update the UN/LOCODE data file
OpenTravelData (OPTD) archives snapshots of the
[UN/LOCODE database](../data/unlocode)
in a [dedicated directory](../data/unlocode/archives/),
in a format friendlier for analysis purpose than the original one.
Also, a few typos are fixed along the way.

#### Typical sequence of commands to clean the downloaded UN/LOCODE data file
* Set up the project, if not already done:
```bash
$ mkdir -p ~/dev/geo
$ cd ~/dev/geo
$ git clone https://github.com/opentraveldata/opentraveldata.git
$ cd ~/dev/geo/opentraveldata/tools
```

* Download the [latest release of UN/LOCODE files](http://www.unece.org/cefact/codesfortrade/codes_index.html):
```bash
$ wget http://www.unece.org/fileadmin/DAM/cefact/locode/loc181csv.zip
```

* Un-pack, remove the unused parts and re-assemble the UN/LOCODE data file:
```bash
$ unzip -x loc181csv.zip && rm -f loc181csv.zip
Archive:  /Users/darnaud/Downloads/loc181csv.zip
  inflating: 2018-1 SubdivisionCodes.csv  
  inflating: 2018-1 UNLOCODE CodeListPart1.csv  
  inflating: 2018-1 UNLOCODE CodeListPart2.csv  
  inflating: 2018-1 UNLOCODE CodeListPart3.csv  
  inflating: 2018-1 UNLOCODE SecretariatNotes.pdf  
$ rm -f 2018-1\ SubdivisionCodes.csv 2018-1\ UNLOCODE\ SecretariatNotes.pdf 
$ cat 2018-1\ UNLOCODE\ CodeListPart1.csv 2018-1\ UNLOCODE\ CodeListPart2.csv 2018-1\ UNLOCODE\ CodeListPart3.csv > unlocode-code-list-2018-1-iso.csv
$ rm -f 2018-1\ UNLOCODE\ CodeListPart1.csv 2018-1\ UNLOCODE\ CodeListPart2.csv 2018-1\ UNLOCODE\ CodeListPart3.csv
```

* Remove the line-feed characters (convert the file from DOS- to Unix-type):
```bash
$ dos2unix unlocode-code-list-2018-1-iso.csv
```

* Convert the character encoding to friendlier UTF-8
```bash
$ iconv -f ISO-8859-1 -t UTF-8 unlocode-code-list-2018-1-iso.csv > unlocode-code-list-2018-1.csv
$ rm -f unlocode-code-list-2018-1-iso.csv
```

* You may want to sort the data file, for instance for later comparison:
```bash
$ sort -t',' -k2,2 -k3,3 -k4,4 unlocode-code-list-2018-1.csv > unlocode-code-list-2018-1-std.csv
$ mv unlocode-code-list-2018-1-std.csv unlocode-code-list-2018-1.csv
```

* Remove (empty) lines with just quotes:
```bash
$ grep -v "^\"$" unlocode-code-list-2018-1.csv > unlocode-code-list-2018-1-ftd.csv
$ mv unlocode-code-list-2018-1-ftd.csv unlocode-code-list-2018-1.csv
```

* Remove comment fields with just opening quotes (that appears when
  a carriage return character is inserted within the comment field:
  the opening quote stays, and an empty line is created with
  the closing character, which is eliminated in the step above):
```bash
$ sed -i -e 's/,\"$/,/g' unlocode-code-list-2018-1.csv
```

* Add the missing ``E`` (East) character in the geographical coordinates
  of the ``SA-SAL`` record (you may want to first check that the error
  is still there):
```bash
$ grep --color "\"2444N 05045\"" unlocode-code-list-2018-1.csv
,"SA","SAL","Salwá","Salwa","04","--3-----","RL","1707",,"2444N 05045",
$ sed -i -e 's/\"2444N 05045\"/\"2444N 05045E\"/g' unlocode-code-list-2018-1.csv
```

* Run the OPTD transformation script, which may report some additional glitches
  (those glitches would need to be fixed with some well crafted ``sed``
  commands like above; that is an exercise given to the reader for now):
```bash
$ sh prepare_unlc_dump_file.sh
[prepare_unlc_dump_file.awk] !! Error at line #36179. Though the change code is '=', there is no record for Fuglafirdi in FO. Full line: "=","FO","","Fuglefjord = Fuglafirdi","Fuglefjord = Fuglafirdi",,,"",,"","",""
[prepare_unlc_dump_file.awk] !! Error at line #56603. Though the change code is '=', there is no record for Kangerlussua in GL. Full line: "=","GL","","Sondre Stromfjord = Kangerlussua","Sondre Stromfjord = Kangerlussua","",,"",,"","",""
[prepare_unlc_dump_file.awk] !! Error at line #56604. Though the change code is '=', there is no record for Manitsoq in GL. Full line: "=","GL","","Sukkertoppen = Manitsoq","Sukkertoppen = Manitsoq","",,"",,"","",""
[prepare_unlc_dump_file.awk] !! Error at line #83012. Though the change code is '=', there is no record for Nizhny Novgorod in RU. Full line: "=","RU","","Gorkiy = Nizhny Novgorod","Gorkiy = Nizhny Novgorod","",,"",,"","",""
[prepare_unlc_dump_file.awk] !! Error at line #88219. Though the change code is '=', there is no record for Adak Island in US. Full line: "=","US","","Adak = Adak Island","Adak = Adak Island","",,"",,"","",""
```

* Tell Git about the new transformed UN/LOCODE data file:
```bash
$ pushd ../data/unlocode
$ git add archives/unlocode-code-list-2018-1.csv
$ rm -f unlocode-code-list-latest.csv
$ ln -s archives/unlocode-code-list-2018-1.csv unlocode-code-list-latest.csv
$ git add unlocode-code-list-latest.csv
$ git commit -m "[POR] Added the latest UN/LOCODE data file" unlocode-code-list-latest.csv archives/unlocode-code-list-2018-1.csv
$ popd
```

* Remove the no longer needed UN/LOCODE raw data file:
```bash
$ rm -f unlocode-code-list-2018-1.csv
```

### See also
* [OpenTravelData Issue #102](https://github.com/opentraveldata/opentraveldata/issues/102)
  for an example on how to spot POR in Vietnam (VN) missing in Geonames
  but present in the UN/LOCODE data file.
* Relevant AWK scripts:
  + [``tools/awklib/geo_lib.awk``](http://github.com/opentraveldata/opentraveldata/blob/master/tools/awklib/geo_lib.awk#function-registerlocodeline)
  + [``tools/prepare_unlc_dump_file.awk``](http://github.com/opentraveldata/opentraveldata/blob/master/tools/prepare_unlc_dump_file.awk)


## Recompute the OPTD-maintained POR file: do 1.1.

### Update from reference data
The reference data has been updated, i.e., the ``dump_from_crb_city.csv``
file has been recomputed.

Recompte the light file of reference POR:
```bash
$ sh prepare_por_ref_light.sh && sh prepare_por_ref_light.sh --clean
```

It should generate the ../opentraveldata/optd_por_ref.csv file. That latter
is not used: it is kept just for reference (hence the name).
```bash
$ git add ../opentraveldata/optd_por_ref.csv
```

Recompute the file of POR not present in Geonames:
```bash
$ sh prepare_por_no_geonames.sh && sh prepare_por_no_geonames.sh --clean
```

Note that the ../opentraveldata/optd_por_exceptions.csv file may need
to be updated, if the above script reports some errors/warnings.

That script should generate the ```../opentraveldata/optd_por_no_geonames.csv```
file
```bash
$ git add ../opentraveldata/optd_por_no_geonames.csv
```

## Recompute the OPTD-maintained POR file: do 1.1.

### Update from Innovata
The Innovata data may be updated, i.e., new Innovata data files have been
downloaded privately, and the dump_from_innovata.csv has to be recomputed.
That file is just used for private reference purpose: no Innovata data is
used within the OpenTravelData project.

Typical commands:
```bash
$ cd <OPTD_ROOT_DIR>/tools
```

Get the ```stations.dat``` file:
```bash
$ dos2unix stations.dat
$ sh prepare_innovata_dump_file.sh .. stations.dat
```

It generates a ```dump_from_innovata.csv``` file:
```bash
$ cp dump_from_innovata.csv ../data/Innovata/innovata_stations.dat
$ git add ../data/Innovata/innovata_stations.dat
$ git commit -m "[POR] New updates for some sources." ../data/Innovata
```

### Update from screen-scraped flight routes
```bash
$ cd <OPTD_ROOT_DIR>/tools
```

The following Python script uses optd_airline_por_rcld.csv
```bash
$ ./make_optd_ref_pr_and_freq.py
```

It should generate two files:
* Importance of airlines (by flight frequency): ref_airline_nb_of_flights.csv
* PageRank values of POR: ref_airport_pageranked.csv

Recalculate the OPTD file of airlines:
```bash
$ ./make_optd_airline_public.sh && ./make_optd_airline_public.sh --clean
$ git add ../opentraveldata/ref_airline_nb_of_flights.csv
$ git add ../opentraveldata/optd_airlines.csv
$ git commit -m "[Airlines] Updated the flight frequencies" ../opentraveldata/ref_airline_nb_of_flights.csv ../opentraveldata/optd_airlines.csv
```

Recalculate the OPTD file of POR:
```bash
$ ./make_optd_por_public.sh && ./make_optd_por_public.sh --clean
$ git add ../opentraveldata/ref_airport_pageranked.csv
$ git add ../opentraveldata/optd_por_public.csv
```

### Compute the differences among all the POR files
```bash
$ cd <OPTD_ROOT_DIR>/tools
$ ./compare_por_files.sh && ./compare_por_files.sh --clean
```

A data file, summing up all the differences, is generated, namely
../opentraveldata/optd_por_diff_w_geonames.csv.
Those differences correspond to the geographical distance weighted
by the airport importance (expressed as the PageRank values derived
from the flight routes for a whole year).
That file is sorted by decreasing differences.
```bash
$ git add ../opentraveldata/optd_por_diff_w_geonames.csv
$ git diff --cached ../opentraveldata/optd_por_diff_w_geonames.csv
$ git commit -m "[POR] New geographical differences"
```

To see the respective details of a given POR (point of reference),
a reminder script is available:
```bash
$ ./extract_por_info.sh
```

It should give something like:
```bash
$ grep "^XCG" ../opentraveldata/optd_por_best_known_so_far.csv \
 dump_from_ref_city.csv dump_from_geonames.csv dump_from_innovata.csv \
 ../opentraveldata/por_in_schedule/por_schedule_counts_2011_01_to_2013_10.csv \
 ../opentraveldata/ref_airport_pageranked.csv \
 ../data/IATA/iata_airport_list_latest.csv
```

Then, compare
* a. in Geonames:
```bash
$ midori http://www.geonames.org/maps/google.html
$ midori http://www.geonames.org/2647216
```
* b. in Google Maps:
```bash
$ midori http://maps.google.com
$ midori http://maps.google.com/?q=51.47115+-0.45649&hl=en
```
* c. in Wikipedia:
```bash
$ midori http://en.wikipedia.org
```
* d. in Bing Maps:
```bash
$ midori http://maps.bing.com
```

### Geonames has better coordinates for a known POR
When the geographical details of a given POR are proved better in Geonames
than in the OPTD-maintained data files, those latters have to be corrected.
Just update the coordinates within the OPTD-maintained list of best known
coordinates:
```bash
$ vi ../opentraveldata/optd_por_best_known_so_far.csv
$ git add ../opentraveldata/optd_por_best_known_so_far.csv
```

For the bulk update, see also ``Bulk fix best known coordinates``.

Proceed with the use case 1.1, since the OPTD-maintained list of best known
coordinates has now better coordinates than the OPTD-maintained list of POR.


### Geonames has details for an unknown POR
A new POR, still unknown from OPTD, may have been specified within Geonames.

The procedure is exactly the same as in 4.1: manually edit the
../opentraveldata/optd_por_best_known_so_far.csv
and re-generate the OPTD-maintained POR file (step 1.1).


### OPTD-maintained best known coordinates file has better coordinates
Fix the POR (points of reference) in Geonames and Wikipedia.
See 3.1 for the URLs.


### OPTD-maintained list has got POR unknown from Geonames
Add the POR in Geonames and Wikipedia. See 2.1 for the URLs.


### Generation of the list of POR, specified in IATA, but missing from Geonames
#### Step 1
Do like in 2.1:
```bash
$ ./compare_por_files.sh
```

#### Step 2
Then, generate the por_in_iata_but_missing_from_geonames.csv and
pageranked_por_in_iata_but_missing_from_geonames.csv files:
```bash
$ ./generate_por_lists_for_geonames.sh
```

If any POR is not in reference data, it will appear and the program
will exit (no file will be generated); follow the suggestion to remove
those entries from the dump_from_geonames.csv.missing file.

#### Step 3
Send the por_in_iata_but_missing_from_geonames.csv file to Geonames
```bash
$ gzip por_in_iata_but_missing_from_geonames.csv
$ gzip pageranked_por_in_iata_but_missing_from_geonames.csv
```

### Bulk fix the best known coordinates
When those are equal to zero and they are known by Geonames and/or
in reference data. That is the bulk version of 4.1.
```bash
$ ./fix_best_known_coordinates.sh
```

When Geonames has better coordinates
```bash
$ wc -l new_optd_por_best_known_so_far.csv.wgeo \
   ../opentraveldata/optd_por_best_known_so_far.csv
$ diff -c new_optd_por_best_known_so_far.csv.wgeo \
	../opentraveldata/optd_por_best_known_so_far.csv | less
```

When reference data has better coordinates
```bash
$ wc -l new_optd_por_best_known_so_far.csv.wrfd \
   ../opentraveldata/optd_por_best_known_so_far.csv
$ diff -c new_optd_por_best_known_so_far.csv.wrfd \
	 ../opentraveldata/optd_por_best_known_so_far.csv | less
```

In case everything seems correct, replace the OPTD-maintained file:
* When Geonames has better coordinates
```bash
$ \mv -f new_optd_por_best_known_so_far.csv.wgeo \
	../opentraveldata/optd_por_best_known_so_far.csv
```
* When reference data has better coordinates
```bash
$ \mv -f new_optd_por_best_known_so_far.csv.wrfd \
	../opentraveldata/optd_por_best_known_so_far.csv
```

Add it into Git and re-check
```bash
$ git add ../opentraveldata/optd_por_best_known_so_far.csv
$ git diff --cached ../opentraveldata/optd_por_best_known_so_far.csv
```

Go to 1.1., as the OPTD-maintained file of best known coordinates
has been updated


### Check issues with Geonames ID on OPTD POR
```bash
$ sh prepare_geonames_dump_file.sh ../ 5
$ sh prepare_geonames_dump_file.sh --clean
$ \rm -f wpk_dump_from_geonames.csv
```

### Spot POR having distinct IATA codes but having the same Geonames ID
```bash
./spot_dup_geonameid.sh
```

### Spot POR for which Geonames may be improved
```bash
$ ./extract_por_for_geonames.sh
```

### Extract POR information from schedules
```bash
$ ./extract_por_from_schedules.sh
```

### Extract airport-related POR missing from Geonames
```bash
$ ./generate_por_apt_list_for_geonames.sh
$ wc -l ../opentraveldata/optd_por_apt_for_geonames.csv
$ less ../opentraveldata/optd_por_apt_for_geonames.csv
```

### Extract POR with state details for a given country
```bash
$ ./extract_state_details.sh IN
$ less ../opentraveldata/optd_country_states.csv.41cty
$ ./extract_state_details.sh --clean
```

## Maintenance

### The format of the allCountries_w_alt.txt file changes
The format of the data/geonames/data/por/data/allCountries_w_alt.txt
may change, i.e., when the data/geonames/data/por/admin/aggregateGeonamesPor.*
(Shell and AWK) scripts are amended. An example of such a change has been
implemented by the
[28ab958cfcd159 commit](http://github.com/opentraveldata/optd/commit/28ab958cfcd159ea96753177d457cd583019a680)
(addition of the continent):
```bash
$ git show 28ab958cfcd159ea96753177d457cd583019a680
```

In that case, the following scripts and data files should be amended accordingly:
* For Geonames raw data processing:
```bash
data/geonames/data/por/admin/aggregateGeonamesPor.awk
data/geonames/data/por/admin/aggregateGeonamesPor.sh
```

* For Geonames data extraction:
```bash
data/tools/extract_por_with_iata_icao.awk
```

* No longer used:
```bash
tools/preprepare_geonames_dump_file.sh
```

* For OPTD-maintained data file processing:
```bash
tools/make_optd_por_public.sh
tools/geo_pk_creator.awk
tools/make_optd_por_public.awk
tools/add_city_name.awk
opentraveldata/optd_por_non_iata.csv
```

* For data publication to Geonames:
```
tools/generate_por_deduplication_suggestions_for_geonames.sh
tools/optd_pk_creator.awk
tools/optd_por_splitter.awk
```

* For OPTD-maintained data extraction for private usage,
  the private Data Analysis project should also be amended through:
```
data_generation/por/make_optd_por_private.awk
data_generation/por/make_optd_por_private.sh
```

### The format of the ``optd_por_public.csv`` file changes
The format of the data/geonames/data/por/data/allCountries_w_alt.txt
may change, i.e., when the data/geonames/data/por/admin/aggregateGeonamesPor.*
(Shell and AWK) scripts are amended. An example of such a change has been
implemented by the 28ab958cfcd159ea96753177d457cd583019a680 commit (addition of
the continent):
```bash
$ git show 28ab958cfcd159ea96753177d457cd583019a680
```

In that case, the following scripts and data files should be amended accordingly:
* For OPTD-maintained data file processing:
```bash
tools/make_optd_por_public.sh
tools/make_optd_por_public.awk
tools/add_city_name.awk
opentraveldata/optd_por_non_iata.csv
```

* For data publication to Geonames:
```bash
tools/generate_por_deduplication_suggestions_for_geonames.sh
tools/optd_pk_creator.awk
tools/optd_por_splitter.awk
```
* For OPTD-maintained data extraction for private usage, the private
  Data Analysis project should also be amended through:
```bash
data_generation/por/make_optd_por_private.awk
data_generation/por/make_optd_por_private.sh
```

### Extract the list of states
```bash
$ ./extract_states.sh IN
$ git add ../opentraveldata/optd_states.csv
$ git commit -m "[States] Updated the list of states"
```


## Details of some data processing tasks

### Building of the main OPTD-maintained POR data file
That section provides more details on how the
[``opentraveldata/optd_por_public.csv``](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_public.csv)
and [``opentraveldata/optd_por_public_all.csv``](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_public_all.csv)
files are generated.

* The main data processing program is the
[``tools/make_optd_por_public.sh`` Shell script](http://github.com/opentraveldata/opentraveldata/blob/master/tools/make_optd_por_public.sh),
  which in turn calls the
[``tools/make_optd_por_public.awk`` AWK script](http://github.com/opentraveldata/opentraveldata/blob/master/tools/make_optd_por_public.awk),
  which in turn calls a few functions from the
[``tools/awklib/geo_lib.awk`` AWK script](http://github.com/opentraveldata/opentraveldata/blob/master/tools/awklib/geo_lib.awk).
  More specifically, for each input data file,
  the [``tools/make_optd_por_public.awk`` AWK script](http://github.com/opentraveldata/opentraveldata/blob/master/tools/make_optd_por_public.awk)
  calls a function named like ``registerXxxLine()`` in the
  [``tools/awklib/geo_lib.awk`` AWK script](http://github.com/opentraveldata/opentraveldata/blob/master/tools/awklib/geo_lib.awk).

#### Parsing of the ``optd_por_best_known_so_far.csv`` (OPTD-maintained) file
The [``registerOPTDLine()`` function](http://github.com/opentraveldata/opentraveldata/blob/master/tools/awklib/geo_lib.awk#function-registeroptdline)
is the main one for processing the
[OPTD-maintained POR file (``opentraveldata/optd_por_best_known_so_far.csv``)](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_best_known_so_far.csv).

#### Parsing of the ``dump_from_geonames.csv`` (Genames-derived) file
The [``displayGeonamesPOREntries()`` function](http://github.com/opentraveldata/opentraveldata/blob/master/tools/awklib/geo_lib.awk#function-displaygeonamesporentries)
is the main one for processing the Geonames-derived data file
(``dump_from_geonames.csv``). At that stage, the OPTD-maintained data file
([``opentraveldata/optd_por_best_known_so_far.csv``](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_best_known_so_far.csv))
has already been parsed and the corresponding details are stored in AWK
(``optd_por_xxx_list``) data structures, for instance ``optd_por_loctype_list``
(for the list of OPTD-maintained transport types) and ``optd_por_geoid_list``
(for the list of OPTD-maintained Geonames ID per IATA-referenced POR).

#### Input files for the main OPTD-maintained POR data file processor
That AWK script takes as input the following data files:
* OPTD-maintained lists of:
  + Best known POR (poins of reference):
	  [``opentraveldata/optd_por_best_known_so_far.csv``](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_best_known_so_far.csv)
  + PageRank values:
	  [``opentraveldata/ref_airport_pageranked.csv``](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/ref_airport_pageranked.csv)
  + Country-associated time-zones:
     [``opentraveldata/optd_tz_light.csv``](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_tz_light.csv)
  + Time-zones for a few POR:
	  [``opentraveldata/optd_por_tz.csv``](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_tz.csv)
  + Country-associated continents:
	  [``opentraveldata/optd_cont.csv``](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_cont.csv)
  + US DOT World Area Codes (WAC):
	  [``opentraveldata/optd_usdot_wac.csv``](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_usdot_wac.csv)
  + Country details:
	  [``opentraveldata/optd_countries.csv``](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_countries.csv)
  + Country states:
	  [``opentraveldata/optd_country_states.csv``](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_country_states.csv)

* Geonames: ``tools/dump_from_geonames.csv`` temporary data file, generated
    as explained in the [section above dedicated to getting data from Geonames](#update-from-geonames)

#### Derivation of the time-zone details
When the POR is listed by OPTD without any associated Geonames ID,
the time-zone ID is derived from either:
* The
  [``opentraveldata/optd_por_tz.csv`` file](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_tz.csv),
  when there is en entry for that POR is that file.

* Its associated country otherwise. In that case, a simplified time-zone ID
  is derived directly from the country code. That is obviously inaccurate
  for countries such as Russia (RU), Canada (CA), USA (US), Antartica (AQ)
  or Australia (AU).
  The best solution is really to add the Geonames ID of the POR to the
  [``optd_por_best_known_so_far.csv`` file](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_best_known_so_far.csv),
  and to add it (previously) to Geonames if needed, that is,
  when that latter does not already reference it.

#### Addition of city names
The city (``UTF8`` and ``ASCII``) names are added afterwards, by another
AWK script, namely [``tools/add_city_name.awk``](http://github.com/opentraveldata/opentraveldata/blob/master/tools/add_city_name.awk).

#### Sample output lines of ``optd_por_public.csv``
That sub-section lists a few samples of output records of the
[``optd_por_public.csv`` generated data file](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_public.csv),
echoing the input data from the
[OPTD-maintained ``optd_por_best_known_so_far.csv`` file](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_best_known_so_far.csv)
in [the above-mentioned section](#update-from-geonames).

##### Standard transport- and city-related pairs
* Following are the records for [Nice](http://geonames.org/2990440)
  and [its airport](http://geonames.org/6299418):
```csv
NCE^LFMN^^Y^6299418^^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.658411^7.215872^S^AIRP^0.08188805262796059^^^^FR^^France^Europe^93^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Alpes-Maritimes^Alpes-Maritimes^062^06088^0^3^5^Europe/Paris^1.0^2.0^1.0^2018-06-18^NCE^Nice^NCE|2990440|Nice|Nice^^^A^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^en|Nice Côte d'Azur International Airport|p^427^France^EUR^FRNCE|
NCE^^^Y^2990440^^Nice^Nice^43.70313^7.26608^P^PPLA2^0.08188805262796059^^^^FR^^France^Europe^93^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Alpes-Maritimes^Alpes-Maritimes^062^06088^338620^25^18^Europe/Paris^1.0^2.0^1.0^2018-06-18^NCE^Nice^NCE|2990440|Nice|Nice^NCE^^C^http://en.wikipedia.org/wiki/Nice^en|Nice|=post|06100|=yue|尼斯|^427^France^EUR^FRNCE|
```

##### Cities with several transport-related POR
```csv
CHI^^^Y^4887398^^Chicago^Chicago^41.85003^-87.65005^P^PPLA2^0.6133625163311509^^^^US^^United States^North America^IL^Illinois^Illinois^031^Cook County^Cook County^14000^^2720546^179^180^America/Chicago^-6.0^-5.0^-6.0^2017-05-23^CHI^Chicago^CHI|4887398|Chicago|Chicago^DPA,GYY,MDW,ORD,PWK,RFD,ZUN^IL^C^http://en.wikipedia.org/wiki/Chicago^en|Chicago|p=ru|Чикаго|=zh|芝加哥|=post|60601|=|The Windy City|^41^Illinois^USD^USCHI|
DPA^KDPA^DPA^Y^4890214^^DuPage County Airport^DuPage County Airport^41.90642^-88.24841^S^AIRP^^^^^US^^United States^North America^IL^Illinois^Illinois^043^DuPage County^DuPage County^79410^^0^229^228^America/Chicago^-6.0^-5.0^-6.0^2018-07-15^CHI^Chicago^CHI|4887398|Chicago|Chicago^^IL^A^http://en.wikipedia.org/wiki/DuPage_Airport^en|DuPage County Airport|p^41^Illinois^USD^USWOP|
MDW^KMDW^MDW^Y^4887472^^Chicago Midway International Airport^Chicago Midway International Airport^41.785972^-87.752417^S^AIRP^0.12491579567091372^^^^US^^United States^North America^IL^Illinois^Illinois^031^Cook County^Cook County^14000^^0^185^185^America/Chicago^-6.0^-5.0^-6.0^2018-07-15^CHI^Chicago^CHI|4887398|Chicago|Chicago^^IL^A^http://en.wikipedia.org/wiki/Midway_International_Airport^en|Chicago Midway International Airport|p^41^Illinois^USD^USDBD|
ORD^KORD^ORD^Y^4887479^^Chicago O'Hare International Airport^Chicago O'Hare International Airport^41.978603^-87.904842^S^AIRP^0.4871606262308594^^^^US^^United States^North America^IL^Illinois^Illinois^031^Cook County^Cook County^14000^^0^201^202^America/Chicago^-6.0^-5.0^-6.0^2018-03-29^CHI^Chicago^CHI|4887398|Chicago|Chicago^^IL^A^http://en.wikipedia.org/wiki/O%27Hare_International_Airport^en|Chicago O'Hare International Airport|p=ru|Международный аэропорт Чикаго О'Хара|^41^Illinois^USD^USORD|
ZUN^^^Y^4914391^^Chicago Union Station^Chicago Union Station^41.87864^-87.64033^S^RSTN^^^^^US^^United States^North America^IL^Illinois^Illinois^031^Cook County^Cook County^14000^^0^180^186^America/Chicago^-6.0^-5.0^-6.0^2017-05-23^CHI^Chicago^CHI|4887398|Chicago|Chicago^^IL^R^http://en.wikipedia.org/wiki/Chicago_Union_Station^en|Chicago Union Station|^41^Illinois^USD^USCHI|
```

#### Transport-related POR serving several cities
```csv
```

# Airlines

# Aircraft equipments

