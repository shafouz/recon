#!/bin/bash

. $utils
. $recon/utils/assert.sh

# $1 = wordlist
# $2 = requests_per_second
# $3 = time_per_part
# $4 = request_file"

if [ $# != 4 ]; then
  log_failure "missing argument"
  log_failure "arguments: wordlist, rps, time_per_part, request_file"
  exit
fi

wordlist="$1"

function get_number_of_parts(){
  declare -i time_per_part=${3:-25}
  declare -i length=$( wc -l "$wordlists/$1.txt" | tr ' ' '\n' | head -n 1 )
  declare -i requests_per_second=$((${2:-100}))
  declare -i requests_per_minute=$((requests_per_second * 60))
  declare -i number_of_parts=$(echo "$length / ($requests_per_minute * $time_per_part) + 1" | bc)
  printf "$number_of_parts"
}

number_of_parts=$(get_number_of_parts $wordlist $2 $3)

assert_eq "$(get_number_of_parts txt 1 60)" "2" "error on get_number_of_parts function"
assert_eq "$(get_number_of_parts asp 100 30)" "5" "error on get_number_of_parts function"
assert_eq "$(get_number_of_parts $wordlist $2 $3)" "$number_of_parts" "error on get_number_of_parts function"

filename=$(cat /dev/urandom | base64 | rg -o '\w{8}' | head -n 1)

for i in $(seq 1 $number_of_parts); do
  jwt=$($recon/utils/scripts/get_jwt.py)
  request=$(cat "$4" | sed "s#<JWT>#$jwt#")
  for part in "$(split "$wordlists/$wordlist.txt" -n l/$i/$number_of_parts)"; do
    ffuf -w <(printf "$part") -X PUT -request <(printf "$request") -rate 100 -o $(get_raw_results_path)/"$filename-$(date +%s)-part$i".csv -replay-proxy http://192.168.15.51:8080
  done
done
