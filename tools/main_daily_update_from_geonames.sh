set -e

TODAY=$(date +%Y%m%d)
echo "Processing ${TODAY} ..."

./getDataFromGeonamesWebsite.sh
./aggregateGeonamesPor.sh
./extract_por_from_geonames.sh
./extract_por_from_geonames.sh --clean
cp -f por_intorg_${TODAY}.csv dump_from_geonames.csv
./make_optd_por_public.sh
./make_optd_por_public.sh --clean
./extract_por_unlc.sh
