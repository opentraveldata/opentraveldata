
Overview
========
That directory contains the files maintained by the OpenTravelData
team (http://github.com/opentraveldata/opentraveldata) for various
types of travel-related referential data:
* Points of Reference (POR). For now, only the POR having got a IATA code,
  with a few exceptions (airports having an ICAO code, but not IATA code).
* Countries and continents.
* Time-zones for a few POR.
* Airlines and alliances. For now, only the airlines having a 2-letter
  IATA code.
* Aircraft.

Geographical-related Data
=========================
A few files are maintained, others are generated.

Curated
-------
* `optd_por_best_known_so_far.csv` is the list of best known details
  for the Points of Reference (POR), for geographical coordinates,
  serving city and Geonames reference.
* `optd_por_no_longer_valid.csv` is the list of no longer valid POR.
* `optd_por_exceptions.csv` is a list of exception rules, describing POR being
  valid for some sources while not/no longer valid for some other sources.
  Those exception rules allow to silent quality assurance scripts on already
  known (and tracked) issues.
* `optd_regions.csv` and `optd_region_details.csv` are the list of regions
  and sub-regions from various projects or institutions (UN WTO, Geonames),
  which are called "users" here.
  The whole idea is that each user may specify different list of countries
  and their associated details. For instance, some users will have Australia
  part of Asia, while other users will consider that Australia is a continent
  in itself. Some users will consider that Kosovo is an independent country,
  while some other users will not recognize that country.
  Those specifications are being migrated into a dedicated directory,
  `curated/regions`, and the data files follow a naming convention,
  `optd_region_NNNN_Uuuu.csv`, where `NNNN` corresponds to the user ID and
  `Uuuu` corresponds to the user name.
  A lot of work still needs to be done before the other region data files
  may be decommissioned.
* `optd_usdot_wac.csv` is the list of World Area Codes (WAC), as maintained
  by the US Department of Transportation (DOT):
  http://www.transtats.bts.gov/Fields.asp?Table_ID=315
  For the United States (US) and Canada, the WAC are specified at state level.
  For all the other countries, the WAC are specified at country level.

Generated
---------
* `optd_countries.csv` is a format translation from the Geonames country
  information data file:
  http://download.geonames.org/export/dump/countryInfo.txt
* `optd_por_public.csv` is the main POR data file, meant to be
  used by everyone, with all the details.

Mixed
-----
* `optd_por_best_to_reject.csv` is the list of POR not referenced by IATA.
  A typical use case is when the FAA code has been taken for the IATA code,
  for instance with DAW, as of May 2015: http://geonames.org/5092710.
  Someone should go through that list, check it item and item, and amend
  the corresponding records, usually in Geonames, where the mistake has been
  done in the first place. IATA may be the culprit in some other cases.
* `optd_por_tz.csv`. Overall curated, but regurlaly generated thanks to GeoBases
  and Geonames
* `optd_country_region_info.csv` and `optd_cont.csv` are the lists of countries,
  with their associated details. Those are generated from Geonames.
  Note that there are no script to generate those files yet. As a matter of
  fact, those two files should be replaced by `optd_countries.csv`.
* `optd_por_diff_w_geonames.csv` is the list of geographical distances
  for the POR, as known from `optd_por_best_known_so_far.csv` on one hand,
  and as known by Geonames on the other hand.
  Someone should go through that list, check it item by item, and amend
  the corresponding records, usually in optd_por_best_known_so_far.csv,
  where the mistake (for geographical coordinates) has been done most of
  the time. Sometimes the culprit may be Geonames; but it is then easy to amend.

Airlines
========

Curated
-------
* `optd_airline_best_known_so_far.csv` is the list of best known details
  for the airlines.
* `optd_airline_alliance_membership.csv` is the list of best known
  airline alliance membership details.
* `optd_airline_no_longer_valid.csv` is the list of no longer valid airlines,
  i.e., of airlines no longer having a two-letter IATA code. Those airlines
  may still operate, though, but they will not appear in any IATA-endorsed
  flight schedule.

Generated
---------
* `optd_airline_diff_w_alc.csv` is the list of the differences of airline names,
  as on one hand in `optd_airline_best_known_so_far.csv`, and on the other
  hand in `optd_airline_alliance_membership.csv`.
  Someone should go through that list, check it item by item, and amend
  either of the two sources, depending where the mistake is.
* `optd_airline_diff_w_rfd.csv` is the list of the differences of airline names,
  as on one hand in `optd_airline_best_known_so_far.csv`, and on the other
  hand from reference data (based on publicly available international standard
  such as some IATA data; see the URL below for such a publicly available data
  source).
  That file is meant to be a safety net when incorporating updates from either
  source. Any update should be checked against the reality, first thanks
  to IATA search page (http://www.iata.org/publications/Pages/code-search.aspx),
  then through Wikipedia.
* `optd_airlines.csv` is the main airline details data file, meant to be used
  by everyone, with all the details.


Aircraft
========

Curated
-------
* `optd_aircraft.csv` is the list of best known details for aircraft.


Format Details
==============
US DOT World Area Codes (WAC)
-----------------------------
File: `optd_usdot_wac.csv`
Source: http://www.transtats.bts.gov/Fields.asp?Table_ID=315

* For the United States, see:
  http://en.wikipedia.org/wiki/Territories_of_the_United_States
* For the Canada, see:
  http://en.wikipedia.org/wiki/Provinces_and_territories_of_Canada

Note that, according to the US DOT WAC table, the US contain four more states
than the usual 50 states (http://en.wikipedia.org/wiki/U.S._state):
- 3/301 Puerto Rico (US-PR)
  See also http://en.wikipedia.org/wiki/Political_status_of_Puerto_Rico
- 4/401 U.S. Virgin Islands (US-VI)
  See also http://en.wikipedia.org/wiki/United_States_Virgin_Islands
- 5/501 U.S. Pacific Trust Territories and Possessions (US-TT)
  See also http://en.wikipedia.org/wiki/Unincorporated_territories_of_the_United_States
- 32/3201 District of Columbia (US-DC)
  See also http://en.wikipedia.org/wiki/District_of_Columbia_statehood_movement

### Fields
* WAC              World Area Code
* wac_seq_id2      Unique Identifier for a World Area Code (WAC) at a given
 				   point of time. WAC attributes may change over time.
				   For example, the country name associated with the WAC
				   can change, but the WAC code stays the same.	 
* wac_name:        World Area Code Name	 
* world_area_name  Geographic Region of World Area Code	 
* ctry_short_name  Country Name	 
* ctry_type        Country Type	 
* cptl             Capital	 
* svgty            Sovereignty	 
* ctry_code_iso    Two-Character ISO Country Code	 
* state_code       State Abbreviation	 
* state_name       State Name	 
* state_fips       FIPS (Federal Information Processing Standard) State Code	 
* from_date        Start Date of World Area Code Attributes	 
* to_date          End Date of World Area Code Attributes (Active = NULL)	 
* comments         Comments	 
* is_latest        Indicates whether this row contains the latest attributes
                   for the World Area Code (1 = Yes, 0 = No)

Aircraft
--------
File: `optd_aircraft.csv`

### Fields
* iata_code
* manufacturer
* model
* iata_group
* iata_category
* icao_code
* nb_engines
* aircraft_type
 - H: helicopter
 - J: jet
 - P: piston-engined aircraft
 - S: surface transportation
 - T: turboprop-engined aircraft
