
$sys = "IPRO","LOIS","KEC"
$in_path = "C:\NMON\"
$out_path = "Z:\ManualReport\"
$yesterday = (get-date).AddDays(-1).ToString('yyyyMMdd')

foreach ($i in $sys) 
{
    $in_file = $in_path + $i + "DAILY.docx"
    $out_file = $out_path + $i + "\" + $i + "_DAILY_$yesterday.pdf"
    $wd = new-object -comobject word.application # create a com object interface (word application)
    $doc = $wd.documents.open($in_file) # open doc
    $wd.run("refresh") # exec macro named refresh
    $doc.saveas([ref] $out_file, [ref] 17)
    $doc.close()
    $wd.quit() # exit application
}

$mailbody = @"
\\mdc-evs-file\MDCfiles\aixperf\ManualReport\IPRO\IPRO_DAILY_$yesterday.pdf

\\mdc-evs-file\MDCfiles\aixperf\ManualReport\LOIS\LOIS_DAILY_$yesterday.pdf

\\mdc-evs-file\MDCfiles\aixperf\ManualReport\KEC\KEC_DAILY_$yesterday.pdf

"@


$paramHash = @{
 To = "Boyczuk, Byron <BBoyczuk@livingstonintl.com>", "AIX Support <AIXSupport@livingstonintl.com>"
 From = "lchen@livingstonintl.com"
 Subject = "Daily KEC/LOIS/IPRO Performance Report"
 Body = "$mailbody"
 SmtpServer = "mdcmailhub.lii01.livun.com"
}
 
Send-MailMessage @paramHash
