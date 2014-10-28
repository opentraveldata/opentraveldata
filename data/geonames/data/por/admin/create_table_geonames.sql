-- MySQL dump 10.11
--
-- Host: localhost    Database: geonames
-- ------------------------------------------------------
-- Server version	5.5.18

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admin1_codes_ascii`
--

DROP TABLE IF EXISTS `admin1_codes_ascii`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `admin1_codes_ascii` (
  `ccode` char(2) NOT NULL,
  `code` varchar(7) NOT NULL,
  `name` text NOT NULL,
  `nameAscii` text default NULL,
  `geonameid` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;


--
-- Table structure for table `admin2_codes`
--

DROP TABLE IF EXISTS `admin2_codes`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `admin2_codes` (
  `ccode` char(2) NOT NULL,
  `code1` varchar(7) default NULL,
  `code2` varchar(100) NOT NULL,
  `name_local` text default NULL,
  `name` text NOT NULL,
  `geonameid` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;


--
-- Table structure for table `airports_pageranked`
--

DROP TABLE IF EXISTS `airport_pageranked`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `airport_pageranked` (
 iata_code char(3) NOT NULL,
 location_type varchar(4) default NULL,
 page_rank decimal(15,12) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;


--
-- Table structure for table `alternate_name`
--

DROP TABLE IF EXISTS `alternate_name`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `alternate_name` (
  `alternatenameId` int(11) NOT NULL,
  `geonameid` int(11) default NULL,
  `isoLanguage` varchar(7) default NULL,
  `alternateName` varchar(200) default NULL,
  `isPreferredName` tinyint(1) default NULL,
  `isShortName` tinyint(1) default NULL,
  `isColloquial` tinyint(1) default NULL,
  `isHistoric` tinyint(1) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;


--
-- Table structure for table `continent_codes`
--

DROP TABLE IF EXISTS `continent_codes`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `continent_codes` (
  `code` char(2) NOT NULL,
  `name` varchar(20) default NULL,
  `geonameid` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;


--
-- Table structure for table `country_info`
--

DROP TABLE IF EXISTS `country_info`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `country_info` (
  `iso_alpha2` char(2) default NULL,
  `iso_alpha3` char(3) default NULL,
  `iso_numeric` int(11) default NULL,
  `fips_code` varchar(3) default NULL,
  `name` varchar(200) default NULL,
  `capital` varchar(200) default NULL,
  `areainsqkm` bigint(20) default NULL,
  `population` int(11) default NULL,
  `continent` char(2) default NULL,
  `tld` varchar(4) default NULL,
  `currency_code` char(3) default NULL,
  `currency_name` varchar(32) default NULL,
  `phone` varchar(16) default NULL,
  `postal_code_format` varchar(64) default NULL,
  `postal_code_regex` varchar(256) default NULL,
  `languages` varchar(200) default NULL,
  `geonameId` int(11) default NULL,
  `neighbours` varchar(64) default NULL,
  `equivalent_fips_code` varchar(3) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;


--
-- Table structure for table `feature_classes`
--

DROP TABLE IF EXISTS `feature_classes`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `feature_classes` (
  `class` char(1) NOT NULL,
  `names` varchar(200) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;


--
-- Table structure for table `feature_codes`
--

DROP TABLE IF EXISTS `feature_codes`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `feature_codes` (
  `class` char(1) NOT NULL,
  `code` varchar(5) NOT NULL,
  `name_en` varchar(200) default NULL,
  `description_en` text default NULL,
  `name_ru` varchar(200) default NULL,
  `description_ru` text default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;


--
-- Table structure for table `geoname`
--

DROP TABLE IF EXISTS `geoname`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `geoname` (
  `geonameid` int(11) NOT NULL,
  `name` varchar(200) default NULL,
  `asciiname` varchar(200) default NULL,
  `alternatenames` varchar(4000) default NULL,
  `latitude` decimal(10,7) default NULL,
  `longitude` decimal(10,7) default NULL,
  `fclass` char(1) default NULL,
  `fcode` varchar(10) default NULL,
  `country` varchar(2) default NULL,
  `cc2` varchar(60) default NULL,
  `admin1` varchar(20) default NULL,
  `admin2` varchar(80) default NULL,
  `admin3` varchar(20) default NULL,
  `admin4` varchar(20) default NULL,
  `population` int(11) default NULL,
  `elevation` int(11) default NULL,
  `gtopo30` int(11) default NULL,
  `timezone` varchar(40) default NULL,
  `moddate` date default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;


--
-- Table structure for table `hierarchy`
--

DROP TABLE IF EXISTS `hierarchy`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE hierarchy (
  `parentId` int(11) NOT NULL,
  `childId` int(11) NOT NULL,
  `relationType` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET utf8;
SET character_set_client = @saved_cs_client;


--
-- Table structure for table `iso_language_codes`
--

DROP TABLE IF EXISTS `iso_language_codes`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `iso_language_codes` (
  `iso_639_3` char(4) default NULL,
  `iso_639_2` varchar(50) default NULL,
  `iso_639_1` varchar(50) default NULL,
  `language_name` varchar(200) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;


--
-- Table structure for table `time_zones`
--

DROP TABLE IF EXISTS `time_zones`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `time_zones` (
  `country` varchar(2) default NULL,
  `timeZoneId` varchar(200) default NULL,
  `GMT_offset` decimal(3,1) default NULL,
  `DST_offset` decimal(3,1) default NULL,
  `raw_offset` decimal(3,1) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;


--
-- Table structure for table `zip_codes`
--

DROP TABLE IF EXISTS `zip_codes`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `zip_codes` (
  `iso_alpha2` char(2) default NULL,
  `postal_code` varchar(10) default NULL,
  `place_name` varchar(200) default NULL,
  `admin_name1` varchar(100) default NULL,
  `admin_code1` varchar(20) default NULL,
  `admin_name2` varchar(100) default NULL,
  `admin_code2` varchar(20) default NULL,
  `admin_name3` varchar(100) default NULL,
  `latitude` decimal(10,7) default NULL,
  `longitude` decimal(10,7) default NULL,
  `accuracy` int(1) default NULL
) DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;


--
-- Function to display decimal numbers without trailing zeros
--


SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
DELIMITER $$
USE `geo_geonames`$$

DROP FUNCTION IF EXISTS `FN_STRIP_TRAILING_ZER0`$$

CREATE DEFINER=`geo`@`%` FUNCTION `FN_STRIP_TRAILING_ZER0`(tNumber DECIMAL(10,7)) RETURNS VARCHAR(20) CHARSET utf8

BEGIN
     DECLARE strBuff VARCHAR(20);
     DECLARE cnt  NUMERIC(2);
     DECLARE tString VARCHAR(20);
     SELECT CAST(tNumber AS CHAR) INTO tString;
     SELECT LOCATE('.',tString) INTO cnt;
     IF cnt > 0 THEN
         SELECT TRIM(TRAILING '.' FROM TRIM(TRAILING '0' FROM tString)) INTO strBuff;   
     ELSE
        SET strBuff = tString;
     END IF;
     RETURN strBuff;

END$$
DELIMITER ;
SET character_set_client = @saved_cs_client;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2009-02-09  0:52:34
