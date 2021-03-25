#Configuration in XML

$powerpath = "$env:POWERPATH"
$runtime = (get-date).ToString('yyyyMMddHHmmss')

$hostname = "server"
$username = "sysadm"
$password = " "

$sysadmpath = "$powerpath\sysadm"

$localpwd = "$sysadmpath\sush"
$remotepwd = "/tmp"

$opensshpath = "$powerpath\OpenSSH-Win32"
$publickey = "$opensshpath\keyfile\Publickey"
$privatekey = "$opensshpath\keyfile\Privatekey"

$xmlfile = "$powerpath\bin\temp\test_sysadmhosts.xml"

#Email content
$mailbody = @"
content1

content2

content3

"@

#Email context
$paramEmail = @{
 To = "Chen, Liru <lchen@livingstonintl.com>", "Chen, Liru <chenliruroyal@gmail.com>"
 From = "Chen, Liru <lchen@livingstonintl.com>"
 Subject = "SysAdm"
 Body = "$mailbody"
 SmtpServer = "mdcmailhub.lii01.livun.com"
}

##visudo to edit /etc/sudoers on AIX
## Livingston Users
#lchen ALL = NOPASSWD: /usr/bin/su -*
#The user lchen can run commands /usr/bin/su -* as any user without giving his password.
#fred ALL = (DB) NOPASSWD: ALL
#The user fred can run commands as any user in the DB Runas_Alias (oracle or sybase) without giving a password.

##visudo to edit /etc/sudoers on Linux
## Allows people in group wheel to run all command on all machine as all user by giving a password
# %wheel        ALL=(ALL)       ALL
# example: lchen <--user group/name   ALL <-- machine =(ALL) <--runas user       ALL <-- command

#Prepare sush running files
Get-Content $localpwd\sush.new-item|%{if(-Not (Test-Path $localpwd\$_)) {New-Item $localpwd\$_}}


function sysadm_ssh {

    param(
        $Commandfile
        )
  
    $ssh = "$opensshpath\ssh.exe -i $privatekey -p $port -oStrictHostKeyChecking=no -oPasswordAuthentication=no"
    if($sudoer){$ssh = "$opensshpath\ssh.exe -t -i $privatekey -p $port -oStrictHostKeyChecking=no -oPasswordAuthentication=no"}
    
    $commands = Get-Content $commandfile
    foreach ($command in $commands)
    {
        if (Test-Path "$localpwd\sushwin\mySSH.cmd"){Clear-Content "$localpwd\sushwin\mySSH.cmd"}
        
        if($sudoer){$command = "echo $password | sudo -S su - -c `' $command  `'" }
                
        Add-Content "$localpwd\sushwin\mySSH.cmd","$sysadmpath\log\mySSH.log" "$ssh $username@$hostname `"$command`" "
        
        $mysshcode = (Start-Process "$localpwd\sushwin\mySSH.cmd" -Wait -PassThru).ExitCode
        Add-Content "$sysadmpath\log\mySSH.log" "Exit Code: $mysshcode"
        
        if($mysshcode -eq 0){$sshcode = $true}else{$sshcode = $false}
    }
    
    return $sshcode
}


function sysadm_scp {

    param(
        $Scpfile,
        [switch]$From
        )
 
    $scp = "$opensshpath\scp.exe -i $privatekey -P $port -oStrictHostKeyChecking=no -oPasswordAuthentication=no"
     
    $files = Get-Content $scpfile
    foreach($file in $files)
    {

        if($file.split(",").Count -ne 4){continue}
        else
        {
            $scpuser = $file.split(",").Item(0)
            $scpfile = $file.split(",").Item(1)
            $localpath = $file.split(",").Item(2)
            $remotepath = $file.split(",").Item(3)
        }

        $filebkup = $scpfile + "_" + $runtime
        if(Test-Path "$localpwd\sushwin\mySCP.cmd"){Clear-Content "$localpwd\sushwin\mySCP.cmd"}
        
        if($From)
        {
            if(Test-Path "$localpath\$scpfile"){ Move-Item "$localpath\$scpfile" "$localpath\$filebkup" -Force}
            Add-Content "$localpwd\sushwin\mySCP.cmd","$sysadmpath\log\mySCP.log" "$scp $scpuser@$hostname`:$remotepath/$scpfile $localpath\$scpfile"

        }else{
            
            if(Test-Path "$localpwd\sushwin\mySSH.bkup"){Clear-Content "$localpwd\sushwin\mySSH.bkup"}
            
            if(Test-Path "$localpath\$scpfile")
            {
                Add-Content "$localpwd\sushwin\mySSH.bkup" "[[ -f $remotepath/$scpfile ]] && mv -f $remotepath/$scpfile $remotepath/$filebkup"
                $mysshcode = sysadm_ssh -Commandfile "$localpwd\sushwin\mySSH.bkup"

                Add-Content "$localpwd\sushwin\mySCP.cmd","$sysadmpath\log\mySCP.log" "$scp $localpath\$scpfile $scpuser@$hostname`:$remotepath/$scpfile"
            }
        }

        $myscpcode = (Start-Process "$localpwd\sushwin\mySCP.cmd" -Wait -PassThru).ExitCode
        Add-Content "$sysadmpath\log\mySCP.log" "Exit Code: $myscpcode"
            
        if($myscpcode -eq 0){$scpcode = $true}else{$scpcode = $false}
    }

    return $scpcode
}


