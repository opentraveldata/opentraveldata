set -e

TODAY=$(date +%Y%m%d)
echo "Processing ${TODAY} ..."

./getDataFromGeonamesWebsite.sh
./aggregateGeonamesPor.sh
./extract_por_from_geonames.sh
./extract_por_from_geonames.sh --clean
cp -f por_intorg_${TODAY}.csv dump_from_geonames.csv

# For pageranks
./make_optd_ref_pr_and_freq.py

# For airlines
./make_optd_airline_public.py

# For POR
./make_optd_por_public.sh
./make_optd_por_public.sh --clean
./extract_por_unlc.sh
