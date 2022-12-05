#! /bin/bash
config_str="{\"c\":\"JP\",\"st\":\"TOKYO\",\"l\":\"musashino-city\",\"o\":\"Yokogawa.Inc.\",\"ou\":\"mes\"}"

function get_json_value()
{
  local json=$1
  local key=$2

  if [[ -z "$3" ]]; then
    local num=1
  else
    local num=$3
  fi

  local value=$(echo "${json}" | awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'${key}'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p)

  echo ${value}
}

var_c=$(get_json_value $config_str c)
var_st=$(get_json_value $config_str st)
var_l=$(get_json_value $config_str l)
var_o=$(get_json_value $config_str o)
var_ou=$(get_json_value $config_str ou)
echo "openssl req -x509 -newkey rsa:4096 -keyout certs/\$keyname -out certs/\$certname -sha256 -days 365 -nodes -subj '/C=${var_c}/ST=${var_st}/L=${var_l}/O=${var_o}/OU=${var_ou}/CN='\$i'.yts.yokogawa.co.jp' -addext \"subjectAltName=DNS:'\$i'.yts.mes.co.jp\""