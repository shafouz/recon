#!/bin/bash

source $utils

while read args <<< $(IFS=" "; pop); do
  # timestamp
  if [ "${args[0]}" == "#" ]; then
    continue
  fi

  if [ -z "$args" ]; then
    echo sleeping
    sleep 60
  else
    args=${args/-r* /-r $recon/sqlmap/input/}

    python3 ~/workspace/programs/sqlmap-dev/sqlmap.py --output-dir=$results/sqlmap/data/ --risk=3 --answers=Y --time-sec=10 $args
  fi
done
