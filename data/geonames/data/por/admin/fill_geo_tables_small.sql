--
--
--
set autocommit=0;
set unique_checks=0;
set foreign_key_checks=0;

--
-- Load Geonames Zip/Postal code data into the tables of the
-- geo_geonames database
--
-- Note: use ./loadGeonamesZipByChunks.sh instead
--
-- LOAD DATA LOCAL INFILE '../../zip/allCountries.txt'
-- INTO TABLE zip_codes (
-- iso_alpha2, postal_code, place_name, 
-- admin_name1, admin_code1, admin_name2, admin_code2, admin_name3,
-- latitude, longitude, accuracy);

--
-- Load Geonames POR data into the tables of the geo_geonames database
--
-- Note: use ./loadGeonamesPorAllByChunks.sh instead
--
-- LOAD DATA LOCAL INFILE '../../por/data/allCountries.txt'
-- INTO TABLE geoname CHARACTER SET UTF8 (
-- geonameid, name, asciiname, alternatenames, latitude, longitude, 
-- fclass, fcode, country, cc2, admin1, admin2, admin3, admin4,
-- population, elevation, gtopo30, timezone, moddate);
-- commit;
 
--
-- Note: use ./loadGeonamesPorAltByChunks.sh instead
--
-- LOAD DATA LOCAL INFILE '../../por/data/alternateNames.txt'
-- INTO TABLE alternate_name CHARACTER SET UTF8 (
-- alternatenameid, geonameid, isoLanguage, alternateName, 
-- isPreferredName, isShortName);
-- commit;


--
-- PageRanked POR
--
-- Sample: LON-C^LON^0.995550996263
--
LOAD DATA LOCAL INFILE '../../../../ORI/ref_airport_pageranked.csv'
REPLACE
INTO TABLE airport_pageranked
CHARACTER SET UTF8
FIELDS TERMINATED BY '^'
 (@pk, iata_code, page_rank)
 set location_type = SUBSTRING(@pk, 5);
commit;
-- IGNORE 1 LINES

 
--
-- Administrative Subdivision #1
-- That file has to be altered, so that the code be split in two parts
-- (see loadGeonamesData.sh for more details).
--
LOAD DATA LOCAL INFILE '../../por/data/admin1CodesASCII.txt'
INTO TABLE admin1_codes_ascii (ccode, code, name, nameAscii, geonameid);
commit;
 
--
-- Administrative Subdivision #2
-- That file has to be altered, so that the code be split in three parts
-- (see loadGeonamesData.sh for more details).
--
LOAD DATA LOCAL INFILE '../../por/data/admin2Codes.txt'
INTO TABLE admin2_codes CHARACTER SET UTF8
	 (ccode, code1, code2, name_local, name, geonameid);
commit;

-- Feature Classes
-- That table has been created from the geonames.org page
-- (http://www.geonames.org/export/codes.html)
LOAD DATA LOCAL INFILE '../../por/data/featureClasses_en.txt'
INTO TABLE feature_classes FIELDS TERMINATED BY ';' (class, names);
commit;

-- Feature Codes
LOAD DATA LOCAL INFILE '../../por/data/featureCodes_en.txt'
INTO TABLE feature_codes CHARACTER SET UTF8
	 (class, code, name_en, description_en);
commit;

LOAD DATA LOCAL INFILE '../../por/data/hierarchy.txt'
INTO TABLE hierarchy CHARACTER SET UTF8 (parentId, childId, relationType);
commit;

LOAD DATA LOCAL INFILE '../../por/data/iso-languagecodes.txt'
INTO TABLE iso_language_codes CHARACTER SET UTF8
	 IGNORE 1 LINES
	 (iso_639_3, iso_639_2, iso_639_1, language_name);
commit;
 
LOAD DATA LOCAL INFILE '../../por/data/timeZones.txt'
INTO TABLE time_zones IGNORE 1 LINES
	 (country, timeZoneId, GMT_offset, DST_offset, raw_offset);
commit;


-- Country Information
-- Note:
--  1. The file may have to be converted from DOS to Unix (with the dos2unix
--     command)
--  2. The header must be removed, so that a single comment/header line remains
LOAD DATA LOCAL INFILE '../../por/data/countryInfo.txt'
INTO TABLE country_info
	 (iso_alpha2, iso_alpha3, iso_numeric, fips_code, name, capital,
	 areaInSqKm, population, continent, tld, currency_code, currency_name,
	 phone, postal_code_format, postal_code_regex, languages,
	 geonameId, neighbours, equivalent_fips_code);
commit;

-- Continent Codes
-- That table has been created from the geonames.org readme.txt 
-- (http://download.geonames.org/export/dump/readme.txt, copied as
-- ../../por/README) file
LOAD DATA LOCAL INFILE '../../por/data/continentCodes.txt'
INTO TABLE continent_codes (code, name, geonameId);
commit;

--
--
--
set unique_checks=1;
set foreign_key_checks=1;

