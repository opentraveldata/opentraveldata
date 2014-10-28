
--
-- Extract information from the Geonames tables (in particular, geoname and
-- alternate_name), for all the transport-related points of reference (POR,
-- i.e., mainly airports, airbases, airfields, heliports).
--
-- Two intermediary tables are generated, namely iata_codes and icao_codes,
-- which contain the geoname ID, code type (IATA, resp. ICAO) and
-- IATA (resp. ICAO) code.
-- Those two temporary tables are then joined with the 'geoname' table,
-- which contains all the details for those given points of reference (POR).
--
-- It may appear not so simple to have such an intermediary step. That is
-- because some airports/heliports do not have IATA and/or ICAO code at all.
-- For those cases, the corresponding field will be NULL in the output (stdout).
--
-- Note: the cities (g1.fcode like 'PPL%') and administrative divisions
-- (g1.fcode like 'ADM%') are extracted in another SQL script.
--
-- Feature code:
-- AIRB: Air base; AIRF: Air field; AIRH: Heliport; AIRP: Airport; 
-- AIRQ: Abandoned air field; AIRS: Seaplane landing field
-- RSTN: Railway station
--


select iata_codes.alternateName as iata_code, icao_codes.alternateName as icao_code,
	   g.geonameid, g.name, g.asciiname, g.latitude, g.longitude,
	   g.country, g.cc2, g.fclass, g.fcode,
	   g.admin1, g.admin2, g.admin3, g.admin4,
	   g.population, g.elevation, g.gtopo30,
	   g.timezone, tz.GMT_offset, tz.DST_offset, tz.raw_offset,
	   g.moddate, g.alternatenames,
	   alt_names.isoLanguage as altname_iso, alt_names.alternateName as altname_text
from time_zones as tz, geoname as g
	 left join alternate_name as iata_codes using (geonameid)
	 left join alternate_name as icao_codes using (geonameid)
	 left join alternate_name as alt_names using (geonameid)
where (g.fcode = 'AIRB' or g.fcode = 'AIRF' or g.fcode = 'AIRH'
	   or g.fcode = 'AIRP' or g.fcode = 'AIRS' or g.fcode = 'RSTN')
	  and g.timezone = tz.timeZoneId
	  and ((iata_codes.isoLanguage = 'iata' and iata_codes.isHistoric = 0)
	  	   or iata_codes.geonameid is NULL)
	  and ((icao_codes.isoLanguage = 'icao' and icao_codes.isHistoric = 0)
	  	   or icao_codes.geonameid is NULL)
order by iata_code, icao_code, g.fcode
;

--	  and (alt_names.isoLanguage = 'en' or alt_names.isoLanguage = 'link'
--	  	  or alt_names.isoLanguage = 'ru' or alt_names.isoLanguage = 'zh'
--		  or alt_names.isoLanguage = '' or alt_names.geonameid is NULL)