function sysadm_passwd {

    param(
        [switch]$Reset
        )

    if($reset)
    {
        $securestring = $Password | ConvertTo-SecureString -AsPlainText -Force

        $securepassword = $securestring | ConvertFrom-SecureString

        if((Get-Content $localpwd\sushwin\myPASSWD) -match "$hostname $username" )
        {
            (Get-Content $localpwd\sushwin\myPASSWD) -notmatch "$hostname $username" | Out-File $localpwd\sushwin\myPASSWD
        }
        Add-Content "$localpwd\sushwin\myPASSWD" "$hostname $username $securepassword"  
  
    }else{
        
        $securepassword = Get-Content $localpwd\sushwin\myPASSWD | Select-String "$hostname $username" | %{$_.line.split(" ",3).Item(2)} 
        
        if($securepassword)
        {
            $securestring = $securepassword | ConvertTo-SecureString
            $password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securestring))
        }
        #else{
        #    $securestring = Read-Host "What is [$Username] password ? " -AsSecureString
        #}
        
        #$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securepassword)
    }
    
    return $password

}

function sysadm_choice {

    param(
        $buttons,
        $title,
        $message
        )    
    
    [System.Management.Automation.Host.ChoiceDescription[]]$options = @()

    $keys = $buttons.GetEnumerator() | Sort-Object key

    foreach ($key in $keys.name ) {

        $txt = $key
        $msg = $buttons.Get_Item($key)

        $options += New-Object System.Management.Automation.Host.ChoiceDescription "&$txt", "$msg"
        
    }

    $default = 0

    $choice = $host.ui.PromptForChoice($title, $message, $Options, $default)

    return $choice
}


