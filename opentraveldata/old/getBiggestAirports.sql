--
--
--
(select (airpop.tpax)/1000 as 'popularity', 
		places.code as 'airport_code', places.code as 'city_code', 
		places.longitude as 'longitude', places.latitude  as 'latitude'
from airport_popularity AS airpop, ref_place_details AS places
WHERE airpop.airport_code = places.code
	  AND places.is_city = 'y')
UNION
(select (airpop.tpax)/1000 AS 'popularity',
		places.code as 'airport_code', places.city_code as 'city_code',
		places.longitude as 'longitude', places.latitude  as 'latitude'
from airport_popularity AS airpop, ref_place_details AS places
WHERE airpop.airport_code = places.code
	  AND places.is_city = 'n')
ORDER BY popularity DESC
;
