
See http://api.infochimps.com/describe/web/an/de/geo

Reproduced below, for convenience. Check the Web site for copyright.
=====================================================================
Digital Element IP Intelligence
Find a wealth of information about the geolocation of this person’s IP.

Please see the Digital Element documentation page (http://api.infochimps.com/describe/web/an/de/) for information about this supplier and pricing.

This data is considered a Premier Dataset, and only Brass Monkey customers or higher will be able to use it. We offer a 14 day trial for any new Brass monkey signup, with which you can tryout the data for free up to the 5,000 call limit.

This data originally comes from Digital Element (http://www.digital-element.com/)

API Call
--------
Parameters:
GET http://api.infochimps.com/web/an/de/geo.json?ip=[ipaddress]
* ip – an IP address (just like you think: 86.75.30.9 or 2.4.60.1)

Returns:
* country – 3-letter country name
* region – Region name (“no region” when country lacks regions)
* city – City name
* conn_speed – The connection speed of the IP. Possible values include
** ?
** dialup
** broadband
** cable
** xdsl
** mobile
** t1
** t3
** oc3
** oc12
** satellite
** wireless
* country_conf – Confidence in assignment of country
* region_conf – Confidence in assignment of region
* city_conf – Confidence in assignment of city
* metro_code – Digital Envoy metro code. Metros are regions larger than cities that may cross state lines. In the US, metro codes are based on Designated Market Areas (DMAs). In the UK, metro codes are based on ITV regions. Cities not in any particular metro are a “0”. Cities that have not yet had an appropriate metroization standard applied are a “-1”.
* lat – Latitude
* longitude – Longitude
* country_code – Digital Envoy country code
* region_code – Digital Envoy region code
* city_code – Digital Envoy city code
* continent_code – Digital Envoy continent code. Possible values are
** 0 – No continent
** 1 – Africa
** 2 – Antarctica
** 3 – Australia
** 4 – Asia
** 5 – Europe
** 6 – North America
** 7 – South America
* two_letter_country – 2-letter country name
* area_code – 3-digit US telephone area code.
* gmt_offset – Time zone GMT/UTC offset (+hhmm)
* in_dst – Are they currently observering DST?
* zip – ZIP code, where available.
* zip_country – 3-letter country code.

Note that some addresses will not return all the fields

Example:
--------
GET http://api.infochimps.com/web/an/de/geo.json?ip=86.75.30.9&apikey=api_test-W1cipwpcdu9Cbd9pmm8D4Cjc469
{
  "region": "070",
  "city": "tranebjerg",
  "country": "dnk",
  "country_code": 208,
  "city_code": 12771,
  "country_conf": 5,
  "city_conf": 3,
  "region_code": 11705,
  "continent_code": 5,
  "region_conf": 4,
  "conn_speed": "xdsl",
  "two_letter_country": "dk",
  "metro_code": -1,
  "longitude": 10.589,
  "lat": 55.832,
  "zip": "01803",
  "area_code": 781,
  "in_dst": "y",
  "zip_country": "usa",
  "gmt_offset": -400
}

