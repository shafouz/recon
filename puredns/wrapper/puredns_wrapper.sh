#!/bin/bash

source $utils

# DEFAULT_WORDLIST="/home/shafou/wordlists/testwl.txt"
DEFAULT_WORDLIST="/home/shafou/wordlists/dnsbigreal.txt"

while read domain prefix suffix _ <<< $(IFS=" "; pop); do

  if [ "${domain[0]}" == "#" ]; then
    continue
  fi

  if [ -z $domain ]; then
    echo "starting handler"
    _start_handler
    echo exiting
    exit
  else
    sed "s#^#$prefix#" $DEFAULT_WORDLIST | \
      sed "s#\$#$suffix#" | \
      puredns bruteforce "$domain" \
      -r $recon/utils/resolvers.txt \
      -w "$(get_raw_results_path)/${prefix}_${suffix}.${domain}.txt" \
      --wildcard-batch 1000000 \
      -l 0 \
      --bin /home/shafou/workspace/programs/massdns/bin/massdns
  fi
done