function sysadm_publickey {

    try{
        $secstr = New-Object -TypeName System.Security.SecureString
        $password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}

        $cred = new-object `
                 -typename System.Management.Automation.PSCredential `
                 -argumentlist $username, $secstr

        #No Private key for ssh session by New-SSHSession when using port other than 22, it maybe a bug
    
        $session = Posh-SSH\New-SSHSession `
                    -ComputerName $hostname `
                    -Cred $cred `
                    -AcceptKey $true `
                    -ConnectionTimeOut 10 `
                    -KeepAliveInterval 10 `
                    -Port $port
    }catch{
        #Write-Host "No session on $hostname" -ForegroundColor Red -BackgroundColor Blue
        return $false
    }
    
    #deploy public key on remote Unix-like server
    $publickeycontent = Get-Content $Publickey

    $sshcmd = Posh-SSH\invoke-sshcommand `
              -Index $Session.index `
              -Command "grep '$publickeycontent' ~/.ssh/authorized_keys" `
              -Verbose
                     
    if ($sshcmd.ExitStatus -eq 0)
    {
        Posh-SSH\Remove-SSHSession -Index $session.Index
        return $true
        
    }else{
        $sshcmd = Posh-SSH\invoke-sshcommand `
                   -Index $Session.index `
                   -Command  "[[ ! -d ~/.ssh ]] && mkdir -p ~/.ssh;echo '$publickeycontent' >> ~/.ssh/authorized_keys;chmod 700 ~/.ssh;chmod 600 ~/.ssh/authorized_keys" `
                   -Verbose

        if($sshcmd.ExitStatus -eq 0)
        {
            Posh-SSH\Remove-SSHSession -Index $session.Index
            return $true 
        }else{
            Posh-SSH\Remove-SSHSession -Index $session.Index
            return $false
        }

    }
}

function sysadm_connect {

    do
    { 
        #$sshcode = sysadm_ssh -Commandfile "$localpwd\sushwin\mySSH.conn"
        $publickeycode = sysadm_publickey
        if($publickeycode)        #if($sshcode)
        {
            $password = sysadm_passwd -Reset

            Set-Variable -Name username -Scope 1 -Value $username  
            Set-Variable -Name password -Scope 1 -Value $password 
            Set-Variable -Name hostname -Scope 1 -Value $hostname 
            Set-Variable -Name port -Scope 1 -Value $port
            Set-Variable -Name sudoer -Scope 1 -Value $sudoer            
            
            return $true

        }else{

            $title = "Username: $username on Server Name: $hostname"
            $buttons = @{"0-Retry" = "Manually Re-enter connect string"; "1-Next" = "Next server,and/or quit"}
            $message = @" 
                    
$username on $hostname : $port unreachable !
                                        
"@
            $choice = sysadm_choice -buttons $buttons -title $title -message $message
                
            if($choice -eq 0) 
            {
                try{
                    $connectstring = "$username/******@$hostname`:$port" ;if($sudoer){$connectstring = "$username/******@$hostname`:$port!"}
                    
                    $connectstring = Read-InputBoxDialog -Message "Please Re-enter the connect string'" -WindowTitle "Input Box" -DefaultText $connectstring
                                
                    $hostname = $connectstring.Split("[/@:!]").item(2)
                    $username = $connectstring.Split("[/@:!]").item(0)
                    $password = $connectstring.Split("[/@:!]").item(1);if(!$password -or ($password.trim() -eq "") -or ($password -eq "******")){ $password = sysadm_passwd }
                    $port = $connectstring.Split("[/@:!]").item(3)
                    if($connectstring.Split("[/@:!]").Count -eq 5) {$sudoer = $true}else{$sudoer = $false}
                
                }catch{
                    #Write-Host "No session on $hostname" -ForegroundColor Red -BackgroundColor Blue
                    return $false
                }
             
            }else{return $false}
         
         } #continue
    
    }while($true)

}

function sysadm_del {

    param(
         $delfiles
         )
    
    if(Test-Path "$localpwd\sushwin\mySSH.del"){Clear-Content "$localpwd\sushwin\mySSH.del"}

    $files = Get-Content $delfiles
    foreach ($file in $files)
    {

        if($file.split(",").count -ne 4){continue}
        else
        {
            $deluser = $file.split(",").Item(0)
            $delfile = $file.split(",").Item(1)
            $localpath = $file.split(",").Item(2)
            $remotepath = $file.split(",").Item(3)
        }
                
        Add-Content "$localpwd\sushwin\mySSH.del" "[[ -f $remotepath/$delfile ]] && rm -f $remotepath/$delfile"
    }
    
    sysadm_ssh -Commandfile "$localpwd\sushwin\mySSH.del"

}

