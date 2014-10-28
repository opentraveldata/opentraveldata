--
-- @brief SQL script creating the indexes for the Geonames-related tables.
--        See also create_table_geonames.sql in the same directory.
-- @author Denis Arnaud <denis.arnaud_geonames@m4x.org>
--


--
-- Index structure for table `admin1_codes_ascii`
--

ALTER TABLE `admin1_codes_ascii` ADD PRIMARY KEY (`geonameid`);
ALTER TABLE `admin1_codes_ascii` ADD UNIQUE (`ccode`, `code`);


--
-- Index structure for table `admin2_codes`
--

ALTER TABLE `admin2_codes` ADD PRIMARY KEY (`geonameid`);
ALTER TABLE `admin2_codes` ADD UNIQUE (`ccode`, `code1`, `code2`);


--
-- Index structure for table `airport_pageranked`
--
ALTER TABLE `airport_pageranked` ADD PRIMARY KEY (`iata_code`, `location_type`);


--
-- Index structure for table `alternate_name`
--
ALTER TABLE `alternate_name` ADD PRIMARY KEY (`alternatenameId`);
ALTER TABLE `alternate_name` ADD INDEX (`geonameid`);
ALTER TABLE `alternate_name` ADD INDEX (`isoLanguage`);


--
-- Index structure for table `continent_codes`
--

ALTER TABLE `continent_codes` ADD PRIMARY KEY (`code`);


--
-- Index structure for table `country_info`
--

ALTER TABLE `country_info` ADD PRIMARY KEY (`iso_alpha2`);
ALTER TABLE `country_info` ADD UNIQUE (`iso_alpha3`);
ALTER TABLE `country_info` ADD UNIQUE (`iso_numeric`);
ALTER TABLE `country_info` ADD INDEX (`fips_code`);
ALTER TABLE `country_info` ADD UNIQUE (`name`);
ALTER TABLE `country_info` ADD INDEX (`geonameId`);


--
-- Index structure for table `feature_codes`
--

ALTER TABLE `feature_codes` ADD PRIMARY KEY (`code`);
ALTER TABLE `feature_codes` ADD INDEX (`class`);


--
-- Index structure for table `geoname`
--

ALTER TABLE `geoname` ADD PRIMARY KEY (`geonameid`);
ALTER TABLE `geoname` ADD INDEX (`fcode`);
ALTER TABLE `geoname` ADD INDEX (`timezone`);


--
-- Index structure for table `iso_language_codes`
--

ALTER TABLE `iso_language_codes` ADD PRIMARY KEY (`iso_639_3`);


--
-- Index structure for table `time_zones`
--

ALTER TABLE `time_zones` ADD PRIMARY KEY (`timeZoneId`);
ALTER TABLE `time_zones` ADD INDEX (`country`);


--
-- Index structure for table `hierarchy`
--

-- ALTER TABLE `hierarchy` ADD PRIMARY KEY (`parentId`, `childId`);
ALTER TABLE `hierarchy` ADD INDEX (`parentId`, `childId`);


--
-- Index structure for table `zip`
--

ALTER TABLE `zip_codes` ADD INDEX (`iso_alpha2`, `postal_code`);

