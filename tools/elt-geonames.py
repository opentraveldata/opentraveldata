#!/usr/bin/env python
#
# File: http://github.com/opentraveldata/opentraveldata/blob/master/tools/
#
import duckdb
import polars as pl
import sqlalchemy
import csv

conn = duckdb.connect()
conn = duckdb.connect(database='db.duckdb', read_only=False)

geoname_base_dir: str = "../data/geonames/data/por"
geoname_csv_dir: str = f"{geoname_base_dir}/data"
geoname_pqt_dir: str = f"{geoname_base_dir}/parquet"

# allCountries
geoname_allctry_fn: str = "allCountries"
geoname_allctry_csv: str = f"{geoname_csv_dir}/{geoname_allctry_fn}.txt"
geoname_allctry_pqt: str = f"{geoname_pqt_dir}/{geoname_allctry_fn}.parquet"

geoname_allctry_cln = {
        "geonameid": "bigint",
        "name": "varchar",
        "asciiname": "varchar",
        "alternatenames": "varchar",
        "latitude": "double",
        "longitude": "double",
        "fclass": "char(1)",
        "fcode": "varchar(10)",
        "country": "varchar(2)",
        "cc2": "varchar",
        "admin1": "varchar",
        "admin2": "varchar",
        "admin3": "varchar",
        "admin4": "varchar",
        "population": "smallint",
        "elevation": "integer",
        "dem": "integer",
        "timezone": "varchar",
        "moddate": "date"
        }

geoname_allctry_elt_query: str = f"""
COPY (
  SELECT *
  FROM read_csv_auto("{geoname_allctry_csv}",
                     header=True,
                     dateformat="%Y-%m-%d",
                     columns={geoname_allctry_cln},
                     quote=csv.QUOTE_NONE,
                     filename=True,
                     AUTO_DETECT=TRUE)
  )
  TO '{geoname_allctry_pqt}' (FORMAT 'parquet')
"""

geoname_allctry_view_query: str = f"drop view if exists allcountries; create view allcountries as select * from '{geoname_allctry_pqt}'"

# Alternate names
geoname_altname_fn: str = "alternateNames"
geoname_altname_csv: str = f"{geoname_csv_dir}/{geoname_altname_fn}.txt"
geoname_altname_pqt: str = f"{geoname_pqt_dir}/{geoname_altname_fn}.parquet"

geoname_altname_cln = {
        "alternatenameId": "bigint",
        "geonameid": "bigint",
        "isoLanguage": "varchar",
        "alternateName": "varchar",
        "isPreferredName": "smallint",
        "isShortName": "smallint",
        "isColloquial": "smallint",
        "isHistoric": "smallint"
        }

geoname_altname_elt_query: str = f"""
COPY (
  SELECT *
  FROM read_csv_auto("{geoname_altname_csv}",
                     header=True,
                     dateformat="%Y-%m-%d",
                     columns={geoname_altname_cln},
                     quote=csv.QUOTE_NONE,
                     filename=True,
                     AUTO_DETECT=TRUE)
  )
  TO '{geoname_altname_pqt}' (FORMAT 'parquet')
"""

geoname_altname_view_query: str = f"drop view if exists altnames; create view altnames as select * from '{geoname_altname_pqt}'"

# Joint of allCountries and altNames on the GeonameID
geoname_joint_fn: str = "geonames"
geoname_joint_pqt: str = f"{geoname_pqt_dir}/{geoname_joint_fn}.parquet"

geoname_join_view_query: str = f"""
drop view if exists geoanames;

create view geonames as
  select *
  from allcountries ac
  join altnames an
    on ac.geonameid = an.geonameid;

copy geonames to '{geoname_joint_pqt}'
"""

geoame_nce_query: str = "select * from geonames where isoLanguage='iata' and alternateName='NCE'"

def eltCSVToParquet():
    """
    Parse CSV files into Parquet
    """
    # CSV to Parquet for allCountries
    conn.execute(geoname_allctry_elt_query)

    # CSV to Parquet for alternateNames
    conn.execute(geoname_altname_elt_query)

def createViews():
    """
    Create DuckDB views
    """
    # allCountries
    conn.execute(geoname_allctry_view_query)

    # alternateNames
    conn.execute(geoname_altname_view_query)

def joinViews():
    """
    Join allCountries with altNames on the GeonameID
    """
    conn.execute(geoname_join_view_query)

def countRows():
    """
    Check that everything goes right
    """
    count_query: str = """
    select count(*)/1e6 as nb from allcountries
    union all
    select count(*)/1e6 as nb from altnames
    union all
    select count(*)/1e6 as nb from geonames
    """

    nb_list = conn.execute(count_query).fetchall()
    return nb_list

def getNCErows():
    """
    Retrieve all the records featuring NCE as the IATA code
    """
    nce_recs = conn.execute(geoame_nce_query).fetchall()
    return nce_recs

# Main
#eltCSVToParquet()

#createViews()

#joinViews()

nb_list = countRows()
print(f"Number of rows: {nb_list}")

nce_recs = getNCErows()
print("List of records featuring NCE as the IATA code:")
for nce_rec in nce_recs:
    print(nce_rec)


