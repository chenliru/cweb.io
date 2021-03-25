
$ipro = "ecm01","ecm02","ecm03","ecm04","ecm05","ecm06","ecm07","ecm08","ecm09","ecm10","ecm11"
$lois = "wes01","wes02","ihs01","ihs02","was01","was02","icm01","icm02","tsm01","ipm02"
$keclinux = "kc1prapkc01","kc1prapkc02","kc2prapkc02","kc1prdb01"
$kec = "kc1prapal01"

$in_path = "C:\NMON\out\"
$nmon_path = "Z:\"

$control_ipro = $in_path + "controlIPRO.txt"
$control_lois = $in_path + "controlLOIS.txt"
$control_kec = $in_path + "controlKEC.txt"
$control_linux = $in_path + "controlLINUX.txt"
$yesterday = (get-date).AddDays(-1).ToString('yyMMdd')
$linuxyesterday = (get-date).AddDays(-1).ToString('yyyyMMdd')

if (Test-Path $control_ipro) {
    Clear-Content $control_ipro
}
foreach ($i in $ipro) 
{
    $nmon_file_name = $nmon_path + $i + "\" + $i + "_$yesterday" + "_0000.nmon"
    Add-Content $control_ipro $nmon_file_name
}

if (Test-Path $control_lois) {
    Clear-Content $control_lois
}
foreach ($i in $lois) 
{
    $nmon_file_name = $nmon_path + $i + "\" + $i + "_$yesterday" + "_0000.nmon"
    Add-Content $control_lois $nmon_file_name
}

if (Test-Path $control_kec) {
    Clear-Content $control_kec
}
foreach ($i in $kec) 
{
    $nmon_file_name = $nmon_path + $i + "\" + $i + "_$yesterday" + "_0000.nmon"
    Add-Content $control_kec $nmon_file_name
}

if (Test-Path $control_linux) {
    Clear-Content $control_linux
}

foreach ($i in $keclinux) 
{
    $nmon_file_name = $nmon_path + $i + "\" + $i + "_$linuxyesterday" + "_nmon.csv"
    Add-Content $control_linux $nmon_file_name
}

