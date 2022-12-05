$config_str = "n=hes01;c=JP;st=TOKYO;l=musashino-city;o=Yokogawa,Inc.;ou=mes"

Function get_config_value($str, $key)
{
    $value
    $items = $str.split(";")

    for($i=0; $i -lt $items.Length; $i++)   
    {   
        $item = $items[$i].split("=")
        if($item[0] -eq $key)
        {
            $value = $item[1]
            break
        }
    }

    return $value
}

$var_c=$("$(get_config_value $config_str c)" -replace " ","")
$var_st=$("$(get_config_value $config_str st)" -replace " ","")
$var_l=$("$(get_config_value $config_str l)" -replace " ","")
$var_o=$("$(get_config_value $config_str o)" -replace " ","")
$var_ou=$("$(get_config_value $config_str ou)" -replace " ","")
$var_n=$("$(get_config_value $config_str n)" -replace " ","")
echo $("openssl req -x509 -newkey rsa:4096 -keyout certs/" + '$keyname' + " -out certs/" + '$certname' + " -sha256 -days 365 -nodes -subj '/C=$var_c/ST=$var_st/L=$var_l/O=$var_o/OU=$var_ou/CN='$var_n'.yts.yokogawa.co.jp' -addext 'subjectAltName=DNS:'$var_n'.yts.mes.co.jp'")