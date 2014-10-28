--
-- @brief SQL script creating the indexes for the ORI-related tables.
--        See also create_ori_tables.sql in the same directory.
-- @author Denis Arnaud <denis.arnaud_ori@m4x.org>
--

--
-- Index structure for table por (points of reference)
-- 

ALTER TABLE por ADD PRIMARY KEY (`iata_code`);

ALTER TABLE por ADD INDEX (`icao_code`);

ALTER TABLE por ADD INDEX (`geonameid`);

ALTER TABLE por ADD INDEX (`name`);

ALTER TABLE por ADD INDEX (`asciiname`);

ALTER TABLE por ADD INDEX (`alternatenames`);

ALTER TABLE por ADD INDEX (`latitude`);

ALTER TABLE por ADD INDEX (`longitude`);

ALTER TABLE por ADD INDEX (`fcode`);

ALTER TABLE por ADD INDEX (`admin1`);
ALTER TABLE por ADD INDEX (`admin2`);

ALTER TABLE por ADD INDEX (`city_code`);

ALTER TABLE por ADD INDEX (`state_code`);

ALTER TABLE por ADD INDEX (`country_code`);

ALTER TABLE por ADD INDEX (`region_code`);

ALTER TABLE por ADD INDEX (`location_type`);

ALTER TABLE por ADD INDEX (`population`);

ALTER TABLE por ADD INDEX (`elevation`);
-- ALTER TABLE por ADD INDEX (`gtopo30`);

ALTER TABLE por ADD INDEX (`timezone`);

ALTER TABLE por ADD INDEX (`moddate`);


--
-- Index structure for the airport popularity table
--
-- region_code, country, city, airport, airport_code, atmsa, atmsb, atmsc, atmsd
-- tatm, paxa, paxb, paxc, paxd, tpax, frta, frtb, tfrt, mail, tcgo
-- latmsa, latmsb, latmsc, latmsd, ltatm, lpaxa, lpaxb, lpaxc, lpaxd
-- ltpax, lfrta, lfrtb, ltfrt, lmail, ltcgo

ALTER TABLE airport_popularity ADD PRIMARY KEY (`airport_code`);

--
-- Index structure for the airport importance table
--
-- iata_code, location_type, page_rank

ALTER TABLE airport_pageranked ADD PRIMARY KEY (`iata_code`, `location_type`);

