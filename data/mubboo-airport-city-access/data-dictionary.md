# Mubboo Airport-to-City-Centre Access Index 2026: dataset

One row per city and its primary airport (60 rows). Each row gives the published official figures for
getting from that airport to one fixed city-centre point by public transport, the official taxi
figures, and whether late-night and step-free access is stated. 46 rows have a verified fastest
public-transport time; the others say why not in `m1_missing_reason`.

Report and method: https://mubboo.flights/research/airport-city-access-index

## What the rows are, and are not

- The values are **published official figures** (transport operators, airport operators, city and
  national transport authorities, regulators), retrieved between 26 and 27 September 2026. They reflect summer
  timetables. They are **scheduled or stated figures, not measured journeys**.
- Blank cells mean the value could not be verified: either the official source did not publish it, or
  the source could not be read reliably by our collection (`m1_missing_reason` says which for the fastest
  journey). A blank is never zero and never "no", and no estimate was substituted.
- Money columns ending `_local` are in the row's `currency`. Columns ending `_eur` use one conversion
  date (`fx_date`): ECB euro reference rates, or the national central bank's official rate via USD for
  currencies the ECB does not publish. Conversion is for comparison only.

## Columns

| Column | Meaning |
|---|---|
| `city`, `display_name` | City, and the name the report uses where the primary airport is not the obvious one (for example "Florence (from Pisa)"). |
| `airport_iata`, `airport_selection` | The primary airport: most international passengers in the latest full year, from official statistics. `confirmed`, `single-airport` or `provisional` (the statistic for a competing airport could not be retrieved). |
| `centre_point_type`, `centre_point` | The fixed centre point: the seat of the municipal government by default; the historic seat where the government has moved out of the historic centre (London, Buenos Aires); a named visitor-district point for Las Vegas, Orlando and Cancún; a stated government seat where there is no municipal government (Hong Kong, Singapore); the county government centre for Miami. |
| `m1_fastest_minutes` | Fastest scheduled or operator-stated public-transport journey from the airport to any stop within 3 km (straight line) of the centre point, including scheduled transfer waits. Walking to the platform and immigration are excluded. |
| `m1_end_stop`, `m1_end_stop_to_centre_m` | The stop the journey ends at and its straight-line distance to the centre point. |
| `m2_cheapest_fare_*` | Lowest walk-up adult single fare for any eligible public route reaching the 3 km radius, including mandatory airport supplements. No passes, discounts or online-only prices. |
| `m2_fastest_route_fare_*` | Walk-up adult single fare of the `m1` journey. |
| `m2_temporary_fare_note`, `m2_cheapest_fare_normal_local` | Set when the cheapest fare on the retrieval date was a temporary discount (Melbourne: Victoria's half-price fares, 1 June 2026 to 1 January 2027). The value is kept as published; the normal fare is given alongside. |
| `m2_airport_fee_local` | The mandatory airport supplement inside the fare, where the operator itemises it (Sydney station access fee, JFK AirTrain fee, YVR AddFare). Already included in the fares. |
| `m3a_official_flat_taxi_*` | A fixed airport-to-zone taxi fare published by the airport, city or regulator. |
| `m3b_tariff_lower_bound_*`, `m3b_road_km` | **A lower bound calculated from the official tariff, not a quote**: flag fall plus the regulated per-km rate times the road distance (OpenStreetMap routing). Waiting time, surcharges, tolls and tips are excluded. Only fixed regulated meter tariffs are used; tariffs the source calls a maximum are excluded. Never compare `m3b` with `m3a`. |
| `m4_late_night_public_service` | `yes` if an official timetable shows a public departure from the airport toward the centre between 00:00 and 04:59; `no` if the operator's timetable shows none; `no statement` if the official source was read and settles nothing; `not verified` if it could not be read or confirmed (`m4_note` says why where known). |
| `m5_step_free_operator_statement` | What the operator states: `yes, both ends`, `partly` (one end, exceptions, or only a list of lifts), `no (operator)`, `not stated`, or `not verified` (source could not be read). Not an accessibility audit. |
| `m6_offpeak_headway_minutes` | Published interval between departures of the `m1` service. Context only. |
| `m1_transfer_wait` | Blank when the fastest journey's scheduled interchange wait is included (or there is no interchange); otherwise says why it is not. |
| `m1_note` | Caveat on the fastest journey: fastest official figure found, provisional, or the lower end of a published range. |
| `m2_note` | Set when not every route could be priced, so a lower walk-up fare may exist. |
| `m3a_basis` | Blank when the official flat fare includes the mandatory surcharges; otherwise states the basis. |
| `m3a_note` | Other status of the flat fare, for example a trial. |
| `season_change_flag` | The row reflects a temporary or seasonal operation (works timetable, replacement coaches, suspended route) stated by the operator. |

Column prefixes follow the report's measures: `m1` fastest journey, `m2` public-transport fares, `m3a`
official flat taxi fare, `m3b` taxi lower bound from the tariff, `m4` late-night service, `m5` step-free
statement, `m6` service interval.

The companion file `mubboo-airport-city-access-index-2026-sources.csv` lists, for every value, the official
source URL, the retrieval time (UTC), the capture method and the SHA-256 of the captured page. Its `metric`
column says which value the source supports: `primaryAirport` (airport statistics), `centrePoint`, `m1`,
`m2cheap`, `m2fast`, `m3a`, `m3bTariff`, `m4`, `m5`, `m6` as above; `secondary:<IATA>:<metric>` for the
comparison airport (Florence's own airport); `<metric>:label` for a source that supports a label on a value
rather than the value itself (Melbourne's temporary half-price fare); and `fx` for each exchange rate used.
The captured pages themselves are archived by Mubboo and are not redistributed.

## Licence

The values in this file were calculated by Mubboo Flights and are published
under the Creative Commons Attribution 4.0 International licence (CC BY 4.0):
https://creativecommons.org/licenses/by/4.0/. You may copy, redistribute and
adapt them, including commercially, provided you credit "Mubboo Flights
Research" and link to the report:
https://mubboo.flights/research/airport-city-access-index. The licence covers
only Mubboo's own calculated values and charts. It does not cover the source
files published by operators, regulators or statistics agencies, which remain
under their own terms and are not redistributed here.

When you quote a row, quote the retrieval period and the centre point with it: the index measures
airport to one fixed point, not to any particular hotel.

Corrections and method questions: see the report page.

Generated by `build_dataset.py` from `research/results-v2.json` (SHA-256 `fb77cc002246c934396bd1fa6feb8564729cea5a8f6f7f02080c3a432d250214`). Retrieval
between 26 and 27 September 2026; currency conversion date 2026-09-25.
