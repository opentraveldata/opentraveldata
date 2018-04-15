# Use cases

## Generate the OPTD-maintained POR (points of reference) file
```bash
$ cd <OPTD_ROOT_DIR>/tools
$ ./make_optd_por_public.sh && ./make_optd_por_public.sh --clean
$ git add ../opentraveldata/optd_por_public.csv
$ git diff --cached optd_por_public.csv
$ git ci -m "[POR] Integrated the latest updates from Geonames."
```

## Update from Geonames
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

Back in OPTD, generate two ```por_*iata_YYYYMMDD.csv``` data files:
* ```por_iata_YYYYMMDD.csv``` references all the POR having a IATA code in Geonames
* ```por_noiata_YYYYMMDD.csv``` references all the POR having no IATA code (but
 which could have one in Geonames)
```bash
$ cd <OPTD_ROOT_DIR>/tools
$ ./extract_por_with_iata_icao.sh && ./extract_por_with_iata_icao.sh --clean
```

Copy the generated por_iata_YYYYMMDD.csv file into dump_from_geonames.csv
```bash
$ cp -f por_iata_YYYYMMDD.csv dump_from_geonames.csv
```

Note that the ```por_noiata_YYYYMMDD.csv``` has usually a size of around 1.5 GB.

## Add state (administrative level) codes for a given country
See [OpenTravelData Issue #78](https://github.com/opentraveldata/opentraveldata/issues/78)
for the example on how to add Russian state codes.

As many other big countries (e.g., USA, Australia, Brazil), Russia has got regions (administrative level 1), which are assigned standard (ISO 3166-2) codes: http://en.wikipedia.org/wiki/ISO_3166-2:RU
Those codes should be added to the optd_por_public.csv file.

The region codes should first be added to the [``opentraveldata/optd_country_states.csv`` CSV file](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_country_states.csv). They can be derived from the [Geonames ADM1 codes](http://download.geonames.org/export/dump/admin1CodesASCII.txt).

And, then, the [``opentraveldata/optd_state_exceptions.csv`` CSV file](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_state_exceptions.csv) must be amended with the new Russian region codes, in order to reflect that IATA does not reference those regions correctly.

A way to extract the state (administrative level 1) details from the file in order to add them into the file:
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
* [``tools/awklib/geo_lib.awk``](http://github.com/opentraveldata/opentraveldata/blob/master/tools/awklib/geo_lib.awk#L1462)
* [``tools/make_optd_por_public.awk``](http://github.com/opentraveldata/opentraveldata/blob/master/tools/make_optd_por_public.awk#L232)


# Recompute the OPTD-maintained POR file: do 1.1.

## Update from reference data
The reference data has been updated, i.e., the ```dump_from_crb_city.csv```
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

# Recompute the OPTD-maintained POR file: do 1.1.

## Update from Innovata
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

## Update from screen-scraped flight routes
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

## Compute the differences among all the POR files
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

## Geonames has better coordinates for a known POR
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


## Geonames has details for an unknown POR
A new POR, still unknown from OPTD, may have been specified within Geonames.

The procedure is exactly the same as in 4.1: manually edit the
../opentraveldata/optd_por_best_known_so_far.csv
and re-generate the OPTD-maintained POR file (step 1.1).


## OPTD-maintained best known coordinates file has better coordinates
Fix the POR (points of reference) in Geonames and Wikipedia.
See 3.1 for the URLs.


## OPTD-maintained list has got POR unknown from Geonames
Add the POR in Geonames and Wikipedia. See 2.1 for the URLs.


## Generation of the list of POR, specified in IATA, but missing from Geonames
### Step 1
Do like in 2.1:
```bash
$ ./compare_por_files.sh
```

### Step 2
Then, generate the por_in_iata_but_missing_from_geonames.csv and
pageranked_por_in_iata_but_missing_from_geonames.csv files:
```bash
$ ./generate_por_lists_for_geonames.sh
```

If any POR is not in reference data, it will appear and the program
will exit (no file will be generated); follow the suggestion to remove
those entries from the dump_from_geonames.csv.missing file.

### Step 3
Send the por_in_iata_but_missing_from_geonames.csv file to Geonames
```bash
$ gzip por_in_iata_but_missing_from_geonames.csv
$ gzip pageranked_por_in_iata_but_missing_from_geonames.csv
```

## Bulk fix the best known coordinates
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


## Check issues with Geonames ID on OPTD POR
```bash
$ sh prepare_geonames_dump_file.sh ../ 5
$ sh prepare_geonames_dump_file.sh --clean
$ \rm -f wpk_dump_from_geonames.csv
```

## Spot POR having distinct IATA codes but having the same Geonames ID
```bash
./spot_dup_geonameid.sh
```

## Spot POR for which Geonames may be improved
```bash
$ ./extract_por_for_geonames.sh
```

## Extract POR information from schedules
```bash
$ ./extract_por_from_schedules.sh
```

## Extract airport-related POR missing from Geonames
```bash
$ ./generate_por_apt_list_for_geonames.sh
$ wc -l ../opentraveldata/optd_por_apt_for_geonames.csv
$ less ../opentraveldata/optd_por_apt_for_geonames.csv
```

## Extract POR with state details for a given country
```bash
$ ./extract_state_details.sh IN
$ less ../opentraveldata/optd_country_states.csv.41cty
$ ./extract_state_details.sh --clean
```

# Maintenance

## The format of the allCountries_w_alt.txt file changes
The format of the data/geonames/data/por/data/allCountries_w_alt.txt
may change, i.e., when the data/geonames/data/por/admin/aggregateGeonamesPor.*
(Shell and AWK) scripts are amended. An example of such a change has been
implemented by the 28ab958cfcd159ea96753177d457cd583019a680 commit (addition of
the continent):
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
No longer used:
```bash
tools/preprepare_geonames_dump_file.sh
```

For OPTD-maintained data file processing:
```bash
tools/make_optd_por_public.sh
tools/geo_pk_creator.awk
tools/make_optd_por_public.awk
tools/add_city_name.awk
opentraveldata/optd_por_non_iata.csv
```

For data publication to Geonames:
```
tools/generate_por_deduplication_suggestions_for_geonames.sh
tools/optd_pk_creator.awk
tools/optd_por_splitter.awk
```

For OPTD-maintained data extraction for private usage, the private Data Analysis
project should also be amended through:
```
data_generation/por/make_optd_por_private.awk
data_generation/por/make_optd_por_private.sh
```

## The format of the optd_por_public.csv file changes
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

## Extract the list of states
```bash
$ ./extract_states.sh IN
$ git add ../opentraveldata/optd_states.csv
$ git commit -m "[States] Updated the list of states"
```
