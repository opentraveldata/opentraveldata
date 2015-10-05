
Overview
========
That directory contains the files maintained by the OpenTravelData
team (http://github.com/opentraveldata/opentraveldata) for various
types of travel-related referential data:
* Points of Reference (POR). For now, only the POR having got a IATA code.
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
* optd_por_best_known_so_far.csv is the list of best known details
  for the Points of Reference (POR), for geographical coordinates,
  serving city and Geonames reference.
* optd_por_no_longer_valid.csv is the list of no longer valid POR.
* optd_regions.csv and optd_region_details.csv are the list of regions
  from various projects or institutions (UN WTO, Geonames).

Generated
---------
* optd_por_public.csv is the main referential data file, meant to be
  used by everyone, with all the details.

Mixed
-----
* optd_por_best_to_reject.csv is the list of POR not referenced by IATA.
  A typical use case is when the FAA code has been taken for the IATA code,
  for instance with DAW, as of May 2015: http://geonames.org/5092710.
  Someone should go through that list, check it item and item, and amend
  the corresponding records, usually in Geonames, where the mistake has been
  done in the first place. IATA may be the culprit in some other cases.
* optd_por_tz.csv. Overall curated, but regurlaly generated thanks to GeoBases
  and Geonames
* optd_country_region_info.csv and optd_cont.csv are the lists of countries,
  with their associated details. Those are generated from Geonames. 
* optd_por_diff_w_geonames.csv is the list of geographical distances
  for the POR, as known from optd_por_best_known_so_far.csv on one hand,
  and as known by Geonames on the other hand.
  Someone should go through that list, check it item by item, and amend
  the corresponding records, usually in optd_por_best_known_so_far.csv,
  where the mistake (for geographical coordinates) has been done most of
  the time. Sometimes the culprit may be Geonames; but it is then easy to amend.

Airlines
========

Curated
-------
* optd_airline_best_known_so_far.csv is the list of best known details
  for the airlines.
* optd_airline_alliance_membership.csv is the list of best known
  airline alliance membership details.
* optd_airline_no_longer_valid.csv is the list of no longer valid airlines,
  i.e., of airlines no longer having a two-letter IATA code. Those airlines
  may still operate, though, but they will not appear in any IATA-endorsed
  flight schedule.

Generated
---------
* optd_airline_diff_w_alc.csv is the list of the differences of airline names,
  as on one hand in optd_airline_best_known_so_far.csv, and on the other
  hand in optd_airline_alliance_membership.csv.
  Someone should go through that list, check it item by item, and amend
  either of the two sources, depending where the mistake is.
* optd_airline_diff_w_rfd.csv is the list of the differences of airline names,
  as on one hand in optd_airline_best_known_so_far.csv, and on the other
  hand from reference data (based on publicly available international standard
  such as some IATA data; see the URL below for such a publicly available data
  source).
  That file is meant to be a safenet when incorporating updates from either
  source. Any update should be checked against the reality, first thanks
  to IATA search page (http://www.iata.org/publications/Pages/code-search.aspx),
  then through Wikipedia.
* optd_airlines.csv is the main referential data file, meant to be used
  by everyone, with all the details.


Aircraft
========

Curated
-------
#### `optd_aircraft.csv`
List of best known details for aircraft. With the following columns:
 - iata_code
 - manufacturer
 - model
 - iata_group
 - iata_category
 - icao_code
 - nb_engines
 - aircraft_type
  * H: helicopter
  * J: jet
  * P: piston-engined aircraft
  * S: surface transportation
  * T: turboprop-engined aircraft




