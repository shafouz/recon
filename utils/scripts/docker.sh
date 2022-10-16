#!/bin/bash

OPTIONS="fu:"
LOPTIONS="file,url:"
args=$(getopt --options=$OPTIONS --longoptions=$LOPTIONS -- "$@")

while true; do
  case "$1" in
    --file|-f)
      file=$(</dev/stdin)
      printf "$file" > hosts.txt
      ./multi_targets.sh hosts.txt
      wait
      break
      ;;
    --url|-u)
      url="$2"
      java -jar ./iis_shortname_scanner.jar 2 20 $url
      break
      ;;
    *) break ;;
  esac
done
