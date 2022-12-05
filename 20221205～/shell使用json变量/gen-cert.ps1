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

$cert_folder = "certs"
$pfx_names = @(
    "n=hrs01;c=JP;st=TOKYO_01;l=musashino-city_01;o=Yokogawa,Inc._01;ou=mes_01",
    "n=tky01;c=JP;st=TOKYO_02;l=musashino-city_02;o=Yokogawa,Inc._02;ou=mes_02")

if(Test-Path -Path $cert_folder)
{
    echo "certs folder exists."
}
else
{
    New-Item -ItemType "directory" -Force -Path $cert_folder
}

for($i=0; $i -lt $pfx_names.Length; $i++)
{
    $var_n=$("$(get_config_value $pfx_names[$i] n)" -replace " ","")
    $keyname = $var_n + '-webap01_cert.key'
    $certname=$var_n + '-webap01_cert.crt'
    $pfxname=$var_n + '-webap01_cert.pfx'

    if(Test-Path -Path "$cert_folder/$keyname")
    {
        echo "certs/$keyname exists"
    }
    else
    {
        $var_c=$("$(get_config_value $pfx_names[$i] c)" -replace " ","")
        $var_st=$("$(get_config_value $pfx_names[$i] st)" -replace " ","")
        $var_l=$("$(get_config_value $pfx_names[$i] l)" -replace " ","")
        $var_o=$("$(get_config_value $pfx_names[$i] o)" -replace " ","")
        $var_ou=$("$(get_config_value $pfx_names[$i] ou)" -replace " ","")
        echo $("openssl req -x509 -newkey rsa:4096 -keyout certs/$keyname -out certs/$certname -sha256 -days 365 -nodes -subj /C=$var_c/ST=$var_st/L=$var_l/O=$var_o/OU=$var_ou/CN=$var_n.yts.yokogawa.co.jp -addext subjectAltName=DNS:$var_n.yts.mes.co.jp")
    }
}