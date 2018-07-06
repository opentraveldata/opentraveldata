#!/bin/bash

awk -F'^' '{printf ("%s", "|-\n"); for (idx=1; idx<NF; idx++) {printf ("| %s", $idx "\n")}}' ../opentraveldata/optd_usdot_wac.csv


