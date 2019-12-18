#!/bin/bash

n=0
while read -r map_line
do
	n=$((n+1))
	printf '[%s] %s\n' "${n}" "${map_line}"
done < ci-scripts/titsc_delivery_map.csv

