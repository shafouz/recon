#!/bin/bash

source $utils

mv -n $(get_raw_results_path)/* $(get_trash_path)
mv -n $(get_processed_path)/* $(get_trash_path)
