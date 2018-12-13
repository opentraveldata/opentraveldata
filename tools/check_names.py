#!/usr/bin/env python
# -*- coding: utf-8 -*-

from neobase import NeoBase


def main():
    g = NeoBase()

    for p in g:
        if not g.get(p, 'name'):
            print ('No name for {0}'.format(p))
        if not g.get(p, 'city_code_list'):
            print ('No city_code_list for {0}'.format(p))
        if not g.get(p, 'city_name_list'):
            print ('{0} with name {1} has city_code_list {2} and city_name_list {3}'.format(
               g.get(p, 'iata_code'),
               g.get(p, 'name'),
               g.get(p, 'city_code_list'),
               g.get(p, 'city_name_list')))


if __name__ == '__main__':
    main()


