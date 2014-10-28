# usps_states_list.sql
#
# This will create and then populate a MySQL table with a list of the names and
# USPS abbreviations for US states and possessions in existence as of the date 
# below.
#
# Usage:
#    mysql -u username -ppassword database_name < usps_states_list.sql
#
# For updates to this file, see http://27.org/isocountrylist/
# For more about USPS state abbreviations, see http://www.usps.com/ncsc/lookups/usps_abbreviations.html
#
# Wm. Rhodes <iso_country_list@27.org>
# 1/1/03
#

CREATE TABLE IF NOT EXISTS states (
  id INT NOT NULL auto_increment,
  name CHAR(40) NOT NULL,
  abbrev CHAR(2) NOT NULL,
  PRIMARY KEY (id)
);

INSERT INTO states VALUES (NULL, 'Alaska', 'AK');
INSERT INTO states VALUES (NULL, 'Alabama', 'AL');
INSERT INTO states VALUES (NULL, 'American Samoa', 'AS');
INSERT INTO states VALUES (NULL, 'Arizona', 'AZ');
INSERT INTO states VALUES (NULL, 'Arkansas', 'AR');
INSERT INTO states VALUES (NULL, 'California', 'CA');
INSERT INTO states VALUES (NULL, 'Colorado', 'CO');
INSERT INTO states VALUES (NULL, 'Connecticut', 'CT');
INSERT INTO states VALUES (NULL, 'Delaware', 'DE');
INSERT INTO states VALUES (NULL, 'District of Columbia', 'DC');
INSERT INTO states VALUES (NULL, 'Federated States of Micronesia', 'FM');
INSERT INTO states VALUES (NULL, 'Florida', 'FL');
INSERT INTO states VALUES (NULL, 'Georgia', 'GA');
INSERT INTO states VALUES (NULL, 'Guam', 'GU');
INSERT INTO states VALUES (NULL, 'Hawaii', 'HI');
INSERT INTO states VALUES (NULL, 'Idaho', 'ID');
INSERT INTO states VALUES (NULL, 'Illinois', 'IL');
INSERT INTO states VALUES (NULL, 'Indiana', 'IN');
INSERT INTO states VALUES (NULL, 'Iowa', 'IA');
INSERT INTO states VALUES (NULL, 'Kansas', 'KS');
INSERT INTO states VALUES (NULL, 'Kentucky', 'KY');
INSERT INTO states VALUES (NULL, 'Louisiana', 'LA');
INSERT INTO states VALUES (NULL, 'Maine', 'ME');
INSERT INTO states VALUES (NULL, 'Marshall Islands', 'MH');
INSERT INTO states VALUES (NULL, 'Maryland', 'MD');
INSERT INTO states VALUES (NULL, 'Massachusetts', 'MA');
INSERT INTO states VALUES (NULL, 'Michigan', 'MI');
INSERT INTO states VALUES (NULL, 'Minnesota', 'MN');
INSERT INTO states VALUES (NULL, 'Mississippi', 'MS');
INSERT INTO states VALUES (NULL, 'Missouri', 'MO');
INSERT INTO states VALUES (NULL, 'Montana', 'MT');
INSERT INTO states VALUES (NULL, 'Nebraska', 'NE');
INSERT INTO states VALUES (NULL, 'Nevada', 'NV');
INSERT INTO states VALUES (NULL, 'New Hampshire', 'NH');
INSERT INTO states VALUES (NULL, 'New Jersey', 'NJ');
INSERT INTO states VALUES (NULL, 'New Mexico', 'NM');
INSERT INTO states VALUES (NULL, 'New York', 'NY');
INSERT INTO states VALUES (NULL, 'North Carolina', 'NC');
INSERT INTO states VALUES (NULL, 'North Dakota', 'ND');
INSERT INTO states VALUES (NULL, 'Northern Mariana Islands', 'MP');
INSERT INTO states VALUES (NULL, 'Ohio', 'OH');
INSERT INTO states VALUES (NULL, 'Oklahoma', 'OK');
INSERT INTO states VALUES (NULL, 'Oregon', 'OR');
INSERT INTO states VALUES (NULL, 'Palau', 'PW');
INSERT INTO states VALUES (NULL, 'Pennsylvania', 'PA');
INSERT INTO states VALUES (NULL, 'Puerto Rico', 'PR');
INSERT INTO states VALUES (NULL, 'Rhode Island', 'RI');
INSERT INTO states VALUES (NULL, 'South Carolina', 'SC');
INSERT INTO states VALUES (NULL, 'South Dakota', 'SD');
INSERT INTO states VALUES (NULL, 'Tennessee', 'TN');
INSERT INTO states VALUES (NULL, 'Texas', 'TX');
INSERT INTO states VALUES (NULL, 'Utah', 'UT');
INSERT INTO states VALUES (NULL, 'Vermont', 'VT');
INSERT INTO states VALUES (NULL, 'Virgin Islands', 'VI');
INSERT INTO states VALUES (NULL, 'Virginia', 'VA');
INSERT INTO states VALUES (NULL, 'Washington', 'WA');
INSERT INTO states VALUES (NULL, 'West Virginia', 'WV');
INSERT INTO states VALUES (NULL, 'Wisconsin', 'WI');
INSERT INTO states VALUES (NULL, 'Wyoming', 'WY');
INSERT INTO states VALUES (NULL, 'Armed Forces Africa', 'AE');
INSERT INTO states VALUES (NULL, 'Armed Forces Americas (except Canada)', 'AA');
INSERT INTO states VALUES (NULL, 'Armed Forces Canada', 'AE');
INSERT INTO states VALUES (NULL, 'Armed Forces Europe', 'AE');
INSERT INTO states VALUES (NULL, 'Armed Forces Middle East', 'AE');
INSERT INTO states VALUES (NULL, 'Armed Forces Pacific', 'AP');

