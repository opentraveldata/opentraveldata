
--
-- Create the 'geo' user, with standard (non-administrator) privileges
--

-- With the GRANT statement, when the user is not already existing
-- it is created.
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, FILE, INDEX, ALTER,
      CREATE TEMPORARY TABLES, CREATE VIEW, EVENT, TRIGGER, SHOW VIEW,
      CREATE ROUTINE, ALTER ROUTINE, EXECUTE ON *.*
      TO 'geo'@'localhost' IDENTIFIED BY 'geo';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, FILE, INDEX, ALTER,
      CREATE TEMPORARY TABLES, CREATE VIEW, EVENT, TRIGGER, SHOW VIEW,
      CREATE ROUTINE, ALTER ROUTINE, EXECUTE ON *.*
      TO 'geo'@'%' IDENTIFIED BY 'geo';

flush privileges;

