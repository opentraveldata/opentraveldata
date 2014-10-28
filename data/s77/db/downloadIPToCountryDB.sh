#!/bin/sh

# Free GeoIP database and service:
# Software77
# 1. Portal: http://software77.net/geo-ip/
# 2. Database FAQ: http://software77.net/faq.html#automated
# 3. C source code: http://software77.net/geo/IP-Country.zip

# Load automatically the (software77) GeoIP database
LOCAL_DB_DIR=/data/geoip/db
cd ${LOCAL_DB_DIR}
GEO_DB_ROOT_NAME="IpToCountry"
GEO_DB_NAME_SUFFIX=".csv"
GEO_DB_NAME=${GEO_DB_ROOT_NAME}${GEO_DB_NAME_SUFFIX}
ZIP_SUFFIX=".gz"
rm -f ${GEO_DB_NAME}${ZIP_SUFFIX}
wget http://software77.net/geo-ip?DL=1 -O ${GEO_DB_NAME}${ZIP_SUFFIX}
cd -

