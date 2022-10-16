#!/bin/bash

source $utils

$(handler_path)/puredns_add.sh
$(handler_path)/puredns_resolve.sh
# $(handler_path)/puredns_trash.sh
