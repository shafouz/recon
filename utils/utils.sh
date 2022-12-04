#!/bin/bash

# ENV

export results_path_test="$results/19-10-22/subdomains"
export wk="/home/shafou/workspace"
export stow="/home/shafou/stow"
export recon="/home/shafou/recon"
export results="$recon/results"
export utils="$recon/utils/utils.sh"
export PATH=$PATH:/home/shafou/.local/bin
export wordlists="/home/shafou/wordlists"
export burpext="/home/shafou/workspace/burp/"
export tools=(ffuf puredns)
export rust="/home/shafou/workspace/rust"
export today="$(date -d "today" +%d-%m-%y)"
export wl="/home/shafou/workspace/wordlists"
export programs="/home/shafou/workspace/programs"
export AIRFLOW_HOME="/home/shafou/airflow"

# CLI
linkfinder(){
  python3 /home/shafou/workspace/programs/LinkFinder/linkfinder.py "$@"
}

prx(){
  ffuf "$@" -replay-proxy http://192.168.15.51:8080
}

fnm(){
  find -name "*$1*"
}

shortname(){
  sudo docker run -w /usr/src/myapp/IIS-ShortName-Scanner -it -v $(realpath .):/usr/src/myapp/IIS-ShortName-Scanner/input/ shortname
}

dump(){
  dirpath="${2:-$recon/results/$1}"
  find "$dirpath" -type f -not -iname ".*" -printf "$(tput setaf 4)$(tput bold)%f$(tput sgr0) $(tput setaf 2)%TH:%TM %TA %Td-%Tm-%TY$(tput sgr0)\n" | column -t | sort -u | sort -k 4 -g
}

bbrf_diff(){
  diff <(bbrf $1) ./$2 | rg ">" | tr -d '> '
}

vwd(){
  nvim $recon/*$1*/input/*$1*-input.txt +"chdir $recon/*$1*/"
}

sdate(){
  date -d "$1" +%s
}

ppbbrf(){
  bbrf show ${1:--} | jq
}

check_results(){
  find $results/$1/ -type f -not -name ".*"
}

get_live_hosts(){
  httpx -probe -nc | rg "SUCCESS" | sed 's# .*##' | sed 's#^https\?://##'
}

vimdir(){
  nvim +"chdir $1"
}

start_notebook(){
  tmux new-session -d "cp $stow/not-stowables/scripts/results.ipynb . ; jupyter-lab"
}

pull_results(){
  if [ $2 ]; then
    # echo "scp -r $vps:$results/*$1*/*$2*/ ."
    scp $vps:"$results/*$1*/*$2*/*" .
  elif [ $1 ]; then
    # echo "scp -r $vps:$results/*$1*/processed/ ."
    scp $vps:"$1" .
  fi
}

edit_input(){
  if [ $2 ]; then
    ssh -t $vps ". /home/shafou/recon/utils/utils.sh; $(declare -f edit_input); edit_input $2"
  else
    nvim $recon/*$1*/input/*$1*-input.txt +"chdir $recon/*$1*/input"
  fi
}

_edit_input(){
  nvim $recon/*$1*/input/*$1*-input.txt +"chdir $recon/*$1*/input"
}

start_wrapper(){
  if [ $2 ]; then
    cd $recon/*$1*/input
    $recon/*$1*/wrapper/*$1*.sh
  else
    tmux new-session -c $recon/*$1*/input -d $recon/*$1*/wrapper/*$1*.sh
  fi
}

start_handler(){
  exit

  if [ $2 ]; then
    cd $recon/*$1*/handler/*$1*
    $recon/*$1*/handler/$1_handler.sh
  else
    tmux new-session -c $recon/*$1*/wrapper/*$1* -d $recon/*$1*/handler/$1_handler.sh
  fi
}

add_tool(){
  mkdir $recon/$1

  mkdir $recon/$1/{input,handler,wrapper}
  touch $recon/$1/{input,handler,wrapper}/.gitkeep

  touch $recon/$1/handler/${1}_handler.sh
  touch $recon/$1/wrapper/${1}_wrapper.sh
  touch $recon/$1/input/$1-input.txt

  mkdir $recon/results/
  mkdir $recon/results/$1
  mkdir $recon/results/$1/{data,commands,processed,trash}
  touch $recon/results/$1/{data,commands,processed,trash}/.gitkeep
}

add_results(){
  mkdir $recon/results/$1
  mkdir $recon/results/$1/{data,commands,processed,trash}
}

# INTERNAL

_start_handler(){
  $(handler_path)/$(get_tool_name)_handler.*
}

get_tool_name(){
  tool=$(echo "$0" | rg -o "(ffuf|sqlmap|nmap|puredns)" | tail -1)
  if [ $tool ]; then
    printf "%s" "$tool"
    exit
  fi

  printf -- "%s" "command-line"
}

handler_path(){
  echo $recon/$(get_tool_name)/handler
}

get_input_list(){
  echo $recon/$(get_tool_name)/input/$(get_tool_name)-input.txt
}

get_previous_commands(){
  echo $recon/$(get_tool_name)/input/previous-commands.txt
}

get_trash_path(){
  echo $results/$(get_tool_name)/trash
}

get_processed_path(){
  echo $results/$(get_tool_name)/processed
}

get_raw_results_path(){
  today="$(date +%d-%m-%y)"
  mkdir $results/$today &> /dev/null
  mkdir $results/$today/$(get_tool_name) &> /dev/null
  output_path="$results/$today/$(get_tool_name)"
  printf -- "%s" "$output_path"
}

get_commands_path(){
  echo $results/$(get_tool_name)/commands
}

get_ffuf_responses_path(){
  echo "$results/ffuf/responses"
}

function get_wl_time(){
  declare -i length=$( wc -l "$wordlists/$1.txt" | tr ' ' '\n' | head -n 1 )
  declare -i requests_per_second=$((${2:-100}))
  declare -i requests_per_minute=$((requests_per_second * 60))
  declare -i wl_time_in_hours=$(echo "$length / ($requests_per_minute * 60)" | bc)
  printf "wordlist: $1 | rate: $2 | length: $length | hours: $wl_time_in_hours"
}

pop(){
  first_line=$(head -1 $(get_input_list))
  rest_of_lines="$(tail -n +2 $(get_input_list))"
  echo "$rest_of_lines" > $(get_input_list)
  echo "$first_line"
}

_bbrf(){
  OPTIONS=""
  LOPTIONS="tool:"
  time=$(date +%s)
  args=$(getopt -q --options=$OPTIONS --longoptions=$LOPTIONS -- "$@")
  tool=$(get_tool_name)
  new_cmd=""

while true; do
  case "$1" in
    _bbrf)
      shift
      ;;
    add)
      new_cmd+="${1} ${2} -t created_at:$time -t updated_at:$time -t ${tool:-"tool"}:true "
      shift 2
      ;;
    update)
      new_cmd+="${1} ${2} -t updated_at:$time -t ${tool:-"tool"}:true "
      shift 2
      ;;
    --tool)
      shift
      new_cmd+=" -t ${1}:true "
      shift
      ;;
    *)
      if [ -z "$1" ]; then break; fi
      new_cmd+="${1} "
      shift
      ;;
  esac
done

# echo "bbrf ${new_cmd}"
eval "bbrf ${new_cmd}"
}
