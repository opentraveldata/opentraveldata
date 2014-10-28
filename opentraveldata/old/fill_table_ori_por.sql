--
-- ORI-maintained list of POR (points of reference, i.e., airports, cities,
-- places, etc.)
-- See https://github.com/opentraveldata/optd/tree/trunk/refdata/ORI
--
--

LOAD DATA LOCAL INFILE 'ori_por_public.csv'
REPLACE
INTO TABLE por
CHARACTER SET UTF8
FIELDS TERMINATED BY '^'
IGNORE 1 LINES
  (iata_code, icao_code, is_geonames, geonameid, name, asciiname,
   alternatenames, latitude, longitude, fclass, fcode, 
   country_code, cc2, admin1, admin2, admin3, admin4, 
   population, elevation, gtopo30, timezone, gmt_offset, dst_offset, raw_offset,
   moddate, is_airport, is_commercial,
   city_code, state_code, region_code, location_type,
   wiki_link,
   lang_alt1, alt_name1, lang_alt2, alt_name2, lang_alt3, alt_name3,
   lang_alt4, alt_name4, lang_alt5, alt_name5, lang_alt6, alt_name6,
   lang_alt7, alt_name7, lang_alt8, alt_name8, lang_alt9, alt_name9,
   lang_alt10, alt_name10);
