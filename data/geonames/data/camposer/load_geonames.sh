#!/bin/bash

####################
# List interest fields (cities - city.sql)
# $1 - geonameid         : integer id of record in geonames database
# $2 - name              : name of geographical point (utf8) varchar(200)
# $9 - country code      : ISO-3166 2-letter country code, 2 characters
# $18 - timezone          : the timezone id (see file timeZone.txt)

# DDL
echo "CREATE TABLE city(geonameid int, name varchar(200), country character(2), timezone varchar(100));" > city.sql
echo >> city.sql 

# INSERTS
# 1. Search ' and replace for ''
# 2. Construct the query (look field separator \t and single quote variable _SQ)
sed "s:':'':g" allCountries.txt | awk -F "\t" -v _SQ="'" '{
  print "INSERT INTO city(geonameid, name, country, timezone) VALUES(" \
  $1 ", " _SQ $2 _SQ ", " _SQ $9 _SQ ", " _SQ $18 _SQ ");"
}' >> city.sql


####################
# List interest fields (countries - country.sql)
# $1 - ISO
# $5 - Country
# $6 - Capital
# $9 - Continent
# $16 - Languages
# $17 - geonameid

# DDL
echo "CREATE TABLE country(iso character(2), country varchar(200), capital varchar(200), continent character(2), languages varchar(200), geonameid int);" > country.sql
echo >> country.sql

# INSERTS
# 1. Discarting rows that begins with #
# 2. Search ' and replace for ''
# 3. Construct the query (look field separator \t and single quote variable _SQ)

grep -v "^#" countryInfo.txt | sed "s:':'':g" | awk -F "\t" -v _SQ="'" '{
  print "INSERT INTO country(iso, country, capital, continent, languages, geonameid) VALUES(" \
  _SQ $1 _SQ ", " _SQ $5 _SQ ", " _SQ $6 _SQ ", " _SQ $9 _SQ ", " _SQ $16 _SQ ", " $17 ");"
}' >> country.sql 

####################
# List continents

# grep -v "^#" countryInfo.txt | awk -F "\t" '{ print $9 }' | sort | uniq -d 

