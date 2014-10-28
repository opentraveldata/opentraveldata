-- phpMyAdmin SQL Dump
-- version 3.0.1.1
-- http://www.phpmyadmin.net
--
-- Server: localhost
-- Generated: 17/11/2008
-- Version of server: 5.0.51
-- Version of PHP: 5.2.6

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Database: `magicolta`
--

-- --------------------------------------------------------

--
-- Structure of table `ip_to_country`
--

DROP TABLE IF EXISTS `ip_to_country`;
CREATE TABLE IF NOT EXISTS `ip_to_country` (
  `ip_from` int(15) NOT NULL,
  `ip_to` int(15) NOT NULL,
  `registry` varchar(10) collate utf8_unicode_ci default NULL,
  `assigned_date` int(15) NOT NULL,
  `country_code_2` char(2) collate utf8_unicode_ci NOT NULL,
  `country_code_3` varchar(3) collate utf8_unicode_ci,
  `country_name` varchar(30) collate utf8_unicode_ci,
  PRIMARY KEY (`ip_from`),
  UNIQUE KEY `ip_idx` (`ip_from`,`ip_to`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

