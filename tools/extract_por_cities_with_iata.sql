
--
-- Extract information from the Geonames tables (in particular, geoname and
-- alternate_name), for all the populated places (i.e., cities) and
-- administrative divisions (e.g., municipalities) having got a IATA code
-- (e.g., 'LON' for London, UK, 'PAR' for Paris, France and
-- 'SFO' for San Francisco, CA, USA).
--

select a.alternateName as iata_code, 'NULL',
	   g.geonameid, g.name, g.asciiname,
	   FN_STRIP_TRAILING_ZER0 (g.latitude) as latitude,
	   FN_STRIP_TRAILING_ZER0 (g.longitude) as longitude,
	   g.country, g.cc2, g.fclass, g.fcode,
	   g.admin1, g.admin2, g.admin3, g.admin4,
	   g.population, IF (g.elevation=0, '', g.elevation) as elevation, g.gtopo30,
	   g.timezone, tz.GMT_offset, tz.DST_offset, tz.raw_offset,
	   g.moddate, g.alternatenames
from time_zones as tz, geoname as g

left join alternate_name as a on g.geonameid = a.geonameid

where (g.fcode like 'PPL%' or g.fcode like 'ADM%')
	  and a.isoLanguage = 'iata'
	  and a.isHistoric = 0
	  and g.timezone = tz.timeZoneId

order by iata_code, g.fcode
;


--
-- ===================================================================
--
-- Note: the following SQL request is syntactically correct. However,
--       it can run for hours on a good CPU (e.g., Athlon X6).
--       So, do not try it at home...
--

-- select a.alternateName as iata_code, 'NULL',
-- 	   g.geonameid, g.name, g.asciiname, g.latitude, g.longitude,
-- 	   g.country, g.cc2, g.fclass, g.fcode,
-- 	   g.admin1, g.admin2, g.admin3, g.admin4,
-- 	   g.population, g.elevation, g.gtopo30,
-- 	   g.timezone, tz.GMT_offset, tz.DST_offset, tz.raw_offset,
-- 	   g.moddate, g.alternatenames,
-- 	   alt_names.isoLanguage as altname_iso,
-- 	   alt_names.alternateName as altname_text
-- from time_zones as tz, geoname as g
-- 
-- left join alternate_name as a on g.geonameid = a.geonameid
-- 
-- left join (
--   select g1.geonameid, a1.isoLanguage, a1.alternateName
--   from geoname as g1
--   left join alternate_name as a1 on g1.geonameid = a1.geonameid
--   where (g1.fcode like 'PPL%' or g1.fcode like 'ADM%')
--   		and (a1.isoLanguage = 'en' or a1.isoLanguage = 'link'
-- 		  or a1.isoLanguage = 'ru' or a1.isoLanguage = 'zh'
-- 		  or a1.isoLanguage = '')
--   order by g1.geonameid, a1.isoLanguage, a1.alternateName
-- ) as alt_names on alt_names.geonameid = g.geonameid
-- 
-- where (g.fcode like 'PPL%' or g.fcode like 'ADM%')
-- 	  and a.isoLanguage = 'iata'
-- 	  and a.isHistoric = 0
-- 	  and g.timezone = tz.timeZoneId
-- 
-- order by iata_code, g.fcode
-- ;

