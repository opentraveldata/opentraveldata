#!/bin/bash

displayItem() {
	idx=$((idx+1))
	printf '[%s] %s\n' "${idx}" "${optd_map_line}"
}

n=0
while IFS="" read -r -u3 optd_map_line
do
	displayItem
done 3< ci-scripts/titsc_delivery_map.csv

