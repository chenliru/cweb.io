
$aix="ecm01","ecm02","ecm03","ecm04","ecm05","ecm06","ecm07","ecm08","ecm09","ecm10","ecm11",
     "wes01","wes02","ihs01","ihs02","was01","was02","icm01","icm02","tsm01","ipm02",
     "kc1prapal01"

$linux="kc1prapkc01","kc1prapkc02","kc2prapkc02","kc1prdb01"

foreach($host_nmon in $aix)
{
    $control_file="nw_control_${host_nmon}.txt"
    if(Test-Path $control_file){Clear-Content $control_file}
    
    for ($d=0; $d -le 4; $d++)
    {
        $day_offset=(get-date).DayOfWeek.value__ + 6 - $d
        $day_nmon=(get-date).AddDays(-$day_offset).ToString('yyMMdd')

        Add-Content $control_file "Z:\${host_nmon}\${host_nmon}_${day_nmon}_0000.nmon"
    }
}


foreach($host_nmon in $linux)
{
    $control_file="nw_control_${host_nmon}.txt"
    if(Test-Path $control_file){Clear-Content $control_file}
    
    for ($d=0; $d -le 4; $d++)
    {
        $day_offset=(get-date).DayOfWeek.value__ + 6 - $d
        $day_nmon=(get-date).AddDays(-$day_offset).ToString('yyyyMMdd')

        Add-Content $control_file "Z:\${host_nmon}\${host_nmon}_${day_nmon}_nmon.csv"
    }
}
