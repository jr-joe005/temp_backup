#! /bin/bash
function get_config_value()
{
    local str=$1
    local key=$2
    local value

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

declare -a pfx_names
pfx_names=(
    "n=hrs01;c=JP;st=TOKYO_01;l=musashino-city_01;o=Yokogawa,Inc._01;ou=mes_01"
    "n=tky01;c=JP;st=TOKYO_02;l=musashino-city_02;o=Yokogawa,Inc._02;ou=mes_02"
)

if [ -d certs ]; then
    echo "certs folder exists."
else
    mkdir certs
fi

for i in "${pfx_names[@]}"
do
    var_n=$(get_config_value $i n)
    keyname=${var_n}'-webap01_cert.key'
    certname=${var_n}'-webap01_cert.crt'
    pfxname=${var_n}'-webap01_cert.pfx'

    if [ -f "certs/"$keyname ]; then
        echo 'certs/'$keyname" exists"
    else
        #openssl req -x509 -newkey rsa:4096 -keyout certs/$keyname -out certs/$certname -sha256 -days 365 -nodes -subj '/C=JP/ST=TOKYO/L=musashino-city/O=Yokogawa,Inc./OU=mes/CN='$i'.yts.yokogawa.co.jp' -addext "subjectAltName=DNS:'$i'.yts.mes.co.jp"

        var_c=$(get_config_value $i c)
        var_st=$(get_config_value $i st)
        var_l=$(get_config_value $i l)
        var_o=$(get_config_value $i o)
        var_ou=$(get_config_value $i ou)
        echo "openssl req -x509 -newkey rsa:4096 -keyout certs/$keyname -out certs/$certname -sha256 -days 365 -nodes -subj /C=${var_c}/ST=${var_st}/L=${var_l}/O=${var_o}/OU=${var_ou}/CN=${var_n}.yts.yokogawa.co.jp -addext \"subjectAltName=DNS:${var_n}.yts.mes.co.jp\""

        #openssl pkcs12 -export -out certs/$pfxname -inkey certs/$keyname -in certs/$certname -passout pass:mesmes
    fi
done

#https://www.ibm.com/docs/en/ibm-mq/7.5?topic=certificates-distinguished-names