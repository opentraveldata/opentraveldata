
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

--
--
--
create temporary table iata_codes
  select g1.geonameid as geonameid, a1.isoLanguage, a1.alternateName as iata_code
  from geoname as g1
  left join alternate_name as a1 on g1.geonameid = a1.geonameid
  where (g1.fcode = 'AIRB' or g1.fcode = 'AIRF' or g1.fcode = 'AIRH'
  		or g1.fcode = 'AIRP' or g1.fcode = 'AIRS' or g1.fcode = 'RSTN')
  		and a1.isoLanguage = 'iata'
		and a1.isHistoric = 0;

alter table iata_codes add index (geonameid);

--
--
--
create temporary table icao_codes
  select g2.geonameid as geonameid, a2.isoLanguage, a2.alternateName as icao_code
  from geoname as g2
  left join alternate_name as a2 on g2.geonameid = a2.geonameid
  where (g2.fcode = 'AIRB' or g2.fcode = 'AIRF' or g2.fcode = 'AIRH'
  		or g2.fcode = 'AIRP' or g2.fcode = 'AIRS' or g2.fcode = 'RSTN')
  		and a2.isoLanguage = 'icao'
		and a2.isHistoric = 0;

-- alter table icao_codes add primary key (geonameid);
alter table icao_codes add index (geonameid);

--
--
--
create temporary table alt_names
  select g3.geonameid as geonameid,
  		 a3.isoLanguage as isoLanguage, a3.alternateName as alt_name
  from geoname as g3
  left join alternate_name as a3 on g3.geonameid = a3.geonameid
  where (g3.fcode = 'AIRB' or g3.fcode = 'AIRF' or g3.fcode = 'AIRH'
  		or g3.fcode = 'AIRP' or g3.fcode = 'AIRS' or g3.fcode = 'RSTN')
  		and (a3.isoLanguage = 'en' or a3.isoLanguage = 'link'
		  or a3.isoLanguage = 'ru' or a3.isoLanguage = 'zh'
		  or a3.isoLanguage = '')
  order by g3.geonameid, a3.isoLanguage, a3.alternateName;

alter table icao_codes add index (geonameid, isoLanguage);

--
--
--
select iata_codes.iata_code, icao_codes.icao_code,
	   g.geonameid, g.name, g.asciiname, g.latitude, g.longitude,
	   g.country, g.cc2, g.fclass, g.fcode,
	   g.admin1, g.admin2, g.admin3, g.admin4,
	   g.population, g.elevation, g.gtopo30,
	   g.timezone, tz.GMT_offset, tz.DST_offset, tz.raw_offset,
	   g.moddate, g.alternatenames,
	   alt_names.isoLanguage as altname_iso, alt_names.alt_name as altname_text
from time_zones as tz,
	 geoname as g
	 left join iata_codes using (geonameid)
	 left join icao_codes using (geonameid)
	 left join alt_names using (geonameid)
where (g.fcode = 'AIRB' or g.fcode = 'AIRF' or g.fcode = 'AIRH'
	  or g.fcode = 'AIRP' or g.fcode = 'AIRS' or g.fcode = 'RSTN')
	  and g.timezone = tz.timeZoneId
order by iata_code, icao_code, g.fcode
;
