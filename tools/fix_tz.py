#!/usr/bin/env python
# -*- coding: utf-8 -*-

from neobase import NeoBase
import pytz


def pors_with_unk_tz(db_oripor):
    for p in db_oripor:
        p_tz = db_oripor.get(p, 'timezone')
        p_iata = db_oripor.get(p, 'iata_code')
        p_geocode = db_oripor.get_location(p)
        try:
            p_city = db_oripor.get(p, 'city_name_list')[0]
        except IndexError:
            p_city = None
        try:
            pytz.timezone(p_tz)
        except pytz.exceptions.UnknownTimeZoneError:
            yield p, p_tz, p_iata, p_city, p_geocode


def main():
    db_oripor = NeoBase()

    with open('tz_fixes.csv', 'w') as out:
        for p, p_tz, p_iata, p_city, p_geocode in pors_with_unk_tz(db_oripor):
            if p_geocode is None:
                print ('! Could not find geocode for {0}'.format(p))
                continue
            # Closest match in GeoNames
            dist, id_ = db_oripor.findClosestFromPoint(p_geocode).next()
            g_city = db_oripor.get(id_, 'name')
            g_tz = db_oripor.get(id_, 'timezone')

            out.write('{0},{1},{2},{3:.2f}\n'.format(p_iata, p_tz, g_tz, dist))

            print ('{0} with tz "{1}" matches tz "{2}" '
                   '(dist {3:.1f}km, "{4}" -> "{5}")'.format(
                    p_iata, p_tz, g_tz, dist, p_city, g_city))


if __name__ == '__main__':
    main()


