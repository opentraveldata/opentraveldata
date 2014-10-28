--
--
--
LOAD DATA LOCAL INFILE 'IpToCountry2.csv' 
INTO TABLE magicolta.ip_to_country 
FIELDS ENCLOSED BY '\"' TERMINATED BY ',';
