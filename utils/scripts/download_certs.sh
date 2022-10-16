#!/bin/bash

parallel "openssl s_client -connect {}:443 2>/dev/null | openssl x509 -in - -text -noout > certs/{}.pem"
# rg -NIo --pcre2 "(?<=Timestamp : ).*" certs | parallel "date -d {} +%s >> temp.txt"
# cat temp.txt | sort -u > timestamps.txt
# rm temp.txt
