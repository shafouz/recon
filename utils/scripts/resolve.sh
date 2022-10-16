#!/bin/bash

source $utils

dnsx -silent -a -resp | tr -d '[]' | tee \
     >(awk '{print $1":"$2}' | _bbrf domain update -) \
     >(awk '{print $2":"$1}' | _bbrf ip add - -p @INFER) \
     >(awk '{print $2":"$1}' | _bbrf ip update -)
