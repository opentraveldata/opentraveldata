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
-- Database: `geo_geonames`
--

-- --------------------------------------------------------

--
-- Structure of table `dic_cities`
--

DROP TABLE IF EXISTS `dic_cities`;
CREATE TABLE IF NOT EXISTS `dic_cities` (
  `language_code` char(2) collate utf8_unicode_ci NOT NULL,
  `city_code` char(3) collate utf8_unicode_ci NOT NULL,
  `city_name` varchar(255) collate utf8_unicode_ci NOT NULL,
  `other_names` varchar(255) collate utf8_unicode_ci default NULL,
  PRIMARY KEY  (`language_code`,`city_code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

