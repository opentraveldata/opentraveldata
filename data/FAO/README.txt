
# See the FAO's web site: http://www.fao.org/countryprofiles/webservices.asp

# Geopolitical data can be downloaded from:
wget http://aims.fao.org/aos/geopolitical.owl
gzip geopolitical.owl

# Country data can be downloaded from:
wget -O country_en.xml http://www.fao.org/countryprofiles/geoinfo/ws/allCountries/EN/
gzip country_en.xml

wget -O country_fr.xml http://www.fao.org/countryprofiles/geoinfo/ws/allCountries/FR/
gzip country_fr.xml

wget -O country_ru.xml http://www.fao.org/countryprofiles/geoinfo/ws/allCountries/RU/
gzip country_ru.xml

wget -O country_zh.xml http://www.fao.org/countryprofiles/geoinfo/ws/allCountries/ZH/
gzip country_zh.xml

wget -O country_ar.xml http://www.fao.org/countryprofiles/geoinfo/ws/allCountries/AR/
gzip country_ar.xml

wget -O country_es.xml http://www.fao.org/countryprofiles/geoinfo/ws/allCountries/ES/
gzip country_es.xml

