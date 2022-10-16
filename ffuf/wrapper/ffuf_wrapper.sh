#!/bin/bash

source $utils

while read input wordlist args <<< $(IFS=" "; pop); do

  if [ "${input[0]}" == "#" ]; then
    continue
  fi

  # timestamp
  if [ -z $input ]; then
    echo "starting handler"
    _start_handler
    echo exiting
    exit
  else
    start_time=$(date +%s)
    case "$input" in
      # case http
      *://*)
      # csv path
      output="$(echo $input | sed "s#^https\?://##" | tr '/' '.')-$start_time"
      # url
      input="-u $input" ;;
    *)
      # get host path from raw http
      host=$(head -2 $input | tail -1 | rg -o --pcre2 "(?<= ).+?$" | tr '/' '.')
      path="$(head -1 $input | rg -o --pcre2 '/.+(?= )' | tr '/' '.')"

        # raw http request to timestamp.txt
        cp "$input" "$(get_commands_path)/$start_time.txt"

        # csv path
        output="$host$path-$start_time"
        # request path
        input="-request $input" ;;
    esac

    ffuf $input -w $wordlists/$wordlist.txt -o $(get_raw_results_path)/$output.csv $args
  fi

done
