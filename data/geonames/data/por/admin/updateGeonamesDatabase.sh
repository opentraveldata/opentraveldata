#!/bin/bash
# Script got from: http://forum.geonames.org/gforum/posts/list/15/732.page

for i in 'AD' 'AE' 'AF' 'AG' 'AI' 'AL' 'AM' 'AN' 'AO' 'AQ' 'AR' 'AS' 'AT' 'AU' 'AW' 'AZ' 'BA' 'BB' 'BD' 'BE' 'BF' 'BG' 'BH' 'BI' 'BJ' 'BL' 'BM' 'BN' 'BO' 'BR' 'BS' 'BT' 'BV' 'BW' 'BY' 'BZ' 'CA' 'CC' 'CD' 'CF' 'CG' 'CH' 'CI' 'CK' 'CL' 'CM' 'CN' 'CO' 'CR' 'CU' 'CV' 'CX' 'CY' 'CZ' 'DE' 'DJ' 'DK' 'DM' 'DO' 'DZ' 'EC' 'EE' 'EG' 'EH' 'ER' 'ES' 'ET' 'FI' 'FJ' 'FK' 'FM' 'FO' 'FR' 'GA' 'GB' 'GD' 'GE' 'GF' 'GG' 'GH' 'GI' 'GL' 'GM' 'GN' 'GP' 'GQ' 'GR' 'GS' 'GT' 'GU' 'GW' 'GY' 'HK' 'HM' 'HN' 'HR' 'HT' 'HU' 'ID' 'IE' 'IL' 'IM' 'IN' 'IO' 'IQ' 'IR' 'IS' 'IT' 'JE' 'JM' 'JO' 'JP' 'KE' 'KG' 'KH' 'KI' 'KM' 'KN' 'KP' 'KR' 'KW' 'KY' 'KZ' 'LA' 'LB' 'LC' 'LI' 'LK' 'LR' 'LS' 'LT' 'LU' 'LV' 'LY' 'MA' 'MC' 'MD' 'ME' 'MF' 'MG' 'MH' 'MK' 'ML' 'MM' 'MN' 'MO' 'MP' 'MQ' 'MR' 'MS' 'MT' 'MU' 'MV' 'MW' 'MX' 'MY' 'MZ' 'NA' 'NC' 'NE' 'NF' 'NG' 'NI' 'NL' 'NO' 'NP' 'NR' 'NU' 'NZ' 'OM' 'PA' 'PE' 'PF' 'PG' 'PH' 'PK' 'PL' 'PM' 'PN' 'PR' 'PS' 'PT' 'PW' 'PY' 'QA' 'RE' 'RO' 'RS' 'RU' 'RW' 'SA' 'SB' 'SC' 'SD' 'SE' 'SG' 'SH' 'SI' 'SJ' 'SK' 'SL' 'SM' 'SN' 'SO' 'SR' 'ST' 'SV' 'SY' 'SZ' 'TC' 'TD' 'TF' 'TG' 'TH' 'TJ' 'TK' 'TL' 'TM' 'TN' 'TO' 'TR' 'TT' 'TV' 'TW' 'TZ' 'UA' 'UG' 'UM' 'US' 'UY' 'UZ' 'VA' 'VC' 'VE' 'VG' 'VI' 'VN' 'VU' 'WF' 'WS' 'YE' 'YT' 'ZA' 'ZM' 'ZW'
do
	fl=`wget -r http://download.geonames.org/export/dump/$i.zip`

if [ "$?" = "0" ];
then
	unzip -o /home/user/Desktop/geonames.script/download.geonames.org/export/dump/$i.zip
	mysql --user mysqldbuser --password=mysqlpassword -e "USE denbg_geonames;
CREATE TABLE IF NOT EXISTS $i (
intID int(11) unsigned NOT NULL AUTO_INCREMENT,
strName varchar(200) COLLATE utf8_unicode_ci NOT NULL,
strAsciiName varchar(200) COLLATE utf8_unicode_ci NOT NULL,
strAlternateNames varchar(4000) COLLATE utf8_unicode_ci NOT NULL,
fltLatitude float NOT NULL,
fltLongitude float NOT NULL,
strFeatureClass char(1) COLLATE utf8_unicode_ci NOT NULL,
strFeatureCode varchar(10) COLLATE utf8_unicode_ci NOT NULL,
strCountryCode varchar(2) COLLATE utf8_unicode_ci NOT NULL,
strCC2 varchar(60) COLLATE utf8_unicode_ci NOT NULL,
strAdmin1Code varchar(20) COLLATE utf8_unicode_ci NOT NULL,
strAdmin2Code varchar(80) COLLATE utf8_unicode_ci NOT NULL,
strAdmin3Code varchar(20) COLLATE utf8_unicode_ci NOT NULL,
strAdmin4Code varchar(20) COLLATE utf8_unicode_ci NOT NULL,
intPopulation int(11) NOT NULL,
intElevation int(11) NOT NULL,
intGtopo30 int(11) NOT NULL,
strTimeZone varchar(100) COLLATE utf8_unicode_ci NOT NULL,
dtaModification date NOT NULL,
PRIMARY KEY (intID),
KEY intID (intID,strFeatureClass,strFeatureCode,strCountryCode),
KEY intPopulation (intPopulation),
FULLTEXT KEY strAlternateNames (strName,strAsciiName,strAlternateNames)
) DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
TRUNCATE TABLE $i;
LOAD DATA INFILE '/home/user/Desktop/geonames.script/$i.txt' INTO TABLE $i (intID,strName,strAsciiName,strAlternateNames,fltLatitude,fltLongitude,strFeatureClass,strFeatureCode,strCountryCode,strCC2,strAdmin1Code,strAdmin2Code,strAdmin3Code,strAdmin4Code,intPopulation,intElevation,intGtopo30,strTimeZone,dtaModification);
INSERT INTO denbg_denbg.geonames (intID,strName,strAsciiName,strAlternateNames,fltLatitude,fltLongitude,strFeatureClass,strFeatureCode,strCountryCode,strCC2,strAdmin1Code,strAdmin2Code,strAdmin3Code,strAdmin4Code,intPopulation,intElevation,intGtopo30,strTimeZone,dtaModification) SELECT * FROM denbg_geonames.bg ON DUPLICATE KEY UPDATE strName=VALUES(strName),strAsciiName=VALUES(strAsciiName),strAlternateNames=VALUES(strAlternateNames),fltLatitude=VALUES(fltLatitude),fltLongitude=VALUES(fltLongitude),strFeatureClass=VALUES(strFeatureClass),strFeatureCode=VALUES(strFeatureCode),strCountryCode=VALUES(strCountryCode),strCC2=VALUES(strCC2),strAdmin1Code=VALUES(strAdmin1Code),strAdmin2Code=VALUES(strAdmin2Code),strAdmin3Code=VALUES(strAdmin3Code),strAdmin4Code=VALUES(strAdmin4Code),intPopulation=VALUES(intPopulation),intElevation=VALUES(intElevation),intGtopo30=VALUES(intGtopo30),strTimeZone=VALUES(strTimeZone),dtaModification=VALUES(dtaModification);"
else
	echo "geonames aborted."
fi
done

