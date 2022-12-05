#! /bin/bash
config_str="c=JP;st=TOKYO;l=musashino-city;o=Yokogawa,Inc.;ou=mes"

function get_config_value()
{
    local str=$1
    local key=$2
    local value="${key}...."

    array=(${str//;/ })
    for var in "${array[@]}"
    do
      item=(${var//=/ })
      value+="-${var}<[${item[0]}:${item[1]}]>    "
      if [ "${item[0]}" == "${key}" ];
        then
          value=${item[1]}
          break
      fi
    done

    echo "${value}"
}

var_c=$(get_config_value $config_str c)
var_st=$(get_config_value $config_str st)
var_l=$(get_config_value $config_str l)
var_o=$(get_config_value $config_str o)
var_ou=$(get_config_value $config_str ou)
echo "openssl req -x509 -newkey rsa:4096 -keyout certs/\$keyname -out certs/\$certname -sha256 -days 365 -nodes -subj '/C=${var_c}/ST=${var_st}/L=${var_l}/O=${var_o}/OU=${var_ou}/CN='\$i'.yts.yokogawa.co.jp' -addext \"subjectAltName=DNS:'\$i'.yts.mes.co.jp\""

