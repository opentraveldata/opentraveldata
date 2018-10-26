# Reference
* [This README](http://github.com/opentraveldata/opentraveldata/tree/master/data/GeoPC)
* [GeoPostcodes](http://www.geopostcodes.com)
  + [Administrative country subdivisions](http://www.geopostcodes.com/resources#admin)
  + [ISO 3166-2](http://www.geopostcodes.com/resources#iso)
  + [NGA / FIPS](http://www.geopostcodes.com/resources#fips)
  + [NUTS](http://www.geopostcodes.com/resources#nuts)

# Data extraction

## ISO 3166-2 Codes
* Complementary references:
  + [Country codes on International Organization for Standardization (ISO)](http://www.iso.org/iso/country_codes.htm)
  + [ISO 3166-2 on Wikipedia](https://en.wikipedia.org/wiki/ISO_3166-2)
* Download and extract the ISO 3166-2 country subdivisions:
```bash
$ mkdir -p ~/dev/geo/geopc && cd ~/dev/geo/geopc
$ wget "http://www.geopostcodes.com/inc/download.php?f=ISO3166-2&t=9" -O GeoPC_ISO3166-2.csv.zip
$ unzip -x GeoPC_ISO3166-2.csv.zip && rm -f GeoPC_ISO3166-2.csv.zip
```

## NGA / FIPS
* Complementary references:
  + [National Geospatial-Intelligence Agency (NGA) codes, formerly known as FIPS PUB 10-4](http://earth-info.nga.mil/gns/html/gazetteers2.html)
  + [(deprecated) Federal Information Processing Standards (FIPS) on Wikipedia](http://en.wikipedia.org/wiki/Federal_Information_Processing_Standards#Withdrawal_of_geographic_codes)
    - [List of FIPS country codes (FIPS 10-4)](http://en.wikipedia.org/wiki/List_of_FIPS_country_codes)
    - [List of FIPS region codes (FIPS 10-4)](http://en.wikipedia.org/wiki/List_of_FIPS_region_codes)
    - [List of FIPS state codes (FIPS 5-2)](http://en.wikipedia.org/wiki/Federal_Information_Processing_Standard_state_code)
  + [NGA codes on Wikipedia]()
* Download and extract the NGA/FIPS country subdivisions:
```bash 
$ mkdir -p ~/dev/geo/geopc && cd ~/dev/geo/geopc
$ wget "http://www.geopostcodes.com/inc/download.php?f=NGA&t=9" -O GeoPC_NGA.csv.zip
$ unzip -x GeoPC_NGA.csv.zip && rm -f GeoPC_NGA.csv.zip
```

## NUTS
* Complementary references:
  + [Eurostat](http://epp.eurostat.ec.europa.eu)
  + [Nomenclature of Territorial Units for Statistics (NUTS) on Wikipedia](http://en.wikipedia.org/wiki/Nomenclature_of_Territorial_Units_for_Statistics)
* Download and extract the NUTS (European) country subdivisions:
```bash 
$ mkdir -p ~/dev/geo/geopc && cd ~/dev/geo/geopc
$ wget "http://www.geopostcodes.com/inc/download.php?f=NUTS&t=9" -O GeoPC_NUTS.csv.zip
$ unzip -x GeoPC_NGA.csvzip && rm -f GeoPC_NUTS.csv.zip
```



