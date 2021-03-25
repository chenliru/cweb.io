
$nmon_base = "c:\auto_nmon\"
$nmon_in = "$nmon_base\in\"
$nmon_out = "$nmon_base\out\"
$nmon_tmp = "$nmon_base\tmp\"
$nmon_script = "$nmon_base\script\"
$nmon_report = "$nmon_base\report\"
$nmon_system = ""

$nmon_xml = $nmon_script + "nmonhosts.xml"

$control = $nmon_tmp + "control.txt"

#$excel = "C:\Program Files\Microsoft Office\Office14\excel.exe"
$nmon_hosts = [xml] ( Get-Content $nmon_xml)

$nmon_date = $nmon_hosts.nmon.nmon_date.date
$nmon_days = $nmon_hosts.nmon.nmon_date.days

$nmon_analyser = $nmon_script + "Nmon_v47.xlsm"


function scp_nmon_files ($hostname, $username, $password, $keyfile, $filename, $localpath, $remotepath)
{
  
    $secstr = New-Object -TypeName System.Security.SecureString
    $password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}

    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr

    $localfile = $localpath + $filename
    $remotefile = $remotepath + $filename

    if($password -ne "") {
        Get-SCPFile -ComputerName $hostname -Credential $cred -LocalFile $localfile -RemoteFile $remotefile
        return $?
    } else {
        Get-SCPFile -ComputerName $nmonhost -Credential $cred -KeyFile $keyfile `
            -LocalFile $localfile -RemoteFile $remotefile
        return $?
    }
}


function nmon_file
{   
    foreach ($i in $input)
    {
        $nmonhost = $i

        $nmonos = $nmon_hosts.nmon.nmon_app.nmon_os|Where-Object {$_.nmon_host.host -eq $i}|ForEach-Object {$_.os}

        $username = $nmon_hosts.nmon.nmon_app.nmon_os.nmon_host|Where-Object {$_.host -eq $i}|ForEach-Object {$_.user}
        $password = $nmon_hosts.nmon.nmon_app.nmon_os.nmon_host|Where-Object {$_.host -eq $i}|ForEach-Object {$_.passwd}
        $keyfile = $nmon_hosts.nmon.nmon_app.nmon_os.nmon_host|Where-Object {$_.host -eq $i}|ForEach-Object {$_.keyfile}

        $nmonpath = $nmon_hosts.nmon.nmon_app.nmon_os.nmon_host|Where-Object {$_.host -eq $i}|ForEach-Object {$_.path}


        if (Test-Path $nmon_tmp\control_$nmonhost) {Clear-Content $nmon_tmp\control_$nmonhost}
        
        for ($d=0; $d -le $nmon_days-1; $d++)
        {
            if ( $nmonos -eq "aix") 
            {$nmonfile = $nmonhost + "_" + (get-date $nmon_date).AddDays($d).ToString('yyMMdd') + "_0000.nmon"}

            if ( $nmonos -eq "linux") 
            {$nmonfile = $nmonhost + "_" + (get-date $nmon_date).AddDays($d).ToString('yyyyMMdd') + "_nmon.csv"}

            $scpresult = scp_nmon_files $nmonhost $username $password $keyfile $nmonfile $nmon_in\ $nmonpath/
            if($scpresult -eq "True") {Add-Content $nmon_tmp\control_$nmonhost "$nmon_in$nmonfile"}
        }
    }

}

function nmon_analyser
{
    $excel_app = new-object -comobject excel.application

    foreach ($i in $input)
    {
        $nmonhost =$i
        $nmonos = $nmon_hosts.nmon.nmon_app.nmon_os|Where-Object {$_.nmon_host.host -eq $i}|
            ForEach-Object {$_.os}
        
        if ((Test-Path $nmon_tmp\control_$nmonhost) -and ((Get-Item $nmon_tmp\control_$nmonhost).length -ne 0kb))
        {
            #cmd.exe /c copy /Y $nmon_tmp\control_$nmonhost $control
            Copy-Item $nmon_tmp\control_$nmonhost $control -force
            
            #cmd.exe /c $excel $nmon_analyser
            $wb_analyser = $excel_app.Application.workbooks.open($nmon_analyser)
            #$wb_analyser.close()
        }
    } 
    
    $excel_app.quit()
}

function nmon_excel_macro
{
    #Call the application
    $macrofile = "$nmon_script\nmonmacro.xlsm"
    echo $macrofile

    $excel_app = new-object -comobject excel.application
          
    #open the Excel file and activate the macro enabled content
    $wb_macro = $excel_app.Application.workbooks.open($macrofile)

    foreach ($i in $input)
    {
        $nmonhost =$i
        $infile = "$nmon_tmp\$nmonhost" + ".xlsx"

        if ((Get-ChildItem $nmon_tmp\${nmonhost}_*).Count -eq 1)
        {
            #cmd.exe /c move /Y $nmon_tmp\${nmonhost}_* $infile
            Move-Item  $nmon_tmp\${nmonhost}_* $infile -force
            
            #Now we open the Excel file and activate the macro enabled content
            $wb_infile = $excel_app.Application.workbooks.open($infile)
            
            #The next command makes Excel invisible
            $wb_infile.Activate()
            
            #Now we run all the Macros that need to be run.
            $excel_app.Application.Run("nmonmacro.xlsm!Main")

            #Now we save the workbook in the standard daily format and the close Excel
            $wb_infile.save()
            $wb_infile.close()

        }
    }    

    $wb_macro.close()
    $excel_app.quit()

}


function nmon_doc_report
{
    $word_app = new-object -comobject word.application # create a com object interface (word application)
    $k = 0

    foreach ($i in $input)
    {
        $nmonapp = $i
        $outfilepdf = $nmon_out + "\" + $nmonapp + "_" + (get-date $nmon_date).ToString('yyyyMMdd') + ".pdf"

        if ($nmon_days -gt 1) {$outfilepdf =$nmon_out + "\" + $nmonapp + "_" + 
            (get-date $nmon_date).ToString('yyyyMMdd') + "_" + 
            (get-date $nmon_date).AddDays($nmon_days-1).ToString('yyyyMMdd') + ".pdf" } 

        $nmonapphost = $nmon_hosts.nmon.nmon_app|Where-Object {$_.app -eq $nmonapp}|
            ForEach-Object {$_.nmon_os.nmon_host.host}
        
        if (Test-Path $nmon_tmp\*.docx) {Remove-Item $nmon_tmp\*.docx}

        foreach ($j in $nmonapphost)
        {
            #$nmon_array = $i.split(","); if($nmon_array.Count -ne 2) {continue}
            #$nmon_os, $nmon_host = $i.split(",",2)
            $nmonhost = $j
            $nmonos = $nmon_hosts.nmon.nmon_app.nmon_os|Where-Object {$_.nmon_host.host -eq $j}|
                ForEach-Object {$_.os}
  
            $k++

            if (Test-Path $nmon_tmp\${nmonhost}.xlsx) 
            {
                #cmd.exe /c copy /Y $nmon_tmp\${nmonhost}.xlsx $nmon_tmp\${nmonos}.xlsx
                Copy-Item $nmon_tmp\${nmonhost}.xlsx $nmon_tmp\${nmonos}.xlsx -force
                       
                $infile = $nmon_report + $nmonhost + ".docx"
                if ( -Not (Test-Path $infile) ) {Copy-Item $nmon_report\sample\${nmonos}.docx $infile -force}
                                                #{cmd.exe /c copy $nmon_report\sample\${nmonos}.docx $infile}
        
                $tmpfile = $nmon_tmp  + "tmp$k" + ".docx"

                $doc_infile = $word_app.documents.open($infile) # open doc
                $word_app.run("refresh")         # exec macro named refresh in:
                                                 # C:\Users\lchen\AppData\Roaming\Microsoft\Templates\Normal.dotm

                $doc_infile.saveas([ref] $tmpfile) 
                $doc_infile.saveas([ref] $infile) 
                $doc_infile.close()

            }
         }
  
        $doc_report = $word_app.documents.add() # open new doc

        $word_app.run("merge") # exec macro named merge

        $doc_report.saveas([ref] $outfilepdf, [ref] 17) 
        $doc_report.saveas([ref] "reports.docx")
        $doc_report.close()
    }

    $word_app.quit() # exit application

} 


if (Test-Path $nmon_tmp\*) {Remove-Item $nmon_tmp\* -force}
if (Test-Path $nmon_in\*) {Remove-Item $nmon_in\* -force}
if (Test-Path $nmon_out\*) {Remove-Item $nmon_out\* -force}

$nmon_hosts.nmon.nmon_app.nmon_os.nmon_host.host | nmon_file
$nmon_hosts.nmon.nmon_app.nmon_os.nmon_host.host | nmon_analyser
$nmon_hosts.nmon.nmon_app.nmon_os.nmon_host.host | nmon_excel_macro
$nmon_hosts.nmon.nmon_app.app | nmon_doc_report

