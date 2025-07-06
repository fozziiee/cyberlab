
$ErrorActionPreference = "Stop"

# ===== Enable Logging =======
$logPath = "C:\cyberlab\bootstrap.log"
Start-Transcript -Path $logPath -Append

# ====== Helper: Flag Check ========
function StepCompleted($flag) {
    return (Test-Path $flag)
}

# === Path =====
$tempPath = "C:\Temp"
$cyberlabPath = "C:\cyberlab"
$bootstrapScriptPath = "C:\bootstrap.ps1"
$gitFlag = "$cyberlabPath\git_installed.flag"
$adFlag = "C:\domain.promoted"
$rebootFlag = "$tempPath\after-reboot.flag"

# ===== Ensure Required Folders ==========
New-Item -ItemType Directory -Force -Path $tempPath, $cyberlabPath | Out-Null


# ========== Enable WinRM ==========================
Set-Item -Path "WSMan:\localhost\Service\AllowUnencrypted" -Value true
Set-Item -Path "WSMan:\localhost\Service\Auth\Basic" -Value true
Enable-PSRemoting -Force


# ============= Install Git ============================
if (-not (StepCompleted $gitFlag)) {
    try {
        $gitInstaller = "C:\Temp\GitInstaller.exe"

        Invoke-WebRequest `
            -Uri "https://github.com/git-for-windows/git/releases/download/v2.45.1.windows.1/Git-2.45.1-64-bit.exe" `
            -OutFile $gitInstaller
        
        Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
    }
    catch {
        Write-Error "it install failed: $_"
    }
}

$restartedFlag = "$cyberlabPath\restarted_after_git.flag"

if (-not (Test-Path $restartedFlag)) {
    New-Item -ItemType File -Path "$cyberlabPath\restarted_after_git.flag" -Force
    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$bootstrapScriptPath`""
    exit
}


# ==== Clone AD repo =============
if (-not (Test-Path "$cyberlabPath\AD")) {
    git clone "https://github.com/fozziiee/AD.git" "C:\cyberlab"
}

# ============ Schedule AD Bootstrap Script ==================
$bootstrapADScriptPath = "$cyberlabPath\AD\code\bootstrap_ad.ps1"
$taskExists = Get-ScheduledTask -TaskName "RunPostADScript" -ErrorAction SilentlyContinue

if (-not $taskExists) {
    Write-Host "Creating scheduled task for AD bootstrap script..."
    $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$bootstrapADScriptPath`" -Users 10 -Groups 3 -Admins 1"
    $trigger = New-ScheduledTaskTrigger -AtStartup
    Register-ScheduledTask -TaskName "RunPostADScript" -Action $action -Trigger $trigger -RunLevel Highest -User "SYSTEM"
}

# ============ Set Static IP ==============================
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 10.0.1.100 -PrefixLength 24 -DefaultGateway 10.0.1.1
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1


# ======== Promote to Domain Controller ========================    
if (-not (StepCompleted $adFlag)) {
    $domain = "xyz.local"
    $safeModePassword = ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force

    try {
        Write-Host "Promoting to Domain Controller for $domain..."
        Install-ADDSForest -DomainName $domain -SafeModeAdministratorPassword $safeModePassword -Force:$true
        New-Item -ItemType File -Path $adFlag -Force
        Write-Host "Domain promotion complete"
    }
    catch {
        Write-Error "Domain promotion failed: $_"
        exit 1
    }

}

Write-Host "Bootstrap Complete"

Unregister-ScheduledTask -TaskName "ResumeBootstrap" -Confirm:$false
Unregister-ScheduledTask -TaskName "RunPostADScript" -Confirm:$false

Stop-Transcript