# Show input box popup and return the value entered by the user.
function Read-InputBoxDialog([string]$Message, [string]$WindowTitle, [string]$DefaultText)
{
    Add-Type -AssemblyName Microsoft.VisualBasic
    return [Microsoft.VisualBasic.Interaction]::InputBox($Message, $WindowTitle, $DefaultText)
}

function sysadm_task
{
    $xml = [xml] ( Get-Content $xmlfile )
    $auto=$xml.sysadm.auto;if($auto.ToLower() -eq "true" ){$auto = $true}else{$auto = $false}
            
    if($auto){$tasks = $connect.task}else{$tasks = $connect.task | Out-GridView -OutputMode Multiple -Title "Select Tasks"}
                             
    #if(Test-Path $localpwd\sushwin\mySCP.taskrun){Clear-Content $localpwd\sushwin\mySCP.taskrun}
    Get-Content $localpwd\sush.clear-content|%{if(Test-Path "$localpwd\$_"){Clear-Content "$localpwd\$_"}}
                       
    if(Test-Path $localpwd\sushwin\mySCP.sushput)
    {
        #Clear-Content $localpwd\sushwin\mySCP.sushput
        Add-Content $localpwd\sushwin\mySCP.sushput "$username,sush,$localpwd,$remotepwd"
        Add-Content $localpwd\sushwin\mySCP.sushput "$username,sush.ksh,$localpwd\sushunix,$remotepwd"
    }
    if(Test-Path $localpwd\sushwin\mySSH.sushset)
    {
        #Clear-Content $localpwd\sushwin\mySSH.sushset
        Add-Content $localpwd\sushwin\mySSH.sushset "chmod a+x $remotepwd/sush"
        if($sudoer)
        {
            Add-Content $localpwd\sushwin\mySSH.sushset "chown root.bin $remotepwd/sush"
            Add-Content $localpwd\sushwin\mySSH.sushset "chmod +s $remotepwd/sush"
        }
        Add-Content $localpwd\sushwin\mySSH.sushset "chmod a+x $remotepwd/sush.ksh"
    }
    if(Test-Path $localpwd\sushwin\mySSH.sushrun)
    {
        #Clear-Content $localpwd\sushwin\mySSH.sushrun
        Add-Content $localpwd\sushwin\mySSH.sushrun "cd $remotepwd;./sush"
    }
                

    foreach ($task in $tasks)
    {
        if($sudoer){$su = "sudoer"}else{$su = "nosudoer"}
        if($task.owner){$taskowner = $task.owner}
        
        if($task.put)
        {
            if($task.path){$localpath = $task.path}else{$localpath = "$sysadmpath\put" }
            if($task.putpath){$remotepath = $task.putpath}else{$remotepath = "/tmp"}

            $putfiles = $task.put
            foreach($putfile in $putfiles.Split(","))
            {
                if(Test-Path $localpath\$putfile){Add-Content $localpwd\sushwin\mySCP.taskput "$username,$putfile,$localpath,$remotepath"}
            }
        }
        
        if($task.get)
        {
            if($task.path){$localpath = $task.path}else{$localpath = "$sysadmpath\get" }
            if($task.getpath){$remotepath = $task.getpath}else{$remotepath = "/tmp"}
            
            $getfiles = $task.get
            foreach($getfile in $getfiles.Split(","))
            {
                Add-Content $localpwd\sushwin\mySCP.taskget "$username,$getfile,$localpath,$remotepath"
            }
        }
        
        if($task.run)
        {
            if($task.logpath){$localpath = $task.logpath}else{$localpath = "$sysadmpath\log" }
            if($task.runpath){$remotepath = $task.runpath}else{$remotepath="$remotepwd"}
            
            $runfiles = $task.run
            foreach($runfile in $runfiles.Split(","))
            {
                #if(Test-Path $sysadmpath\$runfile){Add-Content $localpwd\sushwin\mySCP.taskrun "$username $runfile $sysadmpath $remotepath"}
            
                if($task.remotepath){$runfile="$remotepath/$runfile"}
                Add-Content $localpwd\sushunix\myTab.run "$hostname,$taskowner,$runfile,$su,$runtime"
                    
                $out=$runfile.Split(" ").Item(0) + ".out$runtime";$out=$out.Split('/')[-1]
                Add-Content $localpwd\sushwin\mySCP.taskout "$username,$out,$localpath,$remotepwd"
            }
        }

        if($task.del)
        {
            if($task.path){$localpath = $task.path}else{$localpath = "$sysadmpath\del" }
            if($task.delpath){$remotepath = $task.delpath}else{$remotepath = "/tmp"}
            
            $delfiles = $task.del
            foreach($delfile in $delfiles.Split(","))
            {
                Add-Content $localpwd\sushwin\mySCP.taskdel "$username,$delfile,$localpath,$remotepath"
            }
        }
    
    }

    Add-Content $localpwd\sushwin\mySCP.sushput "$username,myTab.run,$localpwd\sushunix,$remotepwd" 
    Add-Content $localpwd\sushwin\mySCP.taskout "$username,sush.out,$sysadmpath\log,$remotepwd"
   
    
    #Clearing not including "$localpwd\sushwin\mySCP.taskrun","$localpwd\sushwin\mySCP.taskput","$localpwd\sushwin\mySCP.taskget"
    Get-Content "$localpwd\sushwin\mySCP.sushput","$localpwd\sushwin\mySCP.taskout","$localpwd\sushwin\mySCP.taskdel" | Out-File "$localpwd\sushwin\myCLEAR"

    #convert files from dos-format to unix-format under unixformat directory
    $unixformat="$localpwd\sushunix"
    Get-ChildItem $unixformat | ForEach-Object {
        # get the contents and replace line breaks by U+000A
        $file= "$unixformat\$_"
        $contents = [IO.File]::ReadAllText($file) -replace "`r`n?", "`n"
        
        # create UTF-8 encoding without signature
        $utf8 = New-Object System.Text.UTF8Encoding $false
        
        # write the text back
        [IO.File]::WriteAllText($file, $contents, $utf8)
    }
    
    #delete empty line in all working files
    $files=Get-Content $localpwd\sush.new-item
    foreach($file in $files)
    {
        $content = [System.IO.File]::ReadAllText("$localpwd\$file")
        $content = $content.Trim()
        [System.IO.File]::WriteAllText("$localpwd\$file", $content)
    }

}


