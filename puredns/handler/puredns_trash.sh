#!/bin/bash

source $utils

mv $(get_raw_results_path)/* $(get_trash_path)
mv $(get_processed_path)/* $(get_trash_path)
