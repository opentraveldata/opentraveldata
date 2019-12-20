OpenTravelData (OPTD) - Release of Data Files
=============================================

# Overview
The [original of that documentation file](https://github.com/opentraveldata/opentraveldata/blob/master/ci-scripts/README.md)
is maintained on the
[OpenTravelData (OPTD) project](https://github.com/opentraveldata/opentraveldata),
within the [`ci-scripts` directory](https://github.com/opentraveldata/opentraveldata/blob/master/ci-scripts).

OPTD produces (at least) two kinds of (mainly CSV) data files:

* OPTD CSV data files, typically curated, maintained and hosted on
  [GitHub in the `opentraveldata` folder](https://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/),
  such as [`opentraveldata/optd_por_public_all.csv`](https://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_por_public_all.csv)
  and [`opentraveldata/optd_airlines.csv`](https://github.com/opentraveldata/opentraveldata/blob/master/opentraveldata/optd_airlines.csv)
* Results from the [Quality Assurance (QA)](https://github.com/opentraveldata/quality-assurance)
  [checking/monitoring processes](https://github.com/opentraveldata/quality-assurance/tree/master/checkers)

The deployment/release itself is managed through [Travis CI](https://www.travis-ci.org/opentraveldata/opentraveldata),
specified in the [`.travis.yml` YAML file](https://github.com/opentraveldata/opentraveldata/blob/master/.travis.yml).

## References
* [OpenTravelData (OPTD) organization on GitHub](https://github.com/opentraveldata)
  + [OPTD Data Management](https://github.com/opentraveldata/opentraveldata)
  + [OPTD Quality Assurance (QA)](https://github.com/opentraveldata/quality-assurance)
* Python wrappers/tools
  + [Neobase](https://github.com/alexprengere/neobase) (all-in-one, light, modern version of GeoBases)
  + [GeoBases](http://opentraveldata.github.com/geobases)
* Documentation format online helper tool
  + [Dillinger](https://dillinger.io)


