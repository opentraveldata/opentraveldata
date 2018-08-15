
# Overview
That directory contains the data files directly maintained by the
[OpenTravelData project](http://github.com/opentraveldata)
for various types of transport-/travel-related referential data:
* Points of Reference/Interest (POR/POI). Those are geographical points,
  referenced at least by a main institution or organization such as
  IATA, ICAO or
  [UN/LOCODE](https://github.com/opentraveldata/opentraveldata/tree/master/data/unlocode),
  and hosts of transport- or travel-related activities.
  More specifically, a POR may be a populated area (e.g., city, island),
  airport, seaplane baase (SPB), heliport, port, railway or bus station.
* Countries, regions (groups of countries) and continents.
* Time-zones (only for the POR not yet referenced by Geonames ID).
* Airlines and alliances. For now, only the airlines having a 2-character
  IATA code or 3-character ICAO code.
* Aircraft.

# Geographical-related Data
A few files are maintained, others are generated.

## Curated
* [``optd_por_best_known_so_far.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_por_best_known_so_far.csv)
  is the list of best known details
  for the Points of Reference (POR), for geographical coordinates,
  serving city and Geonames reference.
  * Those are referenced by IATA (they all have a IATA code).
	As of August 2018, there are around 20,000 POR referenced by IATA.
	Note that most of the IATA codes reference several distinct POR,
	for instance an airport and a served city for the majority of them.
	Hence, there are only around 11,270 IATA codes: in average, a IATA code
	references two POR.
  * On top of those IATA-referenced POR, there are around 90,000 POR
    referenced by another institution/organization, such as ICAO
	or UN/LOCODE. By design, those POR are referenced by Geonames
	(otherwise, OPTD would not be aware of them), which is the
	master/gold record for those POR. In other words, those POR
	are not curated directly by the OPTD project. They may be curated
	indirectly through Geonames. For instance, if some details (e.g.,
	geographical coordinates, name, Wikipedia link) are not	correct
	for some POR, then we may fix them on Geonames, and once the Geonames
	data dumps are then subsequently integrated within OPTD, the errors
	will be fixed.
* [``optd_por_no_longer_valid.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_por_no_longer_valid.csv)
  is the list of no longer valid POR.
  * In other words, those POR were once referenced by IATA, but it is no longer
    the case. Normally, validity dates are specified, so that a single POR
    is referenced at any given time by IATA. Examples of change of referencing
    are when a new airport is built and the operations are transfered to the
    new airport.
  * Sometimes, IATA find out that there is no transport-/travel-related POR
    at the corresponding location, and decide to suppress the referencing.
    The code may then be re-used later for another POR.
* [``optd_por_exceptions.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_por_exceptions.csv)
  is a list of exception rules, describing POR being
  valid for some sources while not/no longer valid for some other sources.
  Those exception rules allow to silent quality assurance scripts on already
  known (and tracked) issues.
* [``optd_regions.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_regions.csv)
  and [``optd_region_details.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_region_details.csv)
  are the list of regions and sub-regions from various projects
  or institutions (UN WTO, Geonames), which are called "users" here.
  The whole idea is that each user may specify different list of countries
  and their associated details. For instance, some users will have Australia
  part of Asia, while other users will consider that Australia is a continent
  in itself. Some users will consider that Kosovo is an independent country,
  while some other users will not recognize that country.
  Those specifications are being migrated into a dedicated directory,
  [``curated/regions``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/curated/regions),
  and the data files follow a naming convention,
  ``optd_region_NNNN_Uuuu.csv``, where ``NNNN`` corresponds to the user ID and
  ``Uuuu`` corresponds to the user name.
  A lot of work still needs to be done before the other region data files
  may be decommissioned.
* [``optd_usdot_wac.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_region_details.csv)
  is the list of World Area Codes (WAC), as maintained by the US Department
  of Transportation (DOT):
  http://www.transtats.bts.gov/Fields.asp?Table_ID=315
  For the United States (US) and Canada, the WAC are specified at state level.
  For all the other countries, the WAC are specified at country level.
  There are some (tractable) issues when it comes to country definition,
  for instance with Virgin Islands or Kosovo. A specific mapping from
  the actual country code to the corresponding WAC code is then performed.

## Generated
* [``optd_countries.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_countries.csv)
  is a format translation from the Geonames country information data file:
  http://download.geonames.org/export/dump/countryInfo.txt
* [``optd_por_public.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_countries.csv)
  is the main POR data file, meant to be used by everyone, with all the details.

## Mixed
* [``optd_por_best_to_reject.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_por_best_to_reject.csv)
  is the list of POR not referenced by IATA.
  A typical use case is when the FAA code has been taken for the IATA code,
  for instance with [``DAW``, as of August 2018](http://geonames.org/5092710).
  Someone should go through that list, check it item by item, and amend
  the corresponding records, usually in Geonames, where the mistake has been
  done in the first place. IATA may be the culprit in some other cases.
* [``optd_por_tz.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_por_tz.csv)
  is the list of time-zones for IATA codes, for which the Geonames ID have
  not been known (or existing) so far. As soon as corresponding POR
  are referenced in the
  [``optd_por_best_known_so_far.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_por_best_known_so_far.csv),
  the corresponding entries should be removed from
  [``optd_por_tz.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_por_tz.csv).
  That file has been generated and curated once, from Geobases and Geonames,
  and is no longer intended to be generated any more. The fate of that file
  is to reduce to zero, as all the POR it contains are progressively integrated
  within Geonames.
* [``optd_country_region_info.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_country_region_info.csv)
  and [``optd_cont.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_cont.csv)
  are the lists of countries, with their associated details.
  Those are generated from Geonames.
  Note that there is no script to generate those files yet. As a matter of
  fact, those two files should be replaced by
  [``optd_countries.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_countries.csv).
* [``optd_por_diff_w_geonames.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_por_diff_w_geonames.csv)
  is the list of geographical distances for the POR,
  as known from [``optd_por_best_known_so_far.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_por_best_known_so_far.csv)
  on one hand,
  and as known by Geonames on the other hand.
  Someone should go through that list, check it item by item, and amend
  the corresponding records, usually in
  [``optd_por_best_known_so_far.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_por_best_known_so_far.csv),
  where the mistake (for geographical coordinates) has been done most of
  the time. Sometimes the culprit may be Geonames; but it is then easy
  to amend (directly in Geonames).
  As a reminder, whenever you want to interact with a Geonames record,
  you can open a web browser on http://geonames.org/geo_id. It is that simple. 

# Airlines

## Curated
* [``optd_airline_best_known_so_far.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_airline_best_known_so_far.csv)
  is the list of best known details for the airlines.
* [``optd_airline_alliance_membership.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_airline_alliance_membership.csv)
  is the list of best known airline alliance membership details.
* [``optd_airline_no_longer_valid.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_airline_no_longer_valid.csv)
  is the list of airlines no longer having a valid IATA 2-letter or
  ICAO 3-letter code.
  Those airlines may still operate, but not with the same IATA or ICAO code.
  A primary key, usually formed from its original name and a version number,
  allows to track the full history along the time of any given airline.
  But, to be honest, those files still need a lot of curation. They are
  reasonably good for the airlines currently operating, or at least
  those which have operated in the recent years (say, after 2015),
  but not so accurate for the histories of all those airlines.

## Generated
* [``optd_airline_diff_w_alc.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_airline_diff_w_alc.csv)
  is the list of the differences of airline names,
  as on one hand in
  [``optd_airline_best_known_so_far.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_airline_best_known_so_far.csv),
  and on the other hand in
  [``optd_airline_alliance_membership.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_airline_alliance_membership.csv).
  Someone should go through that list, check it item by item, and amend
  either of the two sources, depending where the mistake is.
* [``optd_airline_diff_w_rfd.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_airline_diff_w_rfd.csv)
  is the list of the differences of airline names,
  as on one hand in
  [``optd_airline_best_known_so_far.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_airline_best_known_so_far.csv),
  and on the other hand from reference data (based on publicly available
  international standard such as some IATA data; see the URL below
  for such a publicly available data source).
  That file is meant to be a safety net when incorporating updates from either
  source. Any update should be checked against the reality, first thanks
  to IATA search page (http://www.iata.org/publications/Pages/code-search.aspx),
  then through Wikipedia.
* [``optd_airlines.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_airlines.csv)
  is the main airline details data file, meant to be used by everyone,
  with all the details.


# Aircraft

## Curated
* [``optd_aircraft.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_aircraft.csv)
  is the list of best known details for aircraft.


# Format Details

## US DOT World Area Codes (WAC)
File: [``optd_usdot_wac.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_usdot_wac.csv)
Source: http://www.transtats.bts.gov/Fields.asp?Table_ID=315

* For the United States (US), see:
  http://en.wikipedia.org/wiki/Territories_of_the_United_States
* For the Canada (CA), see:
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
* ``WAC``              World Area Code
* ``wac_seq_id2``      Unique Identifier for a World Area Code (WAC) at a given
 				   point of time. WAC attributes may change over time.
				   For example, the country name associated with the WAC
				   can change, but the WAC code stays the same.
* ``wac_name``         World Area Code Name
* ``world_area_name``  Geographic Region of World Area Code
* ``ctry_short_name``  Country Name
* ``ctry_type``        Country Type
* ``cptl``             Capital
* ``svgty``            Sovereignty
* ``ctry_code_iso``    Two-Character ISO Country Code
* ``state_code``       State Abbreviation
* ``state_name``       State Name
* ``state_fips``       FIPS (Federal Information Processing Standard) State Code
* ``from_date``        Start Date of World Area Code Attributes
* ``to_date``          End Date of World Area Code Attributes (Active = NULL)
* ``comments``         Comments
* ``is_latest``        Indicates whether this row contains the latest attributes
                   for the World Area Code (1 = Yes, 0 = No)

## Aircraft
File: [``optd_aircraft.csv``](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata/optd_aircraft.csv)

### Fields
* ``iata_code``
* ``manufacturer``
* ``model``
* ``iata_group``
* ``iata_category``
* ``icao_code``
* ``nb_engines``
* ``aircraft_type``
 - ``H``: helicopter
 - ``J``: jet
 - ``P``: piston-engined aircraft
 - ``S``: surface transportation
 - ``T``: turboprop-engined aircraft