function sysadm_main
{   
    $xml = [xml] ( Get-Content $xmlfile )
    $auto=$xml.sysadm.auto;if($auto.ToLower() -eq "true" ){$auto = $true}else{$auto = $false}
    
    if($auto){$servers = $xml.sysadm.host}else{$servers = $xml.sysadm.host | Out-GridView -PassThru -Title "Select Host"}

    foreach($server in $servers)
    {
        
        if($auto){$connects = $server.connect}else{$connects = $server.connect | Out-GridView -PassThru -Title "Select connection"}
        
        foreach ($connect in $connects)
        {
            $connectid = $connect.id

            #check host availability
            if ( $xml.sysadm.host.id.GetType().name -match "obj" )
            {
                if($xml.sysadm.host.Where({$_.connect.id -eq $connectid}).name){$hostname = $xml.sysadm.host.Where({$_.connect.id -eq $connectid}).name}
                if($xml.sysadm.host.Where({$_.connect.id -eq $connectid}).port){$port = $xml.sysadm.host.Where({$_.connect.id -eq $connectid}).port}
           
            }else{
            
                if($xml.sysadm.host.name){$hostname = $xml.sysadm.host.name}
                if($xml.sysadm.host.port){$port = $xml.sysadm.host.port}
 
            }
            if( -Not (Test-Connection -ComputerName $hostname -Count 1 -Quiet)){Write-Host $hostname unreachable}
            

            #prepare key files
            if($connect.publickey){$publickey = $connect.publickey}
            if($connect.privatekey){$privatekey = $connect.privatekey}
            
            if($connect.sudoer -and ($connect.sudoer.ToLower() -eq "true" )){$sudoer = $true}else{$sudoer = $false}
            if($connect.user){$username = $connect.user}
            if($connect.password){$password = $connect.password};if($password.trim() -eq ""){$password = sysadm_passwd}
            if($connect.path){$remotepwd = $connect.path}
                                   
            $conn = sysadm_connect
            
            if($conn)
            {   
                :newconn while($true)   # processing tasks until you choose exist
                {
                    if($auto){$choices = $xml.sysadm.choice}
                    else{
                        $message = @" 
                    
process tasks under User: [$username] connection on Server: [$hostname] 
                                        
"@
                        $title = "Server Name: $hostname"
                        $buttons = @{
                                        "0-Deploy Tasks" = "deploy selected tasks on current connection to remote host" ;
                                        "1-Run Tasks" = "process tasks on current connection" ;
                                        "2-Get Result" = "Get output of tasks" ;
                                        "3-Clear Tasks" = "clear tasks on current connection from remote host" ;
                                        "4-Next" = "move on to next connection if mutiple connections selected" 
                                   }

                
                        $choices = sysadm_choice -buttons $buttons -title $title -message $message
                    }
                                  
                    foreach($choice in $choices)
                    {
                        Switch -Regex ($choice)
                        {
                            [0] #Send selected task scripts/config to remote hosts
                            {
                                sysadm_task
                                                        
                                if((Get-Item "$localpwd\sushwin\mySCP.taskput").length -gt 0){sysadm_scp -Scpfile "$localpwd\sushwin\mySCP.taskput"}
                                if((Get-Item "$localpwd\sushwin\mySSH.taskset").length -gt 0){sysadm_ssh -Commandfile "$localpwd\sushwin\mySSH.taskset"}

                            }

                            [1] #Run task scripts
                            {
                                sysadm_task
                            
                                if((Get-Item "$localpwd\sushwin\mySCP.sushput").length -gt 0){sysadm_scp -Scpfile "$localpwd\sushwin\mySCP.sushput"}
                                if((Get-Item "$localpwd\sushwin\mySSH.sushset").length -gt 0){sysadm_ssh -Commandfile "$localpwd\sushwin\mySSH.sushset"}
                                if((Get-Item "$localpwd\sushwin\mySSH.sushrun").length -gt 0){sysadm_ssh -Commandfile "$localpwd\sushwin\mySSH.sushrun"}
                                if((Get-Item "$localpwd\sushwin\mySCP.taskout").length -gt 0){sysadm_scp -From -Scpfile "$localpwd\sushwin\mySCP.taskout"}
                        
                            }

                            [2] #Get output
                            {
                                sysadm_task

                                #Get output of task scripts from remote hosts
                                if((Get-Item "$localpwd\sushwin\mySCP.taskget").length -gt 0){sysadm_scp -From -Scpfile "$localpwd\sushwin\mySCP.taskget"}
                                
                            }

                            [3] #Clear on remote hosts
                            {
                                sysadm_task

                                if((Get-Item "$localpwd\sushwin\mySCP.taskdel").length -gt 0){sysadm_scp -From -Scpfile "$localpwd\sushwin\mySCP.taskdel"}
                                if((Get-Item "$localpwd\sushwin\myCLEAR").length -gt 0){sysadm_del -Delfiles "$localpwd\sushwin\myCLEAR" }
                            }

                            [4] # next connection, this choice must be included in [xml] file to avoid infinite loop when auto processing
                            {
                                break newconn  # break to upper loop level
                            }
                    
                        } #swith End
                    } 

                } # while true for task process, break to :newconn
 
            
            } # current connection End

        
        } # All connections End

    } # All servers End

}

trap {"Error found: $_"}

sysadm_main
