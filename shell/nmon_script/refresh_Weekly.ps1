$weekdate1 = (get-date).AddDays(-7).ToString('yyyyMMdd')
$weekdate2 = (get-date).AddDays(-3).ToString('yyyyMMdd')

$wd = new-object -comobject word.application # create a com object interface (word application)

$out_file = "Z:\ManualReport\IPRO\IPRO_WEEKLY_${weekdate1}_$weekdate2.pdf"
$doc = $wd.documents.open("C:\NMON\IPROWEEKLY.docx") # open doc
$wd.run("refresh") # exec macro named macro01
$doc.saveas([ref] $out_file, [ref] 17)
$doc.close()

$out_file = "Z:\ManualReport\LOIS\LOIS_WEEKLY_${weekdate1}_$weekdate2.pdf"
$doc = $wd.documents.open("C:\NMON\LOISWEEKLY.docx") # open doc
$wd.run("refresh") # exec macro named macro01
$doc.saveas([ref] $out_file, [ref] 17) 
$doc.close()

$out_file = "Z:\ManualReport\KEC\KEC_WEEKLY_${weekdate1}_$weekdate2.pdf"
$doc = $wd.documents.open("C:\NMON\KECWEEKLY.docx") # open doc
$wd.run("refresh") # exec macro named macro01
$doc.saveas([ref] $out_file, [ref] 17) 
$doc.close()

$wd.quit() # exit application

$mailbody = @"
\\mdc-evs-file\MDCfiles\aixperf\ManualReport\IPRO\IPRO_WEEKLY_${weekdate1}_$weekdate2.pdf

\\mdc-evs-file\MDCfiles\aixperf\ManualReport\LOIS\LOIS_WEEKLY_${weekdate1}_$weekdate2.pdf

\\mdc-evs-file\MDCfiles\aixperf\ManualReport\KEC\KEC_WEEKLY_${weekdate1}_$weekdate2.pdf

"@


$paramHash = @{
 To = "Boyczuk, Byron <BBoyczuk@livingstonintl.com>", "AIX Support <AIXSupport@livingstonintl.com>"
 From = "lchen@livingstonintl.com"
 Subject = "Weekly KEC/LOIS/IPRO Performance Report"
 Body = "$mailbody"
 SmtpServer = "mdcmailhub.lii01.livun.com"
}
 
Send-MailMessage @paramHash
