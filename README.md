[![Build Status](https://travis-ci.org/opentraveldata/opentraveldata.svg?branch=master)](https://travis-ci.org/opentraveldata/opentraveldata)

# Overview
Open Travel Data (OPTD) provides a collection of trasnport, travel and leisure
related data. The project makes extensive use of already existing data sources
such as Geonames and Wikipedia, and adds some glue around those (e.g. links).
All data sets are carefully maintained and kept up-to-date by the OPTD
team.

# Usage
All OPDT curated and maintained data sets are located in the
[``opentraveldata`` directory](https://github.com/opentraveldata/opentraveldata/tree/master/opentraveldata).
Flat files are used with hat (^) separated columns,
so that it should be easy to use with your own tools of choice.
Some usage examples can be found in the [``examples`` directory](https://github.com/opentraveldata/opentraveldata/tree/master/examples).

* The [``tools``](https://github.com/opentraveldata/opentraveldata/tree/master/tools)
  and [``data``](https://github.com/opentraveldata/opentraveldata/tree/master/data)
  directories contain scripts and collected data, which are used to generate
  the data sets.
* [``.travis``](https://github.com/opentraveldata/opentraveldata/tree/master/.travis)
  contains continuous integration (CI) related code.

# GeoBases
[GeoBases](http://opentraveldata.github.io/geobases/) is a good addition to OPTD,
offering easy-to-use data manipulation and visualization Python-based tools
and API, on top of OPTD curated data files.

# OpenTREP
[OpenTREP](http://github.com/trep/opentrep) is a C++-based transport related
full-text search library, with Python bindings, powering the
[Travel Search application](http://search-travel.org). The full stack of that
Web application is open, from the data sources up to the front-end source code,
through the back-end Python and C++ libraries. So, do not hesitate to contribute,
for instance just for the fun of it.

# Data Quality
An independent
[Service Delivery Quality (SDQ) project](http://github.com/service-delivery-quality/quality-assurance/tree/master/samples/opentraveldata)
aims at monitoring the quality of data provide by OPTD. There is still some work
to be done in order to automate most of the steps, though.

# Legacy
This is the master repository of the Open Travel Data (OPTD) project.
For backwards compatability reasons, all changes are synced back to the
[old repository](https://github.com/opentraveldata/optd).

# Contributions
Any contribution or feedback is welcome!
Please do not hesitate
[to open an issue request](http://github.com/opentraveldata/opentraveldata/issues/new)
or
[to suggest enhancement through pull request (PR)](http://github.com/opentraveldata/opentraveldata/compare)!
If you notice something missing, like
[Laudamotion airline (OE)](http://github.com/opentraveldata/opentraveldata/issues/93)
at some point, you can just step up, and we will try to fix what is wrong.
You can also become a regular contributor, just create a GitHub account and
we will enlist you right away! That is the surest way for you to know that you
will always be best served (by yourself) and receive our infinite gratefulness.

OpenTravelData aims at being useful to the human kind, no more, no less.
Anyone is welcome to contribute to make our world a better place.
Knowledge is key, essential to preserve our freedom. We are happy that you read
so far, thanks!

