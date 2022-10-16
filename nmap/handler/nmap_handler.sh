#!/bin/bash

source $utils

$(handler_path)/nmap_clean.sh
$(handler_path)/nmap_add.py
$(handler_path)/nmap_trash.sh
