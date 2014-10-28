
--
-- Extract airport and city information from the Geonames tables (in particular,
-- geoname and alternate_name)
--

select g.geonameid, g.name, g.asciiname, g.latitude, g.longitude,
	   g.country, g.cc2, g.fclass, g.fcode,
	   g.admin1, g.admin2, g.admin3, g.admin4,
	   g.population, g.elevation, g.gtopo30,
	   g.timezone, tz.GMT_offset, tz.DST_offset, tz.raw_offset,
	   g.moddate, g.alternatenames
from time_zones as tz, geoname as g
where (g.fcode = 'PPLA' or g.fcode = 'PPLA2' or g.fcode = 'PPLA3'
	  or g.fcode = 'PPLA4' or g.fcode = 'PPLC' or g.fcode = 'PPLG')
	  and g.timezone = tz.timeZoneId
;
-- where fcode = 'PPL';
