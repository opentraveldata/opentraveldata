--
-- ORI-generated list of airport importance data
--

LOAD DATA LOCAL INFILE 'ref_airport_pageranked.csv'
REPLACE
INTO TABLE airport_pageranked
CHARACTER SET UTF8
FIELDS TERMINATED BY '^'
 (iata_code, location_type, page_rank);

