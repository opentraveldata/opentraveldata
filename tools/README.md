Open Travel Data (OPTD) - Tools - Maintenance
=============================================

# Table of content (ToC)
* [Open Travel Data (OPTD) \- Tools \- Maintenance](#open-travel-data-optd---tools---maintenance)
* [Overview](#overview)
* [POR (points of reference)](#por-points-of-reference)
  * [Data sources](#data-sources)
  * [IATA referencing](#iata-referencing)
  * [OPTD\-generated POR data file](#optd-generated-por-data-file)
  * [OPTD\-maintained POR file](#optd-maintained-por-file)
    * [Rationale](#rationale)
    * [Relationship between a city and its serving POR](#relationship-between-a-city-and-its-serving-por)
    * [Non\-IATA\-referenced POR](#non-iata-referenced-por)
  * [Geonames\-derived POR file](#geonames-derived-por-file)
    * [Summary of updating Geonames data regularly](#summary-of-updating-geonames-data-regularly)
      * [[WIP] New way](#wip-new-way)
      * [Legacy way](#legacy-way)
    * [Download of the Geonames snapshot data files](#download-of-the-geonames-snapshot-data-files)
    * [Generation of the aggregated Geonames snapshot data file](#generation-of-the-aggregated-geonames-snapshot-data-file)
    * [Generation of the main OPTD\-used Geonames data file](#generation-of-the-main-optd-used-geonames-data-file)
    * [Examples of records in the main OPTD\-used Geoanmes data file](#examples-of-records-in-the-main-optd-used-geoanmes-data-file)
      * [Regular relationship between a city and its transport\-related POR](#regular-relationship-between-a-city-and-its-transport-related-por)
      * [A transport\-related POR serving several cities](#a-transport-related-por-serving-several-cities)
      * [Non\-IATA\-referenced OPTD\-known POR](#non-iata-referenced-optd-known-por)
    * [Process Geonames data remotely and merge locally](#process-geonames-data-remotely-and-merge-locally)
  * [Use cases](#use-cases)
    * [Amend the OPTD\-curated POR files](#amend-the-optd-curated-por-files)
    * [Generate the OPTD\-maintained POR (points of reference) file](#generate-the-optd-maintained-por-points-of-reference-file)
    * [Add state (administrative level) codes for a given country](#add-state-administrative-level-codes-for-a-given-country)
    * [Add a field in Geonames dumps](#add-a-field-in-geonames-dumps)
    * [Update the UN/LOCODE data file](#update-the-unlocode-data-file)
      * [Typical sequence of commands to clean the downloaded UN/LOCODE data file](#typical-sequence-of-commands-to-clean-the-downloaded-unlocode-data-file)
      * [See also](#see-also)
    * [Update the OPTD\-curated UN/LOCODE extract](#update-the-optd-curated-unlocode-extract)
    * [Update from reference data](#update-from-reference-data)
    * [Update from Innovata](#update-from-innovata)
    * [Update from screen\-scraped flight routes](#update-from-screen-scraped-flight-routes)
    * [Compute the differences among all the POR files](#compute-the-differences-among-all-the-por-files)
    * [Geonames has better coordinates for a known POR](#geonames-has-better-coordinates-for-a-known-por)
    * [Geonames has details for an unknown POR](#geonames-has-details-for-an-unknown-por)
    * [OPTD\-maintained best known coordinates file has better coordinates](#optd-maintained-best-known-coordinates-file-has-better-coordinates)
    * [OPTD\-maintained list has got POR unknown from Geonames](#optd-maintained-list-has-got-por-unknown-from-geonames)
    * [Generation of the list of POR, specified in IATA, but missing from Geonames](#generation-of-the-list-of-por-specified-in-iata-but-missing-from-geonames)
      * [Step 1](#step-1)
      * [Step 2](#step-2)
      * [Step 3](#step-3)
    * [Bulk fix the best known coordinates](#bulk-fix-the-best-known-coordinates)
    * [Check issues with Geonames ID on OPTD POR](#check-issues-with-geonames-id-on-optd-por)
    * [Spot POR having distinct IATA codes but having the same Geonames ID](#spot-por-having-distinct-iata-codes-but-having-the-same-geonames-id)
    * [Spot POR for which Geonames may be improved](#spot-por-for-which-geonames-may-be-improved)
    * [Extract POR information from schedules](#extract-por-information-from-schedules)
    * [Extract airport\-related POR missing from Geonames](#extract-airport-related-por-missing-from-geonames)
    * [Extract POR with state details for a given country](#extract-por-with-state-details-for-a-given-country)
  * [Maintenance](#maintenance)
    * [The format of the allCountries\_w\_alt\.txt file changes](#the-format-of-the-allcountries_w_alttxt-file-changes)
    * [The format of the optd\_por\_public\.csv file changes](#the-format-of-the-optd_por_publiccsv-file-changes)
    * [Extract the list of states](#extract-the-list-of-states)
    * [Extract the information from airline routes](#extract-the-information-from-airline-routes)
  * [Details of some data processing tasks](#details-of-some-data-processing-tasks)
    * [Building of the main OPTD\-maintained POR data file](#building-of-the-main-optd-maintained-por-data-file)
      * [Parsing of the optd\_por\_best\_known\_so\_far\.csv (OPTD\-maintained) file](#parsing-of-the-optd_por_best_known_so_farcsv-optd-maintained-file)
      * [Parsing of the dump\_from\_geonames\.csv (Genames\-derived) file](#parsing-of-the-dump_from_geonamescsv-genames-derived-file)
      * [Input files for the main OPTD\-maintained POR data file processor](#input-files-for-the-main-optd-maintained-por-data-file-processor)
      * [Derivation of the time\-zone details](#derivation-of-the-time-zone-details)
      * [Addition of city names](#addition-of-city-names)
      * [Sample output lines of optd\_por\_public\.csv](#sample-output-lines-of-optd_por_publiccsv)
        * [Standard transport\- and city\-related pairs](#standard-transport--and-city-related-pairs)
        * [Cities with several transport\-related POR](#cities-with-several-transport-related-por)
      * [Transport\-related POR serving several cities](#transport-related-por-serving-several-cities)
      * [IATA oddicities](#iata-oddicities)
* [Airlines](#airlines)
* [Aircraft equipments](#aircraft-equipments)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc.go)

# Overview
The [original of that documentation file](http://github.com/opentraveldata/opentraveldata/blob/master/tools/README.md)
is maintained on the
[OpenTravelData project](http://github.com/opentraveldata/opentraveldata),
within the [`tools` directory](http://github.com/opentraveldata/opentraveldata/blob/master/tools).

# POR (points of reference)

## Data sources
The two main sources for the geographical points of reference (POR) are:
* The [OpenTravelData (OPTD) project itself](http://github.com/opentraveldata/opentraveldata),
  with its manually curated
  [list of POR (namely `opentraveldata/optd_por_best_known_so_far.csv`)](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_best_known_so_far.csv).
* The [Geonames project](http://geonames.org), from which a POR data file is
  derived, namely `tools/dump_from_geonames.csv`.
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
[`opentraveldata/optd_por_public.csv`](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_public.csv).
The "public" qualifier hints that anyone is able to add, on top of that
POR reference file, his/her own private information.

## OPTD-maintained POR file

### Rationale
The main curated POR file of the
[OpenTravelData project](http://github.com/opentraveldata/opentraveldata)
is the list of "best known details", namely
[`opentraveldata/optd_por_best_known_so_far.csv`](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_best_known_so_far.csv).
It originated (around 2010) from a colection of screen scraped content from
various Web sites.
The OPTD people began to spend significant amount of time curating the list
of POR on various free platforms such as [Geonames](http://geonames.org) and
[Wikipedia](http://wikipedia.org), and that initial knowledge was then fixed
in that `opentraveldata/optd_por_best_known_so_far.csv`, which has been
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
[`RDU-A-4487056`](http://geonames.org/4487056) serves both
[`RDU-C-4464368`](http://geonames.org/4464368) (Raleigh, NC, US) and
[`RDU-C-4487042`](http://geonames.org/4487042) (Durham, NC, US)
in North Carolina (NC), United States (US).
In that case, there are two entries for `RDU-C`. The corresponding entries
in the [`optd_por_best_known_so_far.csv` file](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_best_known_so_far.csv)
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
   11298
```

### Non-IATA-referenced POR
On the other hand, there are in OPTD many POR not referenced by IATA.
Those POR are extracted from Geonames and end up into OPTD if they have
an ICAO or UN/LOCODE code.

Examples of non-IATA-referenced POR, which end up in OPTD:
* [Yei Airport, South Sudan (SS)](http://geonames.org/8131475),
  referenced by ICAO as `HSYE`
* [Coco Island Airport, Myanmar (MM)](http://geonames.org/11258616),
  referenced by ICAO as `VYCI`
* [Migori Airport, Kenya (KE)](http://geonames.org/11395447),
  referenced by ICAO as `HKMM`

As of July 2018, there are over 90,000 POR having at least an ICAO or
UN/LOCODE code, and which are not referenced by IATA. So, adding them all
to the `optd_por_best_known_so_far.csv` file is not so practical.
And it is not very usefull too; especially now that Geonames has become
the master (provider of so called gold records) for all the new POR.
Hence, all the non-IATA-referenced ICAO- or UN/LOCODE-referenced POR
can be added to the `optd_por_public.csv` file, without them to be curated
one by one in the `optd_por_best_known_so_far.csv` file first.
In any case, those POR are present in the `dump_from_geonames.csv` file.
Command to see the different Geonames feature codes for those
non-IATA-referenced POR:
```bash
$ grep '^\^' dump_from_geonames.csv | cut -d'^' -f14,14 | sort | uniq -c | sort -nr | head
62987 PPL
10357 RSTN
9406 PPLA3
5624 PPLA2
4006 PPLA4
2310 PPLX
2062 AIRP
1247 AIRF
1155 PPLA
 595 ADM3
```

## Geonames-derived POR file
The [Geonames project](http://geonames.org) dumps every morning the content
of their production database. The corresponding snapshot data files can be
downloaded from their [export site](http://download.geonames.org/export/dump/).

OPTD maintains a few scripts to download those Geonames dump data files,
and to generate in several steps the so-called Geonames data sources,
namely `dump_from_geonames.csv` (itself a copy of `por_intorg_YYYYMMDD.csv`)
and `por_all_YYYYMMDD.csv`.

The full sequence of commands, which can be performed at regular intervals,
for instance every day, is:
* [Download the Geonames data dump files](#download-of-the-geonames-snapshot-data-files)
* [Generate the Geonames aggregated data file](#generation-of-the-aggregated-geonames-snapshot-data-file)
  (`allCountries_w_alt.txt` in the `data/geonames/data/por/data` directory)
* [Extract/pre-process and generate the `por_{intorg,all}_YYYYMMDD.csv` files](#generation-of-the-main-optd-used-geonames-data-file)
  (in the `tools` directory)

The [Geonames downloader Shell script](http://github.com/opentraveldata/opentraveldata/blob/master/tools/getDataFromGeonamesWebsite.sh)
relies on a Python script
([`download_if_newer.py`](http://github.com/opentraveldata/opentraveldata/blob/master/tools/download_if_newer.py)),
which itself relies on `Pyenv` and `pipenv`. Instructions on how to install
those Python utilities can be found on
[GitHub](http://github.com/machine-learning-helpers/induction-python/tree/master/installation/virtual-env).

The initialization of the
[OpenTravelData (OPTD) project](http://github.com/opentraveldata/opentraveldata)
(to be done once and for all) is therefore something like:
```bash
$ mkdir -p ~/dev/geo
$ git clone https://github.com/opentraveldata/opentraveldata.git ~/dev/geo/opentraveldata
$ cd ~/dev/geo/opentraveldata/tools
$ pipenv install
```

As mentioned above, the Python dependencies will need `pyenv` and `pipenv` tools
to be available in the environment.

If the project has already been initialized, it can be updated with something
like:
```bash
$ cd ~/dev/geo/opentraveldata/tools
$ git pull
$ pipenv --rm && pipenv install
```

### Summary of updating Geonames data regularly

#### [WIP] New way
DuckDB allows to process and analyze rather big data files on local
computers or rather small virtual machines (VM).

* Check that the CSV input data files have been downloaded
  (the size, uncompressed, is around 2.2 GB):
```bash
$ ls -lFh ../data/geonames/data/por/data/al*.txt
-rw-r--r-- 1 user group 1.6G Jul 15 15:49 ../data/geonames/data/por/data/allCountries.txt
-rw-r--r-- 1 user group 587M Jul 15 04:19 ../data/geonames/data/por/data/alternateNames.txt
```

* Parse the CSV, transform into Parquet files and create views
  (the size is around 900 MB, which is a gain of 2.5 times)
```bash
$ ./elt-geonames.py
ls -lFh ../data/geonames/data/por/parquet/*.parquet
-rw-r--r-- 1 user group 649M Jul 15 16:33 ../data/geonames/data/por/parquet/allCountries.parquet
-rw-r--r-- 1 user group 245M Jul 15 16:54 ../data/geonames/data/por/parquet/alternateNames.parquet
```

* Note that the DuckDB itself is not big, at the storage is relying on the
  Parquet files:
```bash
$ ls -lFh db.duckdb 
-rw-r--r-- 1 user group 2.8M Jul 15 17:50 db.duckdb
```

* Check that everything goes well, by launching DuckDB:
```bash
$ duckdb db.duckdb
```
```sql
D select count(*)/1e6 as nb from allcountries
union all
select count(*)/1e6 as nb from altnames;
┌───────────┐
│    nb     │
│  double   │
├───────────┤
│ 12.400442 │
│ 15.892911 │
└───────────┘
D .quit
```

* Attempt to denormalize
  ([GitHub - DuckDB - `array_agg()` fucntion](https://github.com/duckdb/duckdb/issues/2607))
  + Retrieve all the records corresponding to a specific IATA code:
```sql
D select distinct ac.geonameid,
         string_agg(an.isoLanguage || '|' || an.alternateName, '=') altname_section
  from allcountries ac
  join altnames an
    on ac.geonameid=an.geonameid
  where an.isoLanguage='iata'
    and an.alternateName='NCE'
  group by ac.geonameid;
┌───────────┬─────────────────┐
│ geonameid │ altname_section │
│   int64   │     varchar     │
├───────────┼─────────────────┤
│   2990440 │ iata|NCE        │
│   6299418 │ iata|NCE        │
└───────────┴─────────────────┘
```
  + Retrieve the corresponding alternate names:
```sql
D select distinct ac.geonameid,
         any_value(ac) geoname_core,
         string_agg(an.isoLanguage || '|' || an.alternateName, '=') altname_section
  from allcountries ac
  join altnames an
    on ac.geonameid=an.geonameid
  where ac.geonameid in (2990440, 6299418)
  group by ac.geonameid;
┌───────────┬──────────────────────┬───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ geonameid │     geoname_core     │                                                                                                    altname_section                                                                            │
│   int64   │ struct(geonameid b…  │                                                                                                        varchar                                                                                │
├───────────┼──────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│   6299418 │ {'geonameid': 6299…  │ icao|LFMN=iata|NCE=en|Nice Côte d'Azur International Airport=es|Niza Aeropuerto=link|https://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport=fr|Aéroport de Nice Côte d'Azur=en|Nice …  │
│   2990440 │ {'geonameid': 2990…  │ en|Nice=es|Niza=ar|نيس==ca|Niça=da|Nice=eo|Nico=et|Nice=fi|Nizza=fr|Nice=he|ניס=id|Nice=it|Nizza=ja|ニース=la|Nicaea=lad|Nisa=lb|Nice=lt|Nica=nb|Nice=nl|Nice=no|Nice=oc|Niça=pl|Nicea=pt|N…  │
└───────────┴──────────────────────┴───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

#### Legacy way
Once the project has been initialized and/or updated, the sequence of commands
in order to download Geonames data and to extract the OPTD temporary
POR data files is something like:
```bash
$ TODAY=$(date +%Y%m%d)
$ pushd ~/dev/geo/opentraveldata/tools
$ git pull
$ pipenv --rm && pipenv install
$ ./getDataFromGeonamesWebsite.sh 
$ ./aggregateGeonamesPor.sh
$ ls -laFh ../data/geonames/data/por/data/al*.txt
-rw-r--r--  1 user  staff   1.5G Apr 24 03:10 ../data/geonames/data/por/data/allCountries.txt
-rw-r--r--  1 user  staff   2.6G Apr 24 08:18 ../data/geonames/data/por/data/allCountries_w_alt.txt
-rw-r--r--  1 user  staff   543M Apr 24 03:17 ../data/geonames/data/por/data/alternateNames.txt
$ ./extract_por_from_geonames.sh && ./extract_por_from_geonames.sh --clean
$ ls -laFh por_*.csv
-rw-rw-r--  1 user  staff    45M Apr 24 08:25 por_intorg_${TODAY}.csv
-rw-r--r--  1 user  staff   1.5G Apr 24 08:39 por_all_${TODAY}.csv
$ \cp -f por_intorg_${TODAY}.csv dump_from_geonames.csv
$ popd
```

A few more details for each of those steps are given in dedicated sub-sections
below.

### Download of the Geonames snapshot data files
The [`tools/getDataFromGeonamesWebsite.sh` Shell script](http://github.com/opentraveldata/opentraveldata/blob/master/tools/getDataFromGeonamesWebsite.sh)
downloads all the Geonames dump/snapshot data files,
including among other things:
* [`allCountries.zip`](http://download.geonames.org/export/dump/allCountries.zip)
  (around 350 MB), becoming `allCountries.txt` once unzipped, and listing
  the main details of every single POR known from Geonames
  (over 12 millions of POR).
* [`alternateNames.zip`](http://download.geonames.org/export/dump/alternateNames.zip)
  (around 140 MB), becoming `alternateNames.txt` once unzipped, and listing
  the alternate names of those POR. Note that the codes (_e.g._, IATA, ICAO,
  FAA, TCID, UN/LOCODE, Wikipedia and Wikidata) links are alternate names
  in Geonames parlance.
```bash
$ ls -laFh ~/dev/geo/opentraveldata/data/geonames/data/por/data/{allCountries,alternateNames}.{zip,txt}
-rw-r--r--  1 user  staff   344M Aug 18 03:50 ~/dev/geo/opentraveldata/data/geonames/data/por/data/allCountries.zip
-rw-r--r--  1 user  staff   1.4G Aug 18 03:42 ~/dev/geo/opentraveldata/data/geonames/data/por/data/allCountries.txt
-rw-r--r--  1 user  staff   150M Aug 18 01:52 ~/dev/geo/opentraveldata/data/geonames/data/por/data/alternateNames.zip
-rw-r--r--  1 user  staff   545M Aug 18 03:50 ~/dev/geo/opentraveldata/data/geonames/data/por/data/alternateNames.txt
```

### Generation of the aggregated Geonames snapshot data file
The [`tools/aggregateGeonamesPor.sh` Shell script](http://github.com/opentraveldata/opentraveldata/blob/master/tools/aggregateGeonamesPor.sh)
itself relies on the
[`tools/aggregateGeonamesPor.awk` AWK script](http://github.com/opentraveldata/opentraveldata/blob/master/tools/aggregateGeonamesPor.awk).
That latter, from the two downloaded Geonames snapshot/dump data files,
namely `allCountries.txt` (size of 1.4 GB uncompressed, as of August 2019)
and `alternateNames.txt` (size of 550 MB uncompressed) in the
[`data/geonames/data/por/data` directory](http://github.com/opentraveldata/opentraveldata/blob/master/data/geonames/data/por/data),
generates a combined data file, namely `allCountries_w_alt.txt` (size
of 2.5 GB uncompressed), next to the downloaded Geonames data files.
```bash
$ ls -laFh ~/dev/geo/opentraveldata/data/geonames/data/por/data/al*.txt
-rw-r--r--  1 user  staff   1.4G Aug 18 03:42 ~/dev/geo/opentraveldata/data/geonames/data/por/data/allCountries.txt
-rw-r--r--  1 user  staff   545M Aug 18 03:50 ~/dev/geo/opentraveldata/data/geonames/data/por/data/alternateNames.txt
-rw-r--r--  1 user  staff   2.5G Aug 18 12:19 ~/dev/geo/opentraveldata/data/geonames/data/por/data/allCountries_w_alt.txt
```

### Generation of the main OPTD-used Geonames data file
The [`tools/extract_por_from_geonames.sh` Shell script](http://github.com/opentraveldata/opentraveldata/blob/master/tools/extract_por_from_geonames.sh)
itself relies on the
[`tools/extract_por_with_iata_icao.awk` AWK script](http://github.com/opentraveldata/opentraveldata/blob/master/tools/extract_por_with_iata_icao.awk).
That latter, from the combined Geonames data file, namely
`allCountries_w_alt.txt` in the
[`data/geonames/data/por/data` directory](http://github.com/opentraveldata/opentraveldata/blob/master/data/geonames/data/por/data),
generates the main Geonames POR data files then used by OPTD,
namely `dump_from_geonames.csv` (itself a copy of
`por_intorg_YYYYMMDD.csv`) and `por_all_YYYYMMDD.csv`, in the
[`tools` directory](http://github.com/opentraveldata/opentraveldata/blob/master/tools).
```bash
$ ls -laFh ~/dev/geo/opentraveldata/tools/por_*.csv
-rw-rw-r--  1 user  staff    45M Aug 18 14:06 ~/dev/geo/opentraveldata/tools/por_intorg_${TODAY}.csv
-rw-r--r--  1 user  staff   1.6G Aug 18 12:27 ~/dev/geo/opentraveldata/tools/por_all_${TODAY}.csv
```

### Examples of records in the main OPTD-used Geoanmes data file
Examples of records in the `dump_from_geonames.csv` data file, echoing
the examples shown in the
[OPTD-maintained POR file section above](#optd-maintained-por-file).

#### Regular relationship between a city and its transport-related POR
Following are the details for the
[city of San Francisco](http://geonames.org/5391959) and its
[main airport](http://geonames.org/5391989):
```bash
$ grep -e "\^5391959\^" -e "\^5391989\^" ~/dev/geo/opentraveldata/tools/por_*.csv
```
```csv
SFO^^^5391959^San Francisco^San Francisco^37.77493^-122.41942^US^^United States^North America^P^PPLA2^CA^California^California^075^City and County of San Francisco^City and County of San Francisco^^^864816^16^28^America/Los_Angeles^-8.0^-7.0^-8.0^2019-02-26^San Francisco^http://en.wikipedia.org/wiki/San_Francisco^en|San Francisco|p|ru|Сан-Франциско||abbr|SF|^USSFO|^
SFO^KSFO^SFO^5391989^San Francisco International Airport^San Francisco International Airport^37.61882^-122.3758^US^^United States^North America^S^AIRP^CA^California^California^081^San Mateo County^San Mateo County^^^0^5^-2^America/Los_Angeles^-8.0^-7.0^-8.0^2018-07-15^San Francisco International Airport^http://en.wikipedia.org/wiki/San_Francisco_International_Airport^en|San Francisco International Airport|^USSFO|^
```

#### A transport-related POR serving several cities
Following the [Raleigh-Durham International Airport](http://geonames.org/4487056)
serving the cities of [Durham](http://geonames.org/4464368) and
[Raleigh](http://geonames.org/4487042) in North Carolina (NC) in
the United States (US):
```bash
$ grep -e "\^4464368\^" -e "\^4487042\^" -e "\^4487056\^" ~/dev/geo/opentraveldata/tools/por_*.csv
```
```csv
RDU^^^4464368^Durham^Durham^35.99403^-78.89862^US^^United States^North America^P^PPLA2^NC^North Carolina^North Carolina^063^Durham County^Durham County^90932^^257636^123^121^America/New_York^-5.0^-4.0^-5.0^2017-05-23^Durham,RDU^http://en.wikipedia.org/wiki/Durham%2C_North_Carolina^de|Durham||en|Durham|p^USDUR|
RDU^^^4487042^Raleigh^Raleigh^35.7721^-78.63861^US^^United States^North America^P^PPLA^NC^North Carolina^North Carolina^183^Wake County^Wake County^92612^^451066^96^99^America/New_York^-5.0^-4.0^-5.0^2017-05-23^RDU,Raleigh^http://en.wikipedia.org/wiki/Raleigh%2C_North_Carolina^en|Raleigh|p^USRAG|
RDU^KRDU^^4487056^Raleigh-Durham International Airport^Raleigh-Durham International Airport^35.87946^-78.7871^US^^United States^North America^S^AIRP^NC^North Carolina^North Carolina^183^Wake County^Wake County^90576^^0^126^124^America/New_York^-5.0^-4.0^-5.0^2017-05-23^KRDU,RDU,Raleigh-Durham International Airport^http://en.wikipedia.org/wiki/Raleigh%E2%80%93Durham_International_Airport^en|Raleigh–Durham International Airport|p^USRDU|
```

#### Non-IATA-referenced OPTD-known POR
The following transport-related POR are not referenced by IATA, and also
not known from (or maintained by) OPTD. They are normally referenced by another
organism such as ICAO or UN/LOCODE:
```bash
$ grep -e "\^11085\^" -e "\^54392\^" -e "\^531191\^" ~/dev/geo/opentraveldata/tools/por_*.csv
```
```csv
^^^11085^Bīsheh Kolā^Bisheh Kola^36.18604^53.16789^IR^^Iran^Asia^P^PPL^35^Māzandarān^Mazandaran^^^^^^0^^1168^Asia/Tehran^3.5^4.5^3.5^2012-01-16^Bisheh Kola^^fa|Bīsheh Kolā|^IRBSM|
^^^54392^Malable^Malable^2.17338^45.58548^SO^^Somalia^Africa^L^PRT^13^Middle Shabele^Middle Shabele^^^^^^0^^1^Africa/Mogadishu^3.0^3.0^3.0^2012-01-16^Malable^^|Malable|^SOELM|
^^^531191^Mal’chevskaya^Mal'chevskaya^49.0565^40.36541^RU^^Russia^Europe^S^RSTN^61^Rostov^Rostov^^^^^^0^^199^Europe/Moscow^3.0^3.0^3.0^2017-10-03^Mal’chevskaya^^en|Mal’chevskaya|^RUMAA|
```

### Process Geonames data remotely and merge locally
As Geonames data represent roughly half a Giga Byte (GB) in size
(slightly increasing over time), downloading it requires a good Internet
connection. When the Internet connection is not so good, it is possible
to download and process Geonames data on a remote machine (_e.g._,
a container or a virtual machine on the cloud), itself having a good
Internet bandwidth.

The
[`tools/remotePORProcessAndLocalMerge.sh` Shell script](http://github.com/opentraveldata/opentraveldata/blob/master/tools/remotePORProcessAndLocalMerge.sh)
gives all the details of the commands to be executed on both the remote
and local machines.
That process relies on incremental updates (with the `patch` command),
and must therefore be initialized by downloading and processing Geonames data
on both machines (remote and local) the same initial day, so that both
are `synchronized`, _i.e._, have the same `por_all_YYYYMMDD.csv` files.
The next day, the incremental update process can start.

## Use cases

### Amend the OPTD-curated POR files
```bash
$ cd ~/dev/geo/opentraveldata/opentraveldata
$ vi optd_por_best_known_so_far.csv optd_por_no_longer_valid.csv
$ git add optd_por_best_known_so_far.csv optd_por_no_longer_valid.csv
```

### Generate the OPTD-maintained POR (points of reference) file
* Once the
  [Geonames data have been downloaded and updated](#summary-of-updating-geonames-data-regularly),
  and once the
  [OPTD-curated POR files have been altered](#amend-the-optd-curated-por-files),
  the OPTD POR data may be re-computed and delivered:
```bash
$ cd ~/dev/geo/opentraveldata/tools
$ ./make_optd_por_public.sh && ./make_optd_por_public.sh --clean && ./extract_por_unlc.sh
$ pushd ../opentraveldata
$ git add optd_por_public.csv optd_por_public_all.csv optd_por_unlc.csv
$ git diff --cached optd_por_public_all.csv
$ git commit -m "[POR] Integrated the latest updates from Geonames."
$ popd
```

### Add state (administrative level) codes for a given country
See [OpenTravelData Issue #78](https://github.com/opentraveldata/opentraveldata/issues/78)
for an example on how to add Russian region/state codes.

As many other big countries (_e.g._, United States (US), Australia (AU),
Brazil (BR)), Russia (RU) has got regions (administrative level 1),
which are assigned standard (ISO 3166-2) codes:
http://en.wikipedia.org/wiki/ISO_3166-2:RU
Those codes are to be added to the `optd_por_public.csv` file.

The region codes have first to be added to the
[`opentraveldata/optd_country_states.csv` CSV file](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_country_states.csv).
They can be derived from the
[Geonames ADM1 codes](http://download.geonames.org/export/dump/admin1CodesASCII.txt).

And, then, the
[`opentraveldata/optd_state_exceptions.csv` CSV file](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_state_exceptions.csv)
must be amended with the new Russian region codes, in order to reflect that
IATA does not reference those regions correctly.

A way to extract the state (administrative level 1) details from the file
in order to add them into the file:
```bash
$ # To be performed once
$ mkdir -p ~/dev/geo
$ git clone https://github.com/opentraveldata/opentraveldata.git ~/dev/geo/opentraveldata
$ #
$ pushd ~/dev/geo/opentraveldata/data/geonames/data/por/data
$ wget http://download.geonames.org/export/dump/admin1CodesASCII.txt
$ awk -F '\t' '/^RU/ {state_code = substr ($1, 0, 2); adm1_code = substr ($1, 4); print (state_code "^" $4 "^" adm1_code "^" $2 "^") }' admin1CodesASCII.txt | sort -t'^' -k2n,2
RU^468898^88^Jaroslavl^
RU^472039^86^Voronezj^
RU^472454^85^Vologda^
RU^472755^84^Volgograd Oblast^
...
RU^2125072^92^Kamchatka^
RU^2126099^15^Chukotka^
RU^7779061^93^Transbaikal Territory^
$ popd
```

Just for information, the relevant AWK scripts are:
* [`tools/awklib/geo_lib.awk`](http://github.com/opentraveldata/opentraveldata/blob/master/tools/awklib/geo_lib.awk#function-addctrysubdivdetails)
* [`tools/make_optd_por_public.awk`](http://github.com/opentraveldata/opentraveldata/blob/master/tools/make_optd_por_public.awk#L239)

### Add a field in Geonames dumps
Following is the list of scripts to change when a field is added
to the Geonames dump files (generated by the
[`data/geonames/data/por/admin/aggregateGeonamesPor.awk` AWK script](http://github.com/opentraveldata/opentraveldata/blob/master/data/geonames/data/por/admin/aggregateGeonamesPor.awk)):
* [`tools/add_city_name.awk`](http://github.com/opentraveldata/opentraveldata/blob/master/tools/add_city_name.awk)
* [`tools/add_noiata_por.awk`](http://github.com/opentraveldata/opentraveldata/blob/master/tools/add_noiata_por.awk)
* [`tools/add_por_ref_no_geonames.awk`](http://github.com/opentraveldata/opentraveldata/blob/master/tools/add_por_ref_no_geonames.awk)
* [`tools/extract_non_geonames_por.awk`](http://github.com/opentraveldata/opentraveldata/blob/master/tools/extract_non_geonames_por.awk)
* [`tools/awklib/geo_lib.awk`](http://github.com/opentraveldata/opentraveldata/blob/master/tools/awklib/geo_lib.awk)

* The data file of no-longer-IATA POR
  ([`opentraveldata/optd_por_no_longer_valid.csv`)](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_no_longer_valid.csv)
  should be updated as well (it is manually curated).
  The following AWK-based command may help:
```bash
$ awk -F'^' '{print $0 "^"}' ../opentraveldata/optd_por_no_longer_valid.csv > optd_por_no_longer_valid2.csv && mv optd_por_no_longer_valid2.csv ../opentraveldata/optd_por_no_longer_valid.csv
```

* The data file of POR not (yet) in Geonames
  ([`opentraveldata/optd_por_no_geonames.csv`](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_no_geonames.csv))
  should be updated as well, by launching the
  [`tools/prepare_por_no_geonames.sh` script](http://github.com/opentraveldata/opentraveldata/blob/master/tools/prepare_por_no_geonames.sh)

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
$ git clone https://github.com/opentraveldata/opentraveldata.git ~/dev/geo/opentraveldata
$ cd ~/dev/geo/opentraveldata/tools
```

* Download the
  [latest release of UN/LOCODE files](http://www.unece.org/cefact/codesfortrade/codes_index.html):
```bash
$ UNLCVER="222"; UNLCLVER="2022-2"
$ wget https://service.unece.org/trade/locode/loc${UNLCVER}csv.zip
```

* Un-pack, remove the unused parts and re-assemble the UN/LOCODE data file:
```bash
$ unzip -x loc${UNLCVER}csv.zip && rm -f loc${UNLCVER}csv.zip
Archive:  loc${UNLCVER}csv.zip
  inflating: ${UNLCLVER} SubdivisionCodes.csv
  inflating: ${UNLCLVER} UNLOCODE CodeListPart1.csv
  inflating: ${UNLCLVER} UNLOCODE CodeListPart2.csv
  inflating: ${UNLCLVER} UNLOCODE CodeListPart3.csv
  inflating: ${UNLCLVER} UNLOCODE SecretariatNotes.pdf
$ dos2unix ${UNLCLVER}*.csv
$ mv ${UNLCLVER}\ SubdivisionCodes.csv ../data/unlocode/archives/unece-subdivision-codes-${UNLCLVER}.csv
$ mv ${UNLCLVER}\ UNLOCODE\ SecretariatNotes.pdf ../data/unlocode/unlocode-secretarial-notes-${UNLCLVER}.pdf
$ cat ${UNLCLVER}\ UNLOCODE\ CodeListPart1.csv ${UNLCLVER}\ UNLOCODE\ CodeListPart2.csv ${UNLCLVER}\ UNLOCODE\ CodeListPart3.csv > unlocode-code-list-${UNLCLVER}-iso.csv
$ rm -f ${UNLCLVER}\ UNLOCODE\ CodeListPart1.csv ${UNLCLVER}\ UNLOCODE\ CodeListPart2.csv ${UNLCLVER}\ UNLOCODE\ CodeListPart3.csv
```

* Remove the line-feed characters (convert the file from DOS- to Unix-type):
```bash
$ dos2unix unlocode-code-list-${UNLCLVER}-iso.csv
```

* Convert the character encoding to friendlier UTF-8
```bash
$ iconv -f ISO-8859-1 -t UTF-8 unlocode-code-list-${UNLCLVER}-iso.csv > unlocode-code-list-${UNLCLVER}.csv
$ rm -f unlocode-code-list-${UNLCLVER}-iso.csv
```

* You may want to sort the data file, for instance for later comparison:
```bash
$ sort -t',' -k2,2 -k3,3 -k4,4 unlocode-code-list-${UNLCLVER}.csv > unlocode-code-list-${UNLCLVER}-std.csv
$ mv unlocode-code-list-${UNLCLVER}-std.csv unlocode-code-list-${UNLCLVER}.csv
```

* Remove (empty) lines with just quotes:
```bash
$ grep -v "^\"$" unlocode-code-list-${UNLCLVER}.csv > unlocode-code-list-${UNLCLVER}-ftd.csv
$ mv unlocode-code-list-${UNLCLVER}-ftd.csv unlocode-code-list-${UNLCLVER}.csv
```

* Remove comment fields with just opening quotes (that appears when
  a carriage return character is inserted within the comment field:
  the opening quote stays, and an empty line is created with
  the closing character, which is eliminated in the step above):
```bash
$ gsed -i -e 's/,\"$/,/g' unlocode-code-list-${UNLCLVER}.csv
```

* Add the missing `E` (East) character in the geographical coordinates
  of the `SA-SAL` record (you may want to first check that the error
  is still there):
```bash
$ grep --color "\"2444N 05045\"" unlocode-code-list-${UNLCLVER}.csv
,"SA","SAL","Salwá","Salwa","04","--3-----","RL","1707",,"2444N 05045",
$ gsed -i -e 's/\"2444N 05045\"/\"2444N 05045E\"/g' unlocode-code-list-${UNLCLVER}.csv
```

* Run the OPTD transformation script, which may report some additional glitches
  (those glitches would need to be fixed with some well crafted `sed`
  commands like above; that is an exercise given to the reader for now):
```bash
$ sh prepare_unlc_dump_file.sh
[prepare_unlc_dump_file.awk] !! Error at line #36302. Though the change code is '=', there is no record for Fuglafirdi in FO. Full line: "=","FO","","Fuglefjord = Fuglafirdi","Fuglefjord = Fuglafirdi",,,"",,"","",""
[prepare_unlc_dump_file.awk] !! Error at line #56739. Though the change code is '=', there is no record for Kangerlussua in GL. Full line: "=","GL","","Sondre Stromfjord = Kangerlussua","Sondre Stromfjord = Kangerlussua","",,"",,"","",""
[prepare_unlc_dump_file.awk] !! Error at line #56740. Though the change code is '=', there is no record for Manitsoq in GL. Full line: "=","GL","","Sukkertoppen = Manitsoq","Sukkertoppen = Manitsoq","",,"",,"","",""
[prepare_unlc_dump_file.awk] !! Error at line #83827. Though the change code is '=', there is no record for Nizhny Novgorod in RU. Full line: "=","RU","","Gorkiy = Nizhny Novgorod","Gorkiy = Nizhny Novgorod","",,"",,"","",""
[prepare_unlc_dump_file.awk] !! Error at line #89052. Though the change code is '=', there is no record for Adak Island in US. Full line: "=","US","","Adak = Adak Island","Adak = Adak Island","",,"",,"","",""
```

* Tell Git about the new transformed UN/LOCODE data file:
```bash
$ pushd ../data/unlocode
$ git add archives/unlocode-code-list-${UNLCLVER}.csv
$ unlink unlocode-code-list-latest.csv
$ ln -s archives/unlocode-code-list-${UNLCLVER}.csv unlocode-code-list-latest.csv
$ git add unlocode-code-list-latest.csv
$ git add unlocode-secretarial-notes-${UNLCLVER}.pdf
$ git commit -m "[POR] Added the latest UN/LOCODE data file (${UNLCLVER})" unlocode-code-list-latest.csv archives/unlocode-code-list-${UNLCLVER}.csv
$ popd
```

* Remove the no longer needed UN/LOCODE raw data file:
```bash
$ rm -f unlocode-code-list-${UNLCLVER}.csv
```

#### See also
* [OpenTravelData Issue #102](https://github.com/opentraveldata/opentraveldata/issues/102)
  for an example on how to spot POR in Vietnam (VN) missing in Geonames
  but present in the UN/LOCODE data file.
* Relevant AWK scripts:
  + [`tools/awklib/geo_lib.awk`](https://github.com/opentraveldata/opentraveldata/blob/master/tools/awklib/geo_lib.awk#function-registerlocodeline)
  + [`tools/prepare_unlc_dump_file.awk`](https://github.com/opentraveldata/opentraveldata/blob/master/tools/prepare_unlc_dump_file.awk)

### Update the OPTD-curated UN/LOCODE extract
Thanks to the
[`tools/extract_por_unlc.sh` Shell script](https://github.com/opentraveldata/opentraveldata/blob/master/tools/extract_por_unlc.sh),
OPTD provides a curated extract of POR having UN/LOCODE codes,
with their geo-location, Geonames ID and type:
[`opentraveldata/optd_por_unlc.csv`](https://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_unlc.csv).

That Shell script performs the extraction thanks to the two Geonames-derived
data sources, namely `dump_from_geonames.csv` (itself a copy of
`por_intorg_YYYYMMDD.csv`) and `por_all_YYYYMMDD.csv`.
The OPTD-curated UN/LOCODE extract should therefore be generated as often
as those two Geonames-derived data sources, _i.e._ every day if possible.

Following is an example of the extraction process log on the console:
```bash
$ pushd ~/dev/geo/opentraveldata/tools
$ ./extract_por_unlc.sh
The UN/LOCODE POR file ('~/dev/geo/opentraveldata/opentraveldata/optd_por_unlc.csv') has been generated from 'por_intorg_20200713.csv' and 'por_all_20200713.csv'
There are 99964 records
$ git diff ../opentraveldata/optd_por_unlc.csv
$ git add ../opentraveldata/optd_por_unlc.csv
$ git commit -m "[POR] Updated the UN/LOCODE extract" ../opentraveldata/optd_por_unlc.csv
$ popd
```

### Update from reference data
The reference data has been updated, _i.e._, the `dump_from_crb_city.csv`
file has been recomputed.

Recompute the light file of reference POR:
```bash
$ sh prepare_por_ref_light.sh && sh prepare_por_ref_light.sh --clean
```

It should generate the `../opentraveldata/optd_por_ref.csv` file. That latter
is not used: it is kept just for reference (hence the name).
```bash
$ git add ../opentraveldata/optd_por_ref.csv
```

Recompute the file of POR not present in Geonames:
```bash
$ sh prepare_por_no_geonames.sh && sh prepare_por_no_geonames.sh --clean
```

Note that the 
[`../opentraveldata/optd_por_exceptions.csv`](https://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_exceptions.csv)
and
[`../opentraveldata/optd_por_tz.csv`](https://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_tz.csv)
files may need to be updated, if the above script reports some errors/warnings.
Examples of entries:
* To be added in `../opentraveldata/optd_por_exceptions.csv`:
```csv
BVF^R^0^1^^^^^^BVF used to be Bua Airport, Fiji (FJ), Geonames ID: 8298792
```
* To be removed from `../opentraveldata/optd_por_tz.csv`:
```csv
ZJF^Asia/Dubai
```

That script should generate the `../opentraveldata/optd_por_no_geonames.csv`
file
```bash
$ git add ../opentraveldata/optd_por_no_geonames.csv
```

### Update from Innovata
The Innovata data may be updated, _i.e._, new Innovata data files have been
downloaded privately, and the dump_from_innovata.csv has to be recomputed.
That file is just used for private reference purpose: no Innovata data is
used within the OpenTravelData project.

Typical commands:
```bash
$ cd <OPTD_ROOT_DIR>/tools
```

Get the `stations.dat` file:
```bash
$ dos2unix stations.dat
$ sh prepare_innovata_dump_file.sh .. stations.dat
```

It generates a `dump_from_innovata.csv` file:
```bash
$ cp dump_from_innovata.csv ../data/Innovata/innovata_stations.dat
$ git add ../data/Innovata/innovata_stations.dat
$ git commit -m "[POR] New updates for some sources." ../data/Innovata
```

### Update from screen-scraped flight routes
```bash
$ cd <OPTD_ROOT_DIR>/tools
```

The following Python script uses `optd_airline_por.csv`:
```bash
$ ./make_optd_ref_pr_and_freq.py
```

It should generate two files:
* Importance of airlines (by flight frequency): `ref_airline_nb_of_flights.csv`
* PageRank values of POR: `ref_airport_pageranked.csv`
```bash
$ git add ../opentraveldata/ref_airline_nb_of_flights.csv
$ git add ../opentraveldata/ref_airport_pageranked.csv
```

Recalculate the OPTD file of airlines:
```bash
$ ./make_optd_airline_public.py
$ git add ../opentraveldata/optd_airlines.csv
$ git commit -m "[Airlines] Updated the flight frequencies" ../opentraveldata/ref_airline_nb_of_flights.csv ../opentraveldata/optd_airlines.csv
```

Recalculate the OPTD file of POR:
```bash
$ ./make_optd_por_public.sh && ./make_optd_por_public.sh --clean
$ git add ../opentraveldata/optd_por_public.csv
$ git commit -m "[POR] Updated the PageRank values" ../opentraveldata/ref_airport_pageranked.csv ../opentraveldata/optd_por_public.csv
```

### Compute the differences among all the POR files
```bash
$ cd <OPTD_ROOT_DIR>/tools
$ ./compare_por_files.sh && ./compare_por_files.sh --clean
```

A data file, summing up all the differences, is generated, namely
`../opentraveldata/optd_por_diff_w_geonames.csv`.
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
$ midori "http://maps.google.com/?q=51.47115+-0.45649&hl=en"
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

For the bulk update, see also
[Bulk fix best known coordinates](#bulk-fix-the-best-known-coordinates).

Proceed with the
[Generate the OPTD-maintained POR use case](#generate-the-optd-maintained-por-points-of-reference-file),
since the OPTD-maintained list of best known coordinates has now better
coordinates than the OPTD-maintained list of POR.

### Geonames has details for an unknown POR
A new POR, still unknown from OPTD, may have been specified within Geonames.

The procedure is exactly the same as for
[mending the OPTD-curated POR files](#amend-the-optd-curated-por-files):
manually edit the
`../opentraveldata/optd_por_best_known_so_far.csv` file and
[re-generate the OPTD-maintained POR file](#generate-the-optd-maintained-por-points-of-reference-file).

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
Then, generate the `por_in_iata_but_missing_from_geonames.csv` and
`pageranked_por_in_iata_but_missing_from_geonames.csv` files:
```bash
$ ./generate_por_lists_for_geonames.sh
```

If any POR is not in reference data, it will appear and the program
will exit (no file will be generated); follow the suggestion to remove
those entries from the `dump_from_geonames.csv.missing` file.

#### Step 3
Send the `por_in_iata_but_missing_from_geonames.csv` file to Geonames:
```bash
$ gzip por_in_iata_but_missing_from_geonames.csv
$ gzip pageranked_por_in_iata_but_missing_from_geonames.csv
```

### Bulk fix the best known coordinates
When those are equal to zero and they are known by Geonames and/or
in reference data. That is the bulk version of
[amending the OPTD-curated POR files](#amend-the-optd-curated-por-files):
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

In case everything seems correct, replace the OPTD-maintained file.

* When Geonames has better coordinates:
```bash
$ \mv -f new_optd_por_best_known_so_far.csv.wgeo \
	../opentraveldata/optd_por_best_known_so_far.csv
```
* When reference data has better coordinates:
```bash
$ \mv -f new_optd_por_best_known_so_far.csv.wrfd \
	../opentraveldata/optd_por_best_known_so_far.csv
```

Add it into Git and re-check:
```bash
$ git add ../opentraveldata/optd_por_best_known_so_far.csv
$ git diff --cached ../opentraveldata/optd_por_best_known_so_far.csv
```

Go to
[Generate the OPTD-maintained POR use case](#generate-the-optd-maintained-por-points-of-reference-file),
as the OPTD-maintained file of best known coordinates has been updated.

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

### The format of the `allCountries_w_alt.txt` file changes
The format of the `data/geonames/data/por/data/allCountries_w_alt.txt`
may change, _i.e._, when the
`data/geonames/data/por/admin/aggregateGeonamesPor.*` (Shell and AWK)
scripts are amended. An example of such a change has been implemented
by the
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
```bash
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

### The format of the `optd_por_public.csv` file changes
The format of the `data/geonames/data/por/data/allCountries_w_alt.txt`
may change, _i.e._, when the
`data/geonames/data/por/admin/aggregateGeonamesPor.*` (Shell and AWK)
scripts are amended. An example of such a change has been implemented
by the
[28ab958cfcd1 commit](http://github.com/opentraveldata/optd/commit/28ab958cfcd159ea96753177d457cd583019a680)
(addition of the continent):
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

### Extract the information from airline routes
* Airline routes may also be named flight schedules sometimes
```bash
$ pipenv run ./extract_oag_schedule.py \
    --output-csv=../data/OAG/archives/processed/oag_schedule_200112.csv \
    --ssim7-files=../data/OAG/archives/prcessed/airline-routes-ssim7.gz
$ bzip2 oag_schedule_200112.csv
$ ./extract_ond_operating.sh . 200112
$ git add ../opentraveldata/optd_airline_por.csv
$ git commit -m "[Routes] Updated the list of routes"
```

## Details of some data processing tasks

### Building of the main OPTD-maintained POR data file
That section provides more details on how the
[`opentraveldata/optd_por_public.csv`](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_public.csv)
and [`opentraveldata/optd_por_public_all.csv`](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_public_all.csv)
files are generated.

* The main data processing program is the
[`tools/make_optd_por_public.sh` Shell script](http://github.com/opentraveldata/opentraveldata/blob/master/tools/make_optd_por_public.sh),
  which in turn calls the
[`tools/make_optd_por_public.awk` AWK script](http://github.com/opentraveldata/opentraveldata/blob/master/tools/make_optd_por_public.awk),
  which in turn calls a few functions from the
[`tools/awklib/geo_lib.awk` AWK script](http://github.com/opentraveldata/opentraveldata/blob/master/tools/awklib/geo_lib.awk).
  More specifically, for each input data file,
  the [`tools/make_optd_por_public.awk` AWK script](http://github.com/opentraveldata/opentraveldata/blob/master/tools/make_optd_por_public.awk)
  calls a function named like `registerXxxLine()` in the
  [`tools/awklib/geo_lib.awk` AWK script](http://github.com/opentraveldata/opentraveldata/blob/master/tools/awklib/geo_lib.awk).

#### Parsing of the `optd_por_best_known_so_far.csv` (OPTD-maintained) file
The [`registerOPTDLine()` function](http://github.com/opentraveldata/opentraveldata/blob/master/tools/awklib/geo_lib.awk#function-registeroptdline)
is the main one for processing the
[OPTD-maintained POR file (`opentraveldata/optd_por_best_known_so_far.csv`)](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_best_known_so_far.csv).

#### Parsing of the `dump_from_geonames.csv` (Genames-derived) file
The [`displayGeonamesPOREntries()` function](http://github.com/opentraveldata/opentraveldata/blob/master/tools/awklib/geo_lib.awk#function-displaygeonamesporentries)
is the main one for processing the Geonames-derived data file
(`dump_from_geonames.csv`). At that stage, the OPTD-maintained data file
([`opentraveldata/optd_por_best_known_so_far.csv`](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_best_known_so_far.csv))
has already been parsed and the corresponding details are stored in AWK
(`optd_por_xxx_list`) data structures, for instance `optd_por_loctype_list`
(for the list of OPTD-maintained transport types) and `optd_por_geoid_list`
(for the list of OPTD-maintained Geonames ID per IATA-referenced POR).

#### Input files for the main OPTD-maintained POR data file processor
That AWK script takes as input the following data files:
* OPTD-maintained lists of:
  + Best known POR (poins of reference):
	  [`opentraveldata/optd_por_best_known_so_far.csv`](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_best_known_so_far.csv)
  + PageRank values:
	  [`opentraveldata/ref_airport_pageranked.csv`](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/ref_airport_pageranked.csv)
  + Country-associated time-zones:
     [`opentraveldata/optd_tz_light.csv`](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_tz_light.csv)
  + Time-zones for a few POR:
	  [`opentraveldata/optd_por_tz.csv`](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_tz.csv)
  + Country-associated continents:
	  [`opentraveldata/optd_cont.csv`](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_cont.csv)
  + US DOT World Area Codes (WAC):
	  [`opentraveldata/optd_usdot_wac.csv`](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_usdot_wac.csv)
  + Country details:
	  [`opentraveldata/optd_countries.csv`](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_countries.csv)
  + Country states:
	  [`opentraveldata/optd_country_states.csv`](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_country_states.csv)

* Geonames: `tools/dump_from_geonames.csv` temporary data file, generated
    as explained in the [section above dedicated to getting data from Geonames](#update-from-geonames)

#### Derivation of the time-zone details
When the POR is listed by OPTD without any associated Geonames ID,
the time-zone ID is derived from either:
* The
  [`opentraveldata/optd_por_tz.csv` file](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_tz.csv),
  when there is en entry for that POR is that file.

* Its associated country otherwise. In that case, a simplified time-zone ID
  is derived directly from the country code. That is obviously inaccurate
  for countries such as Russia (RU), Canada (CA), USA (US), Antartica (AQ)
  or Australia (AU).
  The best solution is really to add the Geonames ID of the POR to the
  [`optd_por_best_known_so_far.csv` file](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_best_known_so_far.csv),
  and to add it (previously) to Geonames if needed, that is,
  when that latter does not already reference it.

#### Addition of city names
The city (`UTF8` and `ASCII`) names are added afterwards, by another
AWK script, namely [`tools/add_city_name.awk`](http://github.com/opentraveldata/opentraveldata/blob/master/tools/add_city_name.awk).

#### Sample output lines of `optd_por_public.csv`
That sub-section lists a few samples of output records of the
[`optd_por_public.csv` generated data file](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_public.csv),
echoing the input data from the
[OPTD-maintained `optd_por_best_known_so_far.csv` file](http://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_best_known_so_far.csv)
in [the above-mentioned section](#update-from-geonames).

##### Standard transport- and city-related pairs
* Following are the records for [Nice](http://geonames.org/2990440)
  and [its airport](http://geonames.org/6299418):
```csv
NCE^LFMN^^Y^6299418^^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.658411^7.215872^S^AIRP^0.08188805262796059^^^^FR^^France^Europe^93^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Alpes-Maritimes^Alpes-Maritimes^062^06088^0^3^5^Europe/Paris^1.0^2.0^1.0^2018-06-18^NCE^Nice^NCE|2990440|Nice|Nice^^^A^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^en|Nice Côte d'Azur International Airport|p^427^France^EUR^FRNCE|
NCE^^^Y^2990440^^Nice^Nice^43.70313^7.26608^P^PPLA2^0.08188805262796059^^^^FR^^France^Europe^93^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Alpes-Maritimes^Alpes-Maritimes^062^06088^338620^25^18^Europe/Paris^1.0^2.0^1.0^2018-06-18^NCE^Nice^NCE|2990440|Nice|Nice^NCE^^C^http://en.wikipedia.org/wiki/Nice^en|Nice|=post|06100|=yue|尼斯|^427^France^EUR^FRNCE|^
```

##### Cities with several transport-related POR
```csv
CHI^^^Y^4887398^^Chicago^Chicago^41.85003^-87.65005^P^PPLA2^0.6133625163311509^^^^US^^United States^North America^IL^Illinois^Illinois^031^Cook County^Cook County^14000^^2720546^179^180^America/Chicago^-6.0^-5.0^-6.0^2017-05-23^CHI^Chicago^CHI|4887398|Chicago|Chicago^DPA,GYY,MDW,ORD,PWK,RFD,ZUN^IL^C^http://en.wikipedia.org/wiki/Chicago^en|Chicago|p=ru|Чикаго|=zh|芝加哥|=post|60601|=|The Windy City|^41^Illinois^USD^USCHI|^
DPA^KDPA^DPA^Y^4890214^^DuPage County Airport^DuPage County Airport^41.90642^-88.24841^S^AIRP^^^^^US^^United States^North America^IL^Illinois^Illinois^043^DuPage County^DuPage County^79410^^0^229^228^America/Chicago^-6.0^-5.0^-6.0^2018-07-15^CHI^Chicago^CHI|4887398|Chicago|Chicago^^IL^A^http://en.wikipedia.org/wiki/DuPage_Airport^en|DuPage County Airport|p^41^Illinois^USD^USWOP|^
MDW^KMDW^MDW^Y^4887472^^Chicago Midway International Airport^Chicago Midway International Airport^41.785972^-87.752417^S^AIRP^0.12491579567091372^^^^US^^United States^North America^IL^Illinois^Illinois^031^Cook County^Cook County^14000^^0^185^185^America/Chicago^-6.0^-5.0^-6.0^2018-07-15^CHI^Chicago^CHI|4887398|Chicago|Chicago^^IL^A^http://en.wikipedia.org/wiki/Midway_International_Airport^en|Chicago Midway International Airport|p^41^Illinois^USD^USDBD|^
ORD^KORD^ORD^Y^4887479^^Chicago O'Hare International Airport^Chicago O'Hare International Airport^41.978603^-87.904842^S^AIRP^0.4871606262308594^^^^US^^United States^North America^IL^Illinois^Illinois^031^Cook County^Cook County^14000^^0^201^202^America/Chicago^-6.0^-5.0^-6.0^2018-03-29^CHI^Chicago^CHI|4887398|Chicago|Chicago^^IL^A^http://en.wikipedia.org/wiki/O%27Hare_International_Airport^en|Chicago O'Hare International Airport|p=ru|Международный аэропорт Чикаго О'Хара|^41^Illinois^USD^USORD|^
ZUN^^^Y^4914391^^Chicago Union Station^Chicago Union Station^41.87864^-87.64033^S^RSTN^^^^^US^^United States^North America^IL^Illinois^Illinois^031^Cook County^Cook County^14000^^0^180^186^America/Chicago^-6.0^-5.0^-6.0^2017-05-23^CHI^Chicago^CHI|4887398|Chicago|Chicago^^IL^R^http://en.wikipedia.org/wiki/Chicago_Union_Station^en|Chicago Union Station|^41^Illinois^USD^USCHI|^
```

#### Transport-related POR serving several cities
```csv
BDL^KBDL^^Y^5282636^^Bradley International Airport^Bradley International Airport^41.93798^-72.68782^S^AIRP^0.035212105168206886^^^^US^^United States^North America^CT^Connecticut^Connecticut^003^Hartford County^Hartford County^87070^^0^57^49^America/New_York^-5.0^-4.0^-5.0^2017-05-23^HFD,BDL,SFY^Hartford=Windsor Locks=Springfield^HFD|4835797|Hartford|Hartford=BDL|4845926|Windsor Locks|Windsor Locks=SFY|4951788|Springfield|Springfield^^CT^A^https://en.wikipedia.org/wiki/Bradley_International_Airport^en|Bradley International Airport|p^11^Connecticut^USD^USBDL|^
BDL^^^Y^4845926^^Windsor Locks^Windsor Locks^41.92482^-72.64503^P^PPL^0.035212105168206886^^^^US^^United States^North America^CT^Connecticut^Connecticut^003^Hartford County^Hartford County^87070^^12498^13^16^America/New_York^-5.0^-4.0^-5.0^2017-05-23^BDL^Windsor Locks^BDL|4845926|Windsor Locks|Windsor Locks^BDL^CT^C^https://en.wikipedia.org/wiki/Windsor_Locks%2C_Connecticut^post|06096|=en|Windsor Locks|p^11^Connecticut^USD^USWLC|^
HFD^^^Y^4835797^^Hartford^Hartford^41.76371^-72.68509^P^PPLA^0.035212105168206886^^^^US^^United States^North America^CT^Connecticut^Connecticut^003^Hartford County^Hartford County^37070^^124006^18^27^America/New_York^-5.0^-4.0^-5.0^2017-05-23^HFD^Hartford^HFD|4835797|Hartford|Hartford^BDL,HFD,ZRT^CT^C^https://en.wikipedia.org/wiki/Hartford%2C_Connecticut^en|Hartford|p=wkdt|Q33486|^11^Connecticut^USD^USHFD|^
SFY^^^Y^4951788^^Springfield^Springfield^42.10148^-72.58981^P^PPL^0.035241083203645905^^^^US^^United States^North America^MA^Massachusetts^Massachusetts^013^Hampden County^Hampden County^67000^^154341^25^49^America/New_York^-5.0^-4.0^-5.0^2017-05-23^SFY^Springfield^SFY|4951788|Springfield|Springfield^BAF,BDL,CEF,ZSF^MA^C^https://en.wikipedia.org/wiki/Springfield%2C_Massachusetts^en|Springfield|p^13^Massachusetts^USD^USIED|=USSFY|^
```

#### IATA oddicities
* [EuroAirport Basel Mulhouse Freiburg](https://en.wikipedia.org/wiki/EuroAirport_Basel_Mulhouse_Freiburg):
```csv
BSL^LFSB^^Y^6299466^^EuroAirport Basel–Mulhouse–Freiburg^EuroAirport Basel-Mulhouse-Freiburg^47.58958^7.52991^S^AIRP^0.038281402749869305^^^^FR^^France^Europe^44^Grand Est^Grand Est^68^Haut-Rhin^Haut-Rhin^684^68135^0^269^263^Europe/Paris^1.0^2.0^1.0^2018-11-13^EAP^Basel=Mulhouse^EAP|2661604|Basel|Basel=EAP|2991214|Mulhouse|Mulhouse^^GES^A^https://en.wikipedia.org/wiki/EuroAirport_Basel_Mulhouse_Freiburg^en|EuroAirport Basel–Mulhouse–Freiburg|p^France^EUR^CHBSL|=FRMLH|^
EAP^^^Y^2661604^^Basel^Basel^47.5584^7.57327^P^PPLA^0.043145987834725445^^^^CH^^Switzerland^Europe^BS^Basel-City^Basel-City^1200^Basel-Stadt^Basel-Stadt^2701^^164488^^279^Europe/Zurich^1.0^2.0^1.0^2013-03-10^EAP^Basel=Mulhouse^EAP|2661604|Basel|Basel=EAP|2991214|Mulhouse|Mulhouse^BSL,MLH,ZBA,ZDH^^C^https://en.wikipedia.org/wiki/Basel^en|Basel|^486^Switzerland^CHF^CHBSL|^
EAP^^^Y^2991214^^Mulhouse^Mulhouse^47.75^7.33333^P^PPLA3^0.043145987834725445^^^^FR^^France^Europe^44^Grand Est^Grand Est^68^Haut-Rhin^Haut-Rhin^684^68224^111430^^240^Europe/Paris^1.0^2.0^1.0^2016-02-18^EAP^Basel=Mulhouse^EAP|2661604|Basel|Basel=EAP|2991214|Mulhouse|Mulhouse^BSL,MLH,ZBA,ZDH^GES^C^http://en.wikipedia.org/wiki/Mulhouse^en|Mulhouse|^427^France^EUR^FRMLH|^
```

# Airlines

# Aircraft equipments

