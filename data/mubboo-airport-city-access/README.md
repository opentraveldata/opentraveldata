# Mubboo airport-to-city-centre access: September 2026 snapshot

An independently published, openly licensed dataset of airport access in 60
cities, contributed as a source snapshot under OPTD's `data/` convention. This
addition does not change OPTD's generated reference files or require an API key.

## Source and scope

Publisher: Mubboo Flights Research.

Report and method: https://mubboo.flights/research/airport-city-access-index

The report's version 1.1 changes wording, not the frozen data. Official transport,
airport, city and regulatory sources were retrieved on 26-27 September 2026;
timetables reflect that collection period. Currency conversion uses 25 September
2026 reference rates. This is not a live fare or routing service.

Each row describes one city and its selected primary airport, with an explicitly
defined centre point. There are 46 verified public-transport journey times among
the 60 rows. Times are scheduled or operator-stated, not measured journeys. The
endpoint is a stop within 3 km of the defined centre, not the traveller's hotel.
Missing values and operator-stated accessibility fields must not be interpreted
as zero, no service, or an independent accessibility audit. Taxi flat fares and
meter-tariff lower bounds are different measures; see the dictionary.

## Files

The three source files were downloaded on 25 October 2026 and are included
byte-for-byte, with only the source README renamed to `data-dictionary.md`.

- [City/airport values](mubboo-airport-city-access-index-2026.csv): 60 rows, comma-separated UTF-8 CSV with a header.
- [Source register](mubboo-airport-city-access-index-2026-sources.csv): 535 value-level source records, including public URLs, retrieval times, capture methods and capture hashes.
- [Data dictionary](data-dictionary.md): field meanings, missing-value treatment, methods and licence scope.

Original downloads:

- https://mubboo.flights/research/airport-city-access-index/data/mubboo-airport-city-access-index-2026.csv
- https://mubboo.flights/research/airport-city-access-index/data/mubboo-airport-city-access-index-2026-sources.csv
- https://mubboo.flights/research/airport-city-access-index/data/README.md

SHA-256 checksums:

```text
7d44ed5b9bb5012807460d46c2841a7afa27453d3d4c44d6c35f9fa500f7cd4a  mubboo-airport-city-access-index-2026.csv
1f113910d1304e88a17d6501b437c2a8bb8852621442b3743b086acd25ced912  mubboo-airport-city-access-index-2026-sources.csv
1a94a017ab5f7c9e9d80e6c19a668f9d3de1a7c88b19e9937ba7277eabf6dbd4  data-dictionary.md
```

These are unmodified source CSVs, not caret-separated generated OPTD tables.
Join on `airport_iata` or inspect the named city/centre fields as appropriate;
there is no claim that all city names or geographic grains match OPTD's PORs.

## Licence and attribution

The published data and source register are CC BY 4.0:
https://creativecommons.org/licenses/by/4.0/ . Credit **Mubboo Flights Research**
and link to the report when reusing them. The source publisher's full licence
scope is preserved in `data-dictionary.md`. Operator/regulator pages remain
under their own terms and are not redistributed in this contribution.

Suggested citation: Mubboo Flights Research (2026), Airport-to-City-Centre Access
Index 2026, version 1.1, https://mubboo.flights/research/airport-city-access-index .
Quote the collection period and centre definition with a row. This contribution
does not imply OPTD's endorsement or ongoing maintenance by the OPTD team.