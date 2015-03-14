#!/bin/bash

awk -F'^' '{loc_type=$44; if (length(loc_type) >= 2) {print ($1 "^" loc_type "^" $13)}}' ../opentraveldata/optd_por_public.csv | sort -t'^' -k3gr,3

