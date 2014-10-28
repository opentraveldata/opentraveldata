--
-- ORI-generated list of airport popularity data
--

LOAD DATA LOCAL INFILE 'ref_airport_popularity.csv'
REPLACE
INTO TABLE airport_popularity
CHARACTER SET UTF8
FIELDS TERMINATED BY '^'
IGNORE 1 LINES
 (region_code, country, city, airport, airport_code, atmsa, atmsb, atmsc, atmsd,
  tatm, paxa, paxb, paxc, paxd, tpax, frta, frtb, tfrt, mail, tcgo, 
  latmsa, latmsb, latmsc, latmsd, ltatm, lpaxa, lpaxb, lpaxc, lpaxd, ltpax, 
  lfrta, lfrtb, ltfrt, lmail, ltcgo);

