#!/bin/bash

source $utils

time=$(date +%s)
declare -i i=0

cat $(get_raw_results_path)/* | sort -u > $(get_processed_path)/$i-$time.txt
cat $(get_processed_path)/* | _bbrf domain add -
