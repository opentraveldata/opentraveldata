--
-- Table structure for table `airport_popularity`
--
DROP TABLE IF EXISTS `airport_popularity`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `airport_popularity` (
  `region_code` char(3) NOT NULL,
  `country` varchar(20) NOT NULL,
  `city` varchar(40) NOT NULL,
  `airport` varchar(40) NOT NULL,
  `airport_code` char(3) NOT NULL,
  `atmsa` int(8) NULL,
  `atmsb` int(8) NULL,
  `atmsc` int(8) NULL,
  `atmsd` int(8) NULL,
  `tatm` int(8) NULL,
  `paxa` int(8) NULL,
  `paxb` int(8) NULL,
  `paxc` int(8) NULL,
  `paxd` int(8) NULL,
  `tpax` int(8) NULL,
  `frta` int(8) NULL,
  `frtb` int(8) NULL,
  `tfrt` int(8) NULL,
  `mail` int(8) NULL,
  `tcgo` int(8) NULL,
  `latmsa` int(8) NULL,
  `latmsb` int(8) NULL,
  `latmsc` int(8) NULL,
  `latmsd` int(8) NULL,
  `ltatm` int(8) NULL,
  `lpaxa` int(8) NULL,
  `lpaxb` int(8) NULL,
  `lpaxc` int(8) NULL,
  `lpaxd` int(8) NULL,
  `ltpax` int(8) NULL,
  `lfrta` int(8) NULL,
  `lfrtb` int(8) NULL,
  `ltfrt` int(8) NULL,
  `lmail` int(8) NULL,
  `ltcgo` int(8) NULL,
  PRIMARY KEY (`airport_code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client;
