#!/bin/bash

source $utils

# while read ip args <<< $(IFS=" "; pop); do
while read ip args <<< $(IFS=" "; pop); do

  if [ "${ip[0]}" == "#" ]; then
    continue
  fi

  if [ -z $ip ]; then
    echo "starting handler"
    _start_handler
    echo exiting
    exit
  else
    # echo "sudo nmap -sS -T4 $ip $args"
    sudo nmap -sS -T4 -p- $ip $args -oX $(get_raw_results_path)/$ip.xml
  fi
done
