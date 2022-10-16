#!/bin/bash

source $utils

for file_path in $(find $(get_raw_results_path) -name "*.xml"); do
  filename=$(echo $file_path | tr '/' '\n' | tail -n 1)
  nmap-formatter json $file_path -f $(get_processed_path)/"$filename-$(date +%s)".json
done
