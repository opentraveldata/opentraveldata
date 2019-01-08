
# References
* [`tz` database on Wikipedia](https://en.wikipedia.org/wiki/Tz_database)
* [Official IANA web site](https://www.iana.org/time-zones)

# Getting the data
```bash
$ wget https://data.iana.org/time-zones/releases/tzdata2018i.tar.gz
$ tar zxf tzdata2018i.tar.gz && rm -f tzdata2018i.tar.gz
```

# Extracting the time-zones of a given country
```bash
$ grep "^KZ" zone.tab 
KZ      +4315+07657     Asia/Almaty     Kazakhstan (most areas)
KZ      +4448+06528     Asia/Qyzylorda  Qyzylorda/Kyzylorda/Kzyl-Orda
KZ      +5312+06337     Asia/Qostanay   Qostanay/Kostanay/Kustanay
KZ      +5017+05710     Asia/Aqtobe     Aqtobe/Aktobe
KZ      +4431+05016     Asia/Aqtau      Mangghystau/Mankistau
KZ      +4707+05156     Asia/Atyrau     Atyrau/Atirau/Gur'yev
KZ      +5113+05121     Asia/Oral       West Kazakhstan
```


