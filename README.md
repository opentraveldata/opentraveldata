[![Build Status](https://travis-ci.org/opentraveldata/opentraveldata.svg?branch=master)](https://travis-ci.org/opentraveldata/opentraveldata)

Open travel data (opdt) provides a collection of travel and leisure related data. The project
makes extensive use of already existing data sources such as Geonames and Wikipedia, and adds
some glue around those (e.g. links). All data sets are carefully maintained and kept up-to-date
by the opdt developers.


Usage
======
All opdt curated and maintained data sets are located in the **`opentraveldata`** directory. We use
flat files with hat (^) separated columns that should be easy to use with your tools of
choice. Some usage examples can be found in the **`examples`** directory.

The **`tools`** and **`data`** directories contain scripts and collected data which are used to
generate our data sets. **`.travis`** contains continuous integration related code.


Development
============
This is the master repository of the open travel data project. For backwards
compatability reasons, all changes are synced back to the
[old repository](https://github.com/opentraveldata/optd).
