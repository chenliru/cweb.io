
for ($d=0; $d -le 4; $d++)
{
    $do = 14 -$d
    $dn = 7 -$d
    $oldday = (get-date).AddDays(-$do).ToString('yyMMdd');echo $oldday
    $newday = (get-date).AddDays(-$dn).ToString('yyMMdd');echo $newday

    Get-ChildItem "c:\NMON\out\w_control*.txt" -Recurse |
        ForEach { (Get-Content $_ ) |
        Foreach-Object {$_ -replace $oldday,$newday} |
        Set-content $_
    }
}

#  Get-ChildItem "c:\NMON\out\w_control*.txt" -Recurse |
#        ForEach { (Get-Content $_ ) |
#        Foreach-Object {$_ -replace "161118","161111"} |
#        Set-content $_